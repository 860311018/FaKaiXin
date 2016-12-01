
//
//  FKXMyOrdersCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyOrdersCell.h"
#import "FKXOrderModel.h"

@implementation FKXMyOrdersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(FKXOrderModel *)model {
    _model = model;
    
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:model.headUrl] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nameL.text = model.nickName;
    
    if (model.callLength) {
        self.detailL.text = @"电话咨询";
    }else {
        self.detailL.text = @"图文咨询";
    }
    
    if (self.isWorkBench) {
        
    }else {
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
