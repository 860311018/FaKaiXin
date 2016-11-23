//
//  FKXForgetPasswordVirificationCodeViewController.m
//  Fakaixin
//
//  Created by Connor on 10/17/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXForgetPasswordVirificationCodeViewController.h"
#import "FKXResetPasswordViewController.h"

@interface FKXForgetPasswordVirificationCodeViewController ()
{
    NSTimer *timer;
    NSInteger seconds;

}
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *btnGetInviteCode;

@end

@implementation FKXForgetPasswordVirificationCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_isModityPwd) {
        self.navTitle = @"修改密码";
    }else
    {
        self.navTitle = @"忘记密码";
    }
    seconds = 60;
    self.view.backgroundColor = kColor_MainBackground();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)clickNextStep:(id)sender {
    if (!_inviteCodeTF.text.length) {
        [self showHint:@"请输入验证码"];
        return;
    }
    FKXResetPasswordViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXResetPasswordViewController"];
    vc.isModityPwd = _isModityPwd;
    vc.phone = _phone;
    vc.inviteCode = _inviteCodeTF.text;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickGetInviteCode:(id)sender {
    
    [_inviteCodeTF resignFirstResponder];
    
    NSDictionary *paramDic = @{@"mobile" : _phone, @"type" : @(1)};
    
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
        _btnGetInviteCode.enabled = YES;
        seconds = 60;
        [ _btnGetInviteCode setTitle:@"获取验证码" forState: UIControlStateNormal];
        [ _btnGetInviteCode setTitleColor:UIColorFromRGB(0x0092ff)forState:UIControlStateNormal];
        _btnGetInviteCode.layer.borderColor = UIColorFromRGB(0x0092ff).CGColor;
        
        [ _btnGetInviteCode setEnabled:YES];
    }else{
        seconds--;
        _btnGetInviteCode.enabled = NO;
        NSString *title = [NSString stringWithFormat:@"%ld",(long)seconds];
        [ _btnGetInviteCode setTitleColor:UIColorFromRGB(0x989898)forState:UIControlStateNormal];
        _btnGetInviteCode.layer.borderColor = UIColorFromRGB(0x989898).CGColor;
        [ _btnGetInviteCode setEnabled:NO];
        [ _btnGetInviteCode setTitle:title forState:UIControlStateNormal];
    }
}
@end
