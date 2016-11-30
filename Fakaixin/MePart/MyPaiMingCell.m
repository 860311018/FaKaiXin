//
//  MyPaiMingCell.m
//  testMine
//
//  Created by apple on 2016/11/1.
//  Copyright © 2016年 appleZYH. All rights reserved.
//

#import "MyPaiMingCell.h"
#import "FKXPaiHangModel.h"

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


- (void)setModel:(FKXPaiHangModel *)model {
    _model = model;
    
    if (self.type == 0) {
        NSString *distanceStr = [model.commentDistance stringValue];
        if (!distanceStr) {
            distanceStr = @"0";
        }
        self.distanceN.text = distanceStr;
        self.zanComment.text = @"个评论";
        self.countL.text = [NSString stringWithFormat:@"%@个评论",[model.commentNum stringValue]];

    }else if (self.type == 1) {
        NSString *distanceStr = [model.praiseDistance stringValue];
        if (!distanceStr) {
            distanceStr = @"0";
        }
        self.distanceN.text = distanceStr;
        self.zanComment.text = @"个赞";
        self.countL.text = [NSString stringWithFormat:@"%@个赞",[model.praiseNum stringValue]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
