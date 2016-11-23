//
//  FKXResetPasswordViewController.m
//  Fakaixin
//
//  Created by Connor on 10/17/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXResetPasswordViewController.h"

@interface FKXResetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *resetPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButtonItem;

@end

@implementation FKXResetPasswordViewController
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_isModityPwd) {
        _resetPasswordTextField.placeholder = @"设置密码";
    }else
    {
        _resetPasswordTextField.placeholder = @"重置密码";
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_isModityPwd) {
        self.navTitle = @"修改密码";
    }else
    {
        self.navTitle = @"忘记密码";
    }
    
    self.view.backgroundColor = kColor_MainBackground();

    _resetPasswordTextField.placeholder = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickDone:(id)sender {
    
    [_resetPasswordTextField resignFirstResponder];
    [_confirmPasswordTextField resignFirstResponder];
    
    if (!_resetPasswordTextField.text.length)
    {
        [self showAlertViewWithTitle:@"重置密码不能为空!"];
        return;
    }else if (!_confirmPasswordTextField.text.length)
    {
        [self showAlertViewWithTitle:@"确认密码不能为空!"];
        return;
    }else if (![_confirmPasswordTextField.text isEqualToString:_resetPasswordTextField.text])
    {
        [self showAlertViewWithTitle:@"两次密码不一致!"];
        return;
    }else
    {
        [self showHudInView:self.view hint:@"正在修改..."];
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setValue:_phone forKey:@"mobile"];
        [paramDic setValue:[SecurityUtil encryptMD5String:_resetPasswordTextField.text] forKey:@"pwd"];
        [paramDic setValue:_inviteCode forKey:@"code"];
        [AFRequest sendGetOrPostRequest:@"user/findpwd"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
         {
             [self hideHud];
             if ([data[@"code"] integerValue] == 0)
             {
                 [self showAlertViewWithTitle:@"修改成功"];
                 
                 [FKXUserManager shareInstance].currentUserPassword = _resetPasswordTextField.text;
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
             else if ([data[@"code"] integerValue] == 4)
             {
                 [self showAlertViewWithTitle:data[@"message"]];
                 [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             }else{
                 [self showAlertViewWithTitle:data[@"message"]];
             }             
         } failure:^(NSError *error) {
             [self showHint:@"网络出错"];
             [self hideHud];
         }];
    }
}

@end
