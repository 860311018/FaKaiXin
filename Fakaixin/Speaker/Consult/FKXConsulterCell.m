//
//  FKXConsulterCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXConsulterCell.h"

@interface FKXConsulterCell ()
@property (weak, nonatomic) IBOutlet UIButton *userIcon;    //头像
@property (weak, nonatomic) IBOutlet UILabel *profileLab;   //头衔
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;  //用户名
@property (weak, nonatomic) IBOutlet UILabel *feeConsultLab;//回答的问题个数
@property (weak, nonatomic) IBOutlet UILabel *labIntroduce;//个人简介

@end

@implementation FKXConsulterCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(FKXUserInfoModel *)model
{
    _model = model;
    //头衔
    _userNameLab.text = model.name;
    _profileLab.text = model.profession;
    //简介
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 7;
    NSString *content = model.profile? model.profile : @"";
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName : sty}];
    _labIntroduce.attributedText = att;
    //治愈了
    NSString *feeStr = [NSString stringWithFormat:@"成功治愈了%@人", model.cureCount];
    NSMutableAttributedString *feeAtt = [[NSMutableAttributedString alloc] initWithString:feeStr];
    [feeAtt addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x51b5ff) range:[feeStr rangeOfString:[model.cureCount stringValue]]];
    [_feeConsultLab setAttributedText:feeAtt];
    
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    if (_isVip) {
        self.imgVip.hidden = NO;
    }else{
        self.imgVip.hidden = YES;
    }
}

//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//    CGContextFillRect(context, rect);
//    
//    //上分割线
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1].CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 9));
//}

- (IBAction)clickUserIcon:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(goToDynamicVC:sender:)]) {
//        [self.delegate goToDynamicVC:_model sender:sender];
//    }
}
@end
