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



}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
