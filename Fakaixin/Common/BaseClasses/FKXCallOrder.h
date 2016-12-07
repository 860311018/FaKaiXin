//
//  FKXCallOrder.h
//  Fakaixin
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FKXUserInfoModel;

@class FKXConfirmView;

@class FKXBindPhone;

@interface FKXCallOrder : NSObject

+ (FKXConfirmView *)callOrder:(FKXUserInfoModel *)proModel andVC:(UIViewController *)vc;

+ (FKXBindPhone *)bindPhone:(NSString *)phoneStr andVC:(UIViewController *)vc;

+ (NSInteger )yanzhengCode:(NSString *)phoneStr andVC:(UIViewController *)vc;

+ (NSMutableDictionary *)params:(NSNumber *)listenerId time:(NSNumber *)time totals:(NSNumber *)totals andVC:(UIViewController *)vc;

+ (void)calling:(NSString *)callLength userModel:(FKXUserInfoModel *)userModel proModel:(FKXUserInfoModel *)proModel controller:(UIViewController *)vc;

@end
