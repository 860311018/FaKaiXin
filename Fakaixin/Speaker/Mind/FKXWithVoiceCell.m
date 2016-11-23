//
//  FKXWithVoiceCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/26.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXWithVoiceCell.h"

#define kFontOfContent 14

@interface FKXWithVoiceCell ()

@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@end

@implementation FKXWithVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
//- (void)setFrame:(CGRect)frame
//{
//    frame.origin.y += 5;//整体向下 移动5
//    frame.origin.x += 5;
//    frame.size.width -= 10;
//    frame.size.height -= 10;//间隔为10
//    [super setFrame:frame];
//}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(FKXSecondAskModel *)model
{
    _model = model;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:model.text ? model.text : @"" attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:kFontOfContent],  NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName:UIColorFromRGB(0x333333)}];
    [_labContent setAttributedText:attS];
    
    [_btnPlay setTitle:_model.voiceTime forState:UIControlStateNormal];
}
@end
