//
//  PaiMingFirstCell.m
//  testMine
//
//  Created by apple on 2016/11/1.
//  Copyright © 2016年 appleZYH. All rights reserved.
//

#import "PaiMingFirstCell.h"

@implementation PaiMingFirstCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
    self.headImgV.layer.cornerRadius = ([UIScreen mainScreen].bounds.size.width -20)*0.08;
    self.headImgV.clipsToBounds = YES;

    self.headBackImgV.image = [UIImage imageNamed:@"mine_headBack"];

    self.headIcon.image = [UIImage imageNamed:@"mine_King1"];

    self.paiMingBackImgV.image = [UIImage imageNamed:@"mine_mingciBack1"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
