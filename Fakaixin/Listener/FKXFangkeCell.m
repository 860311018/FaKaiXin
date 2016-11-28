//
//  FKXFangkeCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/28.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXFangkeCell.h"

@implementation FKXFangkeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgV.layer.cornerRadius = 20;
    self.headImgV.layer.masksToBounds = YES;
}

- (IBAction)guanzhu:(id)sender {
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
