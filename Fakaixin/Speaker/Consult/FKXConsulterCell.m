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
    [super awakeFromNib];

    self.headImgV.layer.cornerRadius = 25;
    self.headImgV.layer.masksToBounds = YES;
    
    self.phoneBtn.layer.cornerRadius = 18;
    self.phoneBtn.layer.masksToBounds = YES;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.tagL.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.tagL.bounds;
    maskLayer.path = maskPath.CGPath;
    self.tagL.layer.mask = maskLayer;
    
    [self.tapView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchCall:)]];
}

- (IBAction)touchCall:(id)sender {
    if ([self.delegate respondsToSelector:@selector(consultCallPro:)]) {
        [self.delegate consultCallPro:self.model];
    }
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
    self.nameL.text = model.name;
    self.zhiyeL.text = model.profession;
    self.tagL.text = [NSString stringWithFormat:@"%ld元起",[model.phonePrice integerValue]/100];
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
    
    [self.phoneBtn setImage:[UIImage imageNamed:@"phone_lixian"] forState:UIControlStateNormal];
    
    if ([model.status integerValue] == 1) {
        [self.phoneBtn setImage:[UIImage imageNamed:@"phone_zaixian"] forState:UIControlStateNormal];
        
    }else if ([model.status integerValue] == 2) {
        [self.phoneBtn setImage:[UIImage imageNamed:@"phone_tonghua"] forState:UIControlStateNormal];
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
