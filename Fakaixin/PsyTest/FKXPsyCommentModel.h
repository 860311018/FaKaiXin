//
//  FKXPsyCommentModel.h
//  Fakaixin
//
//  Created by apple on 2016/11/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXPsyCommentModel : AFRequest

/*text:"评论内容",
uid:4,
userHead:"http://7xrrm3.com2.z0.glb.qiniucdn.com/img_default_icon3.png",
userName:"喜感的喵星人"
*/

@property(nonatomic, strong)NSNumber<Optional> * uid;

//评论内容
@property(nonatomic, strong)NSString<Optional> * text;
@property(nonatomic, strong)NSString<Optional> * userHead;
@property(nonatomic, strong)NSString<Optional> * userName;


@end
