//
//  FKXEChatModel.h
//  Fakaixin
//
//  Created by apple on 2016/12/2.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXEChatModel : AFRequest

@property (nonatomic, strong) NSString<Optional> *msg;
@property (nonatomic, strong) NSString<Optional> *type;
@property (nonatomic, strong) NSNumber<Optional> *length;
@property (nonatomic, strong) NSString<Optional> *url;
@property (nonatomic, strong) NSString<Optional> *filename;
@property (nonatomic, strong) NSString<Optional> *secret;
@property (nonatomic, strong) NSNumber<Optional> *lat;
@property (nonatomic, strong) NSNumber<Optional> *lng;
@property (nonatomic, strong) NSString<Optional> *addr;

@end
