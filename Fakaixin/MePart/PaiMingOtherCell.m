//
//  PaiMingOtherCell.m
//  testMine
//
//  Created by apple on 2016/11/1.
//  Copyright © 2016年 appleZYH. All rights reserved.
//

#import "PaiMingOtherCell.h"

@implementation PaiMingOtherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgV.layer.cornerRadius = ([UIScreen mainScreen].bounds.size.width -20)*0.07;
    self.headImgV.clipsToBounds = YES;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width - 0, 1));
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
