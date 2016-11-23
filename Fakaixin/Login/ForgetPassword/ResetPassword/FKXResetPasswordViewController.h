//
//  FKXResetPasswordViewController.h
//  Fakaixin
//
//  Created by Connor on 10/17/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//


//重置密码，输入旧密码，新密码
@interface FKXResetPasswordViewController : FKXBaseViewController

@property(nonatomic, copy)NSString * phone;
@property(nonatomic, copy)NSString * inviteCode;
@property(nonatomic, assign)BOOL isModityPwd;   //是点击"修改密码"进来的

@end
