//
//  FKXMyAskListCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyAskListCell.h"

#define kFontOfContent 15

@interface FKXMyAskListCell ()
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (weak, nonatomic) IBOutlet UIButton *imgIcon;
@end

@implementation FKXMyAskListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickToAgree:(UIButton *)sender
{
    if (sender.tag == 100) {
        if ([self.delegate respondsToSelector:@selector(goToReport:sender:)]) {
            [self.delegate goToReport:_model sender:sender];
        }
    }
    else if (sender.tag == 101){
        if ([self.delegate respondsToSelector:@selector(goToAgree:sender:)]) {
            [self.delegate goToAgree:_model sender:sender];
        }
    }
    else if (sender.tag == 102){
        if ([self.delegate respondsToSelector:@selector(goToDynamicVC:sender:)]) {
            [self.delegate goToDynamicVC:_model sender:sender];
        }
    }
}
-(void)setModel:(FKXSecondAskModel *)model
{
    _model = model;
    _labInfo.text = [NSString stringWithFormat:@"%@|%@",model.listenerNickName,model.listenerProfession];
    
    [_imgIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.listenerHead, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
//    NSString *title = @"限时免费";
//    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"btn_bac_ask_red"] forState:UIControlStateNormal];
//    if ([model.price floatValue] > 0) {
//        title = [NSString stringWithFormat:@"%@元悄悄听", model.price];
//        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"btn_bac_ask_blue"] forState:UIControlStateNormal];
//    }else if ([model.price floatValue] < 0) {
//        title = @"点击播放";
//    }
//    [_btnPlay setTitle:title forState:UIControlStateNormal];
//    [_btnPlay setImage:[UIImage imageNamed:@"img_voice_step3"] forState:UIControlStateNormal];
    
//    _btnPlay.imageView.animationImages =
//    @[[UIImage imageNamed:@"img_voice_step1"],
//      [UIImage imageNamed:@"img_voice_step2"],
//      [UIImage imageNamed:@"img_voice_step3"]];
//    _btnPlay.imageView.animationDuration = 1.5;
    //重置按钮的两个title属性，避免冲突
    [_btnAgree setTitle:nil forState:UIControlStateNormal];
    [_btnAgree setAttributedTitle:nil forState:UIControlStateNormal];
    
    switch ([model.isAccept integerValue]) {
        case -1:
        case -2:
        {
            _imgIcon.hidden = YES;
            _btnPlay.hidden = YES;
            _labInfo.hidden = YES;
            _btnAgree.userInteractionEnabled = NO;
            _btnAgree.hidden = NO;
            [_btnAgree setTitle:@"已过期" forState:UIControlStateNormal];
            [_btnAgree setTitleColor:UIColorFromRGB(0x7a7777) forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            _imgIcon.hidden = YES;
            _btnPlay.hidden = YES;
            _labInfo.hidden = YES;
            _btnAgree.userInteractionEnabled = NO;
            _btnAgree.hidden = NO;
            [_btnAgree setTitle:@"待回复" forState:UIControlStateNormal];
            [_btnAgree setTitleColor:UIColorFromRGB(0x8deda2) forState:UIControlStateNormal];
        }
            break;
        case 3://去听
        {
            _imgIcon.hidden = NO;
            _btnPlay.hidden = NO;
            _labInfo.hidden = NO;
            _btnAgree.hidden = YES;
        }
            break;
        case 0:
        {
            _imgIcon.hidden = NO;
            _btnPlay.hidden = NO;
            _labInfo.hidden = NO;
            _btnAgree.userInteractionEnabled = NO;
            _btnAgree.hidden = NO;
            NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:@"待认可" attributes:@{NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle],NSForegroundColorAttributeName:UIColorFromRGB(0x51b5ff)}];
            [_btnAgree setAttributedTitle:attS forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            _imgIcon.hidden = NO;
            _btnPlay.hidden = NO;
            _labInfo.hidden = NO;
            _btnAgree.userInteractionEnabled = YES;
            _btnAgree.hidden = NO;
            NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:@"去追问" attributes:@{NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle],NSForegroundColorAttributeName:UIColorFromRGB(0x51b5ff)}];
            [_btnAgree setAttributedTitle:attS forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.text ? model.text : @"" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:kFontOfContent], NSForegroundColorAttributeName : UIColorFromRGB(0x333333)}];
    _labContent.attributedText = attStr;
}
@end
