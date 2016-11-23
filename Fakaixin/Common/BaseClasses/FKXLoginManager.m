//
//  FKXLoginManager.m
//  Fakaixin
//
//  Created by Connor on 10/16/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXLoginManager.h"
#import "AppDelegate.h"
#import "FKXLoginViewController.h"

@interface FKXLoginManager ()
{
    UIViewController *viewControllerToBack;
}
@end

@implementation FKXLoginManager

+ (instancetype)shareInstance {
 
    static FKXLoginManager *_loginManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _loginManager = [[FKXLoginManager alloc] init];
    });
    return _loginManager;
}

- (BOOL)isLogin {

    return NO;
}

- (BOOL)isFirstLaunch {
    return NO;
}

- (UIViewController *)rootViewController
{
    NSString *storyboardID = @"FKXLoginViewController";
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:storyboardID];
}

- (void)showTabBarController {
//    __block SpeakerTabBarViewController *vc;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        vc = [[SpeakerTabBarViewController alloc] init];
//        _tabBarVC = vc;
//    });
    if (!_tabBarVC) {
        _tabBarVC = [[SpeakerTabBarViewController alloc] init];
    }
    ApplicationDelegate.window.rootViewController = _tabBarVC;
    [ApplicationDelegate.window makeKeyAndVisible];
}
- (void)showTabBarListenerController {
//    __block ListenerTabBarViewController *vc;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        vc = [[ListenerTabBarViewController alloc] init];
//        _tabBarListenerVC = vc;
//    });
    if (!_tabBarListenerVC) {
        _tabBarListenerVC = [[ListenerTabBarViewController alloc] init];
    }
    ApplicationDelegate.window.rootViewController = _tabBarListenerVC;
    [ApplicationDelegate.window makeKeyAndVisible];
}
-(void)setTabBarVC:(SpeakerTabBarViewController *)tabBarVC
{
    if (!_tabBarVC) {
        _tabBarVC = [[SpeakerTabBarViewController alloc] init];
    }
    _tabBarVC = tabBarVC;
}
-(void)setTabBarListenerVC:(ListenerTabBarViewController *)tabBarListenerVC
{
    if (!_tabBarListenerVC) {
        _tabBarListenerVC = [[ListenerTabBarViewController alloc] init];
    }
    _tabBarListenerVC = tabBarListenerVC;
}
- (void)showLoginViewControllerFromViewController:(id)object withSomeObject:(id)someObject
{
    FKXLoginViewController *viewC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXLoginViewController"];
    viewC.someObject = someObject;
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:viewC];
    
    [object presentViewController:nav animated:YES completion:nil];
}

@end
