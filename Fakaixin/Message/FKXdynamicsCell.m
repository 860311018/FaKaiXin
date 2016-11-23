//
//  FKXdynamicsCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXdynamicsCell.h"
#import "MyDynamicModel.h"

@implementation FKXdynamicsCell

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
    
    
    NSString *contentStr = [NSString stringWithFormat:@"%@：%@",model.toNickname, model.replyText];
   
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:contentStr attributes:@{NSParagraphStyleAttributeName : style}];

    [attStr addAttributes:@{NSParagraphStyleAttributeName : style,NSForegroundColorAttributeName:UIColorFromRGB(0x0093F7)} range:[contentStr rangeOfString:[NSString stringWithFormat:@"%@：",model.toNickname]]];
    
    [self.contentL setAttributedText:attStr];
    
    switch ([model.type integerValue]) {
        case 1:
            self.typeL.text = @"评论了";
            break;
        case 2:
            self.typeL.text = @"抱了";
            break;
        case 3:
            self.typeL.text = @"偷听了";
            break;
        case 4:
            self.typeL.text = @"赞了";
            break;
        default:
            break;
    }

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
