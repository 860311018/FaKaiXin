//
//  FKXLianjieView.h
//  Fakaixin
//
//  Created by apple on 2016/11/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXLianjieView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;


@property (nonatomic,copy) NSString *head;//咨询师头像
@property (nonatomic,copy) NSString *name;//咨询师姓名

+(id)creatZaiXian;

@end
