//
//  FKXCaptchaView.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

//提现弹出的验证码视图
@interface FKXCaptchaView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UITextField *tfInput;

@property (weak, nonatomic) IBOutlet UIButton *btnVerfyCode;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@end
