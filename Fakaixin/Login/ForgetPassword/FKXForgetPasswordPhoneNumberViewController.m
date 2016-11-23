//
//  FKXForgetPasswordPhoneNumberViewController.m
//  Fakaixin
//
//  Created by Connor on 10/17/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXForgetPasswordPhoneNumberViewController.h"
#import "FKXForgetPasswordVirificationCodeViewController.h"

@interface FKXForgetPasswordPhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButtonItem;

@end

@implementation FKXForgetPasswordPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;

    if (_isModityPwd) {
        self.navTitle = @"修改密码";
    }else
    {
        self.navTitle = @"忘记密码";
    }
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.phoneNumberTextField.text.length != 11) {
        [self showHint:@"手机格式不对"];
        return NO;
    }
    return self.phoneNumberTextField.text.length == 11;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FKXForgetPasswordVirificationCodeViewController *vc = segue.destinationViewController;
    vc.isModityPwd = _isModityPwd;
    vc.phone = _phoneNumberTextField.text;
}


@end
