//
//  FKXMyAnswerVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyAnswerVC.h"
#import "NSString+HeightCalculate.h"
#import "FKXMyAnswerCell.h"
#import "FKXCareDetailController.h"
#import "FKXProfessionInfoVC.h"

#define kFontOfContent 15

@interface FKXMyAnswerVC ()<FKXMyAnswerCellDelegate>
{
    NSInteger start;
    NSInteger size;
    CGFloat oneLineH;//一行的高度
    FKXEmptyData *emptyDataView;//空数据界面
}
@property   (nonatomic,strong)NSMutableArray *contentArr;//数据源

@end

@implementation FKXMyAnswerVC
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self headerRefreshEvent];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //基本赋值
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    oneLineH = [@"哈" heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    
    //ui设置
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
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
//加载相同心情的人
- (void)loadData
{
    NSDictionary *paramDic;
    paramDic = @{@"type":_status, @"start":@(start), @"size":@(size)};
    [AFRequest sendGetOrPostRequest:@"voice/meAnswer" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
         NSError *err = nil;
         if ([data[@"code"] integerValue] == 0)
         {
             if (start == 0)
             {
                 [_contentArr removeAllObjects];
                 
                 if ([data[@"data"][@"list"] count] == 0) {
                     [self createEmptyData];
                 }else{
                     if (emptyDataView) {
                         [emptyDataView removeFromSuperview];
                         emptyDataView = nil;
                     }
                 }
             }
             
             for (NSDictionary *dic in data[@"data"][@"list"])
             {
                 FKXSecondAskModel * officalSources =  [[FKXSecondAskModel alloc] initWithDictionary:dic error:&err];
                 [_contentArr addObject:officalSources];
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
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
#pragma mark - UI空数据
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        [emptyDataView.btnDeal addTarget:self action:@selector(clickBtnDeal) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:emptyDataView];
        [emptyDataView.btnDeal setTitleColor:kColorMainRed forState:UIControlStateNormal];
        emptyDataView.btnDeal.layer.borderColor = kColorMainRed.CGColor;
        emptyDataView.titleLab.text = @"你还没有回复过别人的问题哦~";
        [emptyDataView.btnDeal setTitle:@"马上回答~" forState:UIControlStateNormal];
    }
}
- (void)clickBtnDeal
{
    [self.navigationController popViewControllerAnimated:YES];
    [self performSelector:@selector(selectIndexToZero) withObject:nil afterDelay:0.1];
}
- (void)selectIndexToZero
{
    [FKXLoginManager shareInstance].tabBarListenerVC.selectedIndex = 0;
}
#pragma mark - tableView代理
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    CGFloat height = [model.text heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    return 119 + height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];
    FKXMyAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyAnswerCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.isAnswer = YES;
    if ([_status integerValue] == 1) {
        cell.labStatus.hidden = YES;
    }else{
        cell.labStatus.hidden = NO;
    }
    cell.model = model;
    return cell;
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
- (void)goToAnswer:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender
{
    FKXCareDetailController *vc = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXCareDetailController"];
    if ([cellModel.isAccept integerValue] == 2)
    {
        vc.careDetailType = care_detail_type_people;
    }else if ([cellModel.isAccept integerValue] == 3)
    {
        vc.careDetailType = care_detail_type_continue_ask;
    }
    vc.askModel = cellModel;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goToDynamicVC:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender
{
    if ([cellModel.isPublic integerValue] || [FKXUserManager shareInstance].currentUserId == [cellModel.userId integerValue]) {
        FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
        vc.userId = cellModel.userId;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
