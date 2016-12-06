//
//  FKXScrTitelModel.h
//  Fakaixin
//
//  Created by apple on 2016/12/6.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "createTime": "",
 "fromHead": "http://7xrrm3.com2.z0.glb.qiniucdn.com/img_default_icon6.png",
 "fromId": 15,
 "fromNickname": "深邃的樱花",
 "time": 1481012542000,
 "toHead": "哈哈旅途1",
 "toId": 220,
 "toNickname": "http://7xrrm3.com2.z0.glb.qiniucdn.com/FlpLRVgvDcDsdYYxuBaYyTQ_vNEt",
 "type": 4          //1： 提问 ; 2：图文咨询  3：电话服务   4：评价
 */

@interface FKXScrTitelModel :AFRequest

@property(nonatomic, strong)NSString<Optional> * createTime;
@property(nonatomic, strong)NSString<Optional> * fromHead;
@property(nonatomic, strong)NSString<Optional> * fromNickname;
@property(nonatomic, strong)NSString<Optional> * toHead;
@property(nonatomic, strong)NSString<Optional> * toNickname;

@property(nonatomic, strong)NSNumber<Optional> * fromId;
@property(nonatomic, strong)NSNumber<Optional> * toId;
@property(nonatomic, strong)NSNumber<Optional> * type;
@property(nonatomic, strong)NSNumber<Optional> * time;


@end
