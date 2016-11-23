//
//  UILabelTextInRect.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/30.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "UILabelTextInRect.h"

@implementation UILabelTextInRect

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0,15,0,15};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end
