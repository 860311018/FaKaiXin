//
//  AppDelegate.m
//  Fakaixin
//
//  Created by Connor on 10/9/15.
//  Copyright © 2015 FengMi. All rights reserved.
//

#import "AppDelegate.h"
#import "FKXLoginManager.h"
#import "AppDelegate+EaseMob.h"
#import "AppDelegate+FKXBeeCloud.h"
#import "AppDelegate+FKXShareSDK.h"
#import "AppDelegate+FKXUMSDK.h"
#import "FKXUserInfoModel.h"
#import <CoreData/CoreData.h>
#import "FKXChatListController.h"
#import <AdSupport/AdSupport.h>

#import "FKXCommitHtmlViewController.h"
#import "FKXNotificationCenterTableViewController.h"
#import "FKXMyAnswerPageVC.h"
#import "FKXMyAskListPageVC.h"
#import "FKXMyLoveValueController.h"
#import "FKXPersonalViewController.h"
#import "FKXOrderManageController.h"
#import "FKXWorkBenchViewController.h"
#import "Growing.h"

#import "FKXMyOrderVC.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";



//shareSDK
static NSString *const shareAppKey = @"ebe2ab3d75e0";
static NSString *const shareAppSecret = @"4964768dc81efe62d22bacc819ebe162";
//微信
static NSString *const weChatAppID = @"wxbf7526190289f14d";
static NSString *const weChatAppSecret = @"856ceed6c0fcc1826c0a8e6737903af2";
//微博
static NSString *const sinaAppKey = @"2235159571";
static NSString *const sinaAppSecret = @"db33ae8df47f1622eade4ff33e26172d";
//qq
static NSString *const qqAppId = @"1105021488";//转化为16进制 : QQ41DD4A30
static NSString *const qqAppKey = @"rStV05ZaQg0rXkm1";

//BeeCloud
static NSString *const BeeCloudAppId = @"ee3d53f1-c63d-4928-bba3-c16cf1b9a3ba";
//-------------正式环境-------------
//环信
static NSString *const AppKey = @"imfakaixin#online";
static NSString *const ApnsCertName = @"fakaixin_push_distribution";
//友盟推送
static NSString *const UMAppKey = @"567773efe0f55a4a450037cf";
//BeeCloud，需要将beecloud的测试代码改为正式的
static NSString *const BeeCloudAppSecret = @"c2e09ec3-316f-46f6-9583-4bf4c6a62a4e";
////-------------测试环境-------------
////环信
//static NSString *const AppKey = @"imfakaixin#fakaixin";
//static NSString *const ApnsCertName = @"push_dev_fakaixin";
////友盟推送
//static NSString *const UMAppKey = @"567773d4e0f55ad5400026c0";
////BeeCloud，需要将beecloud的测试代码改为正式的
//static NSString *const BeeCloudAppSecret = @"cbd95280-fb7d-4ebc-bcb3-af515b02e88d";//BeeCloudTestSecret

@interface AppDelegate ()<EMChatManagerDelegate>
{
    UIScrollView * welcomeScl;  //欢迎页
    NSDictionary *notifiUserInfo;   //推送消息
    NSDictionary *continueFeeDic;   //需要续费的用户信息
    
    NSDate *endTalkFireDate;
    NSDictionary *launOptions;  //注册通知用的
}
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [UMessage setLogEnabled:YES];
    launOptions = launchOptions;
    //设置未读消息数
    [self setupUnreadMessageCount];
    self.window.backgroundColor = [UIColor whiteColor];

    NSString *idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //将用户的idfa存储到服务器，方便做用户统计
    [AFRequest sendGetOrPostRequest:@"sys/idfa" param:@{@"idfa":idfaStr} requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
//        NSLog(@"data");
    } failure:^(NSError *error) {
        
    }];
    //将用户最后一次登录记录下来，方便做用户统计
    [AFRequest sendGetOrPostRequest:@"user/last_login" param:@{@"uid":@([FKXUserManager shareInstance].currentUserId)} requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        //        NSLog(@"data");
    } failure:^(NSError *error) {
        
    }];
