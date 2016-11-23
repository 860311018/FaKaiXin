//
//  FKXTProfessionTitleCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXTProfessionTitleCell.h"

@implementation FKXTProfessionTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headImgV.layer.cornerRadius = 40;
    self.headImgV.backgroundColor = [UIColor blueColor];
    self.headImgV.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
