//
//  UIViewController+CreateCustomUIViewController.h
//  MobileBusinessApp.Catering.BusinessManage
//
//  Created by 刘胜南 on 15/4/17.
//  Copyright (c) 2015年 刘胜南. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CreateCustomUIViewController)

-(void)setTitleViewOfNavigationItem:(NSString *)title;

-(void)showAlertViewWithTitle:(NSString *)title;

//- (void)clickShareToThirdPlatformWithImageName:(NSString *)imageName title:(NSString *)title content:(NSString *)content url:(NSString *)url eventId:(NSString *)eventId;
//- (void)clickShareToThirdPlatformWithImageUrl:(NSString *)imageName title:(NSString *)title content:(NSString *)content url:(NSString *)url eventId:(NSString *)eventId;
@end
