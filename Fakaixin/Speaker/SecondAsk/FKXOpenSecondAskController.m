//
//  FKXOpenSecondAskController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXOpenSecondAskController.h"
#import "FKXPersonalViewController.h"
#import <QiniuSDK.h>
#import "NSString+Extension.h"

#import "FKXZiXunShiV.h"

#define ImageSize 1024 * 500
#define kIsShowMoreInfo (![_userModel.role integerValue] && !_isOpen) ? NO : YES//只有当角色是0（倾诉者），并且不开通，就把姓名以下的设置界面屏蔽掉

//navBar 筛选按钮大小
#define kFilterBtnWidth 77
#define kFilterBtnHeight 22

@interface FKXOpenSecondAskController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
{
    NSInteger times;
    NSTimer * timer;
    
    NSInteger role;
    UIImage *imageSelected;
    NSMutableArray *goodAtsArr;//擅长领域
    
    UIView *transViewPay;   //透明图
    FKXZiXunShiV *payView;    //界面

}

@property (weak, nonatomic) IBOutlet UITextField *tfUserName;//不设代理，代理方法只对两个价格有效
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (weak, nonatomic) IBOutlet UITextView *myTitle;
@property (weak, nonatomic) IBOutlet UITextView *myIntroduceTV;
@property (weak, nonatomic) IBOutlet UITextField *myPriceTF;//提问费
@property (weak, nonatomic) IBOutlet UITextField *tfConsultPrice;//咨询费

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;//手机号
@property (weak, nonatomic) IBOutlet UITextField *yanzhengTF;//验证码
@property (weak, nonatomic) IBOutlet UITextField *mimaTF;//密码
@property (weak, nonatomic) IBOutlet UILabel *timeL;//获取验证码
@property (weak, nonatomic) IBOutlet UIButton *bangDingBtn;


@property (weak, nonatomic) IBOutlet UITextField *phonePrice;

@property (weak, nonatomic) IBOutlet UIView *myFooterView;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) IBOutlet UIView *viewGoodAt;

@property (nonatomic,copy) NSString *clientNum;
@property (nonatomic,copy) NSString *clientPwd;
@property (nonatomic,copy) NSString *creatTime;


@property (nonatomic,assign) NSInteger yanzhengCode;

@end

