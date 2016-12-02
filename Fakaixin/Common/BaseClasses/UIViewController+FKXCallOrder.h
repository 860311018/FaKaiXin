//
//  UIViewController+FKXCallOrder.h
//  Fakaixin
//
//  Created by apple on 2016/12/2.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    PayType_weChat,
    PayType_Ali,
} PayType;

@class FKXUserInfoModel;

@interface UIViewController (FKXCallOrder)

-(void)callOrder:(FKXUserInfoModel *)model;


@end
