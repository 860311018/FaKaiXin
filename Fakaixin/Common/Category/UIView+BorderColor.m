//
//  UIView+BorderColor.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/3/16.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "UIView+BorderColor.h"

@implementation UIView (BorderColor)
-(void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}
-(UIColor *)borderColor
{
    return (UIColor *)self.layer.borderColor;
}

@end
