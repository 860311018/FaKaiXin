//
//  MyPaiMingCell.m
//  testMine
//
//  Created by apple on 2016/11/1.
//  Copyright © 2016年 appleZYH. All rights reserved.
//

#import "MyPaiMingCell.h"

@implementation MyPaiMingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headShadow.layer.cornerRadius = ([UIScreen mainScreen].bounds.size.width -20)*0.13;
    self.headShadow.clipsToBounds = YES;
    self.headShadow.image = [UIImage imageNamed:@"mine_headShadow"];
    
    self.headImgV.layer.cornerRadius = ([UIScreen mainScreen].bounds.size.width -20-2)*0.13;
    self.headImgV.clipsToBounds = YES;
    
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
