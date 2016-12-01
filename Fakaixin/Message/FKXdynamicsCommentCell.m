//
//  FKXdynamicsCommentCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/21.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXdynamicsCommentCell.h"
#import "MyDynamicModel.h"
@implementation FKXdynamicsCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgV.layer.cornerRadius = 15;
    self.headImgV.layer.masksToBounds = YES;
}

- (void)setModel:(MyDynamicModel *)model {
    _model = model;
    
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    self.nameL.text = model.nickname;

    //评价
    if ([model.type integerValue]==5) {
        self.receiveL.text = @"收到了";
        self.nameL2.text = [NSString stringWithFormat:@"%@的",model.toNickname];
        switch ([model.score integerValue]) {
            case -1:
            {
                self.pingFenL.text = @"差评";
                self.pingFenL.textColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1];
            }
                break;
            case 0:
            {
                self.pingFenL.text = @"中评";
                self.pingFenL.textColor = [UIColor colorWithRed:46/255.0 green:248/255.0 blue:146/255.0 alpha:1];
            }
                break;
            case 1:
            {
                self.pingFenL.text = @"好评";
                self.pingFenL.textColor = [UIColor colorWithRed:255/255.0 green:99/255.0 blue:103/255.0 alpha:1];

            }
                break;
            default:
                break;
        }
    }
    //电话服务
    else if ([model.type integerValue]==7) {
        self.receiveL.text = @"的服务被";
        self.nameL2.text = model.toNickname;
        self.pingFenL.text = @"购买";
        self.pingFenL.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
