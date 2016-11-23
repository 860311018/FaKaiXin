//
//  FKXGrayView.m
//  Fakaixin
//
//  Created by apple on 2016/11/21.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXGrayView.h"
#import "FKXConfirmView.h"
#import "FKXBindPhone.h"

#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

@interface FKXGrayView ()<ConfirmDelegate>
{
    FKXConfirmView * order;
    FKXBindPhone * phone;

}
@end

@implementation FKXGrayView

-(instancetype)initWithPoint:(CGRect)frame{
    if (self=[super init]) {
        self.frame=CGRectMake(0, 0,kScreenWidth, kScreenHeight);
        self.backgroundColor = WINDOW_COLOR;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tap];
        
        order =  [FKXConfirmView creatOrder];
//        CGRect  rect =order.frame;
//        rect.origin.x = point.x;
//        rect.origin.y = point.y;
        order.frame=frame;
        order.confirmDelegate = self;
        
        [self addSubview:order];
        
    }
    return self;
}

- (instancetype)initWithMobileFrame:(CGRect)frame {
    if (self=[super init]) {
        self.frame=CGRectMake(0, 0,kScreenWidth, kScreenHeight);
        self.backgroundColor = WINDOW_COLOR;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tap];
        
        phone =  [FKXBindPhone creatBangDing];
        CGPoint center = self.center;
        phone.center = center;
        
        CGPoint rect = phone.origin;
        rect.y = 64;
        phone.origin = rect;
        
        [self addSubview:phone];
        
    }
    return self;
}



#pragma mark - 订单
- (void)desMinute {
    [_grayDelegate deMinutes];
}

- (void)addMinute {
    [_grayDelegate adMinutes];
}

- (void)bangDingPhone {
    [self hide];
    [_grayDelegate bangDingMobile];
}

- (void)weiXin {
//    [_grayDelegate clickWeiXinPay];
}

- (void)zhiFuBao {
//    [_grayDelegate clickZhiFuBaoPay];
}

- (void)confirm {
    [_grayDelegate clickConfirm];
}


-(void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
}

-(void)hide{
    
    [UIView animateWithDuration:0.6 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
