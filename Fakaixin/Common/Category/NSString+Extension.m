//
//  NSString+Extension.m
//  正则表达式
//
//  Created by apple on 14/11/15.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Extension)


- (BOOL)match:(NSString *)pattern
{
    // 1.创建正则表达式
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    return results.count > 0;
    
    
}

- (BOOL)isQQ
{
    // 1.不能以0开头
    // 2.全部是数字
    // 3.5-11位
    return [self match:@"^[1-9]\\d{4,10}$"];
}



- (BOOL)isRealZip
{
    const char *cValue = [self UTF8String];
    
   // const char * cvalue = [self UTF8String];
    long len = strlen(cValue);
    if (len != 6) {
        return NO;
    }
    for (int i = 0; i < len; i++)
    {
        if (!(cValue[i] >= '0' && cValue[i] <= '9'))
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isRealPhoneNumber
{
    return [self match:@"^1[0-9]\\d{9}$"];
}

- (BOOL)isPositiveInteger {
    return [self match:@"^[1-9]\\d*$"];
}


- (BOOL)isPhoneNumber
{
    
    if (self.length != 11)
    {
        return NO;
    }
   
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|70)\\d{8}$";
    
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[08]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
    
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[016]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    
    NSString *CT = @"(^1(33|53|77|8[019])\\d{8}$)|(^170\\d{8}$)";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:self] == YES)
        || ([regextestcm evaluateWithObject:self] == YES)
        || ([regextestct evaluateWithObject:self] == YES)
        || ([regextestcu evaluateWithObject:self] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isNumber
{
    // 1.全部是数字
    // 2.11位
    // 3.以13\15\18\17开头
    return [self match:@"^[0-9]*$"];
    // JavaScript的正则表达式:\^1[3578]\\d{9}$\
    
}

- (BOOL)isIPAddress
{
    // 1-3个数字: 0-255
    // 1-3个数字.1-3个数字.1-3个数字.1-3个数字
    return [self match:@"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$"];
}

+(NSString *)ret32bitString

{
    
    char data[32];
    
    for (int x = 0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}

//不为nil,空,空格
+ (BOOL)isEmpty:(NSString *)string {
    
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)base64:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

+ (NSString*)md532BitUpper:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    CC_MD5( cStr,[num intValue], result );
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]] uppercaseString];
}


/**
 时间处理成String
 */
//- (NSString *)created_at
//{
//    // _created_at == Fri May 09 16:30:34 +0800 2014
//    // 1.获得通知的发送时间
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//    [fmt setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
//    fmt.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
//    //真机调试下, 必须加上这段
//    //fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    NSDate *createdDate = [fmt dateFromString:self];
//    
//    // 2..判断通知发送时间 和 现在时间 的差距
//    if (createdDate.isToday) { // 今天
//        if (createdDate.deltaWithNow.hour >= 1) {
//            return [NSString stringWithFormat:@"%ld小时前", (long)createdDate.deltaWithNow.hour];
//        } else if (createdDate.deltaWithNow.minute >= 1) {
//            return [NSString stringWithFormat:@"%ld分钟前", (long)createdDate.deltaWithNow.minute];
//        } else {
//            return [NSString stringWithFormat:@"1分钟前"];
//        }
//    } else if (createdDate.isYesterday) { // 昨天
//        fmt.dateFormat = @"昨天 HH:mm";
//        return [fmt stringFromDate:createdDate];
//    } else if (createdDate.deltaWithNow.day) { // 今年(至少是前天)
//        fmt.dateFormat = @"MM-dd HH:mm";
//        return [NSString stringWithFormat:@"%ld天前", (long)createdDate.deltaWithNow.day];
//    } else { // 非今年
//        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
//        return [fmt stringFromDate:createdDate];
//    }
//}
//
@end
