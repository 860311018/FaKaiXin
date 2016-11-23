//
//  DDTagButton.m
//  DingDongSuiFang
//
//  Created by 神农试 on 16/7/18.
//  Copyright © 2016年 神农试. All rights reserved.
//

#import "DDTagButton.h"

@interface DDTagButton ()

@end

@implementation DDTagButton


+ (DDTagButton *)buttonWithTixt:(NSString *)str Color:(UIColor *)color andImage:(UIImage *)image andIsDelete:(BOOL)isDelete
{
    DDTagButton *btn = [[DDTagButton alloc]init];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setBackgroundColor:color];
    btn.titleLabel.font  = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor colorWithRed:65/255.0 green:180/255.0 blue:249/255.0 alpha:1] forState:UIControlStateNormal];
    [btn setTitle:str forState:UIControlStateNormal];

    CGSize btnMaxSize  = CGSizeMake(MAXFLOAT, 20);
    CGSize btnRealSize  = [str boundingRectWithSize:btnMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
   
    
    

    UIImageView * deleteIc = [[UIImageView alloc]initWithFrame:CGRectMake(-btnRealSize.height-3, 0, btnRealSize.height, btnRealSize.height)];
    deleteIc.backgroundColor = [UIColor clearColor];
    deleteIc.image = image;
    
    //正常状态
    if (!isDelete) {
        btn.frame  = CGRectMake(0, 0,btnRealSize.width, 20);
        deleteIc.hidden = YES;
    }
    //可删除状态
    else {
        btn.frame  = CGRectMake(0, 0,btnRealSize.width+5+btnRealSize.height, 20);
        btn.hidden = NO;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
//        [deleteIc addGestureRecognizer:tap];
////        [btn addGestureRecognizer:tap];
    }
    
    
    [btn addSubview:deleteIc];
    
    
    return btn;
}



////点击删除tag
//- (void)tapAction:(UITapGestureRecognizer *)tap {
//    if ([self.deleteTagDelegae respondsToSelector:@selector(deleteTag:)]) {
//        [self.deleteTagDelegae deleteTag:tap.view.tag];
//    }
//}

@end
