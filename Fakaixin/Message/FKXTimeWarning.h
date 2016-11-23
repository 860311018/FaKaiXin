//
//  FKXTimeWarning.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/29.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
//聊天界面的时间提醒，用于分享会是否开始的提醒
@interface FKXTimeWarning : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@end
