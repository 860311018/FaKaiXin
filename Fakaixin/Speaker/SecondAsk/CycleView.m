//
//  CycleView.m
//  MyDrawLine
//
//  Created by 刘胜南 on 16/6/29.
//  Copyright © 2016年 刘胜南. All rights reserved.
//

#import "CycleView.h"

@implementation CycleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    
    CGPoint center = CGPointMake(31.5, 31.5);  //设置圆心位置
    CGFloat radius = 30;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 3); //设置线条宽度
    [kColorMainBlue setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
}
@end
