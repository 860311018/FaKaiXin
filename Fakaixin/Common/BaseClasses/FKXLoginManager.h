//
//  FKXLoginManager.h
//  Fakaixin
//
//  Created by Connor on 10/16/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeakerTabBarViewController.h"
#import "ListenerTabBarViewController.h"
//管理登录相关界面的模型
@interface FKXLoginManager : NSObject

@property (nonatomic,readonly) BOOL isLogin;
@property (nonatomic,readonly) BOOL isFirstLaunch;

@property(nonatomic, strong)SpeakerTabBarViewController * tabBarVC; //方便初始化根视图控制器
@property(nonatomic, strong)ListenerTabBarViewController * tabBarListenerVC; //方便初始化根视图控制器

+ (instancetype)shareInstance;

- (UIViewController *)rootViewController;

- (void)showTabBarController;
- (void)showTabBarListenerController;

- (void)showLoginViewControllerFromViewController:(id)object withSomeObject:(id)someObject;

@end
