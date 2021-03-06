//
//  FKXOrderModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFRequest.h"

/*
 "createTime": 1480413785000,
 "headUrl": "http://wx.qlogo.cn/mmopen/NpTicJIZa0Ht5kia1ClOaXb92fOTL2RzIfurbYeKTwQXPrjibO92rWDKtdEwZuOzYibkyPDQ5SucW9Qt7YZLeSYxwAKGmyHuYJibb/0",
 "listenerId": 221,
 "nickName": "张晓瑞",
 "orderId": 108,
 "status": 1,2，3已拒绝  4 “去看评价”    进行  “打电话”   “完成”
 "talkId": "2007"
 
 "callLength": 60,
 

 */
@interface FKXOrderModel : AFRequest

// 0 图文咨询  1电话咨询  2推荐专家电话咨询
@property (nonatomic, strong) NSNumber<Optional> *type;


@property (nonatomic, strong) NSNumber<Optional> *createTime;

@property (nonatomic, copy) NSString<Optional> *headUrl;

@property (nonatomic, strong) NSNumber<Optional> *listenerId;

@property (nonatomic, strong) NSNumber<Optional> *userId;

@property (nonatomic, copy) NSString <Optional> *nickName;

@property (nonatomic, strong) NSNumber<Optional> *orderId;

@property (nonatomic, strong) NSNumber<Optional> *status;

@property (nonatomic, strong) NSNumber<Optional> *callLength;

@property (nonatomic, copy) NSString<Optional> *talkId;

@property (nonatomic, strong) NSNumber<Optional> *phonePrice;
@property (nonatomic, strong) NSNumber<Optional> *role;
@property (nonatomic, copy) NSString<Optional> *clientNum;
@property (nonatomic, copy) NSString<Optional> *mobile;
@property (nonatomic, strong) NSNumber<Optional> *isOnline;
@property (nonatomic, strong) NSNumber<Optional> *money;



@end
