//
//  FKXLetterListVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXLetterListVC.h"
#import "FKXLetterListCell.h"
#import "FKXReplyLetterVC.h"
#import "FKXLetterModel.h"

@interface FKXLetterListVC ()
{
    NSInteger start;
    NSInteger size;
    FKXEmptyData *emptyDataView;    //空数据
}
@property   (nonatomic,strong)NSMutableArray *contentArr;

@end

@implementation FKXLetterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    start = 0;
    size = kRequestSize;
    self.navTitle = @"来信";
    //ui设置
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //ui设置
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    
    //ui创建
    [self setUpBarButton];
    
    //加载数据
    [self headerRefreshEvent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 空数据
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        emptyDataView.btnDeal.hidden = YES;
        emptyDataView.titleLab.text = @"还没有来信";
        [self.tableView addSubview:emptyDataView];
    }
}
#pragma mark - 子视图
- (void)setUpBarButton
{
    UIImage *consultImage = [UIImage imageNamed:@"back"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
    [btn setBackgroundImage:consultImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}
- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    NSDictionary *paramDic = @{@"start":@(start), @"size":@(size)};//, @"firstWorryId":@([[FKXUserManager shareInstance].noReadOrder integerValue])
    
    [FKXLetterModel sendGetOrPostRequest:@"write/selectWrite" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         if (data)
         {
             if ([data count] < kRequestSize) {
                 self.tableView.footer.hidden = YES;
             }else
             {
                 self.tableView.footer.hidden = NO;
             }
             if (start == 0)
             {
                 [_contentArr removeAllObjects];
                 if ([data count] == 0) {
                     [self createEmptyData];
                 }else{
                     if (emptyDataView) {
                         [emptyDataView removeFromSuperview];
                         emptyDataView = nil;
                     }
                 }
             }
             [_contentArr addObjectsFromArray:data];
             
             [self.tableView reloadData];
             
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
#pragma mark - tableviewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXLetterModel *model = _contentArr[indexPath.row];
    FKXLetterListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXLetterListCell" forIndexPath:indexPath];
    cell.model = model;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXLetterModel *model = _contentArr[indexPath.row];
    FKXReplyLetterVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXReplyLetterVC"];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
