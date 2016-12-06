//
//  FKXConfirmView.h
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfirmDelegate <NSObject>

//- (void)addMinute;
//- (void)desMinute;
- (void)textBeginEdit;
- (void)bangDingPhone:(NSString *)phoneStr;
- (void)weiXin;
- (void)zhiFuBao;

- (void)clickHead:(NSNumber *)listenId;

- (void)confirm:(NSNumber *)listenerId time:(NSNumber *)time totals:(NSNumber *)totals;

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

@property (nonatomic,assign) NSInteger price; //单价
@property (nonatomic,copy) NSString *phoneStr;//电话

@property (nonatomic,copy) NSString *head;//咨询师头像
@property (nonatomic,copy) NSString *name;//咨询师姓名
@property (nonatomic,strong)NSNumber *status;//咨询师在线状态

@property (nonatomic,strong)NSNumber *listenerId;//咨询师Id


- (void)layoutSubviews;

+(id)creatOrder;

@end
