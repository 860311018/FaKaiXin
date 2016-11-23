//
//  FKXOpenSecondAskController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseTableViewController.h"
//开通秒问界面
@interface FKXOpenSecondAskController : FKXBaseTableViewController

@property(nonatomic, assign)BOOL isOpen;//是需要开通的
@property(nonatomic, assign)BOOL isShowClose;//是present的，需要展示关闭按钮

@property(nonatomic, strong)FKXUserInfoModel * userModel;


@end
