//
//  FKXNotificationCenterTableViewCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/6.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXNotificationCenterTableViewCell.h"

@implementation FKXNotificationCenterTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _imageIcon.layer.cornerRadius = _imageIcon.width/2;
    _imageIcon.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(FKXNotifcationModel *)model
{
    _model = model;
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 5;
    NSString *content = model.alert? model.alert : @"";
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName : sty}];
    _labTitle.attributedText = att;
    _labDate.text = model.createTime;
    [_imageIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.fromHeadUrl, cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
}
@end