@implementation FKXOpenSecondAskController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    role = 1;
    goodAtsArr = [NSMutableArray arrayWithCapacity:1];

    self.yanzhengCode = 0;
    self.clientNum = @"";
    self.clientPwd = @"";
    
    //只要进这个界面就给头像和昵称赋值
    [_btnIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_userModel.head, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    

    [self.timeL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recciveCode)]];
    
    _tfUserName.text = _userModel.name;
    if (_isOpen) {
        self.navTitle = @"成为心理关怀师";
    }else
    {
        self.navTitle = @"编辑资料";
        _myPriceTF.text = [NSString stringWithFormat:@"%ld", [_userModel.price integerValue]/100];
        _tfConsultPrice.text = [NSString stringWithFormat:@"%ld", [_userModel.consultingFee integerValue]/100];
        _phonePrice.text = [NSString stringWithFormat:@"%ld", [_userModel.phonePrice integerValue]/100];
        _myTitle.text = _userModel.profession;
        _myIntroduceTV.text = _userModel.profile;
    }
    _myFooterView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 360);
    
    if (_isShowClose) {
        UIImage *image = [UIImage imageNamed:@"img_nav_close"];
        UIButton * leftBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [leftBarBtn setImage:image forState:UIControlStateNormal];
        [leftBarBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    }
    
    if (self.userModel.mobile) {
        self.phoneTF.text = self.userModel.mobile;
        self.phoneTF.enabled = NO;
        
        [self.mimaTF removeFromSuperview];
    }
    
    if (self.userModel.clientNum) {
        self.phoneTF.text = self.userModel.mobile;
        self.phoneTF.enabled = NO;
       
        [self.mimaTF removeFromSuperview];
        [self.yanzhengTF removeFromSuperview];
        [self.timeL removeFromSuperview];
        self.bangDingBtn.enabled = NO;
        
        self.clientNum = self.userModel.clientNum;
        self.clientPwd = self.userModel.clientPwd;
    }
    
    //擅长领域
    [self createGoodAtViews];
}
- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 擅长领域
- (void)createGoodAtViews
{
    NSArray *arrTitleGoodAt = @[@"婚恋出轨", @"失恋阴影", @"夫妻相处", @"婆媳关系"];
    CGFloat xMargin = (self.view.width - kFilterBtnWidth*3)/4;
    CGFloat yBtn = 45;
    for (int i = 0; i < arrTitleGoodAt.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 3) {
            yBtn += 12 + kFilterBtnHeight;
        }
        btn.frame = CGRectMake(xMargin + (kFilterBtnWidth + xMargin)*(i%3), yBtn, kFilterBtnWidth, kFilterBtnHeight);
        [btn setTitle:arrTitleGoodAt[i] forState:UIControlStateNormal];
        btn.titleLabel.font = kFont_F4();
        btn.tag = 200 + i;
        [btn addTarget:self action:@selector(clickBtnGoodAt:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:UIColorFromRGB(0x5c5c5c) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.layer.borderColor = UIColorFromRGB(0x51b5ff).CGColor;
        btn.layer.borderWidth = 1.0;
        btn.layer.cornerRadius = 5;
        
        if ([_userModel.goodAt containsObject:@(btn.tag - 200)]) {
            btn.selected = YES;
            btn.backgroundColor = UIColorFromRGB(0x51b5ff);
            [goodAtsArr addObject:@(btn.tag - 200)];
        }
        [_viewGoodAt addSubview:btn];
    }
}
- (void)clickBtnGoodAt:(UIButton *)btn
{
    if (goodAtsArr.count == 3 && !btn.selected) {
        [self showHint:@"最多选3个～"];
        return;
    }
    btn.selected = !btn.selected;

    if (btn.selected) {
        btn.backgroundColor = UIColorFromRGB(0x51b5ff);
        [goodAtsArr addObject:@(btn.tag - 200)];
    }else{
        btn.backgroundColor = [UIColor whiteColor];
        [goodAtsArr removeObject:@(btn.tag - 200)];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
#pragma mark - 点击事件

//获取验证码
- (void)recciveCode {
    [self.view endEditing:YES];
    
    if (![self.phoneTF.text isRealPhoneNumber]) {
        [self showAlertViewWithTitle:@"手机格式不正确"];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    if (self.userModel.mobile) {
        [dic setObject:self.phoneTF.text forKey:@"mobile"];
        [dic setObject:@(5) forKey:@"type"];

    }else {
        [dic setObject:self.phoneTF.text forKey:@"mobile"];
        [dic setObject:@(2) forKey:@"type"];
    }

    [AFRequest sendGetOrPostRequest:@"sys/mobilecode"param:dic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showAlertViewWithTitle:@"已发送至您的手机"];
             NSInteger codeNum =[data[@"data"] integerValue];
             self.yanzhengCode = codeNum;
             
             [self startTimer];
             
         }else if ([data[@"code"] integerValue] == 4)
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

//点击完成验证
- (IBAction)yanzheng:(id)sender {
    [self.view endEditing:YES];
 
    if ([NSString isEmpty:self.phoneTF.text] && ![self.phoneTF.text isRealPhoneNumber]) {
        [self showHint:@"手机格式错误"];
        return;
    }else if ([NSString isEmpty:self.yanzhengTF.text])
    {
        [self showHint:@"请输入验证码"];
        return;
    }else if ([self.yanzhengTF.text integerValue] != self.yanzhengCode) {
        [self showHint:@"验证码错误！"];
        return;
    }
    else if (!self.userModel.mobile && [NSString isEmpty:self.mimaTF.text])
    {
        [self showHint:@"请输入密码"];
        if (self.mimaTF.text.length<6 ||self.mimaTF.text.length>11) {
            [self showHint:@"密码的长度为6~11位"];
            return;
        }
        return;
    }
    
    //开始申请client
    [self requsetClient];
  
    //将手机号，手机密码，ClientNum ,ClientPwd,creatTime 存入
//    [self addToData];
    
}


//点击保存按钮
- (IBAction)clickToOpen:(UIButton *)sender
{
    [self.view endEditing:YES];
    NSDictionary *paramDic;

    if ([NSString isEmpty:_tfUserName.text]) {
        [self showHint:@"请输入昵称"];
        return;
    }else if (_tfUserName.text.length <2) {
        [self showHint:@"昵称字数要大于2~"];
        return;
    }

    if (kIsShowMoreInfo) {
        
        if ([NSString isEmpty:self.phoneTF.text]) {
            [self showHint:@"请填写您的手机号"];
            return;
        }
        
        if ([NSString isEmpty:self.clientNum]) {
            [self showHint:@"请绑定您的手机号"];
            return;
        }
        
        NSString *title = [_myTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *profile = [_myIntroduceTV.text stringByReplacingOccurrencesOfString:@" "  withString:@""];
        if ([NSString isEmpty:title]) {
            [self showHint:@"请输入头衔"];
            return;
        }else if (title.length<10) {
            [self showHint:@"头衔的字数要大于10"];
            return;
        }
        else if ([NSString isEmpty:profile]) {
            [self showHint:@"请输入简介"];
            return;
        }else if (profile.length<20) {
            [self showHint:@"简介的字数要大于20"];
            return;
        }
        else if ([_myPriceTF.text integerValue] < 1|| [_myPriceTF.text integerValue] > 100) {
            [self showHint:@"价格只能在1到100元之间"];
            return;
        }else if ([_tfConsultPrice.text integerValue] <= 0) {
            [self showHint:@"咨询费需大于0元"];
            return;
        }else if ([_phonePrice.text integerValue] <= 20) {
            [self showHint:@"咨询费需大于20元"];
            return;
        }else if (!goodAtsArr.count)
        {
            [self showHint:@"擅长领域至少选一个～"];
            return;
        }
        
        paramDic = @{@"profile" : profile, @"profession":title, @"price":@([_myPriceTF.text integerValue]*100), @"role" : @(role),@"name" : _tfUserName.text,@"goodAt":goodAtsArr,@"consultingFee" : @([_tfConsultPrice.text integerValue]*100),@"phonePrice":@([_phonePrice.text integerValue]*100)};
    }else{
        paramDic = @{@"name" : _tfUserName.text};
    }
    [AFRequest sendGetOrPostRequest:@"user/edit"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         if ([data[@"code"] integerValue] == 0)
         {
             FKXUserInfoModel *model = _userModel;
             model.name = _tfUserName.text;
             if (kIsShowMoreInfo) {
                 model.profession = _myTitle.text;
                 model.profile = _myIntroduceTV.text;
                 model.role = @(role);
             }
             [FKXUserManager archiverUserInfo:model toUid:[model.uid stringValue]];
         
                 if (_isShowClose) {//如果是present的此界面
                     [self dismissViewControllerAnimated:YES completion:^{
                         if (_isOpen) {
                             [self showView];
                         }
                     }];
                 }else {
                     [self.navigationController popViewControllerAnimated:YES];
                     if (_isOpen) {
                         [self showView];
                }
             }
             
             //登陆成功之后，按照以下代码设置当前登录用户的apns昵称
             [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[model.uid stringValue]
                                                                 password:@"fakaixin" completion:^(NSDictionary *loginInfo, EMError *error) {
                                                                     [self hideHud];
                                                                     if (loginInfo && !error)
                                                                     {
                                                                         //设置推送设置
                                                                         [[EaseMob sharedInstance].chatManager setApnsNickname:_tfUserName.text];
                                                                     }
                                                                 } onQueue:nil];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
         [self hideHud];
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}

- (void)showView {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transViewPay)
    {
        //透明背景
        transViewPay = [[UIView alloc] initWithFrame:screenBounds];
        transViewPay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewPay.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewPay];
        
        payView = [[[NSBundle mainBundle] loadNibNamed:@"FKXZiXunShiV" owner:nil options:nil] firstObject];
        [payView.closeBtn addTarget:self action:@selector(hiddentransViewPay) forControlEvents:UIControlEventTouchUpInside];
        [payView.shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
       
        [transViewPay addSubview:payView];
        payView.center = transViewPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewPay.alpha = 1.0;
        }];
        
    }

}

- (void)share {
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[NSURL URLWithString:@""]];
    NSString *urlStr;
    if ([FKXUserManager shareInstance].inviteCode) {
        urlStr = [NSString stringWithFormat:@"%@front/share.html?inviteCode=%@", kServiceBaseURL,[FKXUserManager shareInstance].inviteCode];
    }else{
        urlStr = [NSString stringWithFormat:@"%@front/share.html", kServiceBaseURL];
    }
    [shareParams SSDKSetupShareParamsByText:@"安抚你的小情绪"
                                     images:imageArray
     
                                        url:[NSURL URLWithString:urlStr]
                                      title:@"如何安全优雅地呵呵"
                                       type:SSDKContentTypeAuto];
    //单个分享
    SSDKPlatformType type = SSDKPlatformSubTypeWechatSession;
    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 [self shareSuccessCallBack];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享取消"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
         }
     }];
}

