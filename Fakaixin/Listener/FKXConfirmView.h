//
//  FKXConfirmView.h
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfirmDelegate <NSObject>

- (void)addMinute;
- (void)desMinute;
- (void)bangDingPhone;
- (void)weiXin;
- (void)zhiFuBao;
- (void)confirm;

@end

@interface FKXConfirmView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;

@property (weak, nonatomic) IBOutlet UILabel *priceL;

@property (weak, nonatomic) IBOutlet UITextField *minutesTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UIButton *bangDingBtn;

@property (weak, nonatomic) IBOutlet UIButton *weiXinPay;

@property (weak, nonatomic) IBOutlet UIButton *zhiFuPay;

@property (weak, nonatomic) IBOutlet UILabel *totalL;

@property (weak, nonatomic) IBOutlet UIButton *confirmOrder;


@property(nonatomic,weak)id<ConfirmDelegate>confirmDelegate;

@property (nonatomic,assign) NSInteger price;

+(id)creatOrder;

@end
