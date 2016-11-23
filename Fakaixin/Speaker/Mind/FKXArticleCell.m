//
//  FKXArticleCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/20.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXArticleCell.h"

@interface FKXArticleCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myBacImg;
@property (weak, nonatomic) IBOutlet UILabel *myTitleLab;
@property (weak, nonatomic) IBOutlet UILabel *myContentLab;

@end

@implementation FKXArticleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //给图片加两个圆角
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 10, _myBacImg.height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 10, _myBacImg.height);
    maskLayer.path = path.CGPath;
    _myBacImg.layer.mask = maskLayer;
    _myBacImg.layer.masksToBounds = YES;
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.borderColor = UIColorFromRGB(0xe7e7e7).CGColor;
    self.contentView.layer.borderWidth = 1.0;
}
- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 6;//整体向下 移动6
    frame.size.height -= 12;//间隔为12
    frame.origin.x += 5;
    frame.size.width -= 10;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(FKXResonance_homepage_model *)model
{
    _model = model;
    self.myTitleLab.text = model.title;
    _myContentLab.text = model.text;
    //    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    //    sty.lineSpacing = 5;
    //    NSString *content = model.text? model.text : @"";
    //    NSAttributedString *att = [[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName : sty}];
    //    _myContentLab.attributedText = att;
    
    [self.myBacImg sd_setImageWithURL:[NSURL URLWithString:model.background] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
    //html格式转为string
    //    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[model.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
}
@end
