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

- (void)loadData;//加载数据，为筛选提供接口

@end