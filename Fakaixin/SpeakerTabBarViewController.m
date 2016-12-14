//
//  SpeakerTabBarViewController.m
//  TabbarVC
//
//  Created by 刘胜南 on 16/3/26.
//  Copyright © 2016年 刘胜南. All rights reserved.
//

#import "SpeakerTabBarViewController.h"
#import "FKXPersonalViewController.h"
#import "FKXMindViewController.h"
#import "FKXSecondAskController.h"
#import "FKXPublishMindViewController.h"
#import "FKXSameMindViewController.h"
#import "FKXChoosePublishView.h"
#import "FKXPublishLetterVC.h"
#import "FKXQingsuVC.h"
#import "FKXConsulterPageVC.h"

#import "FKXConsultViewController.h"

@interface SpeakerTabBarViewController ()<UITabBarControllerDelegate>
{
    UIView *transparentViewPop;//弹出的选项透明背景图
    FKXChoosePublishView *choosePublishView;
}
@end

@implementation SpeakerTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;//设置tabbarController代理
    [self setUpTabBar];//设置tabbar
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITabBarControllerDelegate
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSArray *vcArr = [tabBarController viewControllers];
    if ([viewController isEqual:vcArr[2]])//中心按钮
    {
        [self createTransparentView];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - 子视图
- (void)setUpTabBar
{
    UIImage *bacImg;
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        bacImg = [UIImage imageNamed:@"tab_bar_bac_image_5s"];
    }else{
        bacImg = [UIImage imageNamed:@"tab_bar_bac_image"];
        ;
    }
    //设置当前的tabbar的样式
    [self.tabBar setBackgroundImage:[bacImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.tabBar.tintColor = [UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0];
    //设置整个app的tabbar的样式
    [[UITabBar appearance] setShadowImage :[[UIImage alloc] init]];

    //首页
    FKXMindViewController *speakerMind = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMindViewController"];
    FKXBaseNavigationController *speakerMindNav = [[FKXBaseNavigationController alloc] initWithRootViewController:speakerMind];
    speakerMind.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[[UIImage imageNamed:@"tab_bar_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //预约专家
    FKXConsulterPageVC *proVC = [[FKXConsulterPageVC alloc]init];
//    FKXConsultViewController *proVC = [[FKXConsultViewController alloc]init];
    FKXBaseNavigationController *proNav = [[FKXBaseNavigationController alloc] initWithRootViewController:proVC];
    proNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"咨询" image:[[UIImage imageNamed:@"tab_bar_pro_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_pro_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //发现 （和心事合并）
//    FKXSecondAskController *findVC = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSecondAskController"];
//    [findVC viewDidLoad];
//    FKXBaseNavigationController *findVCNav = [[FKXBaseNavigationController alloc] initWithRootViewController:findVC];
//    findVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"问答" image:[[UIImage imageNamed:@"tab_bar_find_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_find_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIViewController * placeHolderVC = [[UIViewController alloc] init];
    UIImage *centerIma = [UIImage imageNamed:@"tab_bar_center_publish"];
    placeHolderVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[centerIma imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_center_publish"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    placeHolderVC.tabBarItem.imageInsets = UIEdgeInsetsMake(self.tabBar.height/2 - centerIma.size.height/2, 0, -self.tabBar.height/2 + centerIma.size.height/2, 0);
//    //共鸣
    FKXSameMindViewController *feelVC = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSameMindViewController"];
    [feelVC viewDidLoad];
    FKXBaseNavigationController *feelVCNav = [[FKXBaseNavigationController alloc] initWithRootViewController:feelVC];
    feelVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"问答" image:[[UIImage imageNamed:@"tab_bar_find_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_find_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    //我
    FKXPersonalViewController *personal = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPersonalViewController"];
    [personal viewDidLoad];
    FKXBaseNavigationController *personalNav = [[FKXBaseNavigationController alloc] initWithRootViewController:personal];
    personal.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我" image:[[UIImage imageNamed:@"tab_bar_me_nomal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_me_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.viewControllers = @[speakerMindNav,feelVCNav,placeHolderVC,proNav,personalNav];
}
#pragma mark - 创建两个选项
- (void)createTransparentView
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (!transparentViewPop) {
        //透明背景
        transparentViewPop = [[UIView alloc] initWithFrame:screenBounds];
        transparentViewPop.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [transparentViewPop addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTransparentViewPop)]];
        [[UIApplication sharedApplication].keyWindow addSubview:transparentViewPop];
        choosePublishView = [[[NSBundle mainBundle] loadNibNamed:@"FKXChoosePublishView" owner:nil options:nil] firstObject];
        choosePublishView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [choosePublishView.btnClose addTarget:self action:@selector(hiddenTransparentViewPop) forControlEvents:UIControlEventTouchUpInside];
        [choosePublishView.btnMind addTarget:self action:@selector(goToPublishMind) forControlEvents:UIControlEventTouchUpInside];
        [choosePublishView.btnLetter addTarget:self action:@selector(goToCallPhone) forControlEvents:UIControlEventTouchUpInside];
        CGPoint point = CGPointMake(transparentViewPop.center.x, transparentViewPop.height - choosePublishView.height/2);
        choosePublishView.center = point;
        [transparentViewPop addSubview:choosePublishView];
    }
}
- (void)hiddenTransparentViewPop
{
    [UIView animateWithDuration:0.5 animations:^{
        [transparentViewPop removeAllSubviews];
        [transparentViewPop removeFromSuperview];
        transparentViewPop = nil;
    }];
}

#pragma mark - 打电话和发心事

- (void)goToCallPhone {
   
    [self hiddenTransparentViewPop];
    FKXQingsuVC *vc = [[FKXQingsuVC alloc]init];
    vc.showBack = YES;
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    
//    vc.hidesBottomBarWhenPushed = YES;
    [self presentViewController:nav animated:YES completion:nil];
//    self.viewControllers = @[nav];
}

- (void)goToPublishLetter
{
    [self hiddenTransparentViewPop];
    FKXPublishLetterVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishLetterVC"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)goToPublishMind
{
    [self hiddenTransparentViewPop];
    FKXPublishMindViewController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishMindViewController"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}


@end
