//
//  FKXWorkBenchViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXWorkBenchViewController.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXBaseShareView.h"
#import "FKXOrderManageController.h"
#import "FKXServiceVC.h"
#import "FKXTouGaoVC.h"
#import "FKXFangkeVC.h"
#import "FKXMyOrderVC.h"

@interface FKXWorkBenchViewController ()<UITableViewDelegate>
{
    FKXUserInfoModel *userInfoModel;
    UILabel *unReadOrder;
    
    FKXResonance_homepage_model *bannerModel;
}


@property (weak, nonatomic) IBOutlet UIImageView *bannerImgV;

@property (weak, nonatomic) IBOutlet UIImageView *userIcon; //头像
@property (weak, nonatomic) IBOutlet UILabel *userName;     //用户名
@property (weak, nonatomic) IBOutlet UILabel *profileLab;   //职业
@property (weak, nonatomic) IBOutlet UILabel *orderNum;     //总回答
@property (weak, nonatomic) IBOutlet UILabel *InfluenceNum; //影响力
@property (weak, nonatomic) IBOutlet UILabel *incomeLab;    //收入
@property (weak, nonatomic) IBOutlet UIView *viewSectionTwo;
@end

@implementation FKXWorkBenchViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadInfo];
    [self loadUnreadRelMe];//界面出现就更新ui
    
    [self loadBanner];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"工作台";
    _userIcon.layer.borderColor = RGBACOLOR(181, 181, 181, 1.0).CGColor;
    _userIcon.layer.borderWidth = 1.0;
    
     unReadOrder = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width/3 - self.view.width/9, 150, 20, 20)];
    unReadOrder.hidden = YES;
    unReadOrder.font = [UIFont systemFontOfSize:12];
    unReadOrder.backgroundColor = [UIColor redColor];
    unReadOrder.layer.cornerRadius = 10;
    unReadOrder.clipsToBounds = YES;
    unReadOrder.textColor = [UIColor whiteColor];
    unReadOrder.textAlignment = NSTextAlignmentCenter;
    [_viewSectionTwo addSubview:unReadOrder];
    
//    [self loadBanner];
    
    [self loadUnreadRelMe];//保证第一次执行（tabbarVC初始化的时候也加载）

    [self.bannerImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBanner:)]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 点击事件

