
//
//  FKXLianjieView.m
//  Fakaixin
//
//  Created by apple on 2016/11/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXLianjieView.h"

@implementation FKXLianjieView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImgV.layer.cornerRadius = 25;
    self.headImgV.layer.masksToBounds = YES;
    //    self.headImgV.backgroundColor = [UIColor whiteColor];
    [self.iconImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    [self.label1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    [self.backView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    [self.label2 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    
    [self.headImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2:)]];


}

- (void)tap2:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(toHead:)]) {
        [self.delegate toHead:self.lisId];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(call:)]) {
        [self.delegate call:self.callLength];
    }
}

- (void)layoutSubviews {
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.head,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nameL.text = self.name;

}

+ (id)creatZaiXian {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXLianjieView" owner:self options:nil].lastObject;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
