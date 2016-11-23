//
//  NSString+Extension.h
//  正则表达式
//
//  Created by apple on 14/11/15.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
- (BOOL)isQQ;
- (BOOL)isRealZip;
- (BOOL)isRealPhoneNumber;
//- (BOOL)isPhoneNumber;
- (BOOL)isIPAddress;
- (BOOL)isNumber;

- (BOOL)isPositiveInteger;


+(NSString *)ret32bitString;
+ (BOOL)isEmpty:(NSString *)string;
/**
 时间处理成String
 */
//- (NSString *)created_at;


//md5加密（大写）
+ (NSString*)md532BitUpper:(NSString *)str;


//base64加密
+ (NSString *)base64:(NSString *)input;




@end
