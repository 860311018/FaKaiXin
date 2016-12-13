//
//  FKXLoginViewController.m
//  Fakaixin
//
//  Created by Connor on 10/10/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXLoginViewController.h"
#import "FKXUserInfoModel.h"

@interface FKXLoginViewController ()<UITextFieldDelegate>
{
    NSString *nickNameThird; //第三方昵称
    NSString *userIconThird; //第三方头像地址
//    NSUInteger userGender;  //第三方性别  0男 1女 2未知
    NSString *thirdOpenId;  //第三方id
    BOOL isThirdLogin;//是否是第三方登录
}
@property (weak, nonatomic) IBOutlet UIButton *btnWechat;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton    *loginButton;

@end

@implementation FKXLoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    if ([WXApi isWXAppInstalled])
    {
        _btnWechat.hidden = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setUpNavBar];
    [self.passwordTextField setSecureTextEntry:YES];

//    self.userNameTextField.leftViewMode = UITextFieldViewModeAlways;
//    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
//    UIImage *userImg = [UIImage imageNamed:@"img_login_user"];
//    UIImageView *userIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, userImg.size.width + 30, self.userNameTextField.height)];
//    userIV.contentMode = UIViewContentModeScaleAspectFit;
//    userIV.image = userImg;
//    self.userNameTextField.leftView = userIV;
//    
//    
//    UIImage *passImg = [UIImage imageNamed:@"img_login_pass"];
//    UIImageView *passIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, passImg.size.width + 30, self.passwordTextField.height)];
//    passIV.contentMode = UIViewContentModeScaleAspectFit;
//    passIV.image = passImg;
//    self.passwordTextField.leftView = passIV;
}
#pragma mark - UI
- (void)setUpNavBar
{
    UIImage *image = [UIImage imageNamed:@"img_nav_close"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.view.width - image.size.width - 15, 35, image.size.width, image.size.height);
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 方法

//随便逛逛
- (IBAction)guang:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
//    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
//    tab.selectedIndex = 0;
}



- (void)loginSuccessAndFetchTheError:(NSError *)error errorModel:(FMIErrorModelTwo *)errorModel data:(id)data provider:(NSString *)provider
{
    if (data)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccessAndNeedRefreshAllUI object:nil userInfo:@{@"status" : @"login"}];
        FKXUserInfoModel *model = data;
        [FKXUserManager shareInstance].currentUserId = [model.uid integerValue];
        [FKXUserManager shareInstance].currentUserToken = model.token;
        [FKXUserManager shareInstance].currentUserPassword = [SecurityUtil encryptMD5String:_passwordTextField.text];
        
