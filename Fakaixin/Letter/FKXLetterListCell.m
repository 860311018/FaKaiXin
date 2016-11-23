//
//  FKXLetterListCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXLetterListCell.h"

@interface FKXLetterListCell ()
@property (weak, nonatomic) IBOutlet UILabel *labContext;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;

@end

@implementation FKXLetterListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}
- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 10;//整体向下 移动6
    frame.size.height -= 20;//间隔为12
    frame.origin.x += 13;
    frame.size.width -= 23;
    [super setFrame:frame];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(FKXLetterModel *)model
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 9;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.text?model.text:@"" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x333333)}];
    _labContext.attributedText = attStr;
    
    _userName.text = model.userName;
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:model.userHead] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
}
@end
