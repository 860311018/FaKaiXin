//
//  FKXNotificationCenterTableViewCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/6.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXNotifcationModel.h"

//点消息主界面的最上边的通知那一行的cell
@interface FKXNotificationCenterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labDate;

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;

@property(nonatomic, strong)FKXNotifcationModel * model;

@end