//        NSString *nameEncode = [nickName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //第三方登录
        if (isThirdLogin && !model.name && !model.head) {
            model.name = nickNameThird;
            model.head = nickNameThird;
            /*model.sex = [NSNumber numberWithUnsignedInteger:userGender];
             switch (userGender)
             {
             case 0:
             model.sex = [NSNumber numberWithInteger:1];
             break;
             case 1:
             model.sex = [NSNumber numberWithInteger:2];
             break;
             case 2:
             model.sex = [NSNumber numberWithInteger:0];
             break;
             default:
             break;
             }*/
            [self uploadThirdInfoWithNickname:nickNameThird headUrl:userIconThird thirdOpenId:thirdOpenId];//上服务器上传第三方的头像和昵称,方便服务器推送,以及用户修改
        }
        [FKXUserManager archiverUserInfo:model toUid:[model.uid stringValue]];
        //获取邀请码
        [self getInviteCode];
        
        //登陆成功之后，按照以下代码设置当前登录用户的apns昵称
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[model.uid stringValue]
                                                            password:@"fakaixin" completion:^(NSDictionary *loginInfo, EMError *error)
         {
             if (loginInfo && !error)
             {
                 NSLog(@"登录成功,用户信息:%@", loginInfo);
                 [self loadInfo:loginInfo[@"username"]];
                 // 设置自动登录
//                 [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];                       //设置推送设置
                 //LoginBackToConsult
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginBackToConsult" object:nil];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginBackToSameMind" object:nil];
                 [[NSNotificationCenter defaultCenter] postNotificationName:QianDaoBack object:nil];

                 [[EaseMob sharedInstance].chatManager setApnsNickname:model.name];
             }
         } onQueue:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (errorModel)
    {
        NSInteger index = [errorModel.code integerValue];
        if (index == 4)
        {
            [self showAlertViewWithTitle:errorModel.message];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:errorModel.message];
        }
    }
}
- (void)uploadThirdInfoWithNickname:(NSString *)name headUrl:(NSString *)headUrl thirdOpenId:(NSString *)openId
{
//    "headUrl":""//第三方头像
//    "nickName":""//第三方昵称
//    "uid":""//用户id
//    "thirdOpenId":""//第三方id
//    NSString *nameEncode = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:name forKey:@"nickName"];
    [paramDic setValue:openId forKey:@"thirdOpenId"];
    [paramDic setValue:headUrl forKey:@"headUrl"];
    [AFRequest sendGetOrPostRequest:@"user/thirdlogin_call_back"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)getInviteCode
{
    [AFRequest sendGetOrPostRequest:@"share/invite_code" param:@{} requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         if ([data[@"code"] integerValue] == 0)
         {
             [FKXUserManager shareInstance].inviteCode = data[@"data"][@"inviteCode"];
         }
         else
         {
             [self showHint:data[@"message"]];
         }
         
     } failure:^(NSError *error) {
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
#pragma mark - 点击事件
- (IBAction)clickLogin:(id)sender
{
    isThirdLogin = NO;
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    if (_userNameTextField.text.length != 11) {
        [self showAlertViewWithTitle:@"手机号格式不正确"];
        return;
    }else if (!_passwordTextField.text.length)
    {
        [self showAlertViewWithTitle:@"请输入密码"];
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"deviceToken"] = [FKXUserManager shareInstance].deviceTokenString;
    parameters[@"os"] = @"1";
    parameters[@"mobile"] = _userNameTextField.text;
    parameters[@"pwd"] = [SecurityUtil encryptMD5String:_passwordTextField.text];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionNum = [infoDict objectForKey:@"CFBundleVersion"];
    parameters[@"channel"] = [NSString stringWithFormat:@"AppStore%@",versionNum];

//    [AFRequest sendPostRequestTwo:@"user/mobilelogin" param:parameters success:^(id data) {
//        if ([data[@"code"] integerValue ] == 0) {
//            NSDictionary *dic = data[@"data"];
//            FKXUserInfoModel *model = [FKXUserInfoModel ]
//        }
//    } failure:^(NSError *error) {
//        
//    }];
    [FKXUserInfoModel sendGetOrPostRequest:@"user/mobilelogin" param:parameters requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
    {
        [self hideHud];
        [self loginSuccessAndFetchTheError:error errorModel:errorModel data:data provider:nil];

    }];
}
#pragma mark - 第三方登录
- (IBAction)clickSinaLogin:(id)sender {
    isThirdLogin = YES;
    [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
    
    [self thirdLoginByPlatformType:SSDKPlatformTypeSinaWeibo];
}
- (IBAction)clickQQLogin:(id)sender {
    isThirdLogin = YES;
    [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ];
    [self thirdLoginByPlatformType:SSDKPlatformTypeQQ];
}

- (IBAction)clickWechatLogin:(id)sender {
    isThirdLogin = YES;
    [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
    [self thirdLoginByPlatformType:SSDKPlatformTypeWechat];
}
//
- (void)thirdLoginByPlatformType:(SSDKPlatformType)platformType
{
    [self showHudInView:self.view hint:@"正在登录..."];
    
    [ShareSDK getUserInfo:platformType
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         [self hideHud];
         if (state == SSDKResponseStateSuccess)
         {
//             NSLog(@"uid=%@",user.uid);
//             NSLog(@"user.credential=%@,user=%@",user.credential, user);
//             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@, headurl=%@, gender=%lu\nuser=%@,err=%@",user.nickname, user.icon,(unsigned long)user.gender, user,error);
             nickNameThird = user.nickname;
             userIconThird = user.icon;
//             userGender = user.gender;
             thirdOpenId = user.uid;
             [self showHudInView:self.view hint:@"正在登录..."];
             [self thirdLoginByUId:user.uid platformType:platformType];
         }
         else
         {
             [self showAlertViewWithTitle:error.description];
         }
     }];
}
- (void)thirdLoginByUId:(NSString *)uId platformType:(SSDKPlatformType)platformType
{
    NSUInteger type = 0;//QQ
    switch (platformType) {
        case SSDKPlatformTypeWechat:
            type = 1;//微信
            break;
        case SSDKPlatformTypeSinaWeibo:
            type = 2;//新浪微博
            break;
        default:
            break;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"deviceToken"] = [FKXUserManager shareInstance].deviceTokenString;
    parameters[@"os"] = @(1);
    parameters[@"type"] = @(type);
    parameters[@"openId"] = uId;
    
    [FKXUserInfoModel sendGetOrPostRequest:@"user/thirdlogin" param:parameters requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
    {
        [self hideHud];
        
        [self loginSuccessAndFetchTheError:error errorModel:errorModel data:data provider:nil];
    }];
}

//加载倾听者资料
- (void)loadInfo:(NSString *)uidNum
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    NSInteger uid = [uidNum integerValue];
    [paramDic setValue:@(uid) forKey:@"uid"];
    [FKXUserInfoModel sendGetOrPostRequest:@"listener/info"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             //保存用户信息（更新）
             [FKXUserManager archiverUserInfo:data toUid:uidNum];
             
         } else if (errorModel)
         {
             NSInteger index = [errorModel.code integerValue];
             if (index == 4)
             {
                 [self showAlertViewWithTitle:errorModel.message];
                 [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             }else
             {
                 [self showHint:errorModel.message];
             }
         }
     }];
}

@end
