//
//  FKXMyAnswerCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyAnswerCell.h"
@interface FKXMyAnswerCell ()
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labName;

@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UIButton *imgIcon;
@end

@implementation FKXMyAnswerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickToAnswer:(UIButton *)sender
{   
    if (sender.tag == 100 || sender.tag == 102) {
        if ([self.delegate respondsToSelector:@selector(goToAnswer:sender:)]) {
            [self.delegate goToAnswer:_model sender:sender];
        }
    }else  if (sender.tag == 101) {
        if ([self.delegate respondsToSelector:@selector(goToDynamicVC:sender:)]) {
            [self.delegate goToDynamicVC:_model sender:sender];
        }
    }
}
-(void)setModel:(FKXSecondAskModel *)model
{
    _model = model;
    _labTime.text = model.createTime;
    _labName.text = model.userNickName;
    [_imgIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.userHead, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    NSString *str = @"";
    if (_isAnswer)
    {//在我答界面
        switch ([model.isAccept integerValue]) {
            case -1:
                str = @"已过期";
                _btnAnswer.hidden = YES;
                break;
            case 0:
                str = @"待认可";
                _btnAnswer.hidden = YES;
                break;
            case 1:
                str = @"已回答";
                _btnAnswer.hidden = YES;
                break;
            case 2:
                str = @"待回答";
                _btnAnswer.hidden = NO;
                [_btnAnswer setTitle:@"去回答" forState:UIControlStateNormal];
                break;
            case 3:
                str = @"被追问";
                _btnAnswer.hidden = NO;
                [_btnAnswer setTitle:@"去回答" forState:UIControlStateNormal];
                break;
            default:
                str = @"";
                _btnAnswer.hidden = YES;
                break;
        }
    }else{//在我问界面
        switch ([model.isAccept integerValue]) {
            case -1:
                str = @"已过期";
                break;
            case 2:
                str = @"待回复";
                break;
            default:
                break;
        }
    }
    _labStatus.text = str;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.text ? model.text : @"" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
    _labContent.attributedText = attStr;
}
@end
