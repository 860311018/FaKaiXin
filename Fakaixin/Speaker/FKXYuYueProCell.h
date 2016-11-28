//
//  FKXYuYueProCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallProDelegate <NSObject>

- (void)callPro:(FKXUserInfoModel *)proModel;

@end

@interface FKXYuYueProCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *desL;
@property (weak, nonatomic) IBOutlet UILabel *zhiyuL;
@property (weak, nonatomic) IBOutlet UILabel *zhiyeL;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

@property (weak, nonatomic) IBOutlet UIImageView *imgVip;

@property (weak, nonatomic) IBOutlet UIImageView *tagImgV;
@property (weak, nonatomic) IBOutlet UILabel *tagL;

@property(nonatomic, strong)FKXUserInfoModel * model;
@property(nonatomic, assign)BOOL isVip;

@property(nonatomic,weak)id<CallProDelegate>callProDelegate;

@end
