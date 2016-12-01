//
//  FKXFangkeCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/28.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FangKeDelegate <NSObject>

- (void)toChatView:(NSNumber *)uid;

@end

@class FKXUserInfoModel;
@interface FKXFangkeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *proL;
@property (weak, nonatomic) IBOutlet UIButton *gaunzhuBtn;

@property (nonatomic,strong) FKXUserInfoModel *model;

@property (nonatomic,strong) id<FangKeDelegate>delegate;

@end
