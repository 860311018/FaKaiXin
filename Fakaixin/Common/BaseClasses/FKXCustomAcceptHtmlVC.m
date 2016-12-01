//
//  FKXCustomAcceptHtmlVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/22.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXCustomAcceptHtmlVC.h"
#import "FKXPayForAcceptView.h"
#import "HYBJsObjCModel.h"
#import "FKXChooseMoneyView.h"
#import "FKXProfessionInfoVC.h"
#import "FKXGrayView.h"


typedef enum : NSUInteger {
    ClickPayType_praise,//赞赏
    ClickPayType_accept,//付费认可
    ClickPayType_consult//咨询
} ClickPayType;//点击支付的类型，

@interface FKXCustomAcceptHtmlVC ()<BeeCloudDelegate,FKXGrayDelegate>
{
    //认可支付
    UIView *transViewAcceptPay;   //认可支付的透明图
    FKXPayForAcceptView *acceptPayView;    //认可支付界面
    NSString *acceptAlertStr;//支付成功的提示，需要展示后台返回的
    //赞赏支付
    FKXChooseMoneyView *customPopView;
    UIView *popTransparentView;    //弹出选择金额的透明视图
    NSString *btnTitle;
    //咨询支付
    UIView *transViewPay;   //支付的透明图
    FKXPayView *payView;    //支付界面
    
//    BOOL isPraise;//区分赞赏和认可，做不同处理
//    BOOL isConsult;//是否是咨询
    ClickPayType myClickType;
    
    CGFloat keyboardHeight;
}

@property (weak, nonatomic) IBOutlet UILabel *labReward;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIButton *btnPayAccept;

@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *renkeView;

@end

@implementation FKXCustomAcceptHtmlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.isHidenM) {
        self.renkeView.hidden = YES;
    }
    //电话动效
    [self.phoneView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(call)]];
    self.phoneView.transform = CGAffineTransformScale(self.phoneView.transform, 0.8, 0.8);
    [UIView beginAnimations:@"bigToSmall" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    [UIView setAnimationRepeatAutoreverses:YES];
    self.phoneView.transform = CGAffineTransformScale(self.phoneView.transform, 1.2, 1.2);
    [UIView commitAnimations];
    
    
    [_btnPayAccept setTitle:[NSString stringWithFormat:@"%ld元认可", [_secondModel.acceptMoney integerValue]/100] forState:UIControlStateNormal];
    _btnPayAccept.transform = CGAffineTransformScale(_btnPayAccept.transform, 0.8, 0.8);
    [UIView beginAnimations:@"bigToSmall" context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationRepeatCount:2];
    [UIView setAnimationRepeatAutoreverses:YES];
    _btnPayAccept.transform = CGAffineTransformScale(_btnPayAccept.transform, 1.2, 1.2);
    [UIView commitAnimations];
    
    self.navTitle = @"详情";
    self.myWebView.backgroundColor = kColorBackgroundGray;
//    NSAttributedString *attS = [[NSAttributedString alloc] initWithString:_labReward.text attributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
//    [_labReward setAttributedText:attS];
    //设置支付代理
    [BeeCloud setBeeCloudDelegate:self];

    //web请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [_myWebView loadRequest:request];
    
    _labReward.userInteractionEnabled = YES;
    [_labReward addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginReward)]];
    //赋值
    _userName.text = _secondModel.listenerNickName;
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_secondModel.listenerHead,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    [_userIcon addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickHead:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}

