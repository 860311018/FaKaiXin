//
//  FKXPayForAcceptView.h
//  Fakaixin
//
//  Created by liushengnan on 16/9/22.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXPayView.h"

@interface FKXPayForAcceptView : UIView
//@property (weak, nonatomic) IBOutlet UIButton *btnClose;
//@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPrice;
@property(nonatomic, assign)MyPayChannel  myPayChannel;

@property (weak, nonatomic) IBOutlet UIButton *myPayBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnRemain;

@end
