//
//  UIView+BorderWidth.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/3/16.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "UIView+BorderWidth.h"

@implementation UIView (BorderWidth)

-(void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}
-(CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

@end
