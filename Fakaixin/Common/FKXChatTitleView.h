//
//  FKXChatTitleView.h
//  Fakaixin
//
//  Created by apple on 2016/11/28.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXChatTitleView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UIButton *guanzhuBtn;

@property (weak, nonatomic) IBOutlet UILabel *tonghuaMinut;

@property (weak, nonatomic) IBOutlet UILabel *textCount;
@property (weak, nonatomic) IBOutlet UILabel *pingFen;

@property (weak, nonatomic) IBOutlet UILabel *detailL;

@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UILabel *scaleL;
@property (weak, nonatomic) IBOutlet UIButton *confirmOrderBtn;
@property (weak, nonatomic) IBOutlet UIView *view2;

+(id)creatChatTitle;

@end