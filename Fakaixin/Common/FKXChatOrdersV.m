//
//  FKXChatOrdersV.m
//  Fakaixin
//
//  Created by apple on 2016/12/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChatOrdersV.h"

@implementation FKXChatOrdersV

+(id)creatMengCeng {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXChatOrdersV" owner:self options:nil].lastObject;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
