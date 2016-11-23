//
//  FKXCourseModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/26.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AFRequest.h"

@interface FKXCourseModel : AFRequest
/**
 *  background = "";
 keyId = 2;
 startTime = 1356240874000;
 title = dfsjkfg;
 */
@property(nonatomic, copy)NSString<Optional> * background;
@property(nonatomic, strong)NSNumber<Optional> * keyId;
@property(nonatomic, copy)NSString<Optional> * startTime;   //会议开始时间
@property(nonatomic, copy)NSString<Optional> * title;
@property(nonatomic, copy)NSString<Optional> * url;
@property(nonatomic, copy)NSNumber<Optional> * uid;
@property(nonatomic, strong)NSNumber<Optional> * expectCost;    //课程价格
@property(nonatomic, strong)NSNumber<Optional> *status;
@property(nonatomic, copy)NSString<Optional> * content;

@end
