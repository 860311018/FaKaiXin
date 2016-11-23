//
//  FKXMyBackgroundVC.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseTableViewController.h"
#import "FKXMyShopVC.h"

//配饰tableviewVC
@interface FKXMyBackgroundVC : FKXBaseTableViewController

@property (nonatomic, assign) FKXMyShopVC *shopVC;//管理此vc的pageVC，方便重置它的爱心值

@end
