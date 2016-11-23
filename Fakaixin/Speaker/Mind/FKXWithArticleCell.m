//
//  FKXWithArticleCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/26.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXWithArticleCell.h"
@interface FKXWithArticleCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myBacImg;
@property (weak, nonatomic) IBOutlet UILabel *myContentLab;

@end
@implementation FKXWithArticleCell

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
-(void)setModel:(FKXResonance_homepage_model *)model
{
    _model = model;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:model.text ? model.text : @"" attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:14],  NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName:UIColorFromRGB(0x333333)}];
    [_myContentLab setAttributedText:attS];
    
    [self.myBacImg sd_setImageWithURL:[NSURL URLWithString:model.background] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
    //html格式转为string
    //    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[model.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
}
@end
