//
//  FKXBaseNavigationController.m
//  Fakaixin
//
//  Created by Connor on 10/10/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXBaseNavigationController.h"

@interface FKXBaseNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation FKXBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"img_nav_bac"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc]init]];

    //开启系统自带的侧滑
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 手势返回
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //注意,只有非根控制器才有滑动返回功能,根控制器没有
    if (self.childViewControllers.count == 1) {
        return NO;
    }
    return YES;
}

@end
