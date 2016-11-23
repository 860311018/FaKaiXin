//
//  FKXMyDynamicWithVoiceCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyDynamicWithVoiceCell.h"
@interface FKXMyDynamicWithVoiceCell ()
@property (weak, nonatomic) IBOutlet UIButton *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UILabel *userTime;
@property (weak, nonatomic) IBOutlet UILabel *listenerInfo;
@property (weak, nonatomic) IBOutlet UIImageView *listenerIcon;
@property (weak, nonatomic) IBOutlet UILabel *likeNum;
@property (weak, nonatomic) IBOutlet UILabel *listenNum;

@end
@implementation FKXMyDynamicWithVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickUserIcon:(UIButton *)sender {
}
-(void)setModel:(MyDynamicModel *)model
{
    _model = model;
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _userName.text = model.nickname;
    _likeNum.text = [NSString stringWithFormat:@"%@人认可", model.praiseNum];
    _listenNum.text = [NSString stringWithFormat:@"%@人听过", model.listenNum];
    _userTime.text = model.createTime;
    [_listenerIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.toHead,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _listenerInfo.text = [NSString stringWithFormat:@"%@|%@",model.toNickname,model.listenerProfession];
    switch ([model.type integerValue]) {
        case 1:
            _userType.text = @"评论了";
            break;
        case 2:
            _userType.text = @"抱了";
            break;
        case 3:
            _userType.text = @"偷听了";
            break;
        case 4:
            _userType.text = @"赞了";
            break;
        default:
            break;
    }
}
@end
