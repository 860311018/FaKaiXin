//
//  FKXMyToolVC.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseTableViewController.h"
#import "FKXMyShopVC.h"

//道具tableviewVC
@interface FKXMyToolVC : FKXBaseTableViewController

@property (nonatomic, assign) FKXMyShopVC *shopVC;//管理此vc的pageVC，方便重置它的爱心值

@property (nonatomic, assign)NSInteger type;//0道具，2邮票
@end
