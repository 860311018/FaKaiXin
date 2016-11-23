//
//  STypeSignInView.h
//  绘制S型签到
//
//  Created by 刘胜南 on 16/8/24.
//  Copyright © 2016年 刘胜南. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STypeSignInView;
@protocol STypeSignInViewProtocol <NSObject>

- (void)clickToSignIn:(UIButton *)btn;

@end
//S型签到自定义视图
@interface STypeSignInView : UIView

@property(nonatomic, assign)id<STypeSignInViewProtocol> delegate;
@property(nonatomic, assign)NSInteger haveDays;//已经签到的天数

- (void)updateSubviews;
@end