//点击banner
- (void)tapBanner:(UITapGestureRecognizer *)tap {
    
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"mind";
    vc.urlString = [NSString stringWithFormat:@"%@?shareId=%@&uid=%ld&token=%@",bannerModel.url, bannerModel.hotId, (long)[FKXUserManager shareInstance].currentUserId,[FKXUserManager shareInstance].currentUserToken];
    vc.pageType = MyPageType_hot;
    vc.resonanceModel = bannerModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

//查看服务
- (IBAction)lookService:(UIButton *)sender {
    FKXServiceVC *vc = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXServiceVC"];
    vc.model = userInfoModel? userInfoModel:[FKXUserManager getUserInfoModel];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
//查看数据
- (IBAction)lookLiker:(UIButton *)sender {
    [self showHint:@"即将开放"];
}

//查看访客
- (IBAction)lookOrder:(id)sender {
//    [self showHint:@"即将开放"];
    unReadOrder.hidden = YES;
    self.tabBarItem.badgeValue = nil;

    FKXFangkeVC *vc = [[FKXFangkeVC alloc]init];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

//投稿
- (IBAction)tougao:(id)sender {
    
    FKXTouGaoVC *vc = [[FKXTouGaoVC alloc]initWithNibName:@"FKXTouGaoVC" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


//查看订单
- (IBAction)lookData:(UIButton *)sender {
//    FKXOrderManageController *vc = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXOrderManageController"];
//    [vc setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:vc animated:YES];
    FKXMyOrderVC *vc = [[FKXMyOrderVC alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.isWorkBench = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)lookRange:(id)sender {
     [self showHint:@"即将开放"];
}
//查看预览,h5的个人主页
- (IBAction)lookScan:(UIButton *)sender {
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"user_center";
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_home.html?uid=%ld&loginUserId=%ld&token=%@",kServiceBaseURL,(long)[FKXUserManager shareInstance].currentUserId , [FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    vc.userModel = userInfoModel;
    vc.pageType = MyPageType_people;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickShare:(UIButton *)sender {
    NSString *title = @"";
    NSString *content = @"";
    switch ([userInfoModel.role integerValue]) {
        case 1:
        case 2:
        {
            content = @"伐开心认证的心理关怀师";
            title = [NSString stringWithFormat:@"心理关怀师|%@", userInfoModel.name];
        }
            break;
        case 3:
        {
            content = @"随时随地解决您的心理问题";
            title = [NSString stringWithFormat:@"%@的心理工作室 ", userInfoModel.name];
        }
            break;
            
        default:
            break;
    }
    FKXBaseShareView *shareV = [[FKXBaseShareView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrlStr:userInfoModel.head urlStr:[NSString stringWithFormat:@"%@front/QA_home.html?uid=%@&loginUserId=%ld",kServiceBaseURL,userInfoModel.uid, [FKXUserManager shareInstance].currentUserId] title:title text:content];
    [shareV createSubviews];
}

//加载未读的订单个数
#pragma mark - 网络请求部分

- (void)loadBanner {
    NSDictionary *paramDic = @{@"start" : @(0), @"size": @(1)};
    
    [FKXResonance_homepage_model sendGetOrPostRequest:@"share/listenerShare" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         if (data)
         {
             
             bannerModel = data;
             [self.bannerImgV sd_setImageWithURL:[NSURL URLWithString:bannerModel.background] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];

}

- (void)loadUnreadRelMe
{
//    NSNumber *time = [FKXUserManager shareInstance].unAcceptOrderTime ? [FKXUserManager shareInstance].unAcceptOrderTime : @(0);
//    NSDictionary *paramDic = @{@"time" : time};
//    [AFRequest sendGetOrPostRequest:@"listener/unReadOrderList" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
//        
//        [self hideHud];
//        if ([data[@"code"] integerValue] == 0)
//        {
//            NSInteger con = [data[@"data"][@"number"] integerValue];
//            if (con) {
//                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", con];
//                NSString *tit = [NSString stringWithFormat:@"%ld",con];
//                unReadOrder.text = tit;
//                unReadOrder.hidden = NO;
//            }else{
//                self.tabBarItem.badgeValue = nil;
//                unReadOrder.hidden = YES;
//            }
//        }else if ([data[@"code"] integerValue] == 4)
//        {
//            [self showAlertViewWithTitle:data[@"message"]];
//
//            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
//        }else
//        {
//            [self showHint:data[@"message"]];
//        }
//    } failure:^(NSError *error) {
//        [self hideHud];
//        [self showAlertViewWithTitle:@"网络出错"];
//    }];
    
    NSDictionary *paramDic = @{};
    [FKXUserInfoModel sendGetOrPostRequest:@"user/browse_log"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             if ([data count]>0) {
                 FKXUserInfoModel *model = data[0];
                 [[FKXUserManager shareInstance]setNoReadFangke:[NSNumber numberWithInteger:[model.createTimeDate integerValue]]];
             }
         } else if (errorModel)
         {
             [self showHint:errorModel.message];
             
         }
     }];
    
    NSNumber *time2 = [FKXUserManager shareInstance].noReadFangke ? [FKXUserManager shareInstance].noReadFangke : @(0);
    NSDictionary *paramDic2 = @{@"time" : time2};
    [AFRequest sendGetOrPostRequest:@"user/new_browse" param:paramDic2 requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
        [self hideHud];
        NSLog(@"%@",data);
        if ([data[@"code"] integerValue] == 0)
        {
            NSInteger con = [data[@"data"][@"number"] integerValue];
            if (con) {
                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", con];
                NSString *tit = [NSString stringWithFormat:@"%ld",con];
                unReadOrder.text = tit;
                unReadOrder.hidden = NO;
            }else{
                self.tabBarItem.badgeValue = nil;
                unReadOrder.hidden = YES;
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
//加载倾听者资料
- (void)loadInfo
{
    NSDictionary *paramDic = @{@"uid" : @([FKXUserManager shareInstance].currentUserId)};//倾听者id
    
    [FKXUserInfoModel sendGetOrPostRequest:@"listener/info"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
            userInfoModel = data;
             //保存用户信息（更新）
             [FKXUserManager archiverUserInfo:userInfoModel toUid:[userInfoModel.uid stringValue]];

             [_userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",userInfoModel.head, cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
             _InfluenceNum.text = [NSString stringWithFormat:@"%@",userInfoModel.exp];
             _userName.text = userInfoModel.name;
             _profileLab.text = userInfoModel.profession;
             _orderNum.text = [NSString stringWithFormat:@"%@",userInfoModel.questions];
             _incomeLab.text = [NSString stringWithFormat:@"%.2f", [userInfoModel.inCome doubleValue]/100];
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
