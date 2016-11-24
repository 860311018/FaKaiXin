//
//  FKXBindPhone.h
//  Fakaixin
//
//  Created by apple on 2016/11/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BindPhoneDelegate <NSObject>

- (void)receiveCode:(NSString *)phoneStr;

@end

@interface FKXBindPhone : UIView


@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;

@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (nonatomic,copy) NSString *phoneStr;

@property (weak, nonatomic) id<BindPhoneDelegate>bindPhoneDelegate;

+(id)creatBangDing;

@end
