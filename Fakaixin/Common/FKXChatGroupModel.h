//
//  FKXChatGroupModel.h
//  Fakaixin
//
//  Created by apple on 2016/12/2.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXChatGroupModel : AFRequest

@property (nonatomic, strong) NSString<Optional> *type;
@property (nonatomic, strong) NSString<Optional> *from;
@property (nonatomic, strong) NSString<Optional> *chat_type;
@property (nonatomic, strong) NSString<Optional> *msg_id;
@property (nonatomic, strong) NSDictionary<Optional> *payload;
@property (nonatomic, strong) NSNumber<Optional> *timestamp;
@property (nonatomic, strong) NSString<Optional> *to;



@end
