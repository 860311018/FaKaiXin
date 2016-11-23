//
//  UIView+CornerRadius.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/2/25.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "UIView+CornerRadius.h"

@implementation UIView (CornerRadius)

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}
-(CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

@end
