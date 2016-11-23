//
//  FKXCustomCellFrame.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXCustomCellFrame.h"

@implementation FKXCustomCellFrame

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(14, 8, 30, 30);
    self.textLabel.frame = CGRectMake(self.imageView.right + 9, 3, self.width - self.imageView.right - 18, 13);
    self.detailTextLabel.frame = CGRectMake(self.imageView.right + 9, self.textLabel.bottom + 5, self.width - self.imageView.right - 18, 50);
}
@end
