//
//  FKXCommitHtmlViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXCommitHtmlViewController.h"
#import "FKXChooseMoneyView.h"
#import "ChatViewController.h"
#import "HYBJsObjCModel.h"
#import "FKXBaseShareView.h"
#import "FKXPayView.h"
#import "FKXCareDetailController.h"
#import "FKXOpenSecondAskController.h"
#import "FKXProfessionInfoVC.h"

@interface FKXCommitHtmlViewController ()<UIWebViewDelegate,BeeCloudDelegate, UIAlertViewDelegate>
{
    FKXChooseMoneyView *customPopView;
    UIView *transparentView;    //弹出支付金额的
    NSString *btnTitle;
    NSString *groupId;
    
    UIView *transViewPay;   //支付的透明图
    FKXPayView *payView;    //支付界面
    
    NSString *currendReqUrlStr;//当前请求的url(已截取掉token)
    
    NSString *alertStr;//支付成功的提示，需要展示后台返回的
}

@end

@implementation FKXCommitHtmlViewController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccessAndNeedRefreshAllUI object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_pageType == MyPageType_hot) {
        NSString *imageName = @"user_guide_click_barrage_6";
        [FKXUserManager showUserGuideWithKey:imageName withTarget:self  action:@selector(hiddenGuide:)];
    }
}
//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
////    [_myWebView stopLoading];
//    _myWebView = nil;
//    _jsContext = nil;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    //登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessAndNeedRefreshAllUI:) name:kNotificationLoginSuccessAndNeedRefreshAllUI object:nil];

    //设置支付代理
    [BeeCloud setBeeCloudDelegate:self];
    //ui赋值
    self.view.backgroundColor = [UIColor whiteColor];
    self.navTitle = @"详情";
    
    //创建ui
    [self createRightBarButtonItem];
    //web请求
    _myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64)];
    _myWebView.delegate = self;
    _myWebView.backgroundColor = kColorBackgroundGray;
    [self.view addSubview:_myWebView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [_myWebView loadRequest:request];
    
    NSMutableString * mutS = [NSMutableString stringWithString:_urlString];
    currendReqUrlStr = [mutS substringToIndex:[mutS rangeOfString:@"&token="].location]
    ;
}
//重写类目中点击用户指引的方法

- (void)hiddenGuide:(UITapGestureRecognizer *)tap
{
    [tap.view removeFromSuperview];
 
    NSString *imageName = @"user_guide_open_barrage_6";
    [FKXUserManager showUserGuideWithKey:imageName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"内存警告");
}
#pragma mark - 通知
- (void)loginSuccessAndNeedRefreshAllUI:(NSNotification *)not
{
//    [_myWebView reload];
    [_myWebView stopLoading];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UIWebViewDelegate 代理
//获取它加载的网页上面的事件，比如单击了图片，单击了按钮等等。
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"请求的url：%@", [request URL]);
    //触击了一个链接
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL * url = [request URL];
        NSString * string = [url absoluteString];
        NSString * url2 = [[string componentsSeparatedByString:@"?"] lastObject];
        NSString *gId = [[string componentsSeparatedByString:@"="] lastObject];//获取groupid
        //截取除了token的链接
        NSMutableString *mutS = [NSMutableString string];
        NSString * urlHeader = [[string componentsSeparatedByString:@"?"] firstObject];
        [mutS appendFormat:@"%@?", urlHeader];
        NSArray *arr = [url2 componentsSeparatedByString:@"&"];
        for (NSString *subS in arr) {
            if (![subS containsString:@"token"]) {
                [mutS appendFormat:@"%@&", subS];
            }
        }
        currendReqUrlStr = [mutS substringToIndex:mutS.length - 1];
        NSLog(@"请求的str：%@", currendReqUrlStr);
        if ([url2 containsString:@"#course"]) {//购买课程，有门槛，需要调接口
            groupId = gId;
            [self goToPayCourse];
        }else if ([url2 containsString:@"#session"]) {//分享会，有门槛，需要调接口
            groupId = gId;
            [self goToSession];
        }else if ([url2 containsString:@"#pay"]) {//购买服务
            [self bookConsultService];
        }
    }else if(navigationType == UIWebViewNavigationTypeBackForward)
    {
        NSURL * url = [request URL];
        NSString * string = [url absoluteString];
        NSString * url2 = [[string componentsSeparatedByString:@"?"] lastObject];
        //截取除了token的链接
        NSMutableString *mutS = [NSMutableString string];
        NSString * urlHeader = [[string componentsSeparatedByString:@"?"] firstObject];
        [mutS appendFormat:@"%@?", urlHeader];
        NSArray *arr = [url2 componentsSeparatedByString:@"&"];
        for (NSString *subS in arr) {
            if (![subS containsString:@"token"]) {
                [mutS appendFormat:@"%@&", subS];
            }
        }
        currendReqUrlStr = [mutS substringToIndex:mutS.length - 1];
        NSLog(@"请求的str：%@", currendReqUrlStr);
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideHud];
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 通过模型调用方法，这种方式更好些。
    HYBJsObjCModel *model  = [[HYBJsObjCModel alloc] init];
    model.commitVC = self;
    self.jsContext[@"OCModel"] = model;
    model.jsContext = self.jsContext;
    model.webView = _myWebView;
