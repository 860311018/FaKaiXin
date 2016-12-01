//
//  FKXAboutMeCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXAboutMeCell.h"

@interface FKXAboutMeCell ()
@property (weak, nonatomic) IBOutlet UIButton *userIcon;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labDetail;
@property (weak, nonatomic) IBOutlet UIButton *imgDetail;
@end

@implementation FKXAboutMeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)clickToMyDynamic:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(goToDynamicVC:sender:)]) {
        [self.delegate goToDynamicVC:_model sender:sender];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(MyDynamicModel *)model
{
    _model = model;
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.fromHead,cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _labTime.text = model.createTime;
    _userName.text = model.fromNickname;
    
    _labDetail.text = model.replyText;
    
    if ([model.type integerValue] == 7) {
        _labDetail.text = @"查看详情";
        _labDetail.textAlignment = NSTextAlignmentCenter;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    switch ([model.type integerValue]) {
        case 1:
        {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.commentText ? model.commentText : @"" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
            _labContent.attributedText = attStr;
        }
            break;
        case 2:
            _labContent.text = [NSString stringWithFormat:@"%@抱了你一下", model.fromNickname];
            break;
        case 3:
            _labContent.text = [NSString stringWithFormat:@"%@偷听了你的语音", model.fromNickname];
            break;
        case 4:
            _labContent.text = [NSString stringWithFormat:@"%@赞了你的评论", model.fromNickname];
            break;
        case 5:
            _labContent.text = [NSString stringWithFormat:@"%@语音回复了你",model.fromNickname];
            break;
        case 6:
            _labContent.text = [NSString stringWithFormat:@"%@回复了你的信件",model.fromNickname];
            break;
        case 7:
            _labContent.text = [NSString stringWithFormat:@"%@浏览了你,TA也许能够解决你的困惑哦",model.fromNickname];
            break;
        default:
            break;
    }
}
@end
