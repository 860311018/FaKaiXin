//
//  FKXPsyInfoModel.h
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXPsyInfoModel : AFRequest

@property(nonatomic, strong)NSString<Optional> * question;  //测试问题
@property(nonatomic, copy)NSString<Optional> * answer1;
@property(nonatomic, copy)NSString<Optional> * answer2;
@property(nonatomic, copy)NSString<Optional> * answer3;
@property(nonatomic, copy)NSString<Optional> * answer4;
@property(nonatomic, copy)NSString<Optional> * questionBackground;

@property(nonatomic, copy)NSNumber<Optional> * createTime;
@property(nonatomic, copy)NSNumber<Optional> * valid;

@end
