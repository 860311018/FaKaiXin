//
//  FKXdynamicsCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyDynamicModel;
@interface FKXdynamicsCell : UITableViewCell

@property (nonatomic,strong) MyDynamicModel *model;

@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;

@end
