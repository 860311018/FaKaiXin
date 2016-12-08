//
//  FKXChatListController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChatListController.h"
#import "FKXChatListCell.h"
#import "ChatViewController.h"
#import "FKXNotificationCenterTableViewController.h"
#import "FKXPublishCourseController.h"
#import "FKXCareListController.h"

#define kBtnW 48
#define kBtnH 20

@interface FKXChatListController ()<UITableViewDelegate, UITableViewDataSource, EMChatManagerDelegate>
{
    UIView *headerView;
    NSMutableArray *dataArrays;     //数据源
    FKXEmptyData *emptyDataView;    //空数据
    
    NSInteger myUnreadMessage;
    
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property(nonatomic, strong)    UIImageView * noReadRed;  //未读红点

@end

@implementation FKXChatListController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self headerRefreshEvent];
    [self loadNewNotice];//界面出现就更新ui
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _noReadRed.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"消息";
    //UI设置
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //ui设置
    [_myTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    //环信代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //创建ui
    [self createTopView];
    
    [self loadNewNotice];//保证第一次执行（tabbarVC初始化的时候也加载）
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 加载未读通知的红点
- (void)loadNewNotice
{
    NSNumber *lastId = [FKXUserManager shareInstance].unReadNotification ? [FKXUserManager shareInstance].unReadNotification : @(0);
    NSDictionary *paramDic = @{@"lastId" : lastId};
    [AFRequest sendGetOrPostRequest:@"user/newNotice" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            NSInteger con = [data[@"data"][@"newTotal"] integerValue];
            if (con) {
                _noReadRed.hidden = NO;
            }else{
                _noReadRed.hidden = YES;
            }
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
#pragma mark - UI 创建
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.myTableView.width, self.myTableView.height);
        [self.myTableView addSubview:emptyDataView];
    }
    [emptyDataView.btnDeal removeTarget:self action:@selector(clickBtnDealSendMind) forControlEvents:UIControlEventTouchUpInside];
    [emptyDataView.btnDeal removeTarget:self action:@selector(clickBtnDealGoToCare) forControlEvents:UIControlEventTouchUpInside];

    if ([FKXUserManager isUserPattern])
    {
        [emptyDataView.btnDeal setTitleColor:kColorMainBlue forState:UIControlStateNormal];
        emptyDataView.btnDeal.layer.borderColor = kColorMainBlue.CGColor;
        emptyDataView.titleLab.text = @"全世界的讨好，不如一个抱抱";
        [emptyDataView.btnDeal setTitle:@"发个心事" forState:UIControlStateNormal];
        [emptyDataView.btnDeal addTarget:self action:@selector(clickBtnDealSendMind) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        [emptyDataView.btnDeal setTitleColor:kColorMainRed forState:UIControlStateNormal];
        emptyDataView.btnDeal.layer.borderColor = kColorMainRed.CGColor;
        emptyDataView.titleLab.text = @"还没能关怀任何人";
        [emptyDataView.btnDeal setTitle:@"去关怀" forState:UIControlStateNormal];
        [emptyDataView.btnDeal addTarget:self action:@selector(clickBtnDealGoToCare) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)clickBtnDealSendMind
{
    FKXPublishMindViewController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishMindViewController"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)clickBtnDealGoToCare
{
    FKXCareListController *vc = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXCareListController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 刷新列表
- (void)headerRefreshEvent
{
    myUnreadMessage = 0;    //重置为0
    NSArray *allCons = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    NSMutableArray *mutAllCons = [NSMutableArray arrayWithArray:allCons];
    NSSortDescriptor *sortDes = [[NSSortDescriptor alloc] initWithKey:@"latestMessage.timestamp" ascending:NO]; // 降序
    // 基本类型可变数组
    [mutAllCons sortUsingDescriptors:@[sortDes]];
    //记录这个群组列表的所有id，方便下文作比较
    NSMutableArray *grIds = [NSMutableArray arrayWithCapacity:1];
    for (EMConversation *con  in mutAllCons)
    {
        [grIds addObject:con.chatter];
    }
    //开始遍历这个人加入的群组，把未展示的群组，也列出来
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
        self.myTableView.header.state = MJRefreshHeaderStateIdle;
        if (!error) {
            for (EMGroup *gro in groups)
            {
                if (![grIds containsObject:gro.groupId]) {
                    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:gro.groupId conversationType:eConversationTypeGroupChat];
                    [mutAllCons addObject:conversation];
                }
            }
            dataArrays = mutAllCons;
            
            [self.myTableView reloadData];
            
            if ([dataArrays count] == 0) {
                [self createEmptyData];
            }else{
                if (emptyDataView) {
                    [emptyDataView removeFromSuperview];
                    emptyDataView = nil;
                }
            }
        }
        else{
            dataArrays = mutAllCons;
            [self.myTableView reloadData];
            
            if ([dataArrays count] == 0) {
                [self createEmptyData];
            }else{
                if (emptyDataView) {
                    [emptyDataView removeFromSuperview];
                    emptyDataView = nil;
                }
            }
        }
    } onQueue:nil];
}
#pragma mark - 环信收到消息 EMChatManagerChatDelegate
- (void)didReceiveMessage:(EMMessage *)message
{
    [self headerRefreshEvent];
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.myTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.myTableView setSeparatorInset:UIEdgeInsetsZero];
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
#pragma mark - tableviewDelegate
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *conversation = [dataArrays objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES append2Chat:YES];
        [dataArrays removeObjectAtIndex:indexPath.row];
        [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //查找到这个人的信息,,从自己的数据库中删除
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatUser"];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSError *fetchError;
        NSArray *usersArray = [ApplicationDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
        //    EMMessage *lastestMessage = self.conversation.latestMessage;
        for (ChatUser *user in usersArray)
        {
            //接受方信息赋值
            if ([user.userId isEqualToString:conversation.chatter])
            {
                [ApplicationDelegate.managedObjectContext deleteObject:user];
                break;
            }
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMConversation *conversation = dataArrays[indexPath.row];
    FKXChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXChatListCell" forIndexPath:indexPath];
    cell.conversation = conversation;
    if (conversation.conversationType == eConversationTypeGroupChat) {
        cell.btnComeIn.hidden = NO;
    }else{
        cell.btnComeIn.hidden = YES;
    }
    if (conversation.unreadMessagesCount > 0) {
        cell.showBadge.hidden = NO;
        [cell.showBadge setTitle:[NSString stringWithFormat:@"%ld", conversation.unreadMessagesCount] forState:UIControlStateNormal];
        myUnreadMessage += conversation.unreadMessagesCount;
    }else
    {
        cell.showBadge.hidden = YES;
    }
    
    if (indexPath.row == dataArrays.count - 1) {//循环完毕，给item赋值(关怀的tabbaritem需要用)
        if (myUnreadMessage) {
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", myUnreadMessage];
        }else{
            self.tabBarItem.badgeValue = nil;
        }
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArrays.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EMConversation *conversation = dataArrays[indexPath.row];
    if (!conversation.chatter) {
        return;
    }
    
    if ([conversation.chatter integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不可以私信自己哟"];
        return;
    }

    NSDictionary *params = @{@"userId":[FKXUserManager getUserInfoModel].uid,@"listenerId":[NSNumber numberWithInteger:[conversation.chatter integerValue]]};
    
    [AFRequest sendPostRequestTwo:@"user/selectClient" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSDictionary *dic = data[@"data"][@"listenerInfo"];
            FKXUserInfoModel *pModel = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];
            
            NSArray *array = [[FKXUserManager shareInstance] caluteHeight:pModel];
            ChatViewController * chatController=[[ChatViewController alloc] initWithConversationChatter:[pModel.uid stringValue]  conversationType:eConversationTypeChat];
            chatController.title = pModel.name;
            
            if ([pModel.role integerValue] !=0) {
                chatController.toZiXunShi = YES;
            }
            
            chatController.pModel = pModel;
            chatController.headerH = [array[1] floatValue];
            chatController.introStr = array[0];
            
            chatController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatController animated:YES];
            
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
//    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:conversation.chatter conversationType:conversation.conversationType];
//    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatUser"];
//    [fetchRequest setReturnsObjectsAsFaults:NO];
//    NSError *fetchError;
//    NSArray *usersArray = [ApplicationDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
//    for (ChatUser *user in usersArray)
//    {
//        //接受方信息赋值
//        if ([user.userId isEqualToString:conversation.chatter])
//        {
//            chatController.title = user.nick;
//            break;
//        }
//    }
//    [chatController setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:chatController animated:YES];
}
#pragma mark - 创建ui
- (void)createTopView
{
    //初始化整个页面的头部
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, self.view.width, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showNotificationVC)];
    [headerView addGestureRecognizer:tap];
    
    UIImage *lefI = [UIImage imageNamed:@"message_system_notificaiton"];
    //g按钮
    UIButton * gBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    gBtn.frame = CGRectMake(29, (headerView.height - lefI.size.height)/2, 73, lefI.size.height);
    [gBtn setImage:lefI forState:UIControlStateNormal];
    // 顶  左  底  右
    gBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -(gBtn.width/2 - lefI.size.width), 0, 0);
    gBtn.titleEdgeInsets = UIEdgeInsetsMake(0, gBtn.width/2 - 30, 0, 0);
    [gBtn setTitle:@"通知" forState:UIControlStateNormal];
    gBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    gBtn.userInteractionEnabled = NO;
    [gBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [headerView addSubview:gBtn];
    
    _noReadRed = [[UIImageView alloc] initWithFrame:CGRectMake(gBtn.left + 17, gBtn.top, 10, 10)];
    _noReadRed.backgroundColor = [UIColor redColor];
    _noReadRed.layer.cornerRadius = _noReadRed.width/2;
    _noReadRed.clipsToBounds = YES;
    _noReadRed.hidden = YES;
    [headerView addSubview:_noReadRed];
}
#pragma mark - 处理通知
- (void)showNotificationVC
{
    _noReadRed.hidden = YES;
    FKXNotificationCenterTableViewController *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXNotificationCenterTableViewController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
