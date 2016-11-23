//
//  STypeSignInView.m
//  绘制S型签到
//
//  Created by 刘胜南 on 16/8/24.
//  Copyright © 2016年 刘胜南. All rights reserved.
//

#import "STypeSignInView.h"

@implementation STypeSignInView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    for (UIButton *btn in self.subviews) {
//        if (btn.tag == 100) {
//            [path moveToPoint:btn.center];
//        }else{
//            [path addLineToPoint:btn.center];
//        }
//    }
//    [[UIColor greenColor] set];
//    [path setLineWidth:10];
//    [path setLineCapStyle:kCGLineCapRound];
//    [path setLineJoinStyle:kCGLineJoinRound];
//    [path stroke];
    
    UIImage *image = [UIImage imageNamed:@"img_s_type_sign_in_selected"];//根据这个图计算间距
    CGFloat btnW = image.size.width;
    NSInteger cols = 6;
    CGFloat margin = (self.frame.size.width - (cols * btnW)) / (cols - 1);  // 间距
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (int i = 0;i < self.subviews.count;i++) {
        UIButton *btn = self.subviews[i];
        //横着添加图片
        if (i == 0 ||i == 6 ||i == 12 ||i == 18) {//4个全长水平条
            UIImage *image = [UIImage imageNamed:@"img_s_type_margin_horizontal"];
            UIImage *imageBase = [UIImage imageNamed:@"img_s_type_sign_in_normal"];
            [image drawInRect:CGRectMake(imageBase.size.width/2, CGRectGetMidY(btn.frame) - image.size.height/2, self.width - btn.width, imageBase.size.height - 5)];//之所以减5是因为有阴影
        }
        if (i == 24) {//一个半长水平条
            UIImage *image = [UIImage imageNamed:@"img_s_type_margin_horizontal"];
            UIImage *imageBase = [UIImage imageNamed:@"img_s_type_sign_in_normal"];
            [image drawInRect:CGRectMake(imageBase.size.width/2, CGRectGetMidY(btn.frame) - image.size.height/2, btn.width*4 + margin*3 - btn.width/2, imageBase.size.height - 5)];
        }
        if (i == 5 || i == 17 ) {//右边两个竖
            UIImage *image = [UIImage imageNamed:@"img_s_type_margin_vertical"];
            UIImage *imageBase = [UIImage imageNamed:@"img_s_type_sign_in_normal"];
            [image drawInRect:CGRectMake(self.width-imageBase.size.width, btn.center.y, imageBase.size.width - 5, margin + 27 + imageBase.size.height - 5)];
        }
        if (i == 6 || i == 18) {//左边边两个竖
            UIImage *image = [UIImage imageNamed:@"img_s_type_margin_vertical"];
            UIImage *imageBase = [UIImage imageNamed:@"img_s_type_sign_in_normal"];
            [image drawInRect:CGRectMake(5, btn.center.y, imageBase.size.width - 5, margin + 27 + imageBase.size.height - 5)];
        }
    }
    CGContextStrokePath(context);
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)updateSubviews
{
    [self removeAllSubviews];
    // 添加手势按钮控件
    for (int i = 0; i < 28; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.selected = (100 + i < 100 + _haveDays) ? YES : NO;
//        btn.selected = YES;
        if (i == 1 ||i == 6 ||i == 13 ||i == 20 ) {
            [btn setImage:[UIImage imageNamed:@"img_s_type_gold_normal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"img_s_type_gold_selected"] forState:UIControlStateSelected];
            btn.tag = (i+100);    // 设置tag用户检查手势解锁
        }else if(i == 27)
        {
            [btn setImage:[UIImage imageNamed:@"img_s_type_box_normal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"img_s_type_box_selected"] forState:UIControlStateSelected];
            btn.tag = (i+100);    // 设置tag用户检查手势解锁
        }else{
            [btn setImage:[UIImage imageNamed:@"img_s_type_sign_in_normal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"img_s_type_sign_in_selected"] forState:UIControlStateSelected];
            btn.tag = i+100;    // 设置tag用户检查手势解锁
        }
//        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}
- (void)clickBtn:(UIButton *)btn
{
//    if (_delegate&&[_delegate respondsToSelector:@selector(clickToSignIn:)]) {
//        [_delegate clickToSignIn:btn];
//    }
}
-(void)layoutSubviews
{
    UIImage *image = [UIImage imageNamed:@"img_s_type_sign_in_selected"];//根据这个图计算间距
//    CGFloat btnX = 0;
//    CGFloat btnY = 0;
    CGFloat btnW = image.size.width;
    CGFloat btnH = 0;
    NSInteger cols = 6;
    CGFloat margin = (self.frame.size.width - (cols * btnW)) / (cols - 1);  // 间距
    
    CGFloat col = 0;
    NSInteger row = 0;
    
    for (int i = 0; i < self.subviews.count; i++) {
        UIButton *btn = self.subviews[i];
        // 获取当前按钮的行列数
        row = i / cols;
        
        if (row%2 == 0) {
            col = i % cols;
        }else{
            col = 5 - i % cols;
        }
        UIImage *imageS;
        if (i == 1 ||i == 6 ||i == 13 ||i == 20 ) {
            if (btn.selected) {
                imageS = [UIImage imageNamed:@"img_s_type_gold_selected"];
            }else{
                imageS = [UIImage imageNamed:@"img_s_type_gold_normal"];
            }
        }else if(i == 27)
        {
            if (btn.selected) {
                imageS = [UIImage imageNamed:@"img_s_type_box_selected"];
            }else{
                imageS = [UIImage imageNamed:@"img_s_type_box_normal"];
            }
        }else{
           imageS = [UIImage imageNamed:@"img_s_type_sign_in_selected"];
        }
//        btnX = col * (margin + btnW);
//        btnY = row * (margin + btnW);
        //建议定位用Center，比较保险
        btnW = imageS.size.width;
        btnH = imageS.size.height;
        btn.frame = CGRectMake(0, 0, btnW, btnH);
        UIImage * baseImg = [UIImage imageNamed:@"img_s_type_sign_in_selected"];
        CGFloat centerX = baseImg.size.width/2 + col * (margin + baseImg.size.width);
        CGFloat centerY = baseImg.size.height/2 + row * (margin + 15 + baseImg.size.height);//竖着的间隙加15
        btn.center = CGPointMake(centerX, centerY);
    }
}
@end
