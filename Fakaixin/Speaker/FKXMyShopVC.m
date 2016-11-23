//
//  FKXMyShopVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyShopVC.h"
#import "FKXMyToolVC.h"
#import "FKXMyBackgroundVC.h"
#import "FKXMyStampVC.h"
#import "FKXGetMoreLoveValueVC.h"

#define lineWidth 30

@interface FKXMyShopVC ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    UIPageViewController *myPageVC;
    UIView *lineView;  //红色的可移动线
    FKXMyToolVC *myToolVC;//道具
    FKXMyBackgroundVC *myBackgroundVC;//配饰
    FKXMyToolVC *myStampVC;//邮票
}
@property (strong, nonatomic) NSArray *pageContent;
@property (weak, nonatomic) IBOutlet UIView *viewBacLoveValue;
@property(nonatomic, assign)NSInteger status;

@end

@implementation FKXMyShopVC
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //基本数据赋值
    self.navTitle = @"解忧杂货店";
    //ui创建
    lineView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width/3 - lineWidth)/2, 178, lineWidth, 2)];
    lineView.backgroundColor = UIColorFromRGB(0x666666);
    [self.view addSubview:lineView];
    //初始化pageVC
    [self setUpMyPageVC];
    
    [_viewBacLoveValue addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDetail)]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//查看更多详情
- (void)goToDetail
{
    FKXGetMoreLoveValueVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXGetMoreLoveValueVC"];
    vc.love = _love;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - pageVC相关
- (void)setUpMyPageVC
{
    myToolVC = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyToolVC"];
    myToolVC.type = 0;
    myToolVC.shopVC = self;
    
    myBackgroundVC = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyBackgroundVC"];
    myBackgroundVC.shopVC = self;
    
    myStampVC = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyToolVC"];
    myStampVC.type = 2;
    myStampVC.shopVC = self;
    
    _pageContent = @[myBackgroundVC,myToolVC,myStampVC];
    myPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]}];
    myPageVC.delegate = self;
    myPageVC.dataSource = self;
    myPageVC.view.frame = CGRectMake(0, 180, self.view.width, self.view.height - 180);
    [self addChildViewController:myPageVC];
    [self.view addSubview:myPageVC.view];
    
    [myPageVC setViewControllers:@[myBackgroundVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}
// 得到相应的VC对象
- (id)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        return nil;
    }
    switch (index) {
        case 0:
            return myBackgroundVC;
            break;
        case 1:
            return myToolVC;
            break;
        case 2:
            return myStampVC;
            break;
        default:
            return nil;
            break;
    }
}

// 返回上一个ViewController对象
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    NSLog(@"左：%ld", index);
    switch (index) {
        case 0:
        {
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake((self.view.width/3 - lineWidth)/2, 178, lineView.width, lineView.height);
            }];
        }
            break;
        case 1:
        {
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake(self.view.center.x - lineView.width/2, 178, lineView.width, lineView.height);
            }];
        }
            break;
        default:
            break;
    }
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
    switch (index) {
        case 1:
        {
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake(self.view.center.x - lineView.width/2, 178, lineView.width, lineView.height);
            }];
        }
            break;
        case 2:
        {
            CGFloat mar = self.view.width/3;
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake(mar*2 + (mar - lineView.width)/2, 178, lineView.width, lineView.height);
            }];
        }
            break;
        default:
            break;
    }
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [self.pageContent count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - 点击事件
- (IBAction)clickTool:(UIButton *)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        lineView.frame = CGRectMake(self.view.center.x - lineView.width/2, 178, lineView.width, lineView.height);
    }];
    if (_status == 0) {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }else if (_status == 2)
    {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    _status = 1;

}
//点击配饰（头像和背景）
- (IBAction)clickBackground:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        lineView.frame = CGRectMake((self.view.width/3 - lineWidth)/2, 178, lineView.width, lineView.height);
    }];
    [myPageVC setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    _status = 0;
}
//点击邮票
- (IBAction)clickStamp:(id)sender {
    CGFloat mar = self.view.width/3;
    [UIView animateWithDuration:0.3 animations:^{
        lineView.frame = CGRectMake(mar*2 + (mar - lineView.width)/2, 178, lineView.width, lineView.height);
    }];
    [myPageVC setViewControllers:@[[self viewControllerAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    _status = 2;
}

@end
