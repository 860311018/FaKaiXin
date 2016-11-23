//
//  FKXInviteCodeViewController.m
//  Fakaixin
//
//  Created by Connor on 10/15/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXInviteCodeViewController.h"

@interface FKXInviteCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *invitationCodeTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButtonItem;

@end

@implementation FKXInviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"邀请码";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 单击事件

- (IBAction)clickConfirm:(id)sender
{
    [_invitationCodeTextField resignFirstResponder];
    if (!_invitationCodeTextField.text.length) {
        [self showHint:@"请输入邀请码"];
        return;
    }
    NSDictionary *paramDic = @{@"inviteCode": _invitationCodeTextField.text};
    
    [AFRequest sendGetOrPostRequest:@"sys/validateinvite"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
        if ([data[@"code"] integerValue] == 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTheInviteCode" object:nil userInfo:@{@"inviteCode":_invitationCodeTextField.text}];
            [self showAlertViewWithTitle:@"邀请码有效"];
            [self.navigationController popViewControllerAnimated:YES];
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
        
    }];
   
}
@end
