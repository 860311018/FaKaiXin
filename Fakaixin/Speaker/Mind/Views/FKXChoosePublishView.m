//
//  FKXChoosePublishView.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChoosePublishView.h"

@implementation FKXChoosePublishView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _viewL.center = CGPointMake(kScreenWidth/2 - 95, self.height + 40);
     _viewR.center = CGPointMake(_viewL.right + 110, _viewL.center.y);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _viewL.center = CGPointMake(kScreenWidth/2 - 95, self.frame.size.height - 120);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _viewR.center = CGPointMake(_viewL.right + 110, _viewL.center.y);
        
    } completion:nil];
}
@end
