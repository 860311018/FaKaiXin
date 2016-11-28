//
//  FKXConsultViewController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

typedef enum : NSUInteger {
    PayType_weChat,
    PayType_Ali,
} PayType;

//咨询者tableviewVC
@interface FKXConsultViewController : FKXBaseViewController

@property(nonatomic, copy)NSDictionary *paraDic;

- (void)loadData;//加载数据，为筛选提供接口

@property (nonatomic,assign) PayType payType;
@property (nonatomic,strong) UITableView *tableView;

@end
