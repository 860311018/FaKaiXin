//
//  HYBJsObjCModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/5/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKXCommitHtmlViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "FKXCustomAcceptHtmlVC.h"

@protocol JavaScriptObjectiveCDelegate <JSExport>

- (void)clickHotPraise:(NSString *)str;//点击热门赞赏
- (void)userClickedSendBarrage; //用来判断是否需要登录
- (void)getTheInnerUserInfo:(NSString *)str;    //获取内层用户信息
//个人被提问调用支付，支付成功刷新界面
- (void)someOneAskedMeAQuestion:(NSString *)str;
//专题，我也来答
- (void)IAlseComeToAnswerTheQuestion;
//享问详情，赞赏
- (void)rewordForTheSecondAskDetail:(NSString *)str;
//付费听
- (void)payForVoice:(NSString *)str;

//播放完毕后回调我们方法,
- (void)userDidFinishPlayingTheVoice;
//h5种点击头像跳转到客服端写的个人动态主页
- (void)goToPersonalDynamicPage:(NSString *)str;
@end

//与h5交互的模型
@interface HYBJsObjCModel : NSObject<JavaScriptObjectiveCDelegate>
// 此模型用于注入JS的模型，这样就可以通过模型来调用方法。
@property(nonatomic, weak)JSContext * jsContext;
@property(nonatomic, weak)UIWebView * webView;//为了不产生循环引用，用weak
@property(nonatomic, weak)FKXCommitHtmlViewController *commitVC;
@property(nonatomic, weak)FKXCustomAcceptHtmlVC *customAcceptVC;


@end
