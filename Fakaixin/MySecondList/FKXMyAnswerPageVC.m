//
//  FKXMyAnswerPageVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyAnswerPageVC.h"
#import "FKXMyAnswerVC.h"

#define kBtnW 60
#define kBtnH 44

@interface FKXMyAnswerPageVC ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    UIPageViewController *myPageVC;
    UIImageView *bottomLineImg;
    NSInteger currentTag;
}
@property (strong, nonatomic) NSArray *pageContent;

@end

@implementation FKXMyAnswerPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentTag = 100;
    self.navTitle = @"我答";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpCustomSegment];
    [self setUpMyPageVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UI
- (void)setUpCustomSegment
{
    NSArray *titleArr = @[@"全部",@"待回答"];
    CGFloat marginx = (self.view.width - kBtnW*titleArr.count)/(titleArr.count + 1);

    for (int i = 0; i < titleArr.count; i++) {
        //g按钮
        UIButton * gBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        gBtn.frame = CGRectMake(marginx + (marginx + kBtnW)*i, 0, kBtnW, kBtnH);
        if (i == 0) {
            [gBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
        }else{
            [gBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
        gBtn.backgroundColor = [UIColor whiteColor];
        gBtn.tag = 100 + i;
        [gBtn setTitle:titleArr[i] forState:UIControlStateNormal];
        gBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [gBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:gBtn];
    }
    UIButton *btn = [self.view viewWithTag:100];
    bottomLineImg = [[UIImageView alloc] initWithFrame:CGRectMake(btn.left, btn.bottom - 1, btn.width, 2)];
    bottomLineImg.backgroundColor = kColorMainBlue;
    [self.view addSubview:bottomLineImg];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, kBtnH + 1, self.view.width, 1)];
    line.backgroundColor = kColorBackgroundGray;
    [self.view addSubview:line];
}
#pragma mark - 点击事件
- (void)clicked:(UIButton *)btn{
    for (UIButton *subB in self.view.subviews)
    {
        if (subB.tag >= 100 && subB.tag <= 101) {
            [subB setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
    }
    [btn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    
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
    _pageContent = @[@(0), @(1)];
    myPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]}];
    myPageVC.delegate = self;
    myPageVC.dataSource = self;
    CGRect frame = self.view.bounds;;
    frame.origin.y += (kBtnH + 2);
    frame.size.height -= (kBtnH + 2);
    myPageVC.view.frame = frame;
    [self addChildViewController:myPageVC];
    [self.view addSubview:myPageVC.view];
    FKXMyAnswerVC *vc = [self viewControllerAtIndex:0];
    [myPageVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}
// 得到相应的VC对象
- (FKXMyAnswerVC *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    FKXMyAnswerVC *dataViewController = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyAnswerVC"];
    dataViewController.status =[self.pageContent objectAtIndex:index];
    return dataViewController;
}

// 返回上一个ViewController对象
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FKXMyAnswerVC *)viewController];
    NSLog(@"左：%ld", index);
    for (UIButton *subB in self.view.subviews)
    {
        if (subB.tag >= 100 && subB.tag <= 102) {
            [subB setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
    }
    UIButton *bott =  [self.view viewWithTag:100 + index];
    [bott setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = ((UIButton *)[self.view viewWithTag:100 + index]).origin.x;
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
- (NSUInteger)indexOfViewController:(FKXMyAnswerVC *)viewController
{
    NSUInteger index = [self.pageContent indexOfObject:viewController.status];
    return index;
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FKXMyAnswerVC *)viewController];
    NSLog(@"右：%ld", index);
    for (UIButton *subB in self.view.subviews)
    {
        if (subB.tag >= 100 && subB.tag <= 102) {
            [subB setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
    }
    UIButton *bott =  [self.view viewWithTag:100 + index];
    [bott setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = ((UIButton *)[self.view viewWithTag:100 + index]).origin.x;
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