#pragma mark - 点击头像
- (void)clickHead:(UITapGestureRecognizer *)tap {
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = _secondModel.listenerId;
//    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goBack
{
    if (_isShowAlert) {
        UIAlertController *alV = [UIAlertController alertControllerWithTitle:@"这条语音回复您满意吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"我再想想" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"深得朕心" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            UIAlertController *alVSub = [UIAlertController alertControllerWithTitle:@"确定认可该语音回复？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ac1Sub = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                  {
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }];
            UIAlertAction *ac2Sub = [UIAlertAction actionWithTitle:@"认可" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
            {
                [self beginAccept:nil];
            }];
            [alVSub addAction:ac1Sub];
            [alVSub addAction:ac2Sub];
            [self presentViewController:alVSub animated:YES completion:nil];
        }];
        [alV addAction:ac1];
        [alV addAction:ac2];
        [self presentViewController:alV animated:YES completion:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 进个人主页
//h5种点击头像跳转到客服端写的个人动态主页
- (void)goToPersonalDynamicPageWithUid:(NSNumber *)uid
{
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = uid;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark UIWebViewDelegate 代理
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideHud];
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 通过模型调用方法，这种方式更好些。
    HYBJsObjCModel *model  = [[HYBJsObjCModel alloc] init];
    model.customAcceptVC = self;
    self.jsContext[@"OCModel"] = model;
    model.jsContext = self.jsContext;
    model.webView = _myWebView;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    [self hideHud];

}

#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)not
{
    
    NSValue * value = [not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize size = [value CGRectValue].size;
    keyboardHeight = size.height;
    [UIView animateWithDuration:0.5 animations:^{
//        chooseTypeView.frame = CGRectMake(0, kScreenHeight - kCusKeyBorH -keyboardHeight-64,kScreenWidth, kCusKeyBorH);
//        _myTextView.frame = CGRectMake(8,49, kScreenWidth-16, kScreenHeight-49-kCusKeyBorH-keyboardHeight-64);
        
    }];
}
- (void)keyboardWillHide:(NSNotification *)not
{
    [UIView animateWithDuration:0.2 animations:^{
//        chooseTypeView.frame = CGRectMake(0, 249 ,kScreenWidth, kCusKeyBorH);
//        _myTextView.frame = CGRectMake(8, 49, kScreenWidth-16, 200);
    }];
}

#pragma mark - 订单相关

- (void)bangDingMobile {
//    FKXGrayView *phone = [[FKXGrayView alloc]initWithMobileFrame:CGRectMake(0, 0, 0, 0)];
//    [phone show];
}


#pragma mark -点击事件

//电话咨询
- (void)call {
//    CGFloat height = (285.0/350.0)*kScreenWidth;
    FKXGrayView *order = [[FKXGrayView alloc]initWithPoint:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    order.grayDelegate = self;
    [order show];
}

- (void)beginReward {
    myClickType = ClickPayType_praise;
    [self createcustomPopView];
}
- (IBAction)clickPayAccept:(UIButton *)sender {
    myClickType = ClickPayType_accept;
    [self goToPayService];
}
- (IBAction)beginAccept:(UIButton *)sender {
    
    [self showHudInView:self.view hint:@"正在认可..."];
    NSDictionary *paramDic = @{@"voiceId":_payParameterDic[@"voiceId"]};
    
    [AFRequest sendGetOrPostRequest:@"voice/free_accept" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"] yOffset:-300];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
- (IBAction)beginAsk:(UIButton *)sender {
    if (![WXApi isWXAppInstalled]) {
        [self showHint:@"当前不在线"];
        return;
    }

    if ([_secondModel.listenerId integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不能提问自己"];
        return;
    }
    if (!_secondModel.listenerId) {
        return;
    }
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.pageType = MyPageType_people;
//    if ([myUserInfoModel.role integerValue] == 1) {
//        vc.shareType = @"user_center_jinpai";
//    }else{
        vc.shareType = @"user_center_xinli";
//    }
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_home.html?uid=%@&loginUserId=%ld&token=%@",kServiceBaseURL, _secondModel.listenerId, [FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    FKXUserInfoModel *model = [[FKXUserInfoModel alloc] init];
    model.uid = _secondModel.listenerId;
    vc.userModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)beginConsult:(UIButton *)sender {
//    if (![WXApi isWXAppInstalled]) {
//        [self showHint:@"当前不在线"];
//        return;
//    }
    myClickType = ClickPayType_consult;
    if ([_secondModel.listenerId integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不能咨询自己"];
        return;
    }
    if (!_secondModel.listenerId) {
        return;
    }
    [self bookConsultService];
    
    /*
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"user_center_yu_yue";//预约
    vc.pageType = MyPageType_consult;
    vc.urlString = [NSString stringWithFormat:@"%@front/user_center.html?uid=%@&token=%@",kServiceBaseURL, _secondModel.listenerId, [FKXUserManager shareInstance].currentUserToken];

    FKXUserInfoModel *model = [[FKXUserInfoModel alloc] init];
    model.uid = _secondModel.listenerId;
    vc.userModel = model;
    [self.navigationController pushViewController:vc animated:YES];
     */
}
#pragma mark - 认可支付流程  --start
- (void)goToPayService
{
//    if (![WXApi isWXAppInstalled]) {
//        [self showHint:@"当前不在线"];
//        return;
//    }
    
    myClickType = ClickPayType_accept;
    [self showHudInView:self.view hint:@"正在加载..."];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_secondModel.acceptMoney forKey:@"acceptMoney"];//@(100)_secondModel.acceptMoney
    [paramDic setValue:_secondModel.voiceId forKey:@"voiceId"];
    NSString *methodName = @"voice/accept";
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             acceptAlertStr = data[@"data"][@"alert"];
             //认可的字典没初始化
             if (!_payParameterDic) {
                 _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
             }
             [_payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
             CGFloat money = [data[@"data"][@"money"] floatValue];//100.0;
             [_payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
             NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
             [_payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
             //创建购买界面
             [self setUptransViewAcceptPay];
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
- (void)setUptransViewAcceptPay
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transViewAcceptPay)
    {
        //透明背景
        transViewAcceptPay = [[UIView alloc] initWithFrame:screenBounds];
        transViewAcceptPay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        transViewAcceptPay.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewAcceptPay];
        [transViewAcceptPay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddentransViewAcceptPay)]];

        acceptPayView = [[[NSBundle mainBundle] loadNibNamed:@"FKXPayForAcceptView" owner:nil options:nil] firstObject];
//        [acceptPayView.btnClose addTarget:self action:@selector(hiddentransViewAcceptPay) forControlEvents:UIControlEventTouchUpInside];
        [acceptPayView.myPayBtn addTarget:self action:@selector(confirmToPay) forControlEvents:UIControlEventTouchUpInside];
        
        if (_payParameterDic[@"isAmple"]) {
            if (![_payParameterDic[@"isAmple"] integerValue]) {
                acceptPayView.btnRemain.enabled = NO;
                [acceptPayView.btnRemain setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
        
        [transViewAcceptPay addSubview:acceptPayView];
        acceptPayView.center = transViewAcceptPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewAcceptPay.alpha = 1.0;
        }];
        acceptPayView.labPrice.text = [NSString stringWithFormat:@"￥%.2f", [_payParameterDic[@"money"] floatValue]/100];
    }
}
- (void)hiddentransViewAcceptPay
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewAcceptPay.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewAcceptPay removeFromSuperview];
        transViewAcceptPay = nil;
    }];
}
//认可和咨询共用这一个确认方法
- (void)confirmToPay
{
    PayChannel channel = PayChannelWxApp;
    switch (myClickType) {
        case ClickPayType_accept:
        {
            switch (acceptPayView.myPayChannel) {
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
                    
                    [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
                    
                    NSString *methodName = @"sys/balancePay";
                    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                     {
                         [self hideHud];
                         if ([data[@"code"] integerValue] == 0)
                         {
                             switch (myClickType) {
                                 case ClickPayType_accept:
                                     [self showHint:acceptAlertStr];
                                     [self.navigationController popViewControllerAnimated:YES];
                                     break;
                                 case ClickPayType_praise:
                                     [_myWebView reload];
                                     [self showHint:@"赞赏成功，谢谢客官打赏"];
                                     break;
                                 case ClickPayType_consult:
                                     [self showHint:@"支付成功，等待对方确认"];
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
                    switch (myClickType) {
                        case ClickPayType_accept:
                            [self hiddentransViewAcceptPay];
                            break;
                        case ClickPayType_praise:
                            
                            break;
                        case ClickPayType_consult:
                            [self hiddentransViewPay];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case ClickPayType_consult:
        {
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
                    
                    [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
                    
                    NSString *methodName = @"sys/balancePay";
                    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                     {
                         [self hideHud];
                         if ([data[@"code"] integerValue] == 0)
                         {
                             switch (myClickType) {
                                 case ClickPayType_accept:
                                     [self showHint:acceptAlertStr];
                                     [self.navigationController popViewControllerAnimated:YES];
                                     break;
                                 case ClickPayType_praise:
                                     [_myWebView reload];
                                     [self showHint:@"赞赏成功，谢谢客官打赏"];
                                     break;
                                 case ClickPayType_consult:
                                     [self showHint:@"支付成功，等待对方确认"];
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
                    switch (myClickType) {
                        case ClickPayType_accept:
                            [self hiddentransViewAcceptPay];
                            break;
                        case ClickPayType_praise:
                            
                            break;
                        case ClickPayType_consult:
                            [self hiddentransViewPay];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    //如果点击了余额支付，就跳过下边的操作
    switch (myClickType) {
        case ClickPayType_accept:
            if (acceptPayView.myPayChannel == MyPayChannel_remain) {
                return;
            }
            break;
        case ClickPayType_praise:
            
            break;
        case ClickPayType_consult:
            if (payView.myPayChannel == MyPayChannel_remain) {
                return;
            }
            break;
        default:
            break;
    }
    //除余额以外的支付
    [self doPay:channel billNo:_payParameterDic[@"billNo"] money:_payParameterDic[@"money"]];
    switch (myClickType) {
        case ClickPayType_accept:
            [self hiddentransViewAcceptPay];
            break;
        case ClickPayType_praise:
            
            break;
        case ClickPayType_consult:
            [self hiddentransViewPay];
            break;
        default:
            break;
    }
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
#pragma mark - 认可支付流程  --end
#pragma mark - 赞赏选择金额 然后支付 --start
- (void)createcustomPopView
{
    //点击需要支付的界面，如果没有安装微信，不进行下一步
    if (![WXApi isWXAppInstalled]) {
        [self showHint:@"当前不在线"];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!popTransparentView) {
            CGRect frame = [UIScreen mainScreen].bounds;
            //透明背景
            popTransparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            popTransparentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];//[UIColor colorWithWhite:0 alpha:0.6];
            [[UIApplication sharedApplication].keyWindow addSubview:popTransparentView];
        }
        if (!customPopView)
        {
            NSArray *arrs= @[@"2",@"5",@"10",@"20",@"30",@"50"];
            customPopView = [[FKXChooseMoneyView alloc] initWithMoneysArr:arrs];
            [customPopView.myPayBtn addTarget:self action:@selector(chooseMoneyToPay) forControlEvents:UIControlEventTouchUpInside];
            [customPopView.btnClose addTarget:self action:@selector(hiddenpopTransparentView) forControlEvents:UIControlEventTouchUpInside];
            
            for (UIButton *subBtn in customPopView.subviews)
            {
                if (subBtn.tag >= 200 && subBtn.tag <= 205) {// && subBtn.tag <= 105
                    [subBtn addTarget:self action:@selector(chooseMoney:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            [popTransparentView addSubview:customPopView];
            
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                customPopView.center = popTransparentView.center;
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
                              [_myWebView reload];
                              [self showHint:@"赞赏成功，谢谢客官打赏"];
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
                     
                     [self hiddenpopTransparentView];
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
    if (customPopView.myPayChannel == MyPayChannel_remain) {
        return;
    }
    //余额支付以外的支付
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
    [self hiddenpopTransparentView];
}
//6､创建手势处理方法：
- (void)hiddenpopTransparentView
{
    btnTitle = nil;
    [UIView animateWithDuration:0.5 animations:^{
        [popTransparentView removeAllSubviews];
        [popTransparentView removeFromSuperview];
        popTransparentView = nil;
        customPopView = nil;
    }];
}
#pragma mark - 赞赏选择金额 --end
#pragma mark - 咨询支付流程  --start
- (void)bookConsultService
{
    if ([FKXUserManager needShowLoginVC])
    {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
    }else
    {
        //        if (![WXApi isWXAppInstalled]) {
        //            [self showHint:@"当前不在线"];
        //            return;
        //        }else
        if (_secondModel.listenerId == [FKXUserManager getUserInfoModel].uid)
        {
            [self showHint:@"不能咨询自己"];
            return;
        }
        
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setValue:_secondModel.listenerId forKey:@"uid"];
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
        
        payView.labTitle.text = @"咨询";
        payView.labPrice.text = [NSString stringWithFormat:@"%.2f", [_payParameterDic[@"money"] doubleValue]/100];
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
#pragma mark - 咨询支付流程  --end
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
                switch (myClickType) {
                    case ClickPayType_accept:
                        [self showHint:acceptAlertStr];
                        [self.navigationController popViewControllerAnimated:YES];
                        break;
                    case ClickPayType_praise:
                        [_myWebView reload];
                        [self showHint:@"赞赏成功，谢谢客官打赏"];
                        break;
                    case ClickPayType_consult:
                        [self showHint:@"支付成功，等待对方确认"];
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
