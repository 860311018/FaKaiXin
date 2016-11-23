//
//  FKXConfirmView.m
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXConfirmView.h"
#define WINDOW_COLOR  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

@interface FKXConfirmView ()
{
    NSInteger minutes;
    NSInteger totals;
}
@end

@implementation FKXConfirmView


- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImgV.layer.cornerRadius = 25;
    self.headImgV.layer.masksToBounds = YES;
//    self.headImgV.backgroundColor = [UIColor whiteColor];

    [self.weiXinPay setImage:[UIImage imageNamed:@"Order_WeiXin_nor"] forState:UIControlStateNormal];
    [self.weiXinPay setImage:[UIImage imageNamed:@"Order_WeiXin_sel"] forState:UIControlStateSelected];

    [self.zhiFuPay setImage:[UIImage imageNamed:@"Order_ZhiFuBao_nor"] forState:UIControlStateNormal];
    [self.zhiFuPay setImage:[UIImage imageNamed:@"Order_ZhiFuBao_sel"] forState:UIControlStateSelected];
    
    minutes = 15;
    self.price = 10;
    
    self.weiXinPay.selected = YES;
    self.zhiFuPay.selected = NO;
}

- (void)layoutSubviews {
    
    self.priceL.text = [NSString stringWithFormat:@"%ld",self.price];
    
    self.minutesTF.text = [NSString stringWithFormat:@"%ld",minutes];
    
    self.totalL.text = [NSString stringWithFormat:@"%ld",minutes*self.price];
}


+ (id)creatOrder {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXConfirmView" owner:self options:nil].lastObject;
}

- (IBAction)descMinutes:(id)sender {

    if (minutes <= 15) {
        return;
    }
    
    minutes = minutes - 15;
    totals = minutes * self.price;
   
    [self layoutSubviews];

//    [_confirmDelegate desMinute];
}
- (IBAction)addMinutes:(id)sender {

    minutes = minutes + 15;
    totals = minutes * self.price;
    
    [self layoutSubviews];
    
//    [_confirmDelegate addMinute];
}
- (IBAction)bangDing:(id)sender {
    [_confirmDelegate bangDingPhone];
}
- (IBAction)weiXinPay:(id)sender {
    self.weiXinPay.selected = YES;
    self.zhiFuPay.selected = NO;
    [_confirmDelegate weiXin];
}
- (IBAction)zhiFuPay:(id)sender {
    self.weiXinPay.selected = NO;
    self.zhiFuPay.selected = YES;
    [_confirmDelegate zhiFuBao];
}
- (IBAction)confirmOrder:(id)sender {
    [_confirmDelegate confirm];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
