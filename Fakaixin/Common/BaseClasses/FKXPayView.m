//
//  FKXPayView.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/30.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPayView.h"

@implementation FKXPayView
-(void)awakeFromNib
{
    [super awakeFromNib];
    _myPayChannel = MyPayChannel_weChat;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
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
