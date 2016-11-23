//
//  FKXdynamicsVoiceCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyDynamicModel;
@interface FKXdynamicsVoiceCell : UITableViewCell

@property (nonatomic,strong) MyDynamicModel *model;


@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@property (weak, nonatomic) IBOutlet UILabel *contentName;
@property (weak, nonatomic) IBOutlet UIImageView *contentHead;
@property (weak, nonatomic) IBOutlet UILabel *renke;
@property (weak, nonatomic) IBOutlet UILabel *listen;

@end
