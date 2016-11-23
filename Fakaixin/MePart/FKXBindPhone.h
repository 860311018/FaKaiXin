//
//  FKXBindPhone.h
//  Fakaixin
//
//  Created by apple on 2016/11/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXBindPhone : UIView
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;

@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

+(id)creatBangDing;

@end
