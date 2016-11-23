//
//  FKXOrderManageController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXOrderManageController.h"
#import "FKXOrderManageVC.h"


@interface FKXOrderManageController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    UIPageViewController *myPageVC;
    UIView *lineView;  //红色的可移动线
}
@property (weak, nonatomic) IBOutlet UIButton *btnNoAccept;
@property (strong, nonatomic) NSArray *pageContent;

@end

@implementation FKXOrderManageController

- (void)viewDidLoad {
    [super viewDidLoad];
    //基本数据赋值
    self.navTitle = @"订单管理";
    //ui创建
    lineView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width/3 - 65)/2, _btnNoAccept.bottom - 20 - 3, 65, 3)];
    lineView.backgroundColor = kColor_MainRed();
    [self.view addSubview:lineView];
    //初始化pageVC
    [self setUpMyPageVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)goBack
{
    NSString *time = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]];
    NSTimeInterval timeInter = [time integerValue]*1000;
    [FKXUserManager shareInstance].unAcceptOrderTime = @(timeInter);
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - pageVC相关
- (void)setUpMyPageVC
{
    _pageContent = @[@"0",@"1",@"2"];
    myPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]}];
    myPageVC.delegate = self;
    myPageVC.dataSource = self;
    myPageVC.view.frame = CGRectMake(0, 90, self.view.width, self.view.height - 90);
    [self addChildViewController:myPageVC];
    [self.view addSubview:myPageVC.view];
    FKXOrderManageVC *vc = [self viewControllerAtIndex:0];
    [myPageVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}
// 得到相应的VC对象
- (FKXOrderManageVC *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    FKXOrderManageVC *dataViewController = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXOrderManageVC"];
    dataViewController.status = [self.pageContent objectAtIndex:index];
    return dataViewController;
}

// 返回上一个ViewController对象
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FKXOrderManageVC *)viewController];
    NSLog(@"左：%ld", index);
//    mySegment.selectedSegmentIndex = index;
    switch (index) {
        case 0:
        {
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake((self.view.width/3 - 65)/2, lineView.top, lineView.width, lineView.height);
            }];
        }
            break;
        case 1:
        {
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake(self.view.center.x - lineView.width/2, lineView.top, lineView.width, lineView.height);
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
- (NSUInteger)indexOfViewController:(FKXOrderManageVC *)viewController
{
    NSUInteger index = [self.pageContent indexOfObject:viewController.status];
    return index;
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FKXOrderManageVC *)viewController];
    NSLog(@"右：%ld", index);
//    mySegment.selectedSegmentIndex = index;
    switch (index) {
        case 1:
        {
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake(self.view.center.x - lineView.width/2, lineView.top, lineView.width, lineView.height);
            }];
        }
            break;
        case 2:
        {
            CGFloat mar = self.view.width/3;
            [UIView animateWithDuration:0.3 animations:^{
                lineView.frame = CGRectMake(mar*2 + (mar - lineView.width)/2, lineView.top, lineView.width, lineView.height);
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
- (IBAction)clickHaveNo:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        lineView.frame = CGRectMake((self.view.width/3 - 65)/2, lineView.top, lineView.width, lineView.height);
    }];
    [myPageVC setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    _status = 0;
}
- (IBAction)clickGoing:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        lineView.frame = CGRectMake(self.view.center.x - lineView.width/2, lineView.top, lineView.width, lineView.height);
    }];
    if (_status == 0) {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }else if (_status == 2)
    {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    _status = 1;
}
- (IBAction)clickAll:(id)sender {
    CGFloat mar = self.view.width/3;
    [UIView animateWithDuration:0.3 animations:^{
        lineView.frame = CGRectMake(mar*2 + (mar - lineView.width)/2, lineView.top, lineView.width, lineView.height);
    }];
    [myPageVC setViewControllers:@[[self viewControllerAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    _status = 2;
}
@end
