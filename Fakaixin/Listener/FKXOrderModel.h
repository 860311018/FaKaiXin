//
//  FKXOrderModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFRequest.h"

@interface FKXOrderModel : AFRequest

@property(nonatomic, strong)NSNumber * orderId;
@property(nonatomic, copy)NSString * headUrl;
@property(nonatomic, copy)NSString * nickName;
@property(nonatomic, strong)NSNumber * userId;

@end
