//
//  AppDelegate+FKXBeeCloud.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (FKXBeeCloud)

- (void)beeCloudInitWithAppID:(NSString *)appid
                    appSecret:(NSString *)appSecret
                    weChatPay:(NSString *)weChatID;
@end