#pragma mark - 注册通知（包含第一次安装启动和以后启动），如果不注册的话，下边调用环信的登录接口是不能成功的，会报appkey无效
    //创建通知alert,第一次启动提示用户开启通知
    if (![[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"isFirstLaunch%@", AppVersionBuild]])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
        [userDefaults setObject:[NSString stringWithFormat:@"isFirstLaunch%@", AppVersionBuild] forKey:[NSString stringWithFormat:@"isFirstLaunch%@", AppVersionBuild]];
        [userDefaults synchronize];
        
        //[self loadWelcomePage];//用户引导页
        //这是为了先展示自定义的通知提醒，
        //这句话放到设置tabbarVC的前边，因为初始化tabbarVC的时候，有用到这个值
        [FKXUserManager setUserPatternToUser];
        [[FKXLoginManager shareInstance] showTabBarController];
    }else{
        //初始化,调用EaseUI对应方法
        [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:AppKey apnsCertName:ApnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
        [self UMSDKWithWithOptions:launchOptions appKey:UMAppKey];
        
        [[FKXLoginManager shareInstance] showTabBarController];
        //将当前模式设置为倾诉者模式
        [FKXUserManager setUserPatternToUser];
    }
    //点击推送消息进入应用后
#pragma mark - ---UMSDK---
    UMConfigInstance.appKey = UMAppKey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
#pragma mark -- GrowingIO --
    // 启动GrowingIO
    
    [Growing startWithAccountId:@"0a1b4118dd954ec3bcc69da5138bdb96"];
    // 其他配置
    // 开启Growing调试日志 可以开启日志
    // [Growing setEnableLog:YES];
#pragma mark - ---shareSDK---
    [self shareSDKRegisterAppByShareAppKey:shareAppKey
                                sinaAppKey:sinaAppKey
                             sinaAppSecret:sinaAppSecret
                                   qqAppId:qqAppId
                                  qqAppKey:qqAppKey
                               weChatAppID:weChatAppID
                           weChatAppSecret:weChatAppSecret];
#pragma mark - ---环信---
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //登录成功调用环信登录
    //在您调用登录方法前，应该先判断是否设置了自动登录，如果设置了，则不需要您再调用
//    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
//    if (!isAutoLogin)
//    {
        NSString *uid = [NSString stringWithFormat:@"%ld",(long)[FKXUserManager shareInstance].currentUserId];
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:uid password:@"fakaixin" completion:^(NSDictionary *loginInfo, EMError *error)
         {
             if (!error && loginInfo) {
                 NSLog(@"登录成功,用户信息:%@", loginInfo);
                 // 设置自动登录
//                 [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                 //获取数据库中数据
                 [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
             }
             if (error) {
                 NSLog(@"登录失败%@", error);
             }
         } onQueue:nil];
//    }
#pragma mark - ---beeCloud---
    [self beeCloudInitWithAppID:BeeCloudAppId appSecret:BeeCloudAppSecret weChatPay:weChatAppID];
#pragma mark - 清除网页缓存
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionNum = [infoDict objectForKey:@"CFBundleVersion"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"myVersion%@", versionNum]]) {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:versionNum forKey:[NSString stringWithFormat:@"myVersion%@", versionNum]];
        [def synchronize];
        //清除cookie
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        //清除webview的缓存
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
//    [NSThread sleepForTimeInterval:10];
     return YES;
}
#pragma mark - 处理通知
//进我答
- (void)someBuyYouService:(NSDictionary *)not
{
    [[FKXLoginManager shareInstance] showTabBarListenerController];
    [FKXUserManager setUserPatternToListener];
    ListenerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarListenerVC;
    tab.selectedIndex = 4;
    FKXBaseNavigationController *nav = [tab.viewControllers lastObject];
    FKXMyAnswerPageVC *vc2 = [[FKXMyAnswerPageVC alloc] init];
    //push的时候隐藏tabbar
    [vc2 setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc2 animated:YES];
}
//进我问
- (void)receiveSomeoneCare:(NSDictionary *)not
{
    //调用震动
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //    NSDictionary *userinfo = not.userInfo;
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 4;
    FKXBaseNavigationController *nav = [tab.viewControllers lastObject];
    FKXMyAskListPageVC *vc2 = [[FKXMyAskListPageVC alloc] init];
    //push的时候隐藏tabbar
    [vc2 setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc2 animated:YES];
}
- (void)goToMyChatList
{
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 4;
    FKXBaseNavigationController *nav = [[tab viewControllers] lastObject];
    FKXChatListController *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXChatListController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc animated:YES];
}
- (void)goToSecondAskVC:(NSDictionary *)dic
{
//    [[FKXLoginManager shareInstance] showTabBarController];
//    [FKXUserManager setUserPatternToUser];
//    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
//    tab.selectedIndex = 0;
//    FKXBaseNavigationController *nav = [[tab viewControllers] firstObject];
  
    [[FKXLoginManager shareInstance] showTabBarListenerController];
    [FKXUserManager setUserPatternToListener];
    ListenerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarListenerVC;
    tab.selectedIndex = 3;
    FKXBaseNavigationController * nav = [[tab viewControllers] lastObject];
    
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.isNeedTwoItem = YES;
    FKXSecondAskModel *model = [[FKXSecondAskModel alloc] init];
    model.worryId = dic[@"data"][@"worryId"];
    model.voiceId = dic[@"data"][@"voiceId"];
    model.text = dic[@"data"][@"worryText"];
    model.listenerHead = dic[@"headUrl"];
//    model.
    //这里都是已经被认可的，直接传1
    vc.pageType = MyPageType_nothing;
    vc.shareType = @"second_ask";
    NSString *paraStr = @"worryId";//默认传worryId
    NSNumber *paraId;
    if (model.worryId) {
        paraId = model.worryId;
    }
    if (model.topicId) {
        paraStr = @"topicId";
        paraId = model.topicId;
    }
    if (model.lqId) {
        paraStr = @"lqId";
        paraId = model.lqId;
    }
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=1&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, model.voiceId, [FKXUserManager shareInstance].currentUserToken];
    vc.secondModel = model;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc animated:YES];
}
- (void)notificationComing
{
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 4;
    FKXBaseNavigationController *nav = [[tab viewControllers] lastObject];
    FKXNotificationCenterTableViewController *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXNotificationCenterTableViewController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc animated:YES];
}
//热门案例（心事）通知过来的展示
- (void)presentView:(NSDictionary *)dic
{
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 0;
    FKXResonance_homepage_model *model = [[FKXResonance_homepage_model alloc] init];
    
    NSString *title = dic[@"aps"][@"alert"];
    if (title && [title containsString:@"每日精选："]) {
        NSRange range = [title rangeOfString:@"每日精选："];
        model.title = [title substringFromIndex:range.location + range.length];
    }else{
        model.title = @"";
    }
    model.background = dic[@"data"][@"background"];
    model.hotId = dic[@"data"][@"hotId"];
    
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"mind";
    vc.pageType = MyPageType_hot;
    vc.urlString = [NSString stringWithFormat:@"%@front/mind_detail.html?shareId=%@&uid=%ld&token=%@",kServiceBaseURL, model.hotId, (long)[FKXUserManager shareInstance].currentUserId,[FKXUserManager shareInstance].currentUserToken];
    vc.resonanceModel = model;
    [vc setHidesBottomBarWhenPushed:YES];
    FKXBaseNavigationController * nav = [tab viewControllers][0];
    [nav pushViewController:vc animated:YES];
}
//评论过来的推送的展示界面
- (void)presentViewForEvaluate:(NSDictionary *)dic
{
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 0;
    FKXSameMindModel *model = [[FKXSameMindModel alloc] init];
    model.text = dic[@"data"][@"text"];
    model.worryId = dic[@"data"][@"worryId"];

    FKXBaseNavigationController * nav = [tab viewControllers][0];
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"comment";
    vc.pageType = MyPageType_nothing;
    vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,model.worryId, (long)[FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    vc.sameMindModel = model;
    [vc setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc animated:YES];
}
//专题过来的推送的展示界面
- (void)showTopicHtml:(NSDictionary *)dic
{
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 1;
    FKXBaseNavigationController * nav = [tab viewControllers][1];
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    FKXCourseModel *model = [[FKXCourseModel alloc] init];
    model.background = dic[@"data"][@"background"];
    model.keyId = dic[@"data"][@"topicId"];
    model.title = dic[@"aps"][@"alert"];
    model.content = @"";
    vc.shareType = @"topic_2";
    vc.pageType = MyPageType_nothing;
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_q_detail.html?topicId=%@&uid=%ld&token=%@",kServiceBaseURL, model.keyId,(long)[FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    vc.courseModel = model;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc animated:YES];
}
- (void)goToMyValue:(NSDictionary *)dic
{
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 4;
    FKXBaseNavigationController *nav = tab.viewControllers[4];
    FKXMyLoveValueController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyLoveValueController"];
    [nav pushViewController:vc animated:YES];
}
- (void)orderComing:(NSDictionary *)dic
{
    [[FKXLoginManager shareInstance] showTabBarListenerController];
    [FKXUserManager setUserPatternToListener];
    ListenerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarListenerVC;
    tab.selectedIndex = 1;
    FKXBaseNavigationController * nav = [tab viewControllers][1];
    
    FKXMyOrderVC *vc = [[FKXMyOrderVC alloc]init];
    vc.isWorkBench = YES;
    [vc setHidesBottomBarWhenPushed:YES];
    [nav pushViewController:vc animated:YES];
}
#pragma mark - 注册通知 MindViewController调用的
- (void)beginRegisterRemoteNot
{
    //之所以加到这里，是因为要稍后才展示请求用户权限的alert，
    //初始化,调用EaseUI对应方法
    [self easemobApplication:[UIApplication sharedApplication] didFinishLaunchingWithOptions:launOptions appkey:AppKey apnsCertName:ApnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    [self UMSDKWithWithOptions:launOptions appKey:UMAppKey];
}
#pragma mark - 加载欢迎页，留着需要的时候用
//- (void)loadWelcomePage
//{
//    if (!welcomeScl) {
//        UIViewController *vc = [[UIViewController alloc] init];
//        welcomeScl = [[UIScrollView alloc] initWithFrame:vc.view.bounds];
//        [vc.view addSubview:welcomeScl];
//        welcomeScl.contentSize = CGSizeMake(welcomeScl.width*3, welcomeScl.height);
//        welcomeScl.pagingEnabled = YES;
//        for (int i = 0; i < 3; i++) {
//            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(welcomeScl.width*i, 0, welcomeScl.width, welcomeScl.height)];
//            iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"img_welcome%d", i+1]];
//            iv.contentMode = UIViewContentModeScaleAspectFit;
//            [welcomeScl addSubview:iv];
//            if (i == 2) {
//                //g按钮
//                iv.userInteractionEnabled = YES;
//                UIButton * gBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//                gBtn.frame = CGRectMake(40, iv.height - 60 - 70, iv.width - 80, 70);
//                gBtn.backgroundColor = [UIColor clearColor];
//                [gBtn addTarget:self action:@selector(hiddenWelcomePage) forControlEvents:UIControlEventTouchUpInside];
//                [iv addSubview:gBtn];
//            }
//        }
//        self.window.rootViewController = vc;
//    }
//}
//- (void)hiddenWelcomePage
//{
//    [[FKXLoginManager shareInstance] showTabBarController];
//    [FKXUserManager setUserPatternToUser];
//}
#pragma mark - appicationDelegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [FKXUserManager shareInstance].deviceTokenData = deviceToken;

    [UMessage registerDeviceToken:deviceToken];
    
    NSString * deviceTokenString = [[[[[FKXUserManager shareInstance].deviceTokenData description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    [FKXUserManager shareInstance].deviceTokenString = deviceTokenString;
    NSLog(@"deviceTokenString:%@", deviceTokenString);

    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:[FKXUserManager shareInstance].deviceTokenData];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //如果注册不成功，打印错误信息，可以在网上找到对应的解决方案
    //如果注册成功，可以删掉这个方法
    NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}
//ios7之后推荐didReceiveRemoteNotification:fetchCompletionHandler方法
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"didReceiveRemoteNotification" message:userInfo.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
//    
//    //关闭友盟自带的弹出框
//    [UMessage setAutoAlert:NO];
//    
//    [UMessage didReceiveRemoteNotification:userInfo];
//}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    notifiUserInfo = userInfo;
    //关闭友盟自带的弹出框
    [UMessage setAutoAlert:NO];
    
    [UMessage didReceiveRemoteNotification:userInfo];
    
    NSInteger notType = [userInfo[@"type"] integerValue];//推送类型
    switch (notType) {
        case notification_type_care://进我问
        {
            if (application.applicationState != UIApplicationStateActive)
            {
                [self receiveSomeoneCare:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 104;
                [alert show];
                SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
                FKXBaseNavigationController *nav = [tab.viewControllers lastObject];
                FKXPersonalViewController *vc = nav.viewControllers[0];
                if (!vc.redViewAsk) {
                    [vc viewDidLoad];
                }
                vc.redViewAsk.hidden = NO;
                [vc loadUnreadRelMe];
            }
        }
            break;
        case notification_type_continue_ask:
        case notification_type_agree:
        case notification_type_people:
        {//进我答
            if (application.applicationState != UIApplicationStateActive)
            {
                [self someBuyYouService:notifiUserInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看",nil];
                alert.tag = 103;
                [alert show];
                
                [FKXLoginManager shareInstance].tabBarListenerVC = nil;//重置set方法，避免值为nil
                FKXBaseNavigationController *nav = [[FKXLoginManager shareInstance].tabBarListenerVC.viewControllers lastObject];
                FKXPersonalViewController *vc = nav.viewControllers[0];
                if (!vc.redViewAnswer) {
                    [vc viewDidLoad];
                }
                vc.redViewAnswer.hidden = NO;
            }
        }
            break;
        case notification_type_hot:
        {//进热门案例
            if (application.applicationState != UIApplicationStateActive) {
                [self presentView:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 100;
                [alert show];
            }
        }
            break;
        case notification_type_listen://偷听要加载与我接口，单独处理
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self goToMyValue:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 101;
                [alert show];
                if ([FKXUserManager isUserPattern]) {
                    FKXBaseNavigationController *nav = [[FKXLoginManager shareInstance].tabBarVC.viewControllers lastObject];
                    FKXPersonalViewController *vc = nav.viewControllers[0];
                    if (!vc.redViewAnswer) {
                        [vc viewDidLoad];
                    }
                    vc.redViewAnswer.hidden = NO;
                    [vc loadUnreadRelMe];
                }else{
                    FKXBaseNavigationController *nav = [[FKXLoginManager shareInstance].tabBarListenerVC.viewControllers lastObject];
                    FKXPersonalViewController *vc = nav.viewControllers[0];
                    if (!vc.redViewAnswer) {
                        [vc viewDidLoad];
                    }
                    vc.redViewAnswer.hidden = NO;
                    [vc loadUnreadRelMe];
                }
            }
        }
            break;
        case notification_type_refund:
        case notification_type_praise:
        case notification_type_reward://进我的财富查看，
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self goToMyValue:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 101;
                [alert show];
            }
        }
            break;
        case notification_type_evaluate:
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self presentViewForEvaluate:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 105;
                [alert show];
                
                if ([FKXUserManager isUserPattern]) {
                    FKXBaseNavigationController *nav = [[FKXLoginManager shareInstance].tabBarVC.viewControllers lastObject];
                    FKXPersonalViewController *vc = nav.viewControllers[0];
                    if (!vc.redViewAnswer) {
                        [vc viewDidLoad];
                    }
                    [vc loadUnreadRelMe];
                }else{
                    FKXBaseNavigationController *nav = [[FKXLoginManager shareInstance].tabBarListenerVC.viewControllers lastObject];
                    FKXPersonalViewController *vc = nav.viewControllers[0];
                    if (!vc.redViewAnswer) {
                        [vc viewDidLoad];
                    }
                    [vc loadUnreadRelMe];
                }
            }
        }
            break;
        case notification_type_topic:
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self showTopicHtml:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 106;
                [alert show];
            }
        }
            break;
        case notification_type_order_coming:
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self orderComing:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 107;
                [alert show];
                
                ListenerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarListenerVC;
                tab.selectedIndex = 1;
                FKXBaseNavigationController * nav = [tab viewControllers][1];
                FKXWorkBenchViewController *vc = [nav viewControllers][0];
                [vc loadUnreadRelMe];
            }
        }
            break;
        case notification_type_order_is_accepted://谁谁接受了你的订单，请查看，
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self goToMyChatList];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"notification_type_end_talk" object:@""];
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 108;
                [alert show];
            }
        }
            break;
        case notification_type_end_talk:
        {

            if (application.applicationState != UIApplicationStateActive) {
                [self notificationComing];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:nil cancelButtonTitle:@"朕知道了~" otherButtonTitles:nil];
                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"notification_type_end_talk" object:@""];
            }
        }
            break;
        case notification_type_agree_by_another:
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self goToSecondAskVC:userInfo];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 109;
                [alert show];
            }
        }
            break;
        default:
        {
            if (application.applicationState != UIApplicationStateActive) {
                [self notificationComing];
            }else{
                UIAlertView * alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"] message:nil delegate:self cancelButtonTitle:@"忽略此消息" otherButtonTitles:@"去看看", nil];
                alert.tag = 102;
                [alert show];
            }
        }
            break;
    }
    
    // 在此方法中一定要调用completionHandler这个回调，告诉系统是否处理成功
    
