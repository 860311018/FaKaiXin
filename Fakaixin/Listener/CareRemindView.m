//
//  CareRemindView.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "CareRemindView.h"


@interface CareRemindView ()

@property (weak, nonatomic) IBOutlet UILabel *labOne;
@property (weak, nonatomic) IBOutlet UILabel *labTwo;
@property (weak, nonatomic) IBOutlet UILabel *labThree;
@end

@implementation CareRemindView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [super awakeFromNib];
    NSString *str1 = @"回复他人，就有机会被付费认可，打赏和躺着赚他人偷听的钱。";
    NSString *str2 = @"所有人都能免费听前30秒的回复，回复得有趣有料的同时，30秒内做好铺垫能提高用户付费偷听的欲望哦！";
    NSString *str3 = @"每天关怀他人，会拥有更多曝光机会出现在专家列表前列，让他人购买你的服务。";
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:str1 attributes:@{NSParagraphStyleAttributeName : style}];
    [att1 addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf56e6e) range:[str1 rangeOfString:@"付费认可"]];
    [_labOne setAttributedText:att1];
    
    NSMutableAttributedString *att2 = [[NSMutableAttributedString alloc] initWithString:str2 attributes:@{NSParagraphStyleAttributeName : style}];
    [att2 addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf56e6e) range:[str2 rangeOfString:@"30秒内做好铺垫"]];
    [_labTwo setAttributedText:att2];
    
    NSMutableAttributedString *att3 = [[NSMutableAttributedString alloc] initWithString:str3 attributes:@{NSParagraphStyleAttributeName : style}];
    [att3 addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf56e6e) range:[str3 rangeOfString:@"每天"]];
    [_labThree setAttributedText:att3];
}
@end
