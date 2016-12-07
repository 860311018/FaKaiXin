//
//  FKXVoiceResponseCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/21.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXVoiceResponseCell.h"
#import "MyDynamicModel.h"

@implementation FKXVoiceResponseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgV.layer.cornerRadius = 15;
    self.headImgV.layer.masksToBounds = YES;
}

- (void)setModel:(MyDynamicModel *)model {
    _model = model;
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    self.timeL.text = model.createTime;
    self.nameL.text = model.nickname;
    
    NSInteger time = [model.voiceTime integerValue];
    NSInteger second = time%60;
    if (second <10) {
        self.voiceTimeL.text = [NSString stringWithFormat:@"%ld:0%ld",time/60,second];
    }else {
        self.voiceTimeL.text = [NSString stringWithFormat:@"%ld:%ld",time/60,second];
    }
    
    if ([model.isAccept integerValue] == 1) {
        self.zhiyeL.text = @"语音回复了";
    }else {
        self.zhiyeL.text = @"的语音回复被认可了";
    }
    
    NSString *contentStr = [NSString stringWithFormat:@"%@：%@",model.toNickname, model.replyText];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:contentStr attributes:@{NSParagraphStyleAttributeName : style}];
    
    [attStr addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x0093F7)} range:[contentStr rangeOfString:[NSString stringWithFormat:@"%@：",model.toNickname]]];
    
    [self.contentL setAttributedText:attStr];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
