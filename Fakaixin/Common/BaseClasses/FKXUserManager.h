//
//  FKXUserManager.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/23.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AFRequest.h"
@class FKXUserInfoModel;
//用户相关的模型
@interface FKXUserManager : AFRequest

//当前用户uid
@property (nonatomic, assign) NSInteger  currentUserId;
//当前用户token
@property (nonatomic, copy) NSString<Optional>  * currentUserToken;
//当前用户deviceToken
@property (nonatomic, copy) NSString<Optional>  * deviceTokenString;
@property (nonatomic, copy) NSData<Optional>  * deviceTokenData;
//当前用户密码
@property(nonatomic, copy)NSString * currentUserPassword;
@property(nonatomic, copy)NSString * inviteCode;    //邀请码
@property (nonatomic,assign) BOOL isSpeaking;
@property (nonatomic,assign) BOOL isListening;
@property(nonatomic, strong)NSNumber * noReadOrder;//“关怀列表”中加载的最新时间
@property(nonatomic, strong)NSNumber * noReadFangke;//“工作台”中加载的最新时间

@property(nonatomic, strong)NSNumber * unreadRelMe;//“我”中未读动态的最新一条time
@property(nonatomic, strong)NSNumber * unAcceptOrderTime;//“工作台”中查看未接单的最新时间
@property(nonatomic, strong)NSNumber * unReadNotification;//“消息-通知”中查看未读的信息
@property(nonatomic, strong)NSNumber * unReadEaseMobMessage;//环信未读消息,用于每个界面右上角展示未读几条
#pragma mark - 用户相关
//初始化单例
+ (instancetype)shareInstance;

//是否是倾诉者模式
+(BOOL)isUserPattern;
//将模式置为倾诉者
+(void)setUserPatternToUser;
//将模式置为倾听者
+(void)setUserPatternToListener;
//获取存在本地的用户信息model
+(FKXUserInfoModel *)getUserInfoModel;
//是否需要登录
+(BOOL)needShowLoginVC;

//
-(NSArray *)caluteHeight:(FKXUserInfoModel *)model;

/**
 *  是否登录
 *
 *  @return 
 */
- (BOOL)isLogin;

/**
 *  归档信息
 *
 *  @param object   归档的对象
 *  @param fileName 归档的文件名字
 */
+(void)archiverUserInfo:(id)object
                  toUid:(NSString *)Uid;

/**
 *  用户退出登录
 */
+ (void)userLogout;

#pragma mark - 用户指引
/**
 *  展示用户指引
 *
 *  @param key    图片名字
 *  @param target
 *  @param action
 */
+ (void)showUserGuideWithKey:(NSString *)key withTarget:(id)target action:(SEL)action;

/**
 *  展示用户指引
 *
 *  @param key 图片名字
 */
+ (void)showUserGuideWithKey:(NSString *)key;
@end
