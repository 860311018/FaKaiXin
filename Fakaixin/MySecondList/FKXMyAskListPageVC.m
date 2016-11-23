//
//  FKXMyAskListPageVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyAskListPageVC.h"
#import "FKXMyAskListVC.h"
#import "FKXSecondAskController.h"
#import "FKXAboutMeVC.h"

#define kBtnW 48
#define kBtnH 20

@interface FKXMyAskListPageVC ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    UIPageViewController *myPageVC;
    UIImageView *bottomLineImg;
    NSInteger currentTag;
    UIView *titleV;
    
    FKXMyAskListVC *askListVC;
    FKXSecondAskController *secondAskVC;
}
@property (strong, nonatomic) NSArray *pageContent;

@end

@implementation FKXMyAskListPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentTag = 100;
    self.navTitle = @"我问";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavBar];
    [self setUpMyPageVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 导航栏
#pragma mark - Navigation
- (void)clickRightBtn
{
    FKXAboutMeVC *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXAboutMeVC"];
//    vc.noReadNum = noReadNum;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)setUpNavBar
{
    UIImage *imageMind = [UIImage imageNamed:@"img_nav_dynamic"];
    UIButton * leftB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,imageMind.size.width, imageMind.size.height)];
    [leftB setImage:imageMind forState:UIControlStateNormal];
    [leftB addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftB];
    
    titleV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
    NSArray *titleArr = @[@"我问", @"我听"];
    CGFloat marginx = (titleV.width - kBtnW*titleArr.count)/(titleArr.count + 1);
    
    for (int i = 0; i < titleArr.count; i++) {
        //g按钮
        UIButton * gBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        gBtn.frame = CGRectMake(marginx + (marginx + kBtnW)*i, 10, kBtnW, kBtnH);
        [gBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
        gBtn.backgroundColor = [UIColor whiteColor];
        gBtn.tag = 100 + i;
        [gBtn setTitle:titleArr[i] forState:UIControlStateNormal];
        gBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [gBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        [titleV addSubview:gBtn];
    }
    UIButton *btn2 = [titleV viewWithTag:100];
    bottomLineImg = [[UIImageView alloc] initWithFrame:CGRectMake(btn2.left, titleV.height - 3, btn2.width, 3)];
    bottomLineImg.backgroundColor = kColorMainBlue;
    [titleV addSubview:bottomLineImg];
    self.navigationItem.titleView = titleV;
}

#pragma mark - 点击事件
- (void)clicked:(UIButton *)btn{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = btn.frame.origin.x;
        bottomLineImg.frame = frame;
    }];
    
    if (btn.tag > currentTag) {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:btn.tag - 100]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }else if(btn.tag < currentTag) {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:btn.tag - 100]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    currentTag = btn.tag;
}
#pragma mark - pageVC相关
- (void)setUpMyPageVC
{
    askListVC = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyAskListVC"];
    secondAskVC = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSecondAskController"];
    secondAskVC.isMyListenList = YES;
    _pageContent = @[askListVC, secondAskVC];
    myPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]}];
    myPageVC.delegate = self;
    myPageVC.dataSource = self;
//    CGRect frame = self.view.bounds;
//    frame.origin.y += (kBtnH + 2);
//    frame.size.height -= (kBtnH + 2);
//    myPageVC.view.frame = frame;
    [self addChildViewController:myPageVC];
    [self.view addSubview:myPageVC.view];
    FKXMyAskListVC *vc = [self viewControllerAtIndex:0];
    [myPageVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}
// 得到相应的VC对象
- (id)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        return nil;
    }
//    // 创建一个新的控制器类，并且分配给相应的数据
//    FKXMyAskListVC *dataViewController = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyAskListVC"];
//    dataViewController.status =[self.pageContent objectAtIndex:index];
//    return dataViewController;
    if (index == 0) {
        return askListVC;
    }
    return secondAskVC;
}

// 返回上一个ViewController对象
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    NSLog(@"左：%ld", index);
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = ((UIButton *)[titleV viewWithTag:100 + index]).origin.x;
        bottomLineImg.frame = frame;
    }];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index--;
    
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法，自动来维护次序。
    // 不用我们去操心每个ViewController的顺序问题。
    return [self viewControllerAtIndex:index];
}
- (NSUInteger)indexOfViewController:(id)viewController
{
    NSUInteger index = [self.pageContent indexOfObject:viewController];
    return index;
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    NSLog(@"右：%ld", index);
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = ((UIButton *)[titleV viewWithTag:100 + index]).origin.x;
        bottomLineImg.frame = frame;
    }];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [self.pageContent count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
