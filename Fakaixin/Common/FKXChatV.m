//
//  FKXChatV.m
//  Fakaixin
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChatV.h"

@interface FKXChatV ()

@end

@implementation FKXChatV
- (void)awakeFromNib {
    [super awakeFromNib];
//    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
//    self.backImgV set

}



+(id)creatChat {
    return [[NSBundle mainBundle]loadNibNamed:@"FKXChatV" owner:self options:nil].lastObject;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