- (void)shareSuccessCallBack
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"uid"];
    [AFRequest sendGetOrPostRequest:@"sys/share_app" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hiddentransViewPay];
    } failure:^(NSError *error) {
    }];
}

- (void)hiddentransViewPay
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewPay.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewPay removeFromSuperview];
        transViewPay = nil;
        
        SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
        //展示切换模式动画
        FKXBaseNavigationController *nav = [tab.viewControllers lastObject];
        FKXPersonalViewController *vc = [nav viewControllers][0];
        [vc clickOpenAsk:nil];
    }];
    
    
}

//存入绑定手机
- (void)addToData {
    
    NSDictionary *paramDic;

    //未绑定手机号，传入手机号，登录密码，clientPwd，clientNum
    if (!self.userModel.mobile) {
      paramDic = @{@"mobile" : self.phoneTF.text, @"pwd":self.mimaTF.text, @"clientNum":self.clientNum, @"clientPwd" : self.clientPwd};
    }
    //已绑定手机号 ，只需传入clientPwd，clientNum
    else {
        paramDic = @{@"clientNum":self.clientNum, @"clientPwd" : self.clientPwd};
    }
    
    [AFRequest sendGetOrPostRequest:@"user/edit"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"绑定手机成功"];
             self.bangDingBtn.enabled = NO;
 
             FKXUserInfoModel *model = _userModel;
             model.clientNum = self.clientNum;
             model.clientPwd = self.clientPwd;

             
             if (!model.mobile) {
                 model.mobile = self.phoneTF.text;
                 model.pwd = self.mimaTF.text;
             }

             [FKXUserManager archiverUserInfo:model toUid:[model.uid stringValue]];

         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
         [self hideHud];
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
 
}

