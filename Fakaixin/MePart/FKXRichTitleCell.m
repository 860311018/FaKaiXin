//
//  FKXRichTitleCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXRichTitleCell.h"

@interface FKXRichTitleCell ()<UIGestureRecognizerDelegate>

@end

@implementation FKXRichTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
    [self.selectLove setBackgroundImage:[UIImage imageNamed:@"myRich_selectSanJiao"] forState:UIControlStateSelected];
    
    [self.selectIncome setBackgroundImage:[UIImage imageNamed:@"myRich_selectSanJiao"] forState:UIControlStateSelected];
    

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapLove:)];
    [self.loveBackV addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapIncome:)];
    [self.incomeBackV addGestureRecognizer:tap2];
    
}


- (void)tapLove:(UITapGestureRecognizer *)tap {
    self.selectLove.selected = YES;
    self.selectIncome.selected = NO;
    
    [_myRichSelectDelegate selectLove];
}

- (void)tapIncome:(UITapGestureRecognizer *)tap {
    self.selectLove.selected = NO;
    self.selectIncome.selected = YES;
    [_myRichSelectDelegate selectIncome];

}

//- (void)reloadCell {
//    self.selectLove.image = [UIImage imageNamed:@"myRich_selectSanJiao"];
//    self.selectIncome.image = [UIImage imageNamed:@"myRich_selectSanJiao"];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