//    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
//        context.exception = exceptionValue;
//        NSLog(@"异常信息：%@", exceptionValue);
//    };
//    NSString *str = @"我想调用你的方法，给你传值";
//    [self.jsContext evaluateScript:[NSString stringWithFormat:@"getTextareaResult(%@)", str]];

    //    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error
{
    [self hideHud];
}
#pragma  mark - 专题我也来答
// 跳转到 “我也来答” 的界面（语音回复）专题
- (void)goToCareDetailVC
{
    FKXCareDetailController *vc = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXCareDetailController"];
    vc.careDetailType = care_detail_type_special;
    vc.courseModel = _courseModel;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)openSecondAsk
{
    FKXOpenSecondAskController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXOpenSecondAskController"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    vc.isShowClose = YES;
    vc.isOpen = YES;
    vc.userModel = [FKXUserManager getUserInfoModel];
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark - 进个人主页
//h5种点击头像跳转到客服端写的个人动态主页
- (void)goToPersonalDynamicPageWithUid:(NSNumber *)uid
{
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = uid;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 事件
- (void)goToPayCourse
{
    if ([FKXUserManager needShowLoginVC])
    {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
    }else
    {
        if (![WXApi isWXAppInstalled]) {
            [self showHint:@"当前不在线"];
            return;
        }
        
        EMError *errOcc;
        NSArray *occus = [[EaseMob sharedInstance].chatManager fetchOccupantList:groupId error:&errOcc];
        NSString *uid = [NSString stringWithFormat:@"%ld",(long)[FKXUserManager shareInstance].currentUserId];
        BOOL isCon = [occus containsObject:uid];
        if (isCon)
        {
            //进入群组
            ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
            [self.navigationController pushViewController:chatController animated:YES];
        }else{
             [self buyCourse];
        }
    }
}
//购买课程
- (void)buyCourse
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_courseModel.keyId forKey:@"courseId"];
    [paramDic setValue:_courseModel.uid forKey:@"uid"];
    [paramDic setValue:@([_courseModel.expectCost doubleValue]) forKey:@"price"];
    
    NSString *methodName = @"course/pay";
    [self showHudInView:self.view hint:@"正在确认"];
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
             [_payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
             CGFloat money = [data[@"data"][@"money"] floatValue];
             [_payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
             NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
             [_payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
             //创建购买界面
             [self setUpTransViewPay];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
             
         }
     } failure:^(NSError *error) {
         [self hideHud];
         [self showHint:@"网络出错"];
     }];
}
- (void)goToSession
{
    if ([FKXUserManager needShowLoginVC])
    {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
    }else
    {
        EMError *errOcc;
        NSArray *occus = [[EaseMob sharedInstance].chatManager fetchOccupantList:groupId error:&errOcc];
        NSString *uid = [NSString stringWithFormat:@"%ld",(long)[FKXUserManager shareInstance].currentUserId];
        BOOL isCon = [occus containsObject:uid];
        if (isCon)
        {
            //进入群组
            ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
            [self.navigationController pushViewController:chatController animated:YES];
        }else{
            [self meetingValidation];
        }
    }
}
- (void)meetingValidation
{
    [self showHudInView:self.view hint:@"正在预约"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_courseModel.keyId forKey:@"meetId"];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"uid"];
    NSString *methodName = @"meeting/validation";
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             NSString *sta = data[@"data"][@"status"];
             if ([sta integerValue] != 0)
             {
                 //进入群组
                 ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                 [self.navigationController pushViewController:chatController animated:YES];
             }else{
                 //支付爱心值或者分享朋友圈
                 UIAlertController *alV = [UIAlertController alertControllerWithTitle:@"支付爱心值或者分享到朋友圈，就可以参加分享会" message:nil preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"支付爱心值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                 {
                     [self validWithType:1 methodName:@"meeting/validation" para:@"meetId"];
                 }];
                 UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"分享到朋友圈" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                 {
                     NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                     NSArray* imageArray = @[[NSURL URLWithString:_courseModel.background]];
                     
                     [shareParams SSDKSetupShareParamsByText:_courseModel.title
                                                      images:imageArray
                      
                                                         url:[NSURL URLWithString:[NSString stringWithFormat:@"%@front/discovery.html?keyId=%@&uid=%@", kServiceBaseURL,_courseModel.keyId, _courseModel.uid] ]
                                                       title:[NSString stringWithFormat:@"免费分享会|%@", _courseModel.title]
                                                        type:SSDKContentTypeAuto];
                     //单个分享
                     SSDKPlatformType type = SSDKPlatformSubTypeWechatTimeline;
                     //单个分享
                     [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                         switch (state) {
                             case SSDKResponseStateSuccess:
                             {
//                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                     message:nil
//                                                                                    delegate:nil
//                                                                           cancelButtonTitle:@"确定"
//                                                                           otherButtonTitles:nil];
//                                 [alertView show];
                                 [self validWithType:2 methodName:@"meeting/validation" para:@"meetId"];
                                 break;
                             }
                             case SSDKResponseStateFail:
                             {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil, nil];
                                 [alert show];
                                 break;
                             }
                             default:
                                 break;
                         }
                         
                     }];
                 }];
                 [alV addAction:ac1];
                 [alV addAction:ac2];
                 
                 [self presentViewController:alV animated:YES completion:nil];
             }
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
/*
- (void)courseValidation
{
    [self showHudInView:self.view hint:@"正在预约"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_courseModel.keyId forKey:@"courseId"];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"uid"];
    NSString *methodName = @"course/validation";
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             NSString *sta = data[@"data"][@"status"];
             if ([sta integerValue] != 0) {
                 //进入群组
                 ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                 [self.navigationController pushViewController:chatController animated:YES];
             }else{
                 //购买课程或分享三个好友
                 UIAlertController *alV = [UIAlertController alertControllerWithTitle:@"支付金钱或者邀请三个好友进入伐开心，就可以参加课程" message:nil preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"支付金钱" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                 {
                     
                 }];
                 UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"邀请3个好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     NSString *urlStr;
                     if ([FKXUserManager shareInstance].inviteCode) {
                         urlStr = [NSString stringWithFormat:@"%@front/share.html?inviteCode=%@", kServiceBaseURL,[FKXUserManager shareInstance].inviteCode];
                     }else{
                         urlStr = [NSString stringWithFormat:@"%@front/share.html", kServiceBaseURL];
                     }
                     FKXBaseShareView *shareV = [[FKXBaseShareView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrlStr:@"" urlStr:urlStr title:@"如何安全优雅地呵呵" text:@"安抚你的小情绪"];
                     [shareV createSubviews];
//                     [self clickShareToThirdPlatformWithImageName:@"" title:@"如何安全优雅地呵呵" content:@"安抚你的小情绪" url:urlStr eventId:@"click_share_btn_visit_friend_successfully"];
                 }];
                 [alV addAction:ac1];
                 [alV addAction:ac2];
                 [self presentViewController:alV animated:YES completion:nil];
             }
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}*/
//分享会或者课程认证
- (void)validWithType:(NSInteger)type methodName:(NSString *)methodName para:(NSString *)para
{
    [self showHudInView:self.view hint:@"正在预约..."];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_courseModel.keyId forKey:para];
    [paramDic setValue:_courseModel.uid forKey:@"uid"];
    [paramDic setValue:@(type) forKey:@"type"];
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             //申请加入
             EMError *errGro;
             [[EaseMob sharedInstance].chatManager joinPublicGroup:groupId error:&errGro];
             NSLog(@"验证之后申请失败：%@", errGro);
             if (!errGro)
             {
                 //进入群组
                 ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                 [self.navigationController pushViewController:chatController animated:YES];
             }
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
#pragma mark - UI navigation bar
- (void)createRightBarButtonItem
{
    if (_isNeedTwoItem) {
//        UIImage * image = [UIImage imageNamed:@"btn_share"];
//        UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
//        [rightBarBtn setImage:image forState:UIControlStateNormal];
//        [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage * image2 = [UIImage imageNamed:@"btn_comments_new"];
        UIButton * rightBarBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image2.size.width, image2.size.height)];
        [rightBarBtn2 setImage:image2 forState:UIControlStateNormal];
        [rightBarBtn2 setTitle:self.commentStr forState:UIControlStateNormal];
        rightBarBtn2.titleLabel.font = [UIFont systemFontOfSize:15];
        [rightBarBtn2 setTitleColor:kColorMainRed forState:UIControlStateNormal];
        [rightBarBtn2 addTarget:self action:@selector(clickCommit) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn2];
        
