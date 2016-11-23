//
//  FKXSignInVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/25.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXSignInVC.h"
#import "STypeSignInView.h"
#import "FKXSignInView.h"

@interface FKXSignInVC ()//<STypeSignInViewProtocol>
{
    UIView *transViewSignIn;   //透明图
    FKXSignInView *signView;//签到总图
    NSInteger numToClean;//多少天清空
    STypeSignInView *sTypeView;//s型图
    NSInteger daysSignIn;//签到天数
}
@property (weak, nonatomic) IBOutlet UILabel *labNum;
@property (weak, nonatomic) IBOutlet UILabel *labGift;
@property (weak, nonatomic) IBOutlet UILabel *labTotal;

@property (weak, nonatomic) IBOutlet UILabel *labRoleI;
@property (weak, nonatomic) IBOutlet UILabel *labRoleII;
@property (weak, nonatomic) IBOutlet UILabel *labRoleIII;
@end

@implementation FKXSignInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"签到";
    [self setUpBackBtn];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:_labRoleI.text attributes:@{NSParagraphStyleAttributeName : style}];
    [_labRoleI setAttributedText:str1];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:_labRoleII.text attributes:@{NSParagraphStyleAttributeName : style}];
    [_labRoleII setAttributedText:str2];
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:_labRoleIII.text attributes:@{NSParagraphStyleAttributeName : style}];
    [_labRoleIII setAttributedText:str3];
    
    [self loadSignDays];
    [self loadUserCleanLog];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpBackBtn
{
    UIImage *consultImage = [UIImage imageNamed:@"img_sign_in_tree_back"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, consultImage.size.width*3, consultImage.size.height*2)];
    [btn setImage:consultImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 网络请求
- (void)loadSignDays
{
    NSDictionary *paramDic = @{};
    //isCheckIn  0 没有签到  1已经签到了
    [AFRequest sendGetOrPostRequest:@"user/signDays" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            daysSignIn = [data[@"data"][@"signDays"] integerValue];
            _labNum.text = [NSString stringWithFormat:@"%ld天",(long)daysSignIn];
            NSString *str = [data[@"data"][@"type"] integerValue] > 1 ? @"随机红包":@"爱心值";
            _labGift.text = str;
            _labTotal.text = [NSString stringWithFormat:@"%.2f元",[data[@"data"][@"rewards"] floatValue]/100];
            if (sTypeView) {
                sTypeView.haveDays = daysSignIn;
                [sTypeView updateSubviews];
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
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
- (void)loadUserCleanLog
{
    NSDictionary *paramDic = @{};
    
    [AFRequest sendGetOrPostRequest:@"user/cleanLog" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            numToClean = [data[@"data"] integerValue];
            if (signView) {
                signView.labTodays.text = [NSString stringWithFormat:@"%ld天之后清空签到",(long)numToClean];
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
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
- (void)loadUserCheckIn
{
    [self showHudInView:signView hint:@"正在签到..."];
    NSDictionary *paramDic = @{};//补签 传type ＝ 1
    
    [AFRequest sendGetOrPostRequest:@"user/checkIn" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 500)
        {
            [self showHint:data[@"message"] yOffset:-300];
            [self loadUserCleanLog];
            [self loadSignDays];
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"] yOffset:-300];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
- (void)loadUserAddCheckIn
{
    [self showHudInView:signView hint:@"正在签到..."];
    NSDictionary *paramDic = @{@"type":@(1)};//补签 传type ＝ 1
    
    [AFRequest sendGetOrPostRequest:@"user/checkIn" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 500)
        {
            [self showHint:data[@"message"] yOffset:-300];
            [self loadUserCleanLog];
            [self loadSignDays];
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"] yOffset:-300];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
#pragma  mark - 点击事件
//立即签到
- (void)rightNowSignIn
{
    [self loadUserCheckIn];
}
//补签
- (void)addSignIn
{
    [self loadUserAddCheckIn];
}
- (IBAction)clickSignIn:(id)sender {

    if (!transViewSignIn)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        //透明背景
        transViewSignIn = [[UIView alloc] initWithFrame:screenBounds];
        transViewSignIn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewSignIn.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewSignIn];
        
        signView = [[[NSBundle mainBundle] loadNibNamed:@"FKXSignInView" owner:nil options:nil] firstObject];
        signView.labTodays.text = [NSString stringWithFormat:@"%ld天之后清空签到",(long)numToClean];
        sTypeView = [[STypeSignInView alloc] initWithFrame:CGRectMake(10, 75,  signView.width - 20, 300)];
        sTypeView.haveDays = daysSignIn;
        [sTypeView updateSubviews];
        [signView addSubview:sTypeView];
        [signView.btnClose addTarget:self action:@selector(hiddentransViewSignIn) forControlEvents:UIControlEventTouchUpInside];
        [signView.btnSignIn addTarget:self action:@selector(rightNowSignIn) forControlEvents:UIControlEventTouchUpInside];
        [signView.btnAddSign addTarget:self action:@selector(addSignIn) forControlEvents:UIControlEventTouchUpInside];
        [transViewSignIn addSubview:signView];
        signView.center = transViewSignIn.center;
        [UIView animateWithDuration:0.5 animations:^{
            transViewSignIn.alpha = 1.0;
        }];
    }
}
- (void)hiddentransViewSignIn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QianDaoBack object:@""];

    [UIView animateWithDuration:0.5 animations:^{
        transViewSignIn.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewSignIn removeFromSuperview];
        transViewSignIn = nil;
    }];
}

@end
