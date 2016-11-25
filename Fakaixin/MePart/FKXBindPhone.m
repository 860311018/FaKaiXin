//
//  FKXBindPhone.m
//  Fakaixin
//
//  Created by apple on 2016/11/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBindPhone.h"


@implementation FKXBindPhone

- (void)awakeFromNib {
    [super awakeFromNib];
   }

- (void)layoutSubviews {
    if (self.phoneStr) {
        self.phoneTF.text = self.phoneStr;
        self.phoneTF.enabled = NO;
    }
}

- (IBAction)sendCode:(id)sender {
    [_bindPhoneDelegate receiveCode:self.phoneTF.text];
}

- (IBAction)clickSave:(id)sender {
    [_bindPhoneDelegate saveBind:self.phoneTF.text code:self.codeTF.text secret:self.pwdTF.text];
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
