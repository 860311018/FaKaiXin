//
//  AppDelegate+FKXShareSDK.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AppDelegate+FKXShareSDK.h"

@implementation AppDelegate (FKXShareSDK)

- (void)shareSDKRegisterAppByShareAppKey:(NSString *)shareAppKey
                              sinaAppKey:(NSString *)sinaAppKey
                           sinaAppSecret:(NSString *)sinaAppSecret
                                qqAppId:(NSString *)qqAppId
                                qqAppKey:(NSString *)qqAppKey
                            weChatAppID:(NSString *)weChatAppID
                         weChatAppSecret:(NSString *)weChatAppSecret
{
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:shareAppKey
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]//,@(SSDKPlatformSubTypeWechatTimeline)
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
//             case SSDKPlatformSubTypeWechatTimeline:
//                 [ShareSDKConnector connectWeChat:[WXApi class]];
//                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:sinaAppKey
                                           appSecret:sinaAppSecret
                                         redirectUri:@"http://www.sharesdk.cn"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:weChatAppID
                                       appSecret:weChatAppSecret];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:qqAppId
                                      appKey:qqAppKey
                                    authType:SSDKAuthTypeBoth];
                 break;
            
             default:
                 break;
         }
     }];
}

@end
