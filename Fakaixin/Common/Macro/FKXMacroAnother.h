//
//  FKXMacroAnother.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#ifndef FKXMacroAnother_h
#define FKXMacroAnother_h

#define is_iPhone6P [UIScreen mainScreen].bounds.size.width == 414 ? YES : NO
#define is_iPhone6 [UIScreen mainScreen].bounds.size.width == 375 ? YES : NO
#define is_iPhone5 [UIScreen mainScreen].bounds.size.width == 320 ? YES : NO

//URL
//#define kServiceBaseURL @"http://101.200.196.71:8200/"
#define kServiceBaseURL @"http://api.imfakaixin.com/"
//七牛裁切图片，以宽50，高等比裁切
#define cropImageW @"?imageView2/2/w/300"
#define voiceBaseUrl @"http://7xrrm3.com1.z0.glb.clouddn.com/"
#define imageBaseUrl @"http://7xrrm3.com2.z0.glb.qiniucdn.com/"
#define kProtocolUser @"http://www.imfakaixin.com/regu.html"
#define kProtocolListener @"http://www.imfakaixin.com/reg.html"
#define kProtocolHowToBeGoodListener @"http://www.imfakaixin.com/ueg.html"

//基本值
#define kToken [FKXUserManager shareInstance].currentUserToken
#define kRequestSize 10

//#define kMinPaySuccAutoRefundDeadLine 25  //从支付咨询服务成功开始,设置最晚x分钟的回复时间间隔,如果倾诉者没超过这个间隔就回复倾诉者了,,那么就取消自动退款的通知,,如果期间没回复的话,当触发自动退款通知的时候,还要把续费提现的通知也去了
////#define kMinToContinueFee 55  //x分钟后,续费提醒
//#define kMinAutoEnd 60   //x分钟后,由于没有续费就自动结束会话

//登录、注册或者退出成功后的通知
#define kNotificationLoginSuccessAndNeedRefreshAllUI @"kNotificationLoginSuccessAndNeedRefreshAllUI"

#define QianDaoBack @"QianDaoBack"

//类
#import "FKXBaseTableViewController.h"
#import "FKXBaseViewController.h"
#import "UMessage.h"
#import "SecurityUtil.h"
#import "FKXBaseNavigationController.h"
#import "ChatUser.h"
#import "ChatUser+CoreDataProperties.h"
#import "AppDelegate.h"
#import "FKXEmptyData.h"


#endif /* FKXMacroAnother_h */
