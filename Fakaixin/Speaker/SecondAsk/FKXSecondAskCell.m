//
//  FKXSecondAskCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXSecondAskCell.h"
#import "NSString+HeightCalculate.h"

#define kFontOfContent 15

@interface FKXSecondAskCell ()
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UILabel *labPlayNums;
@property (weak, nonatomic) IBOutlet UIButton *imgIcon;
@end


@implementation FKXSecondAskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//点击头像或者点击播放
- (IBAction)clickToPlayRecord:(UIButton *)sender
{
//    if (sender.tag == 100)
//    {
//        if ([self.delegate respondsToSelector:@selector(playRecordBtnDidSelect:sender:)]) {
//            [self.delegate playRecordBtnDidSelect:_model sender:sender];
//        }
//    }
//    else
        if (sender.tag == 101) {
        if ([self.delegate respondsToSelector:@selector(goToDynamicVC:sender:)]) {
            [self.delegate goToDynamicVC:_model sender:sender];
        }
    }
}
-(void)setModel:(FKXSecondAskModel *)model
{
    _model = model;
    
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    CGFloat height = [model.text heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    
    CGFloat oneLineH = [@"哈" heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    
    NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:model.text ? model.text : @"" attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:kFontOfContent], NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName:UIColorFromRGB(666666)}];
    if (height > oneLineH*3)//文字高度大于3行
    {
        CGRect frame = _labContent.frame;
        frame.size.height = oneLineH*3;
        _labContent.numberOfLines = 3;
        _labContent.frame = frame;
    }else{
        CGRect frame = _labContent.frame;
        frame.size.height = height;
        _labContent.numberOfLines = 0;
        _labContent.frame = frame;
    }
    [_labContent setAttributedText:attS];
    
    _labInfo.text = [NSString stringWithFormat:@"%@|%@",model.listenerNickName,model.listenerProfession];
    _labPlayNums.text = [NSString stringWithFormat:@"%@人听过", model.listenNum];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.listenerHead, cropImageW]];
    [_imgIcon sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    NSString *title = @"限时免费";
    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"btn_bac_ask_red"] forState:UIControlStateNormal];
    if ([model.price floatValue] > 0) {
        if (model.voiceUrl30s) {
            title = @"免费试听30秒";
        }else
        {
            title = [NSString stringWithFormat:@"%.1f元悄悄听", [model.price doubleValue]/100];
        }
        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"btn_bac_ask_blue"] forState:UIControlStateNormal];
    }else if ([model.price floatValue] < 0) {
        title = @"点击播放";
        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"btn_bac_ask_blue"] forState:UIControlStateNormal];
    }
    [_btnPlay setTitle:title forState:UIControlStateNormal];
}
@end
