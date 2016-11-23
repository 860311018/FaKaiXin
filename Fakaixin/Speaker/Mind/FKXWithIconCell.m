//
//  FKXWithIconCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/26.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXWithIconCell.h"

@interface FKXWithIconCell ()

@property (weak, nonatomic) IBOutlet UIButton *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

@end

@implementation FKXWithIconCell

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
-(void)setMindModel:(FKXSameMindModel *)mindModel
{
    _mindModel = mindModel;
    [_iconImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",mindModel.head, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _userName.text = mindModel.nickName;
    
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 5;
    NSString *content = mindModel.text? mindModel.text : @"";
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName : sty}];
    _contentLab.attributedText = att;
}
-(void)setModel:(FKXUserInfoModel *)model
{
    _model = model;
    //头衔
    _userName.text = model.name;
    //简介
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 10;
    NSString *content = model.profile? model.profile : @"";
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:14],  NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName:UIColorFromRGB(0x333333)}];
    [_contentLab setAttributedText:attS];

    [_iconImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
}
@end