//        //新增代码
//        UIBarButtonItem *spaceB = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        //左正右负
//        spaceB.width = 40;
//        self.navigationItem.rightBarButtonItems = @[item1,spaceB, item2];
        self.navigationItem.rightBarButtonItem = item2;

    }else{
        UIImage * image = [UIImage imageNamed:@"img_big_share"];
        UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [rightBarBtn setImage:image forState:UIControlStateNormal];
        [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    }
}
#pragma mark - 二级处理事件
//点击评论按钮
- (void)clickCommit
{
    FKXSameMindModel *model = [[FKXSameMindModel alloc] init];
    model.worryId = _secondModel.worryId;
    model.text = _secondModel.text;
    model.head = _secondModel.userHead;
    model.nickName = _secondModel.userNickName;
    
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"comment";
    vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,model.worryId, (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
    vc.sameMindModel = model;
    vc.pageType = MyPageType_nothing;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)clickShare
{
    NSString *title = @"";
    NSString *content = @"";
    NSString *imageUrl = @"";
    if ([_shareType isEqualToString:@"discovery"])//分享会
    {
        content = _courseModel.title ? _courseModel.title : @"";
        title = [NSString stringWithFormat:@"免费分享会|%@", _courseModel.title ? _courseModel.title : @""];
        imageUrl = _courseModel.background;
    }else if ([_shareType isEqualToString:@"course"])//课程
    {
        content = _courseModel.title ? _courseModel.title : @"";
        title = [NSString stringWithFormat:@"线上课程|%@", _courseModel.title ? _courseModel.title : @""];
        imageUrl = _courseModel.background;
    }else if ([_shareType isEqualToString:@"topic_2"])
    {//专题
        content = _courseModel.title ? _courseModel.title : @"";
        title = [NSString stringWithFormat:@"伐开心|%@", _courseModel.title ? _courseModel.title : @""];
        imageUrl = _courseModel.background;
    }else if ([_shareType isEqualToString:@"user_center_xinli"])
    {//心理咨询师
        content = @"随时随地解决您的心理问题";
        title = [NSString stringWithFormat:@"%@的心理工作室 ", _userModel.name];
        imageUrl = _userModel.head;
    }else if ([_shareType isEqualToString:@"user_center_jinpai"])
    {//金牌倾听者
        content = @"伐开心认证的心理关怀师";
        title = [NSString stringWithFormat:@"心理关怀师|%@", _userModel.name];
        imageUrl = _userModel.head;
    }else if ([_shareType isEqualToString:@"user_center"])
    {//个人的名片
        content = [NSString stringWithFormat:@"%@的心理工作室 ", _userModel.name];//@"来自伐开心";
        title = [NSString stringWithFormat:@"心理关怀师|%@", _userModel.name];
        imageUrl = _userModel.head;
    }else if ([_shareType isEqualToString:@"mind"])
    {//心事列表（共鸣）热门案例
        content = @"来自伐开心";
        title = [NSString stringWithFormat:@"伐开心|%@", _resonanceModel.title ? _resonanceModel.title : @""];
        imageUrl = _resonanceModel.background;

        //截取不管是几级的h5界面的shareid的参数
        NSString * url2 = [[currendReqUrlStr componentsSeparatedByString:@"?"] lastObject];
        NSArray *arr = [url2 componentsSeparatedByString:@"&"];
        NSString *shareId;
        for (NSString *subS in arr) {
            if ([subS containsString:@"shareId"]) {
                shareId = [[subS componentsSeparatedByString:@"="] lastObject];
                break;
            }
        }
        FKXBaseShareView *shareV = [[FKXBaseShareView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrlStr:imageUrl urlStr:currendReqUrlStr title:title text:content];
        shareV.hotId = shareId;
        shareV.needUpdateForwardNum = YES;
        [shareV createSubviews];
        return;
    }else if ([_shareType isEqualToString:@"comment"])
    {//相同心情的人，评论
        content = @"来自伐开心";
        title = [NSString stringWithFormat:@"伐开心|%@", _sameMindModel.text ? _sameMindModel.text : @""];
        imageUrl = _sameMindModel.head;
    }else if ([_shareType isEqualToString:@"second_ask"])
    {//秒问的分享
        content = @"来自伐开心";
        title = [NSString stringWithFormat:@"伐开心|%@", _secondModel.text ? _secondModel.text : @""];
        imageUrl = _secondModel.listenerHead;
    }else if ([_shareType isEqualToString:@"user_center_yu_yue"])
    {//预约的分享
        if ([_userModel.role integerValue] == 1) {
            content = @"随时随地解决您的心理问题";
            title = [NSString stringWithFormat:@"%@的心理工作室 ", _userModel.name];
            imageUrl = _userModel.head;
        }else
        {
            content = [NSString stringWithFormat:@"%@的心理工作室 ", _userModel.name];//@"来自伐开心";
            title = [NSString stringWithFormat:@"心理关怀师|%@", _userModel.name];
            imageUrl = _userModel.head;
        }
    }
    
    FKXBaseShareView *shareV = [[FKXBaseShareView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrlStr:imageUrl urlStr:currendReqUrlStr title:title text:content];
    [shareV createSubviews];
}
- (void)goBack
{
    if (_myWebView.canGoBack) {
        [_myWebView goBack];
        return;
    }
    [_myWebView stopLoading];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dismissSelf
{
    if (_myWebView.canGoBack) {
        [_myWebView goBack];
        return;
    }
    [_myWebView stopLoading];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
/*- (void)clickShareToThirdPlatformWithImageName:(NSString *)imageName title:(NSString *)title content:(NSString *)content url:(NSString *)url eventId:(NSString *)eventId;
{
    //1、创建分享参数
//    NSArray* imageArray = @[[UIImage imageNamed:imageName]];
    NSArray* imageArray = @[[NSURL URLWithString:@""]];

    //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:[NSURL URLWithString:url]
                                      title:title
                                       type:SSDKContentTypeAuto];
    if (imageArray) {
        
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:@[
                                         @(SSDKPlatformTypeSinaWeibo),
                                         @(SSDKPlatformSubTypeQQFriend),
                                         @(SSDKPlatformSubTypeQZone),@(SSDKPlatformSubTypeWechatTimeline),
                                         @(SSDKPlatformSubTypeWechatSession)]
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               [self validWithType:2 methodName:@"course/validation" para:@"courseId"];
//                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                   message:nil
//                                                                                  delegate:nil
//                                                                         cancelButtonTitle:@"确定"
//                                                                         otherButtonTitles:nil];
//                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];
    }
}*/
#pragma mark - 预约咨询
- (void)bookConsultService
{
    if ([FKXUserManager needShowLoginVC])
    {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
    }else
    {
        if (![WXApi isWXAppInstalled]) {
            [self showHint:@"当前不在线"];
            return;
        }else
            if (_userModel.uid == [FKXUserManager getUserInfoModel].uid)
        {
            [self showHint:@"不能咨询自己"];
            return;
        }
        
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setValue:_userModel.uid forKey:@"uid"];
        [self showHudInView:self.view hint:@"正在预约..."];
        [AFRequest sendGetOrPostRequest:@"talk/pay" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
         {
             [self hideHud];
             if ([data[@"code"] integerValue] == 0)
             {
                 if (!_payParameterDic) {
                     _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
                 }
                 [_payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
                 CGFloat money = [data[@"data"][@"money"] floatValue];
                 [_payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
                 NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
                 [_payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
                 //创建购买界面
                 [self setUpTransViewPay];
             }
             else if ([data[@"code"] integerValue] == 4)
             {
                 [self showAlertViewWithTitle:data[@"message"]];
                 [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             }else
             {
                 [self showHint:data[@"message"]];
                 
             }
         } failure:^(NSError *error) {
             [self hideHud];
             [self showHint:@"网络出错"];
         }];
    }
}
#pragma mark - 选择金额 然后支付 --start
- (void)createcustomPopView
{
    //点击需要支付的界面，如果没有安装微信，不进行下一步
    if (![WXApi isWXAppInstalled]) {
        [self showHint:@"当前不在线"];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!transparentView) {
            CGRect frame = [UIScreen mainScreen].bounds;
            //透明背景
            transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            transparentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];//[UIColor colorWithWhite:0 alpha:0.6];
            [[UIApplication sharedApplication].keyWindow addSubview:transparentView];
        }
        if (!customPopView)
        {
            NSArray *arrs;
            switch (_pageType) {
                case MyPageType_ask_praise:
                    arrs = @[@"2",@"5",@"10",@"20",@"30",@"50"];
                    break;
                case MyPageType_hot:
                    arrs = @[@"1",@"2",@"5",@"10",@"20",@"50"];
                    break;
                default:
                    break;
            }
            customPopView = [[FKXChooseMoneyView alloc] initWithMoneysArr:arrs];
            [customPopView.myPayBtn addTarget:self action:@selector(chooseMoneyToPay) forControlEvents:UIControlEventTouchUpInside];
            [customPopView.btnClose addTarget:self action:@selector(hiddenTransparentView) forControlEvents:UIControlEventTouchUpInside];
            
            for (UIButton *subBtn in customPopView.subviews)
            {
                if (subBtn.tag >= 200 && subBtn.tag <= 205) {// && subBtn.tag <= 105
                    [subBtn addTarget:self action:@selector(chooseMoney:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            [transparentView addSubview:customPopView];
            
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                customPopView.center = transparentView.center;
            } completion:nil];
        }
    });
    
}
- (void)chooseMoney:(UIButton *)btn
{
    btnTitle = btn.titleLabel.text;
}
- (void)chooseMoneyToPay
{
    if (![btnTitle integerValue]) {
        [self showAlertViewWithTitle:@"请选择打赏金额"];
        return;
    }
    PayChannel channel = PayChannelWxApp;
    switch (customPopView.myPayChannel)
    {
        case MyPayChannel_weChat:
            channel = PayChannelWxApp;
            break;
        case MyPayChannel_Ali:
            channel = PayChannelAliApp;
            break;
        case MyPayChannel_remain:
        {
            switch (_pageType) {
                    case MyPageType_nothing:
                    break;
                case MyPageType_hot:
                {
                    [self showHudInView:self.view hint:@"正在支付..."];
                    NSNumber *money = [NSNumber numberWithInteger:[btnTitle integerValue]*100];
                    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
                    [paramDic setValue:money forKey:@"money"];
                    [paramDic setValue:_payParameterDic[@"shareId"] forKey:@"shareId"];
                    NSString *methodName = @"share/reward";
                    
                    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                     {
                         [self hideHud];
                         if ([data[@"code"] integerValue] == 0)
                         {
//                             NSNumber *money = [NSNumber numberWithInteger:[btnTitle integerValue]*100];
//                             NSNumber *type = @(4);
                             NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
//                             [paramDic setValue:money forKey:@"money"];
//                             [paramDic setValue:_payParameterDic[@"shareId"] forKey:@"shareId"];
//                             [paramDic setValue:type forKey:@"type"];
                             [paramDic setValue:data[@"data"][@"billNo"] forKey:@"billNo"];
                             NSString *methodName = @"sys/balancePay";
                             [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                              {
                                  [self hideHud];
                                  if ([data[@"code"] integerValue] == 0)
                                  {
                                      [self showHint:@"支付成功"];
                                      [_myWebView reload];
                                      
                                      switch (_pageType) {
                                          case MyPageType_hot:
                                              [self showHint:@"赞赏成功，谢谢客官打赏"];
                                              break;
                                          case MyPageType_course:
                                          {
                                              [self showHint:@"支付成功，快去参加课程吧 "];
                                              //申请加入课程
                                              EMError *errGro;
                                              [[EaseMob sharedInstance].chatManager joinPublicGroup:groupId error:&errGro];
                                              if (!errGro)
                                              {
                                                  UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"成功加入群组" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                  [alert show];
                                                  EMGroup *groupInfo = [[EaseMob sharedInstance].chatManager fetchGroupInfo:groupId error:nil];
                                                  
                                                  //进入群组
                                                  ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                                                  chatController.title = groupInfo.groupSubject;
                                                  [self.navigationController pushViewController:chatController animated:YES];
                                              }
                                          }
                                              break;
                                          case MyPageType_people:
                                              [self showHint:@"提问成功，请等待回复"];
                                              break;
                                          case MyPageType_ask_listen:
                                              [self showHint:@"支付成功，快去悄悄听吧"];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectMind" object:nil];
                                              break;
                                          case MyPageType_ask_praise:
                                              [self showHint:@"赞赏成功，谢谢客官打赏"];
                                              break;
                                          case MyPageType_consult:
                                              [self showHint:@"支付成功，等待对方确认"];
                                              break;
                                          case MyPageType_agree:
                                          {
                                              [self showHint:@"认可成功，您可分享出去获得更多收入"];
                                              //重置右边bar按钮
                                              {
                                                  self.navigationItem.rightBarButtonItem = nil;
                                                  if (_isNeedTwoItem) {
                                                      UIImage * image = [UIImage imageNamed:@"btn_share"];
                                                      UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                                      [rightBarBtn setImage:image forState:UIControlStateNormal];
                                                      [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                                      
                                                      UIImage * image2 = [UIImage imageNamed:@"btn_comments_item"];
                                                      UIButton * rightBarBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image2.size.width, image2.size.height)];
                                                      [rightBarBtn2 setImage:image2 forState:UIControlStateNormal];
                                                      [rightBarBtn2 addTarget:self action:@selector(clickCommit) forControlEvents:UIControlEventTouchUpInside];
                                                      UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                                      UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn2];
                                                      
                                                      //新增代码
                                                      UIBarButtonItem *spaceB = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                                                      //左正右负
                                                      spaceB.width = 40;
                                                      self.navigationItem.rightBarButtonItems = @[item1,spaceB, item2];
                                                  }else{
                                                      UIImage * image = [UIImage imageNamed:@"img_big_share"];
                                                      UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                                      [rightBarBtn setImage:image forState:UIControlStateNormal];
                                                      [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                                      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                                  }
                                              }
                                          }
                                              break;
                                          default:
                                              break;
                                      }
                                  }
                                  else if ([data[@"code"] integerValue] == 4)
                                  {
                                      [self showAlertViewWithTitle:data[@"message"]];
                                      
                                      [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                                  }else
                                  {
                                      [self showHint:data[@"message"]];
                                  }
                              } failure:^(NSError *error) {
                                  [self showHint:@"网络出错"];
                                  [self hideHud];
                              }];
                             [self hiddenTransparentView];
                         }
                         else if ([data[@"code"] integerValue] == 4)
                         {
                             [self showAlertViewWithTitle:data[@"message"]];
                             
                             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                         }else
                         {
                             [self showHint:data[@"message"]];
                         }
                     } failure:^(NSError *error) {
                         [self showHint:@"网络出错"];
                         [self hideHud];
                     }];
                }
                    break;
                case MyPageType_course:
                break;
                case MyPageType_people:
                break;
                case MyPageType_ask_listen:
                break;
                case MyPageType_ask_praise:
                {
                    [self showHudInView:self.view hint:@"正在支付..."];
                    NSNumber *money = [NSNumber numberWithInteger:[btnTitle integerValue]*100];
                    
                    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
                    [paramDic setValue:money forKey:@"price"];
                    [paramDic setValue:_payParameterDic[@"voiceId"] forKey:@"voiceId"];
                    NSString *methodName = @"voice/praiseMoney";
                    
                    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                     {
                         [self hideHud];
                         if ([data[@"code"] integerValue] == 0)
                         {
                             NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
                             [paramDic setValue:data[@"data"][@"billNo"] forKey:@"billNo"];
                             NSString *methodName = @"sys/balancePay";
                             [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                              {
                                  [self hideHud];
                                  if ([data[@"code"] integerValue] == 0)
                                  {
                                      [self showHint:@"支付成功"];
                                      [_myWebView reload];
                                      switch (_pageType) {
                                          case MyPageType_hot:
                                              [self showHint:@"赞赏成功，谢谢客官打赏"];
                                              break;
                                          case MyPageType_course:
                                          {
                                              [self showHint:@"支付成功，快去参加课程吧 "];
                                              //申请加入课程
                                              EMError *errGro;
                                              [[EaseMob sharedInstance].chatManager joinPublicGroup:groupId error:&errGro];
                                              if (!errGro)
                                              {
                                                  UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"成功加入群组" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                  [alert show];
                                                  EMGroup *groupInfo = [[EaseMob sharedInstance].chatManager fetchGroupInfo:groupId error:nil];
                                                  
                                                  //进入群组
                                                  ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                                                  chatController.title = groupInfo.groupSubject;
                                                  [self.navigationController pushViewController:chatController animated:YES];
                                              }
                                          }
                                              break;
                                          case MyPageType_people:
                                              [self showHint:@"提问成功，请等待回复"];
                                              break;
                                          case MyPageType_ask_listen:
                                              [self showHint:@"支付成功，快去悄悄听吧"];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectMind" object:nil];
                                              break;
                                          case MyPageType_ask_praise:
                                              [self showHint:@"赞赏成功，谢谢客官打赏"];
                                              break;
                                          case MyPageType_consult:
                                              [self showHint:@"支付成功，等待对方确认"];
                                              break;
                                          case MyPageType_agree:
                                          {
                                              [self showHint:@"认可成功，您可分享出去获得更多收入"];
                                              //重置右边bar按钮
                                              {
                                                  self.navigationItem.rightBarButtonItem = nil;
                                                  if (_isNeedTwoItem) {
                                                      UIImage * image = [UIImage imageNamed:@"btn_share"];
                                                      UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                                      [rightBarBtn setImage:image forState:UIControlStateNormal];
                                                      [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                                      
                                                      UIImage * image2 = [UIImage imageNamed:@"btn_comments_item"];
                                                      UIButton * rightBarBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image2.size.width, image2.size.height)];
                                                      [rightBarBtn2 setImage:image2 forState:UIControlStateNormal];
                                                      [rightBarBtn2 addTarget:self action:@selector(clickCommit) forControlEvents:UIControlEventTouchUpInside];
                                                      UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                                      UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn2];
                                                      
                                                      //新增代码
                                                      UIBarButtonItem *spaceB = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                                                      //左正右负
                                                      spaceB.width = 40;
                                                      self.navigationItem.rightBarButtonItems = @[item1,spaceB, item2];
                                                  }else{
                                                      UIImage * image = [UIImage imageNamed:@"img_big_share"];
                                                      UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                                      [rightBarBtn setImage:image forState:UIControlStateNormal];
                                                      [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                                      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                                  }
                                              }
                                          }
                                              break;
                                          default:
                                              break;
                                      }
                                  }
                                  else if ([data[@"code"] integerValue] == 4)
                                  {
                                      [self showAlertViewWithTitle:data[@"message"]];
                                      
                                      [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                                  }else
                                  {
                                      [self showHint:data[@"message"]];
                                  }
                              } failure:^(NSError *error) {
                                  [self showHint:@"网络出错"];
                                  [self hideHud];
                              }];
                             
                             [self hiddenTransparentView];
                         }
                         else if ([data[@"code"] integerValue] == 4)
                         {
                             [self showAlertViewWithTitle:data[@"message"]];
                             
                             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                         }else
                         {
                             [self showHint:data[@"message"]];
                         }
                     } failure:^(NSError *error) {
                         [self showHint:@"网络出错"];
                         [self hideHud];
                     }];
                }
                break;
            }
        }
            break;
        default:
            break;
    }
    if (customPopView.myPayChannel == MyPayChannel_remain) {
        return;
    }
    //余额支付以外的支付
    switch (_pageType) {
        case MyPageType_hot:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSNumber *money = [NSNumber numberWithInteger:[btnTitle integerValue]*100];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:money forKey:@"money"];
            [paramDic setValue:_payParameterDic[@"shareId"] forKey:@"shareId"];
            NSString *methodName = @"share/reward";
            
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     [self doPay:channel billNo:data[@"data"][@"billNo"] money:money];
                 }
                 else if ([data[@"code"] integerValue] == 4)
                 {
                     [self showAlertViewWithTitle:data[@"message"]];
                     
                     [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                 }else
                 {
                     [self showHint:data[@"message"]];
                 }
             } failure:^(NSError *error) {
                 [self showHint:@"网络出错"];
                 [self hideHud];
             }];
        }
            break;
        case MyPageType_course:
            break;
        case MyPageType_people:
            break;
        case MyPageType_ask_listen:
            break;
        case MyPageType_ask_praise:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSNumber *money = [NSNumber numberWithInteger:[btnTitle integerValue]*100];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:money forKey:@"price"];
            [paramDic setValue:_payParameterDic[@"voiceId"] forKey:@"voiceId"];
            NSString *methodName = @"voice/praiseMoney";
            
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     [self doPay:channel billNo:data[@"data"][@"billNo"] money:money];
                 }
                 else if ([data[@"code"] integerValue] == 4)
                 {
                     [self showAlertViewWithTitle:data[@"message"]];
                     
                     [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                 }else
                 {
                     [self showHint:data[@"message"]];
                 }
             } failure:^(NSError *error) {
                 [self showHint:@"网络出错"];
                 [self hideHud];
             }];
        }
            break;
            
        default:
            break;
    }
    [self hiddenTransparentView];
}
//6､创建手势处理方法：
- (void)hiddenTransparentView
{
    [UIView animateWithDuration:0.5 animations:^{
        [transparentView removeAllSubviews];
        [transparentView removeFromSuperview];
        transparentView = nil;
        customPopView = nil;
    }];
}
#pragma mark - 选择金额 --end
#pragma mark - 支付流程  --start
- (void)goToPayService
{
    //点击需要支付的界面，如果没有安装微信，不进行下一步
    if (![WXApi isWXAppInstalled]) {
        [self showHint:@"当前不在线"];
        return;
    }
    switch (_pageType) {
        case MyPageType_hot:
            break;
        case MyPageType_course:
            break;
        case MyPageType_people:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:_payParameterDic[@"text"] forKey:@"text"];
            [paramDic setValue:_payParameterDic[@"uid"] forKey:@"uid"];
            [AFRequest sendGetOrPostRequest:@"listener/insertQuestion" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
                [self hideHud];
                if ([data[@"code"] integerValue] == 0)
                {
                    if ([_userModel.uid integerValue] == [FKXUserManager shareInstance].currentUserId)
                    {
                        [self showHint:@"不能购买自己的服务"];
                        return;
                    }
                    [_payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
                    [_payParameterDic setObject:data[@"data"][@"talkId"] forKey:@"questionId"];
                    CGFloat money = [data[@"data"][@"money"] floatValue];
                    [_payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
                    NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
                    [_payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
                    //创建购买界面
                    [self setUpTransViewPay];
                    
                }else if ([data[@"code"] integerValue] == 4)
                {
                    [self showAlertViewWithTitle:data[@"message"]];
                    [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                }else
                {
                    [self showHint:data[@"message"]];
                }
            } failure:^(NSError *error) {
                [self hideHud];
                [self showAlertViewWithTitle:@"网络出错"];
            }];
        }
            break;
        case MyPageType_ask_listen:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:@([_payParameterDic[@"price"] doubleValue]*100) forKey:@"price"];
            [paramDic setValue:_payParameterDic[@"voiceId"] forKey:@"voiceId"];
            NSString *methodName = @"voice/pay";
            
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     alertStr = data[@"data"][@"alert"];
                     [_payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
                     CGFloat money = [data[@"data"][@"money"] floatValue];
                     [_payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
                     NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
                     [_payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
                     //创建购买界面
                     [self setUpTransViewPay];
                 }
                 else if ([data[@"code"] integerValue] == 4)
                 {
                     [self showAlertViewWithTitle:data[@"message"]];
                     
                     [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                 }else
                 {
                     [self showHint:data[@"message"]];
                 }
             } failure:^(NSError *error) {
                 [self showHint:@"网络出错"];
                 [self hideHud];
             }];
        }
            break;
        case MyPageType_ask_praise:
            break;
        case MyPageType_agree:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:_secondModel.acceptMoney forKey:@"acceptMoney"];
            [paramDic setValue:_secondModel.voiceId forKey:@"voiceId"];
            NSString *methodName = @"voice/accept";
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     alertStr = data[@"data"][@"alert"];
                     //认可的字典没初始化
                     if (!_payParameterDic) {
                         _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
                     }
                     [_payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
                     CGFloat money = [data[@"data"][@"money"] floatValue];
                     [_payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
                     NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
                     [_payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
                     //创建购买界面
                     [self setUpTransViewPay];
                 }
                 else if ([data[@"code"] integerValue] == 4)
                 {
                     [self showAlertViewWithTitle:data[@"message"]];
                     
                     [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                 }else
                 {
                     [self showHint:data[@"message"]];
                 }
             } failure:^(NSError *error) {
                 [self showHint:@"网络出错"];
                 [self hideHud];
             }];
        }
            break;
        default:
            break;
    }
}
- (void)setUpTransViewPay
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transViewPay)
    {
        //透明背景
        transViewPay = [[UIView alloc] initWithFrame:screenBounds];
        transViewPay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewPay.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewPay];
        
        payView = [[[NSBundle mainBundle] loadNibNamed:@"FKXPayView" owner:nil options:nil] firstObject];
        [payView.btnClose addTarget:self action:@selector(hiddentransViewPay) forControlEvents:UIControlEventTouchUpInside];
        [payView.myPayBtn addTarget:self action:@selector(confirmToPay) forControlEvents:UIControlEventTouchUpInside];
        
        if (_payParameterDic[@"isAmple"]) {
            if (![_payParameterDic[@"isAmple"] integerValue]) {
                payView.btnRemain.enabled = NO;
                [payView.btnRemain setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
        
        [transViewPay addSubview:payView];
        payView.center = transViewPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewPay.alpha = 1.0;
        }];
        
        switch (_pageType) {
            case MyPageType_hot:
                break;
            case MyPageType_course:
            {
                payView.labTitle.text = @"课程费用";
                payView.labPrice.text = [NSString stringWithFormat:@"%.2f", [_courseModel.expectCost doubleValue]/100];
            }
                break;
            case MyPageType_people:
            {
                payView.labTitle.text = @"秒问";
                payView.labPrice.text = [NSString stringWithFormat:@"￥%.2f", [_payParameterDic[@"money"] floatValue]/100];
            }
                break;
            case MyPageType_ask_listen:
            {
                payView.labTitle.text = @"秒问";
                payView.labPrice.text = [NSString stringWithFormat:@"￥%.2f", [_payParameterDic[@"money"] floatValue]/100];
            }
                break;
            case MyPageType_consult:
            {
                payView.labTitle.text = @"咨询";
                payView.labPrice.text = [NSString stringWithFormat:@"￥%.2f", [_payParameterDic[@"money"] floatValue]/100];
            }
                break;
            case MyPageType_ask_praise:
                break;
            case MyPageType_agree:
            {
                payView.labTitle.text = @"认可";
                payView.labPrice.text = [NSString stringWithFormat:@"￥%.2f", [_payParameterDic[@"money"] floatValue]/100];
            }
                break;
            default:
                break;
        }
    }
}
- (void)hiddentransViewPay
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewPay.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewPay removeFromSuperview];
        transViewPay = nil;
    }];
}
- (void)confirmToPay
{
    PayChannel channel = PayChannelWxApp;
    switch (payView.myPayChannel) {
        case MyPayChannel_weChat:
            channel = PayChannelWxApp;
            break;
        case MyPayChannel_Ali:
            channel = PayChannelAliApp;
            break;
        case MyPayChannel_remain:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            switch (_pageType) {
                    case MyPageType_nothing:
                    break;
                case MyPageType_hot:
                    break;
                case MyPageType_course:
                {
                    [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
                }
                    break;
                case MyPageType_people:
                {
                    [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
                }
                    break;
                case MyPageType_ask_listen:
                {
                    [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
                }
                    break;
                case MyPageType_ask_praise:
                    break;
                case MyPageType_agree:
                {
                    [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
                }
                    break;
                    case MyPageType_consult:
                {
                    [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
                }
                    break;
            }
            NSString *methodName = @"sys/balancePay";
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     [_myWebView reload];
                     //课程支付成功要跳到课程
                     if (_pageType == MyPageType_course) {
                         //申请加入课程
                         EMError *errGro;
                         [[EaseMob sharedInstance].chatManager joinPublicGroup:groupId error:&errGro];
                         if (!errGro)
                         {
                             UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"成功加入群组" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                             [alert show];
                             EMGroup *groupInfo = [[EaseMob sharedInstance].chatManager fetchGroupInfo:groupId error:nil];
                             
                             //进入群组
                             ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                             chatController.title = groupInfo.groupSubject;
                             [self.navigationController pushViewController:chatController animated:YES];
                         }
                     }
                     if (_pageType == MyPageType_ask_listen) {
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectMind" object:nil];
                     }
                     if (_pageType == MyPageType_agree) {
                         //重置右边bar按钮
                         {
                             self.navigationItem.rightBarButtonItem = nil;
                             if (_isNeedTwoItem) {
                                 UIImage * image = [UIImage imageNamed:@"btn_share"];
                                 UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                 [rightBarBtn setImage:image forState:UIControlStateNormal];
                                 [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                 
                                 UIImage * image2 = [UIImage imageNamed:@"btn_comments_item"];
                                 UIButton * rightBarBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image2.size.width, image2.size.height)];
                                 [rightBarBtn2 setImage:image2 forState:UIControlStateNormal];
                                 [rightBarBtn2 addTarget:self action:@selector(clickCommit) forControlEvents:UIControlEventTouchUpInside];
                                 UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                 UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn2];
                                 
                                 //新增代码
                                 UIBarButtonItem *spaceB = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                                 //左正右负
                                 spaceB.width = 40;
                                 self.navigationItem.rightBarButtonItems = @[item1,spaceB, item2];
                             }else{
                                 UIImage * image = [UIImage imageNamed:@"img_big_share"];
                                 UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                 [rightBarBtn setImage:image forState:UIControlStateNormal];
                                 [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                             }
                         }
                     }
                     
                     switch (_pageType) {
                         case MyPageType_hot:
                             [self showHint:@"赞赏成功，谢谢客官打赏"];
                             break;
                         case MyPageType_course:
                         {
                             [self showHint:@"支付成功，快去参加课程吧 "];
                             //申请加入课程
                             EMError *errGro;
                             [[EaseMob sharedInstance].chatManager joinPublicGroup:groupId error:&errGro];
                             if (!errGro)
                             {
                                 UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"成功加入群组" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                 [alert show];
                                 EMGroup *groupInfo = [[EaseMob sharedInstance].chatManager fetchGroupInfo:groupId error:nil];
                                 
                                 //进入群组
                                 ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                                 chatController.title = groupInfo.groupSubject;
                                 [self.navigationController pushViewController:chatController animated:YES];
                             }
                         }
                             break;
                         case MyPageType_people:
                             [self showHint:@"提问成功，请等待回复"];
                             break;
                         case MyPageType_ask_listen:
                             [self showHint:alertStr];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectMind" object:nil];
                             break;
                         case MyPageType_ask_praise:
                             [self showHint:@"赞赏成功，谢谢客官打赏"];
                             break;
                         case MyPageType_consult:
                             [self showHint:@"支付成功，等待对方确认"];
                             break;
                         case MyPageType_agree:
                         {
                             [self showHint:alertStr];
                             //重置右边bar按钮
                             {
                                 self.navigationItem.rightBarButtonItem = nil;
                                 if (_isNeedTwoItem) {
                                     UIImage * image = [UIImage imageNamed:@"btn_share"];
                                     UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                     [rightBarBtn setImage:image forState:UIControlStateNormal];
                                     [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                     
                                     UIImage * image2 = [UIImage imageNamed:@"btn_comments_item"];
                                     UIButton * rightBarBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image2.size.width, image2.size.height)];
                                     [rightBarBtn2 setImage:image2 forState:UIControlStateNormal];
                                     [rightBarBtn2 addTarget:self action:@selector(clickCommit) forControlEvents:UIControlEventTouchUpInside];
                                     UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                     UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn2];
                                     
                                     //新增代码
                                     UIBarButtonItem *spaceB = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                                     //左正右负
                                     spaceB.width = 40;
                                     self.navigationItem.rightBarButtonItems = @[item1,spaceB, item2];
                                 }else{
                                     UIImage * image = [UIImage imageNamed:@"img_big_share"];
                                     UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                     [rightBarBtn setImage:image forState:UIControlStateNormal];
                                     [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                 }
                             }
                         }
                             break;
                         default:
                             [self showHint:@"支付成功"];
                             break;
                     }
                 }
                 else if ([data[@"code"] integerValue] == 4)
                 {
                     [self showAlertViewWithTitle:data[@"message"]];
                     
                     [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                 }else
                 {
                     [self showHint:data[@"message"]];
                 }
             } failure:^(NSError *error) {
                 [self showHint:@"网络出错"];
                 [self hideHud];
             }];
            [self hiddentransViewPay];
        }
            break;
        default:
            break;
    }
    if (payView.myPayChannel == MyPayChannel_remain) {
        return;
    }
    //除余额以外的支付
    switch (_pageType) {
        case MyPageType_hot:
            break;
        case MyPageType_course:
        case MyPageType_people:
        case MyPageType_ask_listen:
        case MyPageType_consult:
        case MyPageType_agree:
            [self doPay:channel billNo:_payParameterDic[@"billNo"] money:_payParameterDic[@"money"]];
            break;
        case MyPageType_ask_praise:
            break;
        default:
            break;
    }
    [self hiddentransViewPay];
}
//微信、支付宝
- (void)doPay:(PayChannel)channel billNo:(NSString *)billNo money:(NSNumber *)money {
    [self showHudInView:self.view hint:@"正在支付..."];
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"伐开心订单";
    payReq.totalFee = [NSString stringWithFormat:@"%ld",[money integerValue]];
    payReq.billNo = billNo;
    if (channel == PayChannelAliApp) {
        payReq.scheme = @"Zhifubaozidingyi001test";
    }
    payReq.billTimeOut = 360;
    payReq.viewController = self;
    payReq.optional = nil;
    [BeeCloud sendBCReq:payReq];
}
#pragma mark - 支付流程  --end
#pragma mark - BeeCloudDelegate
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    [self hideHud];
    switch (resp.type) {
        case BCObjsTypePayResp:
        {
            // 支付请求响应
            BCPayResp *tempResp = (BCPayResp *)resp;
            if (tempResp.resultCode == 0)
            {
                [_myWebView reload];
                switch (_pageType) {
                    case MyPageType_hot:
                        [self showHint:@"赞赏成功，谢谢客官打赏"];
                        break;
                    case MyPageType_course:
                    {
                        [self showHint:@"支付成功，快去参加课程吧 "];
                        //申请加入课程
                        EMError *errGro;
                        [[EaseMob sharedInstance].chatManager joinPublicGroup:groupId error:&errGro];
                        if (!errGro)
                        {
                            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"成功加入群组" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alert show];
                            EMGroup *groupInfo = [[EaseMob sharedInstance].chatManager fetchGroupInfo:groupId error:nil];
                            
                            //进入群组
                            ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId conversationType:eConversationTypeGroupChat];
                            chatController.title = groupInfo.groupSubject;
                            [self.navigationController pushViewController:chatController animated:YES];
                        }
                    }
                        break;
                    case MyPageType_people:
                        [self showHint:@"提问成功，请等待回复"];
                        break;
                    case MyPageType_ask_listen:
                        [self showHint:alertStr];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectMind" object:nil];
                        break;
                    case MyPageType_ask_praise:
                        [self showHint:@"赞赏成功，谢谢客官打赏"];
                        break;
                    case MyPageType_consult:
                        [self showHint:@"支付成功，等待对方确认"];
                        break;
                    case MyPageType_agree:
                    {
                        [self showHint:alertStr];
                        //重置右边bar按钮
                        {
                            self.navigationItem.rightBarButtonItem = nil;
                            if (_isNeedTwoItem) {
                                UIImage * image = [UIImage imageNamed:@"btn_share"];
                                UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                [rightBarBtn setImage:image forState:UIControlStateNormal];
                                [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                
                                UIImage * image2 = [UIImage imageNamed:@"btn_comments_item"];
                                UIButton * rightBarBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image2.size.width, image2.size.height)];
                                [rightBarBtn2 setImage:image2 forState:UIControlStateNormal];
                                [rightBarBtn2 addTarget:self action:@selector(clickCommit) forControlEvents:UIControlEventTouchUpInside];
                                UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                                UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn2];
                                
                                //新增代码
                                UIBarButtonItem *spaceB = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                                //左正右负
                                spaceB.width = 40;
                                self.navigationItem.rightBarButtonItems = @[item1,spaceB, item2];
                            }else{
                                UIImage * image = [UIImage imageNamed:@"img_big_share"];
                                UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                [rightBarBtn setImage:image forState:UIControlStateNormal];
                                [rightBarBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
                                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
                            }
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                //支付取消或者支付失败,,或者取消支付都要再次提示用户购买
                [self showAlertViewWithTitle:[NSString stringWithFormat:@"%@", tempResp.errDetail]];
            }
        }
            break;
        default:
            NSLog(@"%@", @"不是支付响应的回调");
            break;
    }
}
@end
