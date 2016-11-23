//
//  FKXBindPhone.m
//  Fakaixin
//
//  Created by apple on 2016/11/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBindPhone.h"

@implementation FKXBindPhone

- (IBAction)sendCode:(id)sender {
}

- (IBAction)clickSave:(id)sender {
}

+(id)creatBangDing {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXBindPhone" owner:self options:nil].lastObject;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
