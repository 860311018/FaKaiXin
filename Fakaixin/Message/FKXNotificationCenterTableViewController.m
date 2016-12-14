//
//  FKXNotificationCenterTableViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/6.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXNotificationCenterTableViewController.h"
#import "FKXNotificationCenterTableViewCell.h"
#import "FKXNotifcationModel.h"
#import "FKXCommitHtmlViewController.h"
#import "NSString+HeightCalculate.h"
#import "FKXEvaluateVC.h"
#import "FKXMyAnswerPageVC.h"

@interface FKXNotificationCenterTableViewController ()
{
    NSInteger start;
    NSInteger size;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property   (nonatomic,strong)NSMutableArray *contentArr;

@end

@implementation FKXNotificationCenterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //基本数据赋值
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    
    //ui赋值
    self.navTitle = @"通知";
    
    //ui设置
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    [self.myTableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];

    //加载通知列表
    [self loadNotList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 网络请求
#pragma mark - ---网络请求---
- (void)headerRefreshEvent
{
    start = 0;
    [self loadNotList];
}
- (void)footRefreshEvent
{
    start += size;
    [self loadNotList];
}

- (void)loadNotList
{
    [self showHudInView:self.view hint:@"正在加载"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"uid"];
    [paramDic setValue:@(start) forKey:@"start"];
    [paramDic setValue:@(size) forKey:@"size"];
    
    [AFRequest sendGetOrPostRequest:@"user/notice_list" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
         NSError *err = nil;
         if ([data[@"code"] integerValue] == 0)
         {
             if (start == 0)
             {
                 [_contentArr removeAllObjects];
             }
             for (NSDictionary *dic in data[@"data"])
             {
                 FKXNotifcationModel * officalSources =  [[FKXNotifcationModel alloc] initWithDictionary:dic error:&err];
                 officalSources.selfId = dic[@"id"];
                 [_contentArr addObject:officalSources];

             }
             for (FKXNotifcationModel *m in _contentArr) {
                 [FKXUserManager shareInstance].unReadNotification = m.selfId;
                 break;
             }
             if ([data[@"data"] count] < kRequestSize) {
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
         [self hideHud];
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FKXNotifcationModel *model = _contentArr[indexPath.row];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [model.alert heightForWidth:screen.size.width - 148 usingFont:[UIFont systemFontOfSize:15] style:style];
    if (height > 50)
    {
        return  height + 20;
    }else{
        return 70;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FKXNotifcationModel *model = _contentArr[indexPath.row];
    FKXNotificationCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXNotificationCenterTableViewCell"];
    if ([model.type integerValue] == notification_type_evaluate || [model.type integerValue] == notification_type_end_talk ||[model.type integerValue] == notification_type_people){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.model = model;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //类型参考Fakaixin-Prefix中的枚举
    FKXNotifcationModel *model = _contentArr[indexPath.row];
    if ([model.type integerValue] == notification_type_evaluate)
    {
        NSData *data = [model.data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
        vc.shareType = @"comment";
        vc.pageType = MyPageType_nothing;
        vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,dic[@"worryId"], (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
        FKXSameMindModel *sameM = [[FKXSameMindModel alloc] init];
        sameM.text = model.alert;
        sameM.head = model.fromHeadUrl;
        vc.sameMindModel = sameM;
        //push的时候隐藏tabbar
        [self.navigationController pushViewController:vc animated:YES];
    }else if([model.type integerValue] == notification_type_end_talk){
        
        //已评价
        if ([model.valid integerValue] == 0) {
            [self showHint:@"该订单已评价"];
            return;
        }
        NSData *data = [model.data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        FKXEvaluateVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXEvaluateVC"];
        vc.type = dic[@"type"];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([model.type integerValue] == notification_type_people){
        FKXMyAnswerPageVC *vc = [[FKXMyAnswerPageVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
