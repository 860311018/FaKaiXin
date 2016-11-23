//
//  FKXCommitHtmlViewController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//


#import "FKXResonance_homepage_model.h"
#import "FKXCourseModel.h"
#import "FKXUserInfoModel.h"
#import "FKXSameMindModel.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "FKXSecondAskModel.h"

//BUY_TALK(0),//购买聊天 buz_id:talkId
//RENEW_TALK(1),//续费聊天 buz_id:talkId
//REWARD(2),//打赏 buz_id:listenerId
//REFUND(3),//退款

//REWARD_SHARE(4),//热门打赏
//BUY_COURSE(5),//购买课程
//BUY_VOICE(6),   //购买秒问语音
//PRAISE_MONEY(7), //秒问赞赏
//TO_LISTENER_QUESTION(8), //向倾听者提问
//ACCEPT_VOICE(9);  // 认可

typedef enum : NSUInteger {
    MyPageType_hot,         //热门文章的打赏
    MyPageType_course,      //课程的支付
    MyPageType_people,      //个人主页的提问
    MyPageType_ask_praise,  //享问的赞赏
    MyPageType_ask_listen,   //享问的偷听
    MyPageType_consult,//一对一咨询
    MyPageType_agree,//语音认可
    MyPageType_nothing  //只是个标示，相当于default
} MyPageType;//进来的页面类型,用来对不同的支付页面做不同的处理

//加载h5界面的webview
@interface FKXCommitHtmlViewController : FKXBaseViewController

@property(nonatomic, copy)NSString * urlString; //加载的h5链接
@property(nonatomic, assign)BOOL isNeedTwoItem; //是否需要两个item
//@property(nonatomic, assign)BOOL showAgreeBtn;//（未认可的情况下）navbar展示感谢按钮

@property(nonatomic, assign)MyPageType pageType;
@property(nonatomic, strong)JSContext * jsContext;
@property(nonatomic, strong)UIWebView *myWebView;
@property(nonatomic, strong)FKXResonance_homepage_model * resonanceModel;   //心事列表(以前叫共鸣列表,热门案例)的model
@property(nonatomic, strong)FKXSameMindModel * sameMindModel;
@property(nonatomic, strong)FKXCourseModel * courseModel;   //课程,分享会,专题列表的model
@property(nonatomic, strong)FKXUserInfoModel *userModel;    //金牌倾听者,心理咨询师列表的model（uid，head，name，price）
@property(nonatomic, copy)NSString * shareType; //分享的类型
@property(nonatomic, strong)FKXSecondAskModel * secondModel;

//调第三方支付前获取订单号，返回字段加入isAmple： 0余额不足，1余额充足
@property(nonatomic, strong)NSMutableDictionary  * payParameterDic;    //支付的参数


//选择金额
- (void)createcustomPopView;
// 跳转到 “我也来答” 的界面（语音回复）
- (void)goToCareDetailVC;
//购买服务，支付个人界面
- (void)goToPayService;
//开通秒问
- (void)openSecondAsk;
//h5种点击头像跳转到客服端写的个人动态主页
- (void)goToPersonalDynamicPageWithUid:(NSNumber *)uid;
@end
