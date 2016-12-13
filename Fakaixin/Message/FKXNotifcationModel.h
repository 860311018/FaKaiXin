//
//  FKXNotifcationModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/3/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXNotifcationModel : AFRequest
/**
 id : ""     //id值
 uid : ""      //用户id
 device:""//设备类型
 type : "" //推送类型
 alert: ""//提示内容
 data : "" //推送内容
 
 alert = "\U60a8\U6536\U5230\U4e86\U5fc3\U4e8b\U8ba2\U5355";
 data = "com.fakaixin.entity.vo.WorryOrderVO@54fc2f6a";
 device = 0;
 fromHeadUrl = "http://7xrrm3.com2.z0.glb.qiniucdn.com/FiGAqgCf_yszB2EKyxHl-es0bw7o";
 id = 23;
 pushTime = 1457750622000;
 type = 0;
 uid = 16;
 */

@property(nonatomic, copy)NSString<Optional>  * alert;
@property(nonatomic, copy)NSString<Optional>  * data;
@property(nonatomic, copy)NSString<Optional>  * createTime;
@property(nonatomic, strong)NSNumber<Optional> * uid;
@property(nonatomic, strong)NSNumber<Optional> * selfId;//这条的id，需要自己处理一下，id是特殊字符
@property(nonatomic, strong)NSNumber<Optional> * device;
@property(nonatomic, strong)NSNumber<Optional> * fromId;
@property(nonatomic, strong)NSNumber<Optional> * type;
@property(nonatomic, copy)NSString<Optional>   * fromHeadUrl;
@property(nonatomic, copy)NSString<Optional>   * fromNickname;
// 0  已评价  1未评价
@property(nonatomic, strong)NSNumber<Optional> * valid;

@property(nonatomic, copy)NSString<Optional> * worryId;
@end
