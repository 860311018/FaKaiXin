//
//  FKXVerfityAlipayTableViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXVerfityAlipayTableViewController.h"

@interface FKXVerfityAlipayTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfAccountNo;
@property (weak, nonatomic) IBOutlet UITextField *tfAccountName;

@end

@implementation FKXVerfityAlipayTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isFromWithDraw) {
        self.navigationItem.leftBarButtonItem = nil;
        
    }else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"绑定支付宝";
    
    self.tableView.tableFooterView.frame = CGRectMake(0, 0, self.view.width, self.tableView.height - 2*44 - 64);

//    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
//    self.navigationController.navigationItem.leftBarButtonItem = left;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickCommit:(id)sender {
    
    if (!_tfAccountNo.text.length) {
        [self showAlertViewWithTitle:@"请输入支付宝登录账号"];
        return;
    }else if (!_tfAccountName.text.length) {
        [self showAlertViewWithTitle:@"请输入支付宝用户名"];
        return;
    }
    NSDictionary *paramDic = @{@"accountNo" : _tfAccountNo.text,@"accountName" : _tfAccountName.text};
    
    [AFRequest sendGetOrPostRequest:@"account/bindalipay"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([data[@"code"] integerValue] == 4)
        {            
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
            
        }
        else
        {
            [self showAlertViewWithTitle:data[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];

}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)clickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
