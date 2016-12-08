//
//  FKXChatTitleView.m
//  Fakaixin
//
//  Created by apple on 2016/11/28.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChatTitleView.h"

@implementation FKXChatTitleView

- (void)awakeFromNib {
    [super awakeFromNib];

    
}



+ (id)creatChatTitle {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXChatTitleView" owner:self options:nil].lastObject;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
