//
//  FKXOrderCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXOrderCell.h"

@interface FKXOrderCell ()
@property (weak, nonatomic) IBOutlet UIButton *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

@end

@implementation FKXOrderCell

- (void)awakeFromNib {
    // Initialization code
    _rejectBtn.tag = 200;
    _acceptBtn.tag = 201;
    _btnService.tag = 202;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//拒绝，接受，服务
- (IBAction)rejectOrAcceptOrder:(UIButton *)sender {
    if (sender.tag == 203) {
        if ([self.delegate respondsToSelector:@selector(goToDynamicVC:sender:)]) {
            [self.delegate goToDynamicVC:_model sender:sender];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(rejectOrAcceptOrder:sender:)])
        {
            [self.delegate rejectOrAcceptOrder:self.model sender:sender];
        }
    }
    
}
-(void)setModel:(FKXOrderModel *)model
{
    _model = model;
    _userName.text = model.nickName;
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.headUrl,cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
}
@end
