//
//  FKXChangePasswordTableViewController.m
//  Fakaixin
//
//  Created by 袁少华 on 16/1/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChangePasswordTableViewController.h"

@interface FKXChangePasswordTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *MyTableView;
@property (weak, nonatomic) IBOutlet UITextField *OldPassWordTextField;

@property (weak, nonatomic) IBOutlet UITextField *NewPassWordTextField;
@property (weak, nonatomic) IBOutlet UITextField *RepeatPassWordTextField;
- (IBAction)GoBackAtion:(id)sender;

- (IBAction)SaveNewPasswordAction:(id)sender;


@end

@implementation FKXChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     _MyTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}



- (IBAction)GoBackAtion:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)SaveNewPasswordAction:(id)sender {
    
    [_OldPassWordTextField resignFirstResponder];
    
    [_NewPassWordTextField resignFirstResponder];
    [_RepeatPassWordTextField resignFirstResponder];
    
    if(!_OldPassWordTextField.text.length)
    {
        [self showAlertViewWithTitle:@"旧密码不能为空!"];
        return;
    }else if (!_NewPassWordTextField.text.length)
    {
        [self showAlertViewWithTitle:@"新密码不能为空!"];
        return;
    }else if (!_RepeatPassWordTextField.text.length)
    {
        [self showAlertViewWithTitle:@"重复密码不能为空!"];
        return;
    }else if (![_RepeatPassWordTextField.text isEqualToString:_NewPassWordTextField.text])
    {
        [self showAlertViewWithTitle:@"两次密码不一致!"];
        return;
    }else
    {
        [self showHudInView:self.view hint:@"正在修改..."];
        NSDictionary *paramDic = @{@"oldPwd":[SecurityUtil encryptMD5String:_OldPassWordTextField.text],@"newPwd": [SecurityUtil encryptMD5String:_NewPassWordTextField.text]};//下边也需要用md5的
        
        [AFRequest sendGetOrPostRequest:@"user/resetpwd"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
         {
             [self hideHud];
             if ([data[@"code"] integerValue] == 0)
             {
                 [self showAlertViewWithTitle:@"修改成功"];
                 
                 [FKXUserManager shareInstance].currentUserPassword = _NewPassWordTextField.text;
                 [self.navigationController popViewControllerAnimated:YES];
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
