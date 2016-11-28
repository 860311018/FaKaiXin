//
//  FKXQingsuVC.h
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    PayType_weChat,
    PayType_Ali,
} PayType;

@interface FKXQingsuVC : FKXBaseViewController

@property(nonatomic, copy)NSDictionary *paraDic;

@property (nonatomic,assign) BOOL showBack;

@property (nonatomic,assign) PayType payType;

@end
