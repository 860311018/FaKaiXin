//
//  UILabelTextInRectHorVer.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "UILabelTextInRectHorVer.h"

@implementation UILabelTextInRectHorVer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets inset = UIEdgeInsetsMake(12, 19, 0, 19);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, inset)];
}
@end
