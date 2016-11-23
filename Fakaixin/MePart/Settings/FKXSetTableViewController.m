//
//  SetTableViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 15/12/30.
//  Copyright © 2015年 Fakaixin. All rights reserved.
//

#import "FKXSetTableViewController.h"
#import "FKXMessageNotificationController.h"
#import "FKXProtocolViewController.h"
#import "FKXForgetPasswordPhoneNumberViewController.h"
#import "FKXMyLoveValueController.h"

@interface FKXSetTableViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;

@end

@implementation FKXSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"设置";

    if ([FKXUserManager needShowLoginVC]) {
        _btnLogout.hidden = YES;
    }
    
    _viewFooter.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 41*5 -8*2 -64);
    
    [self setUpBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpBarButton
{
    UIImage *consultImage = [UIImage imageNamed:@"back"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
    [btn setBackgroundImage:consultImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}
- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        if ([FKXUserManager needShowLoginVC])
        {
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:@"modifyPassword"];
        }else
        {
            //忘记密码
            FKXForgetPasswordPhoneNumberViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXForgetPasswordPhoneNumberViewController"];
            vc.isModityPwd = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 0 && indexPath.row == 1) {
        if ([FKXUserManager needShowLoginVC]) {
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:@"messageNotification"];
        }else
        {
            //消息通知
            FKXMessageNotificationController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMessageNotificationController"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
//    else if (indexPath.section == 0 && indexPath.row == 0) {
//        if ([FKXUserManager needShowLoginVC]) {
//            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
//        }else
//        {
//            //我的财富
//            FKXMyLoveValueController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyLoveValueController"];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        //跪求好评
        NSString *evaluateString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/fa-kai-xin-peng-you-quan-bu/id1077657593?mt=8"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
    }else if (indexPath.section == 0 && indexPath.row == 2)
    {
        
        NSString *protocol;
        NSString *title;
        if ([FKXUserManager isUserPattern]) {
            protocol = kProtocolUser;
            title = @"用户协议";
        }else
        {
            protocol = kProtocolListener;
            title = @"倾听者协议";
        }
        FKXProtocolViewController *vc = [[FKXProtocolViewController alloc] initWithNibName:nil bundle:nil url:protocol title:title];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - 点击事件
- (IBAction)clickLogout:(id)sender {
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"确定退出当前账号?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}
#pragma mark - alertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
    
        [self logout];
    }
}
#pragma mark - 网络请求
- (void)logout{
    
    [self showHudInView:self.view hint:@"正在退出"];
    NSDictionary *paramDic = @{};
    
    [AFRequest sendGetOrPostRequest:@"user/logout"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
    {
        [self hideHud];
        
        if ([data[@"code"] integerValue] == 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccessAndNeedRefreshAllUI object:nil userInfo:@{@"status" : @"logout"}];
            [FKXUserManager userLogout];
            [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
                NSLog(@"环信退出Error:%@.info = %@.", error, info);
            } onQueue:nil];
            [FKXUserManager setUserPatternToUser];
            [self dismissViewControllerAnimated:YES completion:^{
                [[FKXLoginManager shareInstance] showTabBarController];
            }];
            
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
@end
