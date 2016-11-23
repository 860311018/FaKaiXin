//
//  AppDelegate+FKXBeeCloud.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AppDelegate+FKXBeeCloud.h"

@implementation AppDelegate (FKXBeeCloud)

- (void)beeCloudInitWithAppID:(NSString *)appid
                    appSecret:(NSString *)appSecret
                    weChatPay:(NSString *)weChatID
{
    //设置支付代理,记得要在支付页面写上这句话，否则支付成功后不走代理方法 [BeeCloud setBeeCloudDelegate:self];
    
    //开启沙箱测试环境
    [BeeCloud initWithAppID:appid andAppSecret:appSecret sandbox:YES];
    //开启生产环境
//    [BeeCloud initWithAppID:appid andAppSecret:appSecret ];
    //微信支付
    [BeeCloud initWeChatPay:weChatID];
    //查看当前模式
    /* 返回YES代表沙箱测试模式；NO代表生产模式 */
//    BOOL pattern = [BeeCloud getCurrentMode];
//    NSLog(@"支付当前模式:%@", pattern ? @"生产" : @"测试");
}
@end
