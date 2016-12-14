//
//  FKXConsultViewController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//


//咨询者tableviewVC
@interface FKXConsultViewController : FKXBaseTableViewController

@property(nonatomic, copy)NSDictionary *paraDic;

- (void)showView;
- (void)loadData;//加载数据，为筛选提供接口
//- (void)footRefreshEvent;
//- (void)headerRefreshEvent;
//@property (nonatomic,strong) UITableView *tableView;

@end
