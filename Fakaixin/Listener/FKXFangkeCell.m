//
//  FKXFangkeCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/28.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXFangkeCell.h"
#import "FKXUserInfoModel.h"

@implementation FKXFangkeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgV.layer.cornerRadius = 20;
    self.headImgV.layer.masksToBounds = YES;
}

- (IBAction)guanzhu:(id)sender {
    if ([self.delegate respondsToSelector:@selector(toChatView:)]) {
        [self.delegate toChatView:self.model.uid];
    }
}

- (void)setModel:(FKXUserInfoModel *)model {
    _model = model;
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:model.head] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    self.nameL.text = model.name;
    self.proL.text = model.createTime;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
