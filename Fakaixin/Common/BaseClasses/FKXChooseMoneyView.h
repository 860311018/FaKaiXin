//
//  FKXChooseMoneyView.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXPayView.h"
//弹出的选择金额的界面
@interface FKXChooseMoneyView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property(nonatomic, assign)MyPayChannel  myPayChannel;

@property (weak, nonatomic) IBOutlet UIButton *myPayBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnRemain;

-(instancetype)initWithMoneysArr:(NSArray *)arrs;

@end
