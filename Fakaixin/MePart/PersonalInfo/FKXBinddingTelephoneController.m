//
//  FKXBinddingTelephoneController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBinddingTelephoneController.h"
#import "FKXVerfityAlipayTableViewController.h"

@interface FKXBinddingTelephoneController ()
{
    NSTimer *timer;
    NSInteger seconds;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *customFootView;
@property (weak, nonatomic) IBOutlet UIButton *btnInputVerfityCode;
@property (weak, nonatomic) IBOutlet UIView *btnCommit;
@property (weak, nonatomic) IBOutlet UITextField *tfTele;
@property (weak, nonatomic) IBOutlet UITextField *tfVerfityCode;

@end

@implementation FKXBinddingTelephoneController
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (_isFromWithDraw) {
        self.navigationItem.leftBarButtonItem = nil;
        
    }else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.navTitle = @"绑定手机号";
    seconds = 60;
    _btnInputVerfityCode.layer.borderColor = RGBACOLOR(0, 146, 255, 1.0).CGColor;
    _btnInputVerfityCode.layer.borderWidth = 1.0;
    _btnInputVerfityCode.layer.cornerRadius = 3.5;

    _btnCommit.layer.cornerRadius = 5;

    _customFootView.frame = CGRectMake(0, 0, _myTableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 41*2 -1 -64);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _myTableView.frame.size.width, 8)];
    view.backgroundColor = RGBACOLOR(243, 243, 243, 1.0);
    return view;
}

#pragma mark - 点击事件
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//倒计时方法验证码实现倒计时60秒，60秒后按钮变换开始的样子
-(void)timerFireMethod:(NSTimer *)theTimer {
    if (seconds == 1) {
        [theTimer invalidate];
        _btnInputVerfityCode.enabled = YES;
        seconds = 60;
        [_btnInputVerfityCode setTitle:@"获取验证码" forState: UIControlStateNormal];
        [_btnInputVerfityCode setTitleColor:UIColorFromRGB(0x0092ff)forState:UIControlStateNormal];
        _btnInputVerfityCode.layer.borderColor = UIColorFromRGB(0x0092ff).CGColor;

        [_btnInputVerfityCode setEnabled:YES];
    }else{
        seconds--;
        _btnInputVerfityCode.enabled = NO;
        NSString *title = [NSString stringWithFormat:@"%ld",(long)seconds];
        [_btnInputVerfityCode setTitleColor:UIColorFromRGB(0x989898)forState:UIControlStateNormal];
        _btnInputVerfityCode.layer.borderColor = UIColorFromRGB(0x989898).CGColor;
        [_btnInputVerfityCode setEnabled:NO];
        [_btnInputVerfityCode setTitle:title forState:UIControlStateNormal];
    }
}
- (IBAction)clickVerfityCode:(id)sender {
    
    [_tfTele resignFirstResponder];
    [_tfVerfityCode resignFirstResponder];
    
    if (_tfTele.text.length != 11) {
        [self showAlertViewWithTitle:@"手机格式不正确"];
        return;
    }
    
    NSDictionary *paramDic = @{@"mobile" : _tfTele.text, @"type" : @(2)};
    
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

- (IBAction)clickCommit:(id)sender {
    
    if (_tfTele.text.length != 11) {
        [self showAlertViewWithTitle:@"手机格式不正确"];
        return;
    }
    if (!_tfVerfityCode.text.length) {
        [self showAlertViewWithTitle:@"请输入验证码"];
        return;
    }
    NSDictionary *paramDic = @{@"mobile" : _tfTele.text, @"code" : _tfVerfityCode.text};
    
    [AFRequest sendGetOrPostRequest:@"sys/bindmobile"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            FKXUserInfoModel *model = [FKXUserManager getUserInfoModel];
            model.mobile = _tfTele.text;
            [FKXUserManager archiverUserInfo:model toUid:[model.uid stringValue]];
            if (_isFromWithDraw) {
                FKXVerfityAlipayTableViewController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXVerfityAlipayTableViewController"];
                vc.isFromWithDraw = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else
            {
                [self showAlertViewWithTitle:@"绑定成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showAlertViewWithTitle:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];

}
- (IBAction)clickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark textfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_tfTele resignFirstResponder];
    [_tfVerfityCode resignFirstResponder];
    return YES;
}
@end
