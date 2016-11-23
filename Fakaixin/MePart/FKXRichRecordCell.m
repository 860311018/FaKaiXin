//
//  FKXRichRecordCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXRichRecordCell.h"

@implementation FKXRichRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(15, 0, rect.size.width - 20, 0.5));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
