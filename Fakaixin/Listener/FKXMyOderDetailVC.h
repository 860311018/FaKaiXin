//
//  FKXMyOderDetailVC.h
//  Fakaixin
//
//  Created by apple on 2016/12/1.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FKXOrderModel;

@interface FKXMyOderDetailVC : FKXBaseViewController

@property (nonatomic,assign) BOOL isWorkBench;

@property (nonatomic,strong) FKXOrderModel *model;


@end
