//
//  FKXYuYueProCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXYuYueProCell.h"

@implementation FKXYuYueProCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgV.layer.cornerRadius = 25;
    self.headImgV.layer.masksToBounds = YES;
    
    self.phoneBtn.layer.cornerRadius = 18;
    self.phoneBtn.layer.masksToBounds = YES;
}

- (IBAction)touchCall:(id)sender {
    if ([self.callProDelegate respondsToSelector:@selector(callPro)]) {
        [self.callProDelegate callPro];
    }
}


-(void)setModel:(FKXUserInfoModel *)model
{
    _model = model;
    //头衔
    self.nameL.text = model.name;
    self.zhiyeL.text = model.profession;
    //简介
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 7;
    NSString *content = model.profile? model.profile : @"";
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName : sty}];
    self.desL.attributedText = att;
    //治愈了
    NSString *feeStr = [NSString stringWithFormat:@"成功治愈了%@人", model.cureCount];
    NSMutableAttributedString *feeAtt = [[NSMutableAttributedString alloc] initWithString:feeStr];
    [feeAtt addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x51b5ff) range:[feeStr rangeOfString:[model.cureCount stringValue]]];
    [self.zhiyuL setAttributedText:feeAtt];
    
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    if (_isVip) {
        self.imgVip.hidden = NO;
    }else{
        self.imgVip.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
