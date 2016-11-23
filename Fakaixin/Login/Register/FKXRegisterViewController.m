//
//  FKXRegisterViewController.m
//  Fakaixin
//
//  Created by Connor on 10/15/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXRegisterViewController.h"
#import "FKXProtocolViewController.h"

@interface FKXRegisterViewController ()
{
    NSTimer *timer;
    NSInteger seconds;
    
    NSString *inviteCode;   //邀请码
}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *virificationCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *fetchVirificationCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation FKXRegisterViewController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetTheInviteCode" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    seconds = 60;
    [self configView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTheInviteCode:) name:@"GetTheInviteCode" object:nil];
}

-(void)configView {
    
    UILabel * labProtocol = [[UILabel alloc] initWithFrame:CGRectMake(0, 320, self.view.size.width, 30)];
    labProtocol.font = kFont_F5();
    labProtocol.textColor = kColor_MainDarkGray();
    labProtocol.textAlignment = NSTextAlignmentCenter;
    labProtocol.backgroundColor = [UIColor clearColor];
    [self.view addSubview: labProtocol];
    
    NSString *content = @"点击注册,即视为同意伐开心服务协议";
    NSMutableAttributedString *attContent = [[NSMutableAttributedString alloc] initWithString:content];
    
    [attContent addAttribute:NSForegroundColorAttributeName value:kColor_MainLightGray() range:[content rangeOfString:@"伐开心服务协议"]];
    [attContent addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:[content rangeOfString:@"伐开心服务协议"]];
    labProtocol.attributedText = attContent;
    labProtocol.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookUserProtocol)];
    [labProtocol addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 通知
- (void)getTheInviteCode:(NSNotification *)not
{
    inviteCode = not.userInfo[@"inviteCode"];
}
#pragma mark - 事件
-(IBAction)clickRigister:(id)sender
{
    [_phoneNumberTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_virificationCodeTextField resignFirstResponder];

    if (_phoneNumberTextField.text.length != 11) {
        [self showHint:@"手机格式错误"];
        return;
    }else if (!_virificationCodeTextField.text.length)
    {
        [self showHint:@"请输入验证码"];
        return;
    }else if (!_passwordTextField.text.length)
    {
        [self showHint:@"请输入密码"];
        return;
    }
    [self showHudInView:self.view hint:@"注册中..."];
    
    NSString *device = [FKXUserManager shareInstance].deviceTokenString  ? [FKXUserManager shareInstance].deviceTokenString :@"";
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionNum = [infoDict objectForKey:@"CFBundleVersion"];
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paraDic setValue:_phoneNumberTextField.text forKey:@"mobile"];
    [paraDic setValue:[SecurityUtil encryptMD5String:_passwordTextField.text] forKey:@"pwd"];
    [paraDic setValue:_virificationCodeTextField.text forKey:@"code"];
    [paraDic setValue:inviteCode forKey:@"inviteCode"];
    [paraDic setValue:@(1) forKey:@"os"];
    [paraDic setValue:device forKey:@"deviceToken"];
    [paraDic setValue:[NSString stringWithFormat:@"AppStore%@",versionNum] forKey:@"channel"];
    
    [FKXUserInfoModel sendGetOrPostRequest:@"user/register" param:paraDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             [self showHint:@"注册成功"];
             
             FKXUserInfoModel *model = data;
             [FKXUserManager archiverUserInfo:data toUid:[model.uid stringValue]];
             [FKXUserManager shareInstance].currentUserId = [model.uid integerValue];
             [FKXUserManager shareInstance].currentUserToken = model.token;
             [FKXUserManager shareInstance].currentUserPassword = [SecurityUtil encryptMD5String:_passwordTextField.text];
             //登录成功调用环信登录
             //在您调用登录方法前，应该先判断是否设置了自动登录，如果设置了，则不需要您再调用
             BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
             if (!isAutoLogin)
             {
                 [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[model.uid stringValue] password:@"fakaixin" completion:^(NSDictionary *loginInfo, EMError *error)
                  {
                      if (!error && loginInfo) {
                          NSLog(@"登录成功,用户信息:%@", loginInfo);
                          // 设置自动登录
//                          [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                          //设置推送设置
                          [[EaseMob sharedInstance].chatManager setApnsNickname:model.name];
                          
                          [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccessAndNeedRefreshAllUI object:nil userInfo:@{@"status" : @"login"}];
                      }
                      if (error) {
                          NSLog(@"登陆失败:%@", error);
                      }
                      
                  } onQueue:nil];
             }
             [self dismissViewControllerAnimated:YES completion:nil];
         }
         else if (errorModel)
         {
            [self showHint:errorModel.message];
         }
     }];

}
-(IBAction)clickGetVerfyCode:(id)sender
{
    [_phoneNumberTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_virificationCodeTextField resignFirstResponder];
    
    if (_phoneNumberTextField.text.length != 11) {
        [self showAlertViewWithTitle:@"手机格式不正确"];
        return;
    }
    
    NSDictionary *paramDic = @{@"mobile" : _phoneNumberTextField.text, @"type" : @(0)};//_tfTele.text
    
    [AFRequest sendGetOrPostRequest:@"sys/mobilecode"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showAlertViewWithTitle:@"已发送至您的手机"];
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
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}
//倒计时方法验证码实现倒计时60秒，60秒后按钮变换开始的样子
-(void)timerFireMethod:(NSTimer *)theTimer {
    if (seconds == 1) {
        [theTimer invalidate];
        _fetchVirificationCodeButton.enabled = YES;
        seconds = 60;
        [ _fetchVirificationCodeButton setTitle:@"获取验证码" forState: UIControlStateNormal];
        [ _fetchVirificationCodeButton setTitleColor:UIColorFromRGB(0x0092ff)forState:UIControlStateNormal];
         _fetchVirificationCodeButton.layer.borderColor = UIColorFromRGB(0x0092ff).CGColor;
        
        [ _fetchVirificationCodeButton setEnabled:YES];
    }else{
        seconds--;
         _fetchVirificationCodeButton.enabled = NO;
        NSString *title = [NSString stringWithFormat:@"%ld",(long)seconds];
        [ _fetchVirificationCodeButton setTitleColor:UIColorFromRGB(0x989898)forState:UIControlStateNormal];
         _fetchVirificationCodeButton.layer.borderColor = UIColorFromRGB(0x989898).CGColor;
        [ _fetchVirificationCodeButton setEnabled:NO];
        [ _fetchVirificationCodeButton setTitle:title forState:UIControlStateNormal];
    }
}
#pragma mark - 跳转
- (void)lookUserProtocol
{
    NSString *protocol = kProtocolUser;
    NSString *title = @"用户协议";
    FKXProtocolViewController *vc = [[FKXProtocolViewController alloc] initWithNibName:nil bundle:nil url:protocol title:title];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
