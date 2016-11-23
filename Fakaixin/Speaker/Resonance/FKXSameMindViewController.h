//
//  FKXSameMindViewController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseTableViewController.h"
//（相同心情的人），心事界面（以前是共鸣）
@interface FKXSameMindViewController : FKXBaseTableViewController

@property(nonatomic, strong)NSNumber  * passMindType;//通过推荐界面点击进来的心事类型

- (void)viewDidLoad;

@end
