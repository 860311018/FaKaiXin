//
//  FKXRichDetailCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXRichDetailCell.h"

@implementation FKXRichDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)touchTixian:(id)sender {
    [_myRichItemsDelegate selectTiXian];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
