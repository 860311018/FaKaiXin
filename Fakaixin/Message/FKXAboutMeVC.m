//
//  FKXAboutMeVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXAboutMeVC.h"
#import "FKXAboutMeCell.h"
#import "MyDynamicModel.h"
#import "NSString+HeightCalculate.h"
#import "FKXProfessionInfoVC.h"
#import "FKXSameMindModel.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXCustomAcceptHtmlVC.h"
#import "FKXReplyLetterVC.h"

@interface FKXAboutMeVC ()<FKXAboutMeCellDelegate>
{
    NSInteger start;
    NSInteger size;
}
@property   (nonatomic,strong)NSMutableArray *contentArr;

@end

@implementation FKXAboutMeVC
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self headerRefreshEvent];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_noReadNum) {
        size = _noReadNum;
    }else{
        size = kRequestSize;
    }
    self.navTitle = @"与我相关";
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    //ui设置
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 点击事件

- (IBAction)lookMoreData:(id)sender {
    [((UIButton *)sender) removeFromSuperview];
    self.tableView.tableFooterView.frame = CGRectZero;
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    [self footRefreshEvent];
}
#pragma mark - ---网络请求---
- (void)headerRefreshEvent
{
    start = 0;
    [self loadData];
}
- (void)footRefreshEvent
{
    if (_noReadNum) {
        start += _noReadNum;
        _noReadNum = 0;
    }else{
        start += size;
    }
    [self loadData];
}
- (void)loadData
{
    NSDictionary *paramDic = @{@"start" : @(start), @"size": @(size)};
    //重置size；
    size = kRequestSize;
    
    [MyDynamicModel sendGetOrPostRequest:@"user/rel_to_me" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
         if ([data[@"code"] integerValue] == 0)
         {
             if (start == 0)
             {
                 [_contentArr removeAllObjects];
             }
             NSError *err = nil;
             for (NSDictionary *dic in data[@"data"][@"list"])
             {
                 MyDynamicModel * officalSources =  [[MyDynamicModel alloc] initWithDictionary:dic error:&err];
                 [_contentArr addObject:officalSources];
             }
             for (MyDynamicModel *m in _contentArr) {
                 [FKXUserManager shareInstance].unreadRelMe = m.time;
                 break;
             }
             if ([data[@"data"][@"list"] count] < kRequestSize) {
                 self.tableView.footer.hidden = YES;
             }else
             {
                 self.tableView.footer.hidden = NO;
             }
             [self.tableView reloadData];
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
         
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
     }];
    
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
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
#pragma mark - cell自定义代理
- (void)goToDynamicVC:(MyDynamicModel*)cellModel sender:(UIButton*)sender
{
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = cellModel.fromId;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - tableView代理
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDynamicModel *model = [self.contentArr objectAtIndex:indexPath.row];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [model.commentText heightForWidth:screen.size.width - 154 usingFont:[UIFont systemFontOfSize:12] style:style];
    if (height + 70 > 85) {
        return height + 70;
    }
    return 85;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXAboutMeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXAboutMeCell" forIndexPath:indexPath];
    
    MyDynamicModel *model = [self.contentArr objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.model = model;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDynamicModel *dyModel = [self.contentArr objectAtIndex:indexPath.row];
    switch ([dyModel.type integerValue]) {
        case 1:
        case 2:
        case 4:
        {
            FKXSameMindModel *model = [[FKXSameMindModel alloc] init];
            model.worryId = dyModel.worryId;
            model.text = dyModel.replyText;
            model.head = dyModel.head;
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            vc.shareType = @"comment";
            vc.pageType = MyPageType_nothing;
            vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,model.worryId, (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
            vc.sameMindModel = model;
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        case 3:
        {
            FKXSecondAskModel *model = [[FKXSecondAskModel alloc] init];
            model.worryId = dyModel.worryId;
            model.topicId = dyModel.topicId;
            model.text = dyModel.replyText;
            model.userHead = dyModel.toHead;
            model.userNickName = dyModel.toNickname;
            model.listenerNickName = dyModel.fromNickname;
            model.listenerHead = dyModel.fromHead;
            model.listenerId = dyModel.fromId;
            model.voiceId = dyModel.voiceId;
            model.acceptMoney = dyModel.acceptMoney;
            model.isAccept = dyModel.isAccept;
            
            if ([model.isAccept integerValue] == 0) {//需要展示认可
                FKXCustomAcceptHtmlVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXCustomAcceptHtmlVC"];
                NSString *paraStr = @"worryId";//默认传worryId
                NSNumber *paraId;
                if (model.worryId) {
                    paraId = model.worryId;
                }
                if (model.topicId) {
                    paraStr = @"topicId";
                    paraId = model.topicId;
                }
                if (model.lqId) {
                    paraStr = @"lqId";
                    paraId = model.lqId;
                }
                vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=%d&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, model.voiceId,0, [FKXUserManager shareInstance].currentUserToken];
                vc.secondModel = model;
                
                //传相关的支付需要的参数
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
                dic[@"voiceId"] = model.voiceId;
                vc.payParameterDic = dic;
                
                vc.isShowAlert = [model.isAccept integerValue] ? NO : YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
                vc.isNeedTwoItem = YES;
                vc.pageType = MyPageType_agree;
                vc.shareType = @"second_ask";
                NSString *paraStr = @"worryId";//默认传worryId
                NSNumber *paraId;
                if (model.worryId) {
                    paraId = model.worryId;
                }
                if (model.topicId) {
                    paraStr = @"topicId";
                    paraId = model.topicId;
                }
                if (model.lqId) {
                    paraStr = @"lqId";
                    paraId = model.lqId;
                }
                NSInteger agree = 1;
                if ([model.isAccept integerValue] == -1 ||[model.isAccept integerValue] == -2) {
                    agree = 0;
                }
                vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=%ld&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, model.voiceId,agree, [FKXUserManager shareInstance].currentUserToken];
                vc.secondModel = model;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case 6:
        {
            FKXReplyLetterVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil]instantiateViewControllerWithIdentifier:@"FKXReplyLetterVC"];
            vc.dynamicModel = dyModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
