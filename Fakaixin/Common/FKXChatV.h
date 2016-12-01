//
//  FKXChatV.h
//  Fakaixin
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXChatV : UIView
@property (weak, nonatomic) IBOutlet UILabel *introL;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UIImageView *backImgV;

+(id)creatChat;

@end
