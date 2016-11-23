//
//  FKXPsyCommentCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPsyCommentCell.h"
#import "FKXPsyCommentModel.h"

@implementation FKXPsyCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgV.layer.cornerRadius = 15;
    self.headImgV.layer.masksToBounds = YES;

}

- (void)setModel:(FKXPsyCommentModel *)model {
    _model = model;
    
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:model.userHead] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    self.nameL.text = model.userName;
    self.commentL.text = model.text;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