- (void)requsetClient {
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:@{                                            @"appId":ResetAppId,@"charge": @"0",@"mobile":self.phoneTF.text,@"clientType": @"0"}, @"client",nil];
    [AFRequest sendResetPostRequest:@"Clients" param:params success:^(id data) {
        NSString *respCode = data[@"resp"][@"respCode"];
        if ([respCode isEqualToString:@"103114"]) {
            //已经绑定Client 但是没有存入数据库，查询当前绑定信息
            [self selectClient];
        }
        else if ([respCode isEqualToString:@"000000"]) {
//            [self showHint:@"绑定成功"];
            NSDictionary *clientDic = data[@"resp"][@"client"];
            
            self.clientNum = clientDic[@"clientNum"];
            self.clientPwd = clientDic[@"clientPwd"];
            self.creatTime = clientDic[@"createDate"];

            [self addToData];

        }else {
            [self showHint:@"绑定失败"];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self showHint:@"网络出错"];
        [self hideHud];

    }];
}

- (void)selectClient {
    NSString *param = [NSString stringWithFormat:@"&mobile=%@&appId=%@",self.phoneTF.text,ResetAppId];
    [AFRequest sendResetGetRequest:@"ClientsByMobile" param:param success:^(id data) {
        if ([data[@"resp"][@"respCode"] isEqualToString:@"000000"]) {
            self.clientNum = data[@"resp"][@"client"][@"clientNumber"];
            self.clientPwd = data[@"resp"][@"client"][@"clientPwd"];
            self.creatTime = data[@"resp"][@"client"][@"createDate"];
            
            [self addToData];

        }else {
            [self showHint:@"绑定失败"];
        }
    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];
}


- (IBAction)swichValueChanged:(UISwitch *)sender {
    role = sender.on ? 3 : 1;
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark - UITableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!kIsShowMoreInfo) {
        if (indexPath.row) {
            return 0;
        }
        return 130;
    }else{
        switch (indexPath.row) {
            case 0:
                return 130;
                break;
            case 1:
                return 95;
                break;
            case 2:
                return 102;
                break;
            case 3:
                if (!self.userModel.mobile) {
                    return 220;
                }else {
                    if (!self.userModel.clientNum) {
                        return 180;
                    }
                    return 130;
                }
                break;
            case 4:
                return 50;
                break;
            case 5:
                return 50;
                break;
            case 6:
                return 50;
                break;
            case 7:
                return 140;
                break;
            case 8:
                //如果已经设置了0以上的角色，就将“是否是心理咨询师那一行屏蔽掉
                if ([_userModel.role integerValue]) {
                    return 0;
                }
                return 51;
                break;
            default:
                return 0;
                break;
        }
    }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    if (![string isEqualToString:@""])
    {
        const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
        if (*ch < 48 || *ch > 57) {
            return NO;
        }
    }
    return YES;
}

