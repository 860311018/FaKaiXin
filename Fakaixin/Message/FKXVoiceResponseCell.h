//
//  FKXVoiceResponseCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/21.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyDynamicModel;
@interface FKXVoiceResponseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImgV;

@property (weak, nonatomic) IBOutlet UILabel *nameL;

@property (weak, nonatomic) IBOutlet UILabel *zhiyeL;

@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *voiceTimeL;

@property (weak, nonatomic) IBOutlet UIImageView *voiceImgV;

@property (weak, nonatomic) IBOutlet UILabel *contentL;

@property (nonatomic,strong) MyDynamicModel *model;

@end
