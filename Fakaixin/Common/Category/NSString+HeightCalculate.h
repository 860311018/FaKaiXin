//
//  NSString+HeightCalculate.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/5/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HeightCalculate)

- (CGFloat)heightForWidth:(CGFloat)width usingFont:(UIFont *)font style:(NSMutableParagraphStyle *)style;
@end
