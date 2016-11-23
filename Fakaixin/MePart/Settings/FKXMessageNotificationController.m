//
//  FKXMessageNotificationController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMessageNotificationController.h"

@interface FKXMessageNotificationController ()

@property (weak, nonatomic) IBOutlet UISwitch *switchMessageNotificaton;
@property (weak, nonatomic) IBOutlet UISwitch *switchReceiveMessage;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation FKXMessageNotificationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 点击事件
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
//推送通知
- (IBAction)changeMessageNotification:(id)sender {
    UISwitch *swit = sender;
    
    if (swit.on) {
        UIApplication *application = [UIApplication sharedApplication];
        if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
            
        {
            
            UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
            
            [application registerUserNotificationSettings:settings];
            
        }
    }else
    {
        UIApplication *application = [UIApplication sharedApplication];
        if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
            
        {
            
            UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge;
            
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
            
            [application registerUserNotificationSettings:settings];
            
        }
    }
}
//聊天消息
- (IBAction)changeReceiveNotification:(id)sender {
    UISwitch *swit = sender;
    if (swit.on) {
        // 设置全天免打扰，设置后，您将收不到任何推送
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        options.noDisturbStatus = ePushNotificationNoDisturbStatusDay;
        [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options];
    }else
    {
        // 设置全天免打扰，设置后，您将收不到任何推送
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        options.noDisturbStatus = ePushNotificationNoDisturbStatusClose;
        [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options];
    }
}

@end
