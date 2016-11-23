//
//  FKXForgetPasswordVirificationCodeViewController.h
//  Fakaixin
//
//  Created by Connor on 10/17/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//


//忘记密码：2，输入验证码
@interface FKXForgetPasswordVirificationCodeViewController : FKXBaseViewController

@property(nonatomic, copy)NSString * phone;

@property(nonatomic, assign)BOOL isModityPwd;   //是点击"修改密码"进来的

@end
