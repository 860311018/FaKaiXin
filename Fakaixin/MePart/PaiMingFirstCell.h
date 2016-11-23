//
//  PaiMingFirstCell.h
//  testMine
//
//  Created by apple on 2016/11/1.
//  Copyright © 2016年 appleZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaiMingFirstCell : UITableViewCell

//头像挂件
@property (weak, nonatomic) IBOutlet UIImageView *headIcon;

//头像
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;


//名次背景图
@property (weak, nonatomic) IBOutlet UIImageView *paiMingBackImgV;

//名次
@property (weak, nonatomic) IBOutlet UILabel *paiMingL;

//头像背景图
@property (weak, nonatomic) IBOutlet UIImageView *headBackImgV;

//用户名
@property (weak, nonatomic) IBOutlet UILabel *nameL;

@end
