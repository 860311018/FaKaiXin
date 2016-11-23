//
//  FKXSignInView.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/25.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXSignInView.h"

@implementation FKXSignInView

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
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"使用补签" attributes:@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
    [_btnAddSign.titleLabel setAttributedText:str];
}
@end
