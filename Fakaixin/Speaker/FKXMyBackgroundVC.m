//
//  FKXMyBackgroundVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyBackgroundVC.h"
#import "FKXMyBackgroundCell.h"
#import "FKXShopModel.h"

@interface FKXMyBackgroundVC ()<FKXMyBackgroundCellProtocol>
{
    NSMutableArray *dataSources;
}
@end

@implementation FKXMyBackgroundVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataSources = [NSMutableArray arrayWithCapacity:1];
    
    [self loveMarketInfo];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 网络请求
- (void)headerRefreshEvent
{
    [self loveMarketInfo];
}
- (void)loveMarketBuy:(FKXMyBackgroundCell *)cell
{
    [self showHudInView:self.view hint:@"正在兑换"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    paramDic[@"marketId"] = cell.model.marketId;
    [AFRequest sendGetOrPostRequest:@"loveMarket/buy" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"兑换成功"];
             [self loveMarketInfo];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else{
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
- (void)loveMarketInfo
{
    NSDictionary *paramDic = @{@"uid":@([FKXUserManager shareInstance].currentUserId),
                               @"type":@(1)};
    
    [FKXShopModel sendGetOrPostRequest:@"loveMarket/info" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         if ([data[@"code"] integerValue] == 0)
         {
             NSString *love = [NSString stringWithFormat:@"爱心值：%@",[data[@"data"][@"currentLove"] stringValue]];
             _shopVC.love = data[@"data"][@"currentLove"];
             NSMutableAttributedString * attS = [[NSMutableAttributedString alloc] initWithString:love];
             [attS addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xfe9595) range:[love rangeOfString:[data[@"data"][@"currentLove"] stringValue]]];
             [_shopVC.labLoveValue setAttributedText:attS];
             [dataSources removeAllObjects];
             for (NSDictionary *subDic in data[@"data"][@"list"]) {
                 FKXShopModel *model = [[FKXShopModel alloc] initWithDictionary:subDic error:nil];
                 [dataSources addObject:model];
             }
             [self.tableView reloadData];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else{
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
     }];
}
- (void)loveMarketUse:(FKXMyBackgroundCell *)cell
{
    [self showHudInView:self.view hint:@"正在使用..."];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    paramDic[@"marketId"] = cell.model.marketId;
    [AFRequest sendGetOrPostRequest:@"loveMarket/use" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"使用成功"];
             [self loveMarketInfo];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
#pragma mark - cell 自定义代理
- (void)clickCellBtn:(UIButton *)butt withCell:(FKXMyBackgroundCell *)cell
{
    if ([cell.btnChange.titleLabel.text isEqualToString:@"兑换"]) {
        [self loveMarketBuy:cell];
    }else
    {
        [self loveMarketUse:cell];
    }
}
#pragma mark tableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 89;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSources.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXShopModel *model = dataSources[indexPath.row];
    FKXMyBackgroundCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyBackgroundCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = model;
    return cell;
}

@end
