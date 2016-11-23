//
//  FKXVisitFriendsController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXVisitFriendsController.h"

@interface FKXVisitFriendsController ()

@property (weak, nonatomic) IBOutlet UILabel *visitNumber;
@property (weak, nonatomic) IBOutlet UILabel *labRole;
@end

@implementation FKXVisitFriendsController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"随手解救好友";
    
    if ([FKXUserManager shareInstance].inviteCode) {
        NSString *inviteCode = [FKXUserManager shareInstance].inviteCode;
        _visitNumber.text = inviteCode;
    }else
    {
        _visitNumber.hidden = YES;
    }
    NSString *str = [NSString stringWithFormat:@"使用您的邀请码注册的朋友，您可获得最高99元/位的奖励，规则如下：\n1、您的朋友在注册时正确的输入了您的邀请码，并且注册成功，您的账号将会得到¥1元的奖励。\n2、您的朋友在伐开心平台内有任何的消费【包括购买心理咨询服务，打赏倾听者】我们都将奖励您他所有消费金额的10%@，返还到您的账户。每个您邀请的朋友账户返还奖励¥99元为上限。\n3、邀请越多的好友，您获得的奖励越多，上不封顶。\n4、如出现任何违规行为，平台有权作出相应的处理。", @"%"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 9;
    NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSParagraphStyleAttributeName : style}];
    [attS addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9432f) range:[str rangeOfString:@"¥1"]];[attS addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9432f) range:[str rangeOfString:@"¥99"]];[attS addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9432f) range:[str rangeOfString:@"10%"]];
    [_labRole setAttributedText:attS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickShare:(UIButton *)sender {
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[NSURL URLWithString:@""]];
    NSString *urlStr;
    if ([FKXUserManager shareInstance].inviteCode) {
        urlStr = [NSString stringWithFormat:@"%@front/share.html?inviteCode=%@", kServiceBaseURL,[FKXUserManager shareInstance].inviteCode];
    }else{
        urlStr = [NSString stringWithFormat:@"%@front/share.html", kServiceBaseURL];
    }
    [shareParams SSDKSetupShareParamsByText:@"安抚你的小情绪"
                                     images:imageArray
     
                                        url:[NSURL URLWithString:urlStr]
                                      title:@"如何安全优雅地呵呵"
                                       type:SSDKContentTypeAuto];
    //单个分享
    SSDKPlatformType type = SSDKPlatformSubTypeWechatTimeline;
    
    switch (sender.tag) {
        case 100:
        {
            type = SSDKPlatformSubTypeWechatSession;
        }
            break;
        case 101:
        {
            type = SSDKPlatformSubTypeWechatTimeline;
        }
            break;
        case 102:
        {
            type = SSDKPlatformTypeSinaWeibo;
        }
            break;
        case 103:
        {
            type = SSDKPlatformSubTypeQZone;
        }
            break;
        case 104:
        {
            type = SSDKPlatformSubTypeQQFriend;
        }
            break;
        case 105:
        {
            UIPasteboard *pas = [UIPasteboard generalPasteboard];
            [pas setURL:[NSURL URLWithString:urlStr]];
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"已拷贝至剪贴板" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
            break;
            
        default:
            break;
    }
    //单个分享
    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 [self shareSuccessCallBack];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享取消"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
         }
     }];
}
- (void)shareSuccessCallBack
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"uid"];
    [AFRequest sendGetOrPostRequest:@"sys/share_app" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
    } failure:^(NSError *error) {
    }];
}
@end
