//
//  FKXLianjieView.h
//  Fakaixin
//
//  Created by apple on 2016/11/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallDelegate <NSObject>

- (void)call:(NSString *)callLength;
- (void)toHead:(NSNumber *)uid;

@end

@interface FKXLianjieView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (nonatomic,copy) NSString *head;//咨询师头像
@property (nonatomic,copy) NSString *name;//咨询师姓名

@property (nonatomic,weak) id<CallDelegate>delegate;

@property (nonatomic,strong) NSString *callLength;
@property (nonatomic,strong) NSNumber *lisId;

+(id)creatZaiXian;

@end
