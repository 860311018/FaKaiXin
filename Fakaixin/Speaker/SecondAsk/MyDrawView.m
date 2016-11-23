//
//  MyDrawView.m
//  MyDrawLine
//
//  Created by 刘胜南 on 16/6/17.
//  Copyright © 2016年 刘胜南. All rights reserved.
//

#import "MyDrawView.h"

@implementation MyDrawView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    [self drawLine];
//    [self drawLine1];
//    [self drawLine2];
//    [self drawCtxState];
//    [self drawUIBezierPathState];
//    [self drawMyCoordinate];
//    UIPinchGestureRecognizer *ges = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchMySelf:)];
//    [self addGestureRecognizer:ges];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    
    CGPoint center = CGPointMake(31.5, 31.5);  //设置圆心位置
    CGFloat radius = 30;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2;  //圆终点位置
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    CGContextSetLineWidth(ctx, 3); //设置线条宽度
    [UIColorFromRGB(0xd2d2d2) setStroke]; //设置描边颜色
    CGContextAddPath(ctx, path1.CGPath); //把路径添加到上下文
    CGContextStrokePath(ctx);  //渲染
}
-(void)pinchMySelf:(UIPinchGestureRecognizer *)pinchG
{
    UIView *view = pinchG.view;
    view.transform = CGAffineTransformScale(view.transform, pinchG.scale, pinchG.scale);
    [pinchG setScale:1.0];
}

#pragma mark - 坐标
- (void)drawMyCoordinate
{
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 这个方法系统会自动给你生成路径,自动给你添加到上下文,但是底层还是封装的drawLine里写的方法
    //绘制y轴
    CGContextMoveToPoint(ctx, 50, 400);
    CGContextAddLineToPoint(ctx, 50, 50);
    CGContextAddLineToPoint(ctx, 40, 65);
    CGContextMoveToPoint(ctx, 50, 50);
    CGContextAddLineToPoint(ctx, 60, 65);

    //绘制x轴
    CGContextMoveToPoint(ctx, 50, 400);
    CGContextAddLineToPoint(ctx, 50*30, 400);
    CGContextAddLineToPoint(ctx, 50*30 - 15, 385);
    CGContextMoveToPoint(ctx, 50*30, 400);
    CGContextAddLineToPoint(ctx, 50*30 - 15, 415);
    //在y轴绘制单位坐标
    for (int i = 0; i < 5; i++) {
        CGFloat y = 400 - 50*i;
        CGContextMoveToPoint(ctx, 50, y);
        CGContextAddLineToPoint(ctx, 300, y);
        NSString *tit = [NSString stringWithFormat:@"%d", 2800 + 100*i];
        [tit drawAtPoint:CGPointMake(50, y) withAttributes:nil];
    }
    //在x轴绘制单位坐标
    for (int i = 0; i < 30; i++) {
        CGFloat x = 50*(i + 1);
        CGContextMoveToPoint(ctx, x, 400);
        CGContextAddLineToPoint(ctx, x, 50);
        NSString *tit = [NSString stringWithFormat:@"%d", 50 + 50*i];
        [tit drawAtPoint:CGPointMake(50+x, 400) withAttributes:nil];
    }
    
    NSArray *numArr = @[
                        @"3478.78",
                        @"3539.81",
                        @"3294.38",
                        @"3361.56",
                        @"3192.45",
                        @"3192.45",
                        @"3155.88",
                        @"3221.57",
                        @"3118.73",
                        @"3130.73",
                        @"3223.13",
                        @"3174.38",
                        @"3081.35",
                        @"3113.46",
                        @"3128.89",
                        @"2940.51",
                        @"2930.35",
                        @"2853.76",
                        @"2946.09",
                        @"2901.05",
                        @"2961.33",
                        @"2948.64",
                        @"2984.76",
                        @"2963.79",
                        @"2946.71"];
    CGContextMoveToPoint(ctx, 50, 400);
    NSInteger index = 0;
    for (NSString *str in numArr) {
        CGFloat flo = [str floatValue];
        CGContextAddLineToPoint(ctx,50 + 50*index,400 - (flo - 2800)/2);
        index++;
        [str drawAtPoint:CGPointMake(50*index, 400 - (flo - 2800)/2) withAttributes:nil];
    }
    
    //渲染上下文
    CGContextStrokePath(ctx);
}
#pragma mark - 系统原生方法
//内存泄露，注释掉
//- (void)drawLine
//{
//    // 1,获取图形上下文
//    // 目前我们所有的上下文都是以UIGraphics
//    // CGContexRef Ref:引用 CG:目前所用到的类型和函数,一般都是CG开头  CoreGraphics
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    // 2,描述路径
//    // 创建路径
//    CGMutablePathRef path = CGPathCreateMutable();
//    
//    // 设置起点
//    // path:给哪个路径设置起点
//    CGPathMoveToPoint(path, NULL, 50, 50);
//    // 添加一条线到某一点
//    CGPathAddLineToPoint(path, NULL, 200, 200);
//    // 3.把路径添加到上下文
//    CGContextAddPath(ctx, path);
//    // 4.渲染上下文
//    CGContextStrokePath(ctx);   //内存泄露，注释掉
//    
//}
//系统第一层封装
- (void)drawLine1
{
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 这个方法系统会自动给你生成路径,自动给你添加到上下文,但是底层还是封装的drawLine里写的方法
    // 描述路径
    // 设置起点
    CGContextMoveToPoint(ctx, 50, 80);
    //终点
    CGContextAddLineToPoint(ctx, 200, 200);
    //渲染上下文
    CGContextStrokePath(ctx);
}
//贝瑟尔曲线
- (void)drawLine2
{
    // 创建路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    //这是起点
    [path moveToPoint:CGPointMake(50, 120)];
    //添加一根线到某个点上
    [path addLineToPoint:CGPointMake(200, 200)];
    //绘制路径
    [path stroke];
}
//系统方法实现两条线
- (void)drawCtxState
{
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //描述路径
    //起点
    CGContextMoveToPoint(ctx, 100, 300);
    CGContextAddLineToPoint(ctx, 300, 50);
    //设置起点
    CGContextMoveToPoint(ctx, 80, 60);
    //默认下一根线的起点就是上一根线的终点
    CGContextAddLineToPoint(ctx, 100, 200);
    CGContextAddLineToPoint(ctx, 200, 60);
    CGContextAddLineToPoint(ctx, 50, 50);
    // 设置绘图状态,一定要渲染之前
    // 这个只渲染线的颜色
    //    [[UIColor redColor] setStroke];
    // 线的颜色和填充物的颜色都渲染
    [[UIColor redColor] set];
    //线宽
    CGContextSetLineWidth(ctx, 5);
    //设置连接样式
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);
    // 设置顶角样式
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextStrokePath(ctx);
    //填充满图
    //    CGContextFillPath(ctx);
}
//贝瑟尔方法实现两线
- (void)drawUIBezierPathState
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(50, 50)];
    [path addLineToPoint:CGPointMake(200, 300)];
    [path addLineToPoint:CGPointMake(40, 100)];
    [path setLineWidth:5];
    [[UIColor greenColor] set];
    [path stroke];
    // 两条不搭嘎的线,用两条路径
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    
    [path1 moveToPoint:CGPointMake(70, 60)];
    
    [path1 addLineToPoint:CGPointMake(160, 180)];
    
    // 如果想实现两条线颜色不同等方法,分别写两次渲染即可
    path1.lineWidth = 13;
    
    [[UIColor blueColor] set];
    
    [path1 stroke];
}

@end
