//
//  FKXMyAskListLetterCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyAskListLetterCell.h"

@interface FKXMyAskListLetterCell ()
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *labStatus;
@property (weak, nonatomic) IBOutlet UIButton *userIcon;

@end

@implementation FKXMyAskListLetterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(FKXSecondAskModel *)model
{
    _model = model;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.writeText?model.writeText:@"" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x333333)}];
    _labContent.attributedText = attStr;
    
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.userHead, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _userName.text = model.userNickName;
    
    switch ([model.isAccept integerValue]) {
        case 4:
            _labStatus.text = @"信件待回复";
            _labStatus.textColor = UIColorFromRGB(0x67e885);
            break;
        case 5:
            _labStatus.text = @"信件已回复";
            _labStatus.textColor = kColorMainBlue;
            break;
            
        default:
            break;
    }
}
@end
