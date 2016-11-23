//
//  FKXLoveValueTableViewCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXLoveValueTableViewCell.h"

@interface FKXLoveValueTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *labLoveOrigin;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labLoveValue;
@property (weak, nonatomic) IBOutlet UILabel *labUserName;

@end

@implementation FKXLoveValueTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(FKXLoveMoneyDetail *)model
{
//    model.unit 1 爱心值
//    model.unit 2 钱
    NSString *incomeType;
    switch ([model.unit integerValue]) {
        case 1:
            incomeType = @"爱心值";
            break;
        case 2:
            incomeType = @"￥";
        default:
            break;
    }
    _model = model;
    _labLoveOrigin.text = model.type;
    _labelDate.text = model.time;
    if ([model.amount doubleValue] > 0) {
        _labLoveValue.textColor = kColorMainBlue;
        _labLoveValue.text = [NSString stringWithFormat:@"%@+%@",incomeType, model.amount];
    }else{
        _labLoveValue.text = [NSString stringWithFormat:@"%@%@",incomeType, model.amount];

        _labLoveValue.textColor = kColor_MainRed();
    }
    _labUserName.text = model.user;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(15, 0, rect.size.width - 20, 0.5));
}

@end
