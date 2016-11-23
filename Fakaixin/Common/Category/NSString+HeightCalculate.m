//
//  NSString+HeightCalculate.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/5/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "NSString+HeightCalculate.h"

@implementation NSString (HeightCalculate)

- (CGFloat)heightForWidth:(CGFloat)width usingFont:(UIFont *)font style:(NSMutableParagraphStyle *)style
{
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize labelSize = (CGSize){width, FLT_MAX};
    if (style) {
        CGRect r = [self boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName : style} context:context];
        return r.size.height;
    }else{
        CGRect r = [self boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:context];
        return r.size.height;
    }
    
}

@end
