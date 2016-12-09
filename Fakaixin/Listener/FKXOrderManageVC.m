//
//  FKXOrderManageVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXOrderManageVC.h"
#import "FKXOrderCell.h"
#import "FKXOrderModel.h"
#import "FKXCommitHtmlViewController.h"
#import "ChatViewController.h"
#import "FKXProfessionInfoVC.h"

@interface FKXOrderManageVC ()<FKXOrderCellDelegate>
{
    NSInteger start;
    NSInteger size;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property   (nonatomic,strong)NSMutableArray *contentArr;

@end

@implementation FKXOrderManageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //基本数据赋值
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //ui设置
    [_myTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    [_myTableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    
    //加载数据
    [self headerRefreshEvent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ---网络请求---
- (void)headerRefreshEvent
{
    start = 0;
    [self loadData];
}
- (void)footRefreshEvent
{
    start += size;
    [self loadData];
}
- (void)loadData
{
    NSDictionary *paramDic = @{@"start" : @(start), @"size": @(size), @"status" : @([_status integerValue])};
    
    [FKXOrderModel sendGetOrPostRequest:@"listener/orderList" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         _myTableView.header.state = MJRefreshHeaderStateIdle;
         _myTableView.footer.state = MJRefreshFooterStateIdle;
         
         if (data)
         {
             if ([data count] < kRequestSize) {
                 _myTableView.footer.hidden = YES;
             }else
             {
                 _myTableView.footer.hidden = NO;
             }
             
             if (start == 0)
             {
                 [_contentArr removeAllObjects];
                 
             }
             [_contentArr addObjectsFromArray:data];
             
             [_myTableView reloadData];
             
         }else if (errorModel)
         {
             NSInteger index = [errorModel.code integerValue];
 
             if (index == 4)
 
             {
                 [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             }else
             {
                 [self showHint:errorModel.message];
            }
         }
     }];
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([_myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_myTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([_myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_myTableView setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXOrderCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    FKXOrderModel *model = [self.contentArr objectAtIndex:indexPath.row];
    cell.model = model;
    switch ([_status integerValue]) {
        case 0:
        {
            cell.btnService.hidden = YES;
            cell.rejectBtn.hidden = NO;
            cell.acceptBtn.hidden = NO;
        }
            break;
        case 1:
        {
            [cell.btnService setTitle:@"服务" forState:UIControlStateNormal];
            cell.btnService.hidden = NO;
            cell.rejectBtn.hidden = YES;
            cell.acceptBtn.hidden = YES;
        }
            break;
        case 2:
        {
            [cell.btnService setTitle:@"查看评价" forState:UIControlStateNormal];
            cell.btnService.hidden = NO;
            cell.rejectBtn.hidden = YES;
            cell.acceptBtn.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    return cell;
}
#pragma mark - FKXOrderCellDelegate
- (void)goToDynamicVC:(FKXOrderModel*)cellModel sender:(UIButton*)sender
{
//    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
//    vc.userId = cellModel.userId;
//    [vc setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:vc animated:YES];
}
// 0 拒绝 1接受
- (void)rejectOrAcceptOrder:(FKXOrderModel*)cellModel sender:(UIButton *)sender
{
    switch (sender.tag) {
        case 200://拒绝
        {
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:@(3) forKey:@"status"];
            [paramDic setValue:cellModel.orderId forKey:@"orderId"];
            [self showHudInView:self.view hint:@"正在处理"];
            
            [AFRequest sendGetOrPostRequest:@"listener/updateOrder"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
                
                [self hideHud];
                if ([data[@"code"] integerValue] == 0)
                {
                    [self headerRefreshEvent];
                }else if ([data[@"code"] integerValue] == 4)
                {
                    [self showAlertViewWithTitle:data[@"message"]];
                    [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                }else
                {
                    [self showHint:data[@"message"]];
                }
            } failure:^(NSError *error) {
                [self hideHud];
                [self showAlertViewWithTitle:@"网络出错"];
                
            }];
        }
            break;
        case 201://接单
        {
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:@(1) forKey:@"status"];
            [paramDic setValue:cellModel.orderId forKey:@"orderId"];
            [self showHudInView:self.view hint:@"正在处理"];
            
            [AFRequest sendGetOrPostRequest:@"listener/updateOrder"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
                
                [self hideHud];
                if ([data[@"code"] integerValue] == 0)
                {
                    [self headerRefreshEvent];
                    
                   
                    
                    //保存接收方的信息
//                    EMMessage *receiverMessage = [[EMMessage alloc] initWithReceiver:[meInfo.uid stringValue] bodies:nil];
//                    receiverMessage.from = [cellModel.userId stringValue];
//                    receiverMessage.to = [meInfo.uid stringValue];
//                    receiverMessage.ext = @{
//                                            @"head" : cellModel.headUrl,
//                                            @"name": cellModel.nickName,
//                                            @"stop":@(NO)
//                                            };
                    //                    [self insertDataToTableWith:receiverMessage managedObjectContext:ApplicationDelegate.managedObjectContext]; //需要发送的默认消息的用户信息
                    
                    FKXUserInfoModel *meInfo = [FKXUserManager getUserInfoModel];
                    
                    NSArray *textArray = @[@"亲，我来了~在伐开心里可以无压力的倾诉心事，安抚您内心的小怪兽",@"身为伐开心的倾听者，能够倾听帮助您解决烦心事是我义不容辞的责任~",@"您的烦心事尽管告诉我，我会尽我所能帮助您的",@"不开心？来伐开心，我都在这陪伴倾听着你",@"我在呢~每当您有烦心事我都会第一时间出现在您身边的"];
                    NSInteger radom = arc4random()%textArray.count;
                    NSString * welcomeMessage = textArray[radom];
                    
                    //把我的信息发给对方,方便其展示我的信息
                    NSDictionary *dicExt = @{
                                             @"head" : meInfo.head,
                                             @"name": meInfo.name,
                                             };
                    
//                    [EaseSDKHelper sendTextMessage:welcomeMessage to:[cellModel.userId stringValue] messageType:eMessageTypeChat requireEncryption:NO messageExt:dicExt];
                    
                    //进入聊天
//                    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:[cellModel.userId stringValue] conversationType:eConversationTypeChat];
//                    chatController.title = cellModel.nickName;
//                    [self.navigationController pushViewController:chatController animated:YES];
                }else if ([data[@"code"] integerValue] == 4)
                {
                    [self showAlertViewWithTitle:data[@"message"]];
                    [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                }else
                {
                    [self showHint:data[@"message"]];
                }
            } failure:^(NSError *error) {
                [self hideHud];
                [self showAlertViewWithTitle:@"网络出错"];
                
            }];
        }
            break;
        case 202:
        {
            if ([sender.titleLabel.text isEqualToString:@"服务"])
            {
                //进入聊天
//                ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:[cellModel.userId stringValue] conversationType:eConversationTypeChat];
//                chatController.title = cellModel.nickName;
//                [self.navigationController pushViewController:chatController animated:YES];
            }else
            {//查看评价,进个人主页
                FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
                vc.shareType = @"user_center";
                vc.urlString = [NSString stringWithFormat:@"%@front/user_center.html?uid=%ld&token=%@",kServiceBaseURL,(long)[FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
                FKXUserInfoModel *userM = [[FKXUserInfoModel alloc] init];
//                userM.uid = cellModel.userId;
                userM.head = cellModel.headUrl;
                userM.name = cellModel.nickName;
                vc.userModel = userM;
                //push的时候隐藏tabbar
                [vc setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
