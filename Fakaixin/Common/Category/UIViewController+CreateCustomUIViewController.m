//
//  UIViewController+CreateCustomUIViewController.m
//  MobileBusinessApp.Catering.BusinessManage
//
//  Created by 刘胜南 on 15/4/17.
//  Copyright (c) 2015年 刘胜南. All rights reserved.
//

#import "UIViewController+CreateCustomUIViewController.h"
#import "AppDelegate.h"



//#import "SSUIShareActionSheetStyle.h"

@implementation UIViewController (CreateCustomUIViewController)

-(void)setTitleViewOfNavigationItem:(NSString *)title
{
    UILabel *titleLabel           = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.font               = kFont_F1();
    titleLabel.text               = title;
    titleLabel.textColor          = kColor_MainBlackFont();
    titleLabel.textAlignment      = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
//    self.navigationController.navigationBar.tintColor = kColor_MainNavBarColor();
//    self.navigationController.navigationBar.barTintColor = kColor_MainNavBarColor();
}
-(void)showAlertViewWithTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:title delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
