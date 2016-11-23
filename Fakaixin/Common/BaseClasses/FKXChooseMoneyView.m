//
//  FKXChooseMoneyView.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChooseMoneyView.h"

#define kBtnW 74
#define kBtnH 30

@interface FKXChooseMoneyView ()

@end

@implementation FKXChooseMoneyView
-(instancetype)initWithMoneysArr:(NSArray *)arrs
{
    if (self = [super init]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"FKXChooseMoneyView" owner:nil options:nil] firstObject];
        
        _myPayChannel = MyPayChannel_weChat;
        //183 54
        CGFloat marginx = (self.width - kBtnW*3)/4;
        CGFloat marginy = (183 - 54 - kBtnH*2)/3;
        CGFloat y = 54 + marginy;
        for (int i = 0; i < arrs.count; i++) {
            CGFloat x = marginx + (marginx + kBtnW)*(i%3);
            if (i == 3) {
                y += (marginy + kBtnH);
            }
            //g按钮
            UIButton * gBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            gBtn.frame = CGRectMake(x, y, kBtnW, kBtnH);
            gBtn.backgroundColor = [UIColor whiteColor];
            gBtn.tag = 200 + i;
            [gBtn setTitle:arrs[i] forState:UIControlStateNormal];
            gBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [gBtn setTitleColor:UIColorFromRGB(0xeb4f38) forState:UIControlStateNormal];
            gBtn.layer.borderColor = UIColorFromRGB(0xeb4f38).CGColor;
            gBtn.layer.borderWidth = 1.0;
            gBtn.layer.cornerRadius = 5;
            [gBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:gBtn];
        }
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)clicked:(UIButton *)but
{
    for (UIButton *sub in self.subviews) {
        if (sub.tag >= 200) {
            [sub setTitleColor:UIColorFromRGB(0xeb4f38) forState:UIControlStateNormal];
            sub.backgroundColor = [UIColor whiteColor];
            sub.layer.borderWidth = 1.0;
        }
    }
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    but.backgroundColor = UIColorFromRGB(0xfe9595);
    but.layer.borderWidth = 0.0;
}
- (IBAction)clickPayChannel:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 100:
            _myPayChannel = MyPayChannel_weChat;
            break;
        case 101:
            _myPayChannel = MyPayChannel_Ali;
            break;
        case 102:
            _myPayChannel = MyPayChannel_remain;
            break;
        default:
            break;
    }
    for (UIButton *btn in self.subviews)
    {
        if (btn.tag >= 100 && btn.tag <= 102) {
            btn.selected = NO;
        }
    }
    sender.selected = YES;
}
@end