-(void)startTimer
{
    self.timeL.userInteractionEnabled=NO;
    times=60;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeload) userInfo:nil repeats:YES];
            [timer fire];
            [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop]run];
        }
        
    });
}
-(void)timeload
{
    
    times=times-1;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (times>0) {
            self.timeL.textColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1];
            self.timeL.text = [NSString stringWithFormat:@"%lds",(long)times];
        }else
        {
            [timer invalidate];
            timer=nil;
            self.timeL.text = @"重新发送";
            self.timeL.userInteractionEnabled=YES;
            
        }
        
    });
    
    
}


#pragma mark - 编辑个人资料
- (IBAction)goEdit:(id)sender {
    [_tfUserName becomeFirstResponder];
}
-(IBAction)commitLogo:(id)sender
{
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从手机相册中选择", nil];
    actionSheet.tag = 1001;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
//上传头像
- (void)sendIcon:(NSData *)dataImage
{
    __block  NSString *token = @"";
    
    NSDictionary *paramDic = @{};
    
    [AFRequest sendGetOrPostRequest:@"user/upload_image"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             token = data[@"data"][@"token"];
             [self uploadIconByData:dataImage token:token];
             
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
         
         
     } failure:^(NSError *error) {
         [self showAlertViewWithTitle:@"网络出错"];
         [self hideHud];
     }];
}
- (void)uploadIconByData:(NSData *)data token:(NSString *)token
{
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    //    NSData *data = [@"Hello, World!" dataUsingEncoding: NSUTF8StringEncoding];
    
    [upManager putData:data key:nil token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  
                  NSLog(@"七牛上传图片info:%@", info);
                  NSLog(@"七牛上传图片resp:%@", resp);
                  if (resp[@"hash"])
                  {
                      [self uploadIconByHash:resp[@"hash"]];
                  }
                  
              } option:nil];
}
- (void)uploadIconByHash:(NSString *)hash
{
    NSDictionary *paramDic = @{@"key":hash};
    
    [AFRequest sendGetOrPostRequest:@"user/head_url"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"上传成功"];
             [_btnIcon setBackgroundImage:imageSelected forState:UIControlStateNormal];
             NSString *headUrl = data[@"data"];
             FKXUserInfoModel *model = [FKXUserManager getUserInfoModel];
             model.head = headUrl;
             if (headUrl)
             {
                 [FKXUserManager archiverUserInfo:model toUid:[model.uid stringValue]];
             }
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
         
         
     } failure:^(NSError *error) {
         [self showAlertViewWithTitle:@"网络出错"];
         [self hideHud];
     }];
}
#pragma mark --- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001)
    {
        UIImagePickerControllerSourceType type;
        if (buttonIndex == 2)
        {
            return;
        }
        switch (buttonIndex)
        {
            case 0:
                type=UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                type=UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            default:
                type=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
        }
        
        if (![UIImagePickerController isSourceTypeAvailable:type] )
        {
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"抱歉，您的设备不支持" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        UIImagePickerController * pickerController=[[UIImagePickerController alloc]init];
        pickerController.sourceType=type;
        pickerController.delegate=self;
        pickerController.allowsEditing = YES;
        [self presentViewController:pickerController animated:YES completion:nil];
        
    }
}

#pragma mark *** UIImagePickerControllerDelegate

//拍摄取消按钮点击
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//拍照完毕后或者照片选择完毕后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self showHudInView:self.view hint:@"正在上传"];
    
    UIImage * originalImage=[info  objectForKey:UIImagePickerControllerEditedImage];
    imageSelected = originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:
     ^{
         
         NSData * originaData = UIImageJPEGRepresentation(originalImage,0.7);
         
         UIImage *image;
         if (originaData.length > ImageSize)
         {
             image = [self reduceImage:originalImage toSize:CGSizeMake(originalImage.size.width * 0.9, originalImage.size.height * 0.9)];
             originaData = UIImageJPEGRepresentation(image,0.9);
         }
         
         [self sendIcon:originaData];
     }];
}
#pragma mark *** 裁剪图片
-(UIImage *)reduceImage:(UIImage *)image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData * data = UIImageJPEGRepresentation(newImage, 0.9);
    if (data.length > ImageSize)
    {
        [self reduceImage:newImage toSize:CGSizeMake(newImage.size.width * 0.9, newImage.size.height * 0.9)];
    }
    
    return newImage;
}
@end
