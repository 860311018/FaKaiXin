//
//  MyDynamicModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/22.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AFRequest.h"

//个人主页和与我相关展示的model
@interface MyDynamicModel : AFRequest
/**
 *  createTime:"1小时前",
 commentText:"评论的内容"
 toId:198,           //给谁的评论
 toNickname:"评论人的昵称",
 replyText:"评论谁的内容",
 type:2,       //  1评论     2抱    3 偷听    4 赞   
 // (个人主页） 5评价 6我语音回复  7 购买电话服务
 // (与我相关) 5语音回复 6收到回信 7浏览
 voiceId:12,
 voiceUrl:"",
 listenerProfession:"",
 praiseNum:12,
 listenNum:12,
 worryId:12,
 topicId:12,
 */

@property(nonatomic, copy)NSString<Optional> * createTime;
@property(nonatomic, copy)NSString<Optional> * commentText;
@property(nonatomic, copy)NSString<Optional> * toNickname;
@property(nonatomic, copy)NSString<Optional> * toHead;
@property(nonatomic, copy)NSString<Optional> * replyText;//（在信中代表写信内容）
@property(nonatomic, copy)NSString<Optional> * voiceUrl;
@property(nonatomic, copy)NSString<Optional> * listenerProfession;
@property(nonatomic, strong)NSNumber<Optional> * toId;
@property(nonatomic, strong)NSNumber<Optional> * type;
@property(nonatomic, strong)NSNumber<Optional> * voiceId;
@property(nonatomic, strong)NSNumber<Optional> * worryId;
@property(nonatomic, strong)NSNumber<Optional> * topicId;
@property(nonatomic, strong)NSNumber<Optional> * praiseNum;
@property(nonatomic, strong)NSNumber<Optional> * listenNum;
@property(nonatomic, strong)NSNumber<Optional> * time;
@property(nonatomic, strong)NSNumber<Optional> *acceptMoney;//认可的价格
@property(nonatomic, strong)NSNumber<Optional> *isAccept;//是否已经认可

@property(nonatomic, strong)NSNumber<Optional> *score;

//与我相关新增的三个字段
@property(nonatomic, strong)NSNumber<Optional> * fromId;
@property(nonatomic, copy)NSString<Optional> * fromHead;//与我相关的来自某个人的头像
@property(nonatomic, copy)NSString<Optional> * fromNickname;//与我相关

//自己写的3个字段，用来展示我的主页头部的头像等（封装到cell的model中去）
@property(nonatomic, copy)NSString<Optional> * head;//我的动态的来自某个人的头像
@property(nonatomic, copy)NSString<Optional> * nickname;
@property(nonatomic, strong)NSNumber<Optional> * role;

//来信需要的两个参数
@property(nonatomic, copy)NSString<Optional> * backText;//回信内容
@property(nonatomic, copy)NSArray<Optional> *imageArray;//来信的图片

@end
