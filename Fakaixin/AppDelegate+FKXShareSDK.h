//
//  AppDelegate+FKXShareSDK.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (FKXShareSDK)

- (void)shareSDKRegisterAppByShareAppKey:(NSString *)shareAppKey
                              sinaAppKey:(NSString *)sinaAppKey
                           sinaAppSecret:(NSString *)sinaAppSecret
                                 qqAppId:(NSString *)qqAppId
                                qqAppKey:(NSString *)qqAppKey
                             weChatAppID:(NSString *)weChatAppID
                         weChatAppSecret:(NSString *)weChatAppSecret;

@end
