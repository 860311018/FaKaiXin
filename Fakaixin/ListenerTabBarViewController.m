//
//  ListenerTabBarViewController.m
//  TabbarVC
//
//  Created by 刘胜南 on 16/3/26.
//  Copyright © 2016年 刘胜南. All rights reserved.
//

#import "ListenerTabBarViewController.h"
#import "FKXPersonalViewController.h"
#import "FKXWorkBenchViewController.h"
#import "FKXCareListController.h"
#import "FKXLetterListVC.h"

@interface ListenerTabBarViewController ()<UITabBarControllerDelegate>
{
    UIView *transparentView;
    UIView *changePatternBacView;//切换模式的背景图
    UIImageView *rotateImageView;//切换模式的旋转图
    
    FKXChatListController * conversationListVC;//环信会话列表
}
@end

@implementation ListenerTabBarViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (unreadCount > 0)
    {
        conversationListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", unreadCount];
    }else
    {
        conversationListVC.tabBarItem.badgeValue = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;//设置tabbarController代理
    //创建tabbar
    [self setUpTabBar];
    
    //创建子视图
    [self loadTheAnimationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建tabbar
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
    self.tabBar.tintColor = kColor_MainRed_Bac();//设置字体颜色
    //设置整个app的tabbar的样式
    [[UITabBar appearance] setShadowImage :[[UIImage alloc] init]];

    //关怀
    FKXCareListController *lisener = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXCareListController"];
    FKXBaseNavigationController *listenerNav = [[FKXBaseNavigationController alloc] initWithRootViewController:lisener];
    lisener.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"关怀" image:[[UIImage imageNamed:@"tab_bar_care_nomal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_care_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //工作台
    FKXWorkBenchViewController *workVC = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXWorkBenchViewController"];
    FKXBaseNavigationController *workNav = [[FKXBaseNavigationController alloc] initWithRootViewController:workVC];
    workVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"工作台" image:[[UIImage imageNamed:@"tab_bar_work_bench_nomal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_work_bench_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIViewController * placeHolderVC = [[UIViewController alloc] init];
    UIImage *centerIma = [UIImage imageNamed:@"tab_bar_center_letter"];
    placeHolderVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[centerIma imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_center_letter"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    placeHolderVC.tabBarItem.imageInsets = UIEdgeInsetsMake(self.tabBar.height/2 - centerIma.size.height/2, 0, -self.tabBar.height/2 + centerIma.size.height/2, 0);

    //消息
    conversationListVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXChatListController"];
    ApplicationDelegate.conversationListVCListener = conversationListVC;

    FKXBaseNavigationController *messageNav = [[FKXBaseNavigationController alloc] initWithRootViewController:conversationListVC];
    conversationListVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:[[UIImage imageNamed:@"tab_bar_message_nomal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_message_care_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //我
    FKXPersonalViewController *personal = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPersonalViewController"];
    personal.chatListVC = conversationListVC;
    FKXBaseNavigationController *personalNav = [[FKXBaseNavigationController alloc] initWithRootViewController:personal];
    personal.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我" image:[[UIImage imageNamed:@"tab_bar_me_nomal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_me_selected_red"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.viewControllers = @[listenerNav,workNav,placeHolderVC,messageNav,personalNav];
}
#pragma mark - UITabBarControllerDelegate
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSArray *vcArr = [tabBarController viewControllers];
    if ([viewController isEqual:vcArr[2]])//中心按钮
    {
        [self goToLetterList];
        return NO;
    }
    else
    {
        return YES;
    }
}
- (void)goToLetterList
{
    FKXLetterListVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXLetterListVC"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -  －－切换模式－－
- (void)loadTheAnimationView
{
    if (!changePatternBacView) {
        changePatternBacView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//
        changePatternBacView.backgroundColor = kColorMainBlue;
        UIImage *image = [UIImage imageNamed:@"rotate_animate_white"];
        
        rotateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((changePatternBacView.width - image.size.width)/2, changePatternBacView.center.y - image.size.height/2, image.size.width, image.size.height)];
        rotateImageView.image = image;
        [changePatternBacView addSubview:rotateImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, rotateImageView.bottom + 20, changePatternBacView.width, 30)];
        label.backgroundColor = [UIColor clearColor];
        [changePatternBacView addSubview:label];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = UIColorFromRGB(0xffffff);
        label.text = @"正在切换至倾诉模式...";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
    }
}
- (void)showTheAnimation
{
    [UIView beginAnimations:nil context:nil];
    //渲染内存一般写 yes
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:rotateImageView cache:YES];
    [UIView setAnimationDuration:1];
    //[UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:0];
    
    [UIView commitAnimations];
    [self performSelector:@selector(showTheTabBar) withObject:nil afterDelay:1.1];
}
- (void)showTheTabBar
{
    [FKXUserManager setUserPatternToUser];
    [[FKXLoginManager shareInstance] showTabBarController];
    [changePatternBacView removeFromSuperview];
}
- (void)changeTheUserPattern
{
    [ApplicationDelegate.window addSubview:changePatternBacView];
    
    [self performSelector:@selector(showTheAnimation) withObject:nil afterDelay:0.1];
}

@end
