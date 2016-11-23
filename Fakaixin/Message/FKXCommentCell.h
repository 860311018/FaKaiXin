//
//  FKXCommentCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXNotifcationModel.h"
@interface FKXCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labDate;

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property(nonatomic, strong)FKXNotifcationModel * model;
@end
