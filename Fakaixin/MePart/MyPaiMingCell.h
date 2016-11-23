//
//  MyPaiMingCell.h
//  testMine
//
//  Created by apple on 2016/11/1.
//  Copyright © 2016年 appleZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPaiMingCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *footV;

//背景图
@property (weak, nonatomic) IBOutlet UIImageView *backV;


//头像阴影
@property (weak, nonatomic) IBOutlet UIImageView *headShadow;

//头像
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;


//距离上一名距离
@property (weak, nonatomic) IBOutlet UILabel *distanceN;

//评论或赞
@property (weak, nonatomic) IBOutlet UILabel *zanComment;

//个数
@property (weak, nonatomic) IBOutlet UILabel *countL;

@end