//    UIBackgroundFetchResultNewData, // 成功接收到数据
//    UIBackgroundFetchResultNoData,  // 没有接收到数据
//    UIBackgroundFetchResultFailed   // 接受失败
    if (userInfo) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
    
//    NSError *parseError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
//    
//    NSString *userString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"applicationIconBadgeNumber"];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //判断当推送到来之后，”我问“和”我答是否要展示未读红点“
    switch ([UIApplication sharedApplication].applicationIconBadgeNumber) {
        case 1://1,我问
        {
            FKXBaseNavigationController *nav = [[FKXLoginManager shareInstance].tabBarVC.viewControllers lastObject];
            FKXPersonalViewController *vc = nav.viewControllers[0];
            if (!vc.redViewAsk) {
                [vc viewDidLoad];
            }
            vc.redViewAsk.hidden = NO;
            [vc loadUnreadRelMe];
        }
            break;
        case 2://，2我答
        {
            [FKXLoginManager shareInstance].tabBarListenerVC = nil;//重置set方法，避免值为nil
            FKXBaseNavigationController *nav = [[FKXLoginManager shareInstance].tabBarListenerVC.viewControllers lastObject];
            
            FKXPersonalViewController *vc = nav.viewControllers[0];
            if (!vc.redViewAnswer) {
                [vc viewDidLoad];
            }
            vc.redViewAnswer.hidden = NO;
            [vc loadUnreadRelMe];
        }
            break;
        default:
            break;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}
