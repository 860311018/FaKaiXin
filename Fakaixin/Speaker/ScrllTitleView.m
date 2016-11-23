//
//  ScrllTitleView.m
//  Fakaixin
//
//  Created by apple on 2016/11/22.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "ScrllTitleView.h"

@implementation ScrllTitleView
+(id)creatTitleView {
    ScrllTitleView *view = [[NSBundle mainBundle]loadNibNamed:@"ScrllTitleView" owner:self options:nil].lastObject;
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
