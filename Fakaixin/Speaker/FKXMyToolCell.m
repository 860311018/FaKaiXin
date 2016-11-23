//
//  FKXMyToolCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyToolCell.h"

@interface FKXMyToolCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageType;
@property (weak, nonatomic) IBOutlet UILabel *labType;
@property (weak, nonatomic) IBOutlet UILabel *labValue;
@property (weak, nonatomic) IBOutlet UILabel *labNum;

@end

@implementation FKXMyToolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickBtn:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickCellBtn:withCell:)]) {
        [_delegate clickCellBtn:sender withCell:self];
    }
}
-(void)setModel:(FKXShopModel *)model
{
    _model = model;
    [_imageType sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageBaseUrl, model.image1]] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
    if ([model.number integerValue]) {
        _labNum.hidden = NO;
        _labNum.text = [NSString stringWithFormat:@"已有x%@", model.number];
    }else{
        _labNum.hidden = YES;
    }
    switch ([model.element integerValue]) {
        case 1:
            if ([model.type integerValue] == 3) {
                _labType.text = @"邮票";
                _labValue.text = [NSString stringWithFormat:@"%.2f元/张",[model.money integerValue]/100.0];
                
                [_btnChange setTitle:@"购买" forState:UIControlStateNormal];
            }else{
                _labType.text = @"补签卡";
                _labValue.text = [NSString stringWithFormat:@"%@爱心值",model.love];
                [_btnChange setTitle:@"兑换" forState:UIControlStateNormal];
            }
            break;
        case 2:
            _labType.text = @"置顶卡";
            _labValue.text = [NSString stringWithFormat:@"%@爱心值",model.love];
            [_btnChange setTitle:@"兑换" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
//    if ([model.isOwn integerValue] && ![model.inUse integerValue]) {
//        _btnChange.userInteractionEnabled = YES;
//        [_btnChange setTitle:@"使用" forState:UIControlStateNormal];
//    }else if ([model.isOwn integerValue] && [model.inUse integerValue]) {
//        _btnChange.userInteractionEnabled = NO;
//        [_btnChange setTitle:@"使用中" forState:UIControlStateNormal];
//    }else{
//        _btnChange.userInteractionEnabled = YES;
//        [_btnChange setTitle:@"兑换" forState:UIControlStateNormal];
//    }
}
@end
