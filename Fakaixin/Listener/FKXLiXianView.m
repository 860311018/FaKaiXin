//
//  FKXLiXianView.m
//  Fakaixin
//
//  Created by apple on 2016/11/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXLiXianView.h"

@implementation FKXLiXianView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImgV.layer.cornerRadius = 25;
    self.headImgV.layer.masksToBounds = YES;
    //    self.headImgV.backgroundColor = [UIColor whiteColor];
    [self.headImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2:)]];
    
    
}

- (void)tap2:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(lixiantoHead:)]) {
        [self.delegate lixiantoHead:self.lisId];
    }
}


- (void)layoutSubviews {
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.head,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nameL.text = self.name;
    
}

+ (id)creatLiXian {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXLiXianView" owner:self options:nil].lastObject;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
