//
//  FKXGrayView.h
//  Fakaixin
//
//  Created by apple on 2016/11/21.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXConfirmView.h"

@protocol FKXGrayDelegate <NSObject>

- (void)adMinutes;

- (void)deMinutes;

- (void)bangDingMobile;

- (void)clickWeiXinPay;

- (void)clickZhiFuBaoPay;

- (void)clickConfirm;

@end

@interface FKXGrayView : UIView

@property (nonatomic,weak)id<FKXGrayDelegate>grayDelegate;


-(instancetype)initWithPoint:(CGRect)frame;

-(void)show;

//- (instancetype)initWithMobileFrame:(CGRect)frame;


@end
