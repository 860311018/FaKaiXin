//
//  CycleView.h
//  MyDrawLine
//
//  Created by 刘胜南 on 16/6/29.
//  Copyright © 2016年 刘胜南. All rights reserved.
//

#import <UIKit/UIKit.h>
//录音的进度条
@interface CycleView : UIView

@property(nonatomic, assign)CGFloat progress;
- (void)drawProgress:(CGFloat)progress;

@end
