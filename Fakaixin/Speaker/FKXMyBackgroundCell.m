//
//  FKXMyBackgroundCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyBackgroundCell.h"

@interface FKXMyBackgroundCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageype;
@property (weak, nonatomic) IBOutlet UILabel *labValue;

@end

@implementation FKXMyBackgroundCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(clickCellBtn:withCell:)]) {
        [_delegate clickCellBtn:sender withCell:self];
    }
}
-(void)setModel:(FKXShopModel *)model
{
    _model = model;
    [_imageype sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageBaseUrl, model.image1]] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
    _labValue.text = [NSString stringWithFormat:@"%@爱心值",model.love];
    if ([model.isOwn integerValue] && ![model.inUse integerValue]) {
        _btnChange.userInteractionEnabled = YES;
        [_btnChange setTitle:@"使用" forState:UIControlStateNormal];
    }else if ([model.isOwn integerValue] && [model.inUse integerValue]) {
        _btnChange.userInteractionEnabled = NO;
        [_btnChange setTitle:@"使用中" forState:UIControlStateNormal];
    }else{
        _btnChange.userInteractionEnabled = YES;
        [_btnChange setTitle:@"兑换" forState:UIControlStateNormal];
    }
}
@end
