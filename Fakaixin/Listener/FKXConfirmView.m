//
//  FKXConfirmView.m
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "NSString+Extension.h"
#import "FKXConfirmView.h"
#define WINDOW_COLOR  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

@interface FKXConfirmView ()<UITextFieldDelegate>
{
    NSInteger minutes;
    
    NSInteger multiple;

    CGFloat totals;
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
    
    self.phoneTF.delegate = self;
    self.minutesTF.userInteractionEnabled = NO;
    
    minutes = 15;
    multiple = 1;
    
    self.weiXinPay.selected = YES;
    self.zhiFuPay.selected = NO;
   
    [self.headImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHead:)]];

}

- (void)layoutSubviews {
    
    self.priceL.text = [NSString stringWithFormat:@"￥%ld元/15分钟",self.price];
    
    self.minutesTF.text = [NSString stringWithFormat:@"%ld",minutes];
    
    totals = multiple *self.price;
    if (minutes>=60) {
        totals = multiple *self.price*0.9;
    }
    self.totalL.text = [NSString stringWithFormat:@"￥%.2f",totals];
    
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.head,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nameL.text = self.name;
    
    if ([self.status integerValue] == 0) {
        self.statusL.text = @" 离线 ";
    }else if ([self.status integerValue] == 1){
        self.statusL.text = @" 在线 ";
    }else if ([self.status integerValue]) {
        self.statusL.text = @" 通话中 ";
    }
    

    if (self.phoneStr) {
        self.phoneTF.text = self.phoneStr;
        self.phoneTF.enabled = NO;
    }
}


+ (id)creatOrder {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXConfirmView" owner:self options:nil].lastObject;
}

- (void)tapHead:(UITapGestureRecognizer *)tap {
    [_confirmDelegate clickHead:self.listenerId];
}

- (IBAction)descMinutes:(id)sender {

    if (minutes <= 15) {
        
        return;
    }
    
    minutes = minutes - 15;
    multiple = multiple - 1;
    
    [self layoutSubviews];

//    [_confirmDelegate desMinute];
}
- (IBAction)addMinutes:(id)sender {

    minutes = minutes + 15;
    multiple = multiple + 1;
    
    [self layoutSubviews];
    
//    [_confirmDelegate addMinute];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [_confirmDelegate textBeginEdit];
}

- (IBAction)bangDing:(id)sender {
    [self.minutesTF resignFirstResponder];

   
    [_confirmDelegate bangDingPhone:self.phoneTF.text];
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
    NSString *totalStr = [NSString stringWithFormat:@"%f",totals];
    NSInteger total = [totalStr integerValue]*100;
    [_confirmDelegate confirm:self.listenerId time:@(minutes) totals:@(total)];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
