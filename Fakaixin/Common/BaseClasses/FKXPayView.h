//
//  FKXPayView.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/30.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MyPayChannel_weChat,
    MyPayChannel_Ali,
    MyPayChannel_remain,
} MyPayChannel;
//支付界面
@interface FKXPayView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPrice;
@property(nonatomic, assign)MyPayChannel  myPayChannel;

@property (weak, nonatomic) IBOutlet UIButton *myPayBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnRemain;

@end
