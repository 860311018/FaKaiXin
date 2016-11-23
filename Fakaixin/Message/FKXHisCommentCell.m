//
//  FKXHisCommentCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXHisCommentCell.h"

@implementation FKXHisCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headImgV.layer.cornerRadius = 18;
    self.headImgV.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
