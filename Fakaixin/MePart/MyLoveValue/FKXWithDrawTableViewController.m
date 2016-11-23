//
//  FKXWithDrawTableViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXWithDrawTableViewController.h"
#import "FKXCaptchaView.h"

@interface FKXWithDrawTableViewController ()<UITextFieldDelegate>
{
    FKXCaptchaView *captchaView;
    UIView *transparentView;
    NSTimer *timer;
    NSInteger seconds;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *labRemaining;
@property (weak, nonatomic) IBOutlet UITextField *tfWithdraw;

@property (weak, nonatomic) IBOutlet UIButton *btnWithdraw;
@property (weak, nonatomic) IBOutlet UIView *customFootView;
@end

@implementation FKXWithDrawTableViewController
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [captchaView.tfInput resignFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    seconds = 60;
    _labRemaining.text = self.money;
    _tfWithdraw.placeholder = @"请输入金额";
    _btnWithdraw.layer.cornerRadius = 3;
    
    _customFootView.frame = CGRectMake(0, 0, _myTableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 41- 68 -64);
    
    [self createCaptchaView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 创建子视图
- (void)createCaptchaView
{
    if (!transparentView) {
        //透明背景
        transparentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        transparentView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
        transparentView.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:transparentView];
    }
    if (!captchaView)
    {
        captchaView = [[[NSBundle mainBundle] loadNibNamed:@"CaptchaView" owner:nil options:nil] firstObject];
        captchaView.tfInput.delegate = self;
        captchaView.tfInput.borderStyle = UITextBorderStyleNone;
        captchaView.btnConfirm.layer.cornerRadius = 2.0;
        captchaView.tfInput.layer.borderColor = RGBACOLOR(152, 152, 152, 1.0).CGColor;
        captchaView.tfInput.layer.borderWidth = 0.5;
        captchaView.tfInput.layer.cornerRadius = 2.0;
        
        captchaView.btnVerfyCode.layer.borderColor = RGBACOLOR(0, 146, 255, 1.0).CGColor;
        captchaView.btnVerfyCode.layer.borderWidth = 0.5;
        captchaView.btnVerfyCode.layer.cornerRadius = 2.0;
        [captchaView.btnClose addTarget:self action:@selector(hiddenTransparentView) forControlEvents:UIControlEventTouchUpInside];
        [captchaView.btnVerfyCode addTarget:self action:@selector(getVerfyCode) forControlEvents:UIControlEventTouchUpInside];
        [captchaView.btnConfirm addTarget:self action:@selector(clickTheConfirm) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = captchaView.frame;
        frame.origin.x = (self.view.width - 300)/2;
        frame.origin.y = 100;
        captchaView.frame = frame;
        captchaView.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:captchaView];
    }
}
//6､创建手势处理方法：
- (void)hiddenTransparentView
{
    [captchaView.tfInput resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        transparentView.hidden = YES;
        captchaView.hidden = YES;
    }];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _myTableView.frame.size.width, 6)];
    view.backgroundColor = RGBACOLOR(243, 243, 243, 1.0);
    return view;
}

#pragma mark - 点击事件
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickWithdraw:(id)sender {

    if ([_tfWithdraw.text doubleValue] <= 50) {
        [self showAlertViewWithTitle:@"提现金额需大于50元"];
        return;
    }
    else if ([_tfWithdraw.text doubleValue] > [_labRemaining.text doubleValue]) {

        [self showAlertViewWithTitle:@"您的余额不足"];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        transparentView.hidden = NO;
        captchaView.hidden = NO;
    }];
}
//倒计时方法验证码实现倒计时60秒，60秒后按钮变换开始的样子
-(void)timerFireMethod:(NSTimer *)theTimer {
    if (seconds == 1) {
        [theTimer invalidate];
        captchaView.btnVerfyCode.enabled = YES;
        seconds = 60;
        [captchaView.btnVerfyCode setTitle:@"获取验证码" forState: UIControlStateNormal];
        [captchaView.btnVerfyCode setTitleColor:UIColorFromRGB(0x0092ff)forState:UIControlStateNormal];
        captchaView.btnVerfyCode.layer.borderColor = UIColorFromRGB(0x0092ff).CGColor;
        
        [captchaView.btnVerfyCode setEnabled:YES];
    }else{
        seconds--;
        captchaView.btnVerfyCode.enabled = NO;
        NSString *title = [NSString stringWithFormat:@"%ld",(long)seconds];
        [captchaView.btnVerfyCode setTitleColor:UIColorFromRGB(0x989898)forState:UIControlStateNormal];
        captchaView.btnVerfyCode.layer.borderColor = UIColorFromRGB(0x989898).CGColor;
        [captchaView.btnVerfyCode setEnabled:NO];
        [captchaView.btnVerfyCode setTitle:title forState:UIControlStateNormal];
    }
}
- (void)getVerfyCode
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:[FKXUserManager getUserInfoModel].mobile forKey:@"mobile"];
    [paramDic setValue:@(3) forKey:@"type"];
    [self showHudInView:self.view hint:@"正在发送..."];
    [AFRequest sendGetOrPostRequest:@"sys/mobilecode"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showAlertViewWithTitle:@"已发送,请注意查收!"];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             
         }
         else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}
- (void)clickTheConfirm
{
    if (!captchaView.tfInput.text.length) {
        [self showAlertViewWithTitle:@"请输入验证码"];
        return;
    }
    [self loadData];
}
- (void)loadData
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:[FKXUserManager getUserInfoModel].mobile forKey:@"mobile"];
    [paramDic setValue:captchaView.tfInput.text forKey:@"code"];
    [paramDic setValue:@([_tfWithdraw.text doubleValue]*100) forKey:@"money"];
    [self showHudInView:self.view hint:@"正在处理..."];
    [AFRequest sendGetOrPostRequest:@"account/tocash" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
    {
        [self hideHud];
        [self hiddenTransparentView];
        if ([data[@"code"] integerValue] == 0)
        {
            [self showAlertViewWithTitle:@"提现成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }
        else
        {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hiddenTransparentView];
        [self showHint:@"网络出错"];
        [self hideHud];
    }];
}
#pragma mark textfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_tfWithdraw resignFirstResponder];
    [captchaView.tfInput resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
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
@end
