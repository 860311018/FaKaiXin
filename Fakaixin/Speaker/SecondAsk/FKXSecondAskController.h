//
//  FKXSecondAskController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
//问答（以前是享问）tableviewVC
@interface FKXSecondAskController : FKXBaseTableViewController

@property(nonatomic, assign)BOOL isMyListenList;//是否是我听的界面
@property(nonatomic, strong)NSNumber  * passMindType;//通过推荐界面点击进来的心事类型

- (void)viewDidLoad;

@end
