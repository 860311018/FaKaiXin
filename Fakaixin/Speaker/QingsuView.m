//
//  QingsuView.m
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "QingsuView.h"

@implementation QingsuView

+(id)creatView {
    QingsuView *view = [[NSBundle mainBundle]loadNibNamed:@"QingsuView" owner:self options:nil].lastObject;
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
