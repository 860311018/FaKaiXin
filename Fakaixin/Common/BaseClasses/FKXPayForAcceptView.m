//
//  FKXPayForAcceptView.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/22.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPayForAcceptView.h"

@interface FKXPayForAcceptView ()
@property (weak, nonatomic) IBOutlet UILabel *labRemind;
//@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet UIView *viewTwo;

@end

@implementation FKXPayForAcceptView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];
    _myPayChannel = MyPayChannel_weChat;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:_labRemind.text attributes:@{NSParagraphStyleAttributeName: style}];
    [attS addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf88f60) range:[_labRemind.text rangeOfString:@"躺着赚钱"]];
    [_labRemind setAttributedText:attS];

}
//- (IBAction)clickAccept:(UIButton *)sender {
//    [UIView animateWithDuration:1 animations:^{
//        _viewTwo.alpha = 1.0;
//    }];
//}

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
    for (UIButton *btn in _viewTwo.subviews)
    {
        if (btn.tag >= 100 && btn.tag <= 102) {
            btn.selected = NO;
        }
    }
    sender.selected = YES;
}
@end