#pragma mark - alertViewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    [UMessage sendClickReportForRemoteNotification:nil];
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        switch (alertView.tag) {
            case 100://热门
                [self presentView:notifiUserInfo];
                break;
            case 101://财富
                [self goToMyValue:notifiUserInfo];
                break;
            case 102://系统
                [self notificationComing];
                break;
            case 103://我答
                [self someBuyYouService:notifiUserInfo];
                break;
            case 104://我问
                [self receiveSomeoneCare:notifiUserInfo];
                break;
            case 105://评价
                [self presentViewForEvaluate:notifiUserInfo];
                break;
            case 106://专题
                [self showTopicHtml:notifiUserInfo];
                break;
            case 107://订单来了
                [self orderComing:notifiUserInfo];
                break;
            case 108:
                [self goToMyChatList];
                break;
            case 109://被其他人认可了
                [self goToSecondAskVC:notifiUserInfo];
                break;
            default:
                break;
        }
    }
}
#pragma mark - 为保证从支付宝，微信返回本应用，须绑定openUrl
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![BeeCloud handleOpenUrl:url]) {
        //handle其他类型的url
    }
    if ([Growing handleUrl:url])
    {
        return YES;
    }
    return NO;
}
//iOS9之后apple官方建议使用此方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    if (![BeeCloud handleOpenUrl:url]) {
        //handle其他类型的url
    }
    if ([Growing handleUrl:url])
    {
        return YES;
    }
    return NO;
}
#pragma mark - 环信逻辑处理
/*!
 @method
 @brief 用户将要进行自动登录操作的回调
 @discussion
 @param loginInfo 登录的用户信息
 @param error     错误信息
 @result
 */

//- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
//{
//    alertAutoLogin =[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"正在自动登录中..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [alertAutoLogin show];
//}
/*!
 @method
 @brief 用户自动登录完成后的回调
 @discussion
 @param loginInfo 登录的用户信息
 @param error     错误信息
 @result
 */
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    //获取数据库中数据
    [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
    //加载到数据后,重新给未读badge赋值
    [self setupUnreadMessageCount];
    
//    NSLog(@"didAuto自动登录信息:%@,错误信息:%@", loginInfo, error);
}
/*!
 @method
 @brief 当前登录账号在其它设备登录时的通知回调
 @discussion
 @result
 */
//- (void)didLoginFromOtherDevice
//{
//    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的账号已在其它设备登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
//}
#pragma mark -
#pragma mark - 环信收到消息 EMChatManagerChatDelegate
- (void)didReceiveMessage:(EMMessage *)message
{
    //收到消息发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fkxReceiveEaseMobMessage" object:nil];
    BOOL needShowNotification = (message.messageType != eMessageTypeChat) ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        //是否提示响音
        //        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        //        if (!isAppActivity) {
        //            [self showNotificationWithMessage:message];
        //        }else {
        //            [self playSoundAndVibration];
        //        }
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        switch (state) {
//            case UIApplicationStateActive:
//                [self playSoundAndVibration];
//                break;
            case UIApplicationStateInactive:
                [self playSoundAndVibration];
                break;
            case UIApplicationStateBackground:
                [self showNotificationWithMessage:message];
                break;
            default:
                break;
        }
#endif
    }
    
    [self setupUnreadMessageCount];
}
- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        NSString *title = @"未知了";//[[UserProfileManager sharedInstance] getNickNameWithUsername:message.from];
        if (message.messageType == eMessageTypeGroupChat) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        else if (message.messageType == eMessageTypeChatRoom)
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username" ]];
            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
            NSString *chatroomName = [chatrooms objectForKey:message.conversationChatter];
            if (chatroomName)
            {
                title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, chatroomName];
            }
        }
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.messageType] forKey:kMessageType];
    [userInfo setObject:message.conversationChatter forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    return ret;
}
#pragma mark - -统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
        //遍历会话列表,获取用户最新信息
        EMMessage *message = conversation.latestMessage;
        [self insertDataToTableWith:message];
    }
    if (unreadCount > 0)
    {
        [FKXUserManager shareInstance].unReadEaseMobMessage = @(unreadCount);
        _conversationListVCListener.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", unreadCount];
    }else{
        [FKXUserManager shareInstance].unReadEaseMobMessage = @(0);
        _conversationListVCListener.tabBarItem.badgeValue = nil;
    }
}
// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}
- (void)insertDataToTableWith:(EMMessage *)message
{
    NSError *fetchError;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"ChatUser"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray * fetchArray = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    BOOL isContains = NO;
    for (ChatUser *user in fetchArray)
    {
        if (message.messageType == eMessageTypeGroupChat) {
            if ([user.userId isEqualToString:message.groupSenderName])
            {
                isContains = YES;
                
                user.avatar = message.ext[@"head"];
                user.nick = message.ext[@"name"];
                break;
            }
        }else if (message.messageType == eMessageTypeChat){
            if ([user.userId isEqualToString:message.from])
            {
                isContains = YES;
                
                user.avatar = message.ext[@"head"];
                user.nick = message.ext[@"name"];
                break;
            }
        }
        
    }
    if (!isContains)
    {
        //遍历会话列表,获取用户最新信息
        ChatUser *chatUser = [NSEntityDescription insertNewObjectForEntityForName:@"ChatUser" inManagedObjectContext:self.managedObjectContext];
        
        if (message.messageType == eMessageTypeGroupChat) {
            chatUser.userId = message.groupSenderName;
        }else if (message.messageType == eMessageTypeChat){
            chatUser.userId = message.from;
        }
        chatUser.avatar = message.ext[@"head"];
        chatUser.nick = message.ext[@"name"];
    }
    //保存数据库
    [self saveContext];
}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.lsn.Fakaixin" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Fakaixin" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fakaixin.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
