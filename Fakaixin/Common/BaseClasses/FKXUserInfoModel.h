//
//  FKXUserInfoModel.h
//  Fakaixin
//
//  Created by Connor on 10/16/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "AFRequest.h"


@interface FKXUserInfoModel : AFRequest

/**
 *    uid : 10001,             //倾听者id
 name : "自卑的小土豆",            //倾听者名称
 sex : 2                        //倾听者性别
 head : "head.png"                  //倾听者头像
 listenNum : 344,                     //倾听人数
 listenTime : 333,                     //倾听分钟数
 praiseRate : 98,                      //好评百分比
 beatRate : 89,                        //打败人数百分比
 level : 2,                                 //倾听者等级
 profile : "我哥哥是骄傲的小土豆~",      //个人简介
 goodAt : [0,1,2],                      //擅长领域 ，对应心事类型的编号
 exp : 122,                 //倾听者经验值
 honor : "乐于助人"                   //倾听者荣誉名称
 price : 5                                 //金牌倾听者咨询费
 */

@property (nonatomic, strong) NSNumber<Optional> *age;
@property (nonatomic, copy  ) NSString<Optional>           *background;
@property (nonatomic, strong) NSNumber<Optional> *beatRate;
@property (nonatomic, copy  ) NSString<Optional>* credentials;
@property (nonatomic, strong) NSNumber<Optional> *exp;
@property(nonatomic, strong)  NSArray <Optional> *goodAt;
@property (nonatomic, copy  ) NSString<Optional>           *head;
@property (nonatomic, strong) NSNumber<Optional> *level;    //1.正式倾听者  2.金牌倾听者
@property (nonatomic, strong) NSNumber<Optional> *listenNum;
@property (nonatomic, strong) NSNumber<Optional> *listenTime;
@property (nonatomic, strong) NSNumber<Optional> *marry;
@property(nonatomic, copy   ) NSString<Optional> *mobile;
@property (nonatomic, copy  ) NSString<Optional>           *name;
@property (nonatomic, strong) NSNumber<Optional> *praiseRate;
@property (nonatomic, strong) NSNumber<Optional> *price;//提问费
@property(nonatomic, strong)NSNumber<Optional> * consultingFee;//咨询费
@property(nonatomic, strong)NSNumber<Optional> * phonePrice;//电话咨询费
@property (nonatomic, strong) NSNumber<Optional> *status;
@property(nonatomic, strong)NSString<Optional> * clientNum;
@property(nonatomic, strong)NSString<Optional> * clientPwd;
@property(nonatomic, strong)NSString<Optional> *pwd;

@property (nonatomic, copy  ) NSString<Optional> *profession;
@property (nonatomic, copy  ) NSString<Optional> *profile;
@property (nonatomic, strong) NSNumber<Optional> *role; //0 倾诉者；1 倾听者（关怀者）；3 咨询师
@property (nonatomic, strong) NSNumber<Optional>           *sex;
@property (nonatomic, copy  ) NSString<Optional> *talkId;   //这是创建聊天后产生的talkId
@property (nonatomic, strong) NSNumber<Optional>      *tag;
@property (nonatomic, copy  ) NSString<Optional> *token;
//@property (nonatomic, copy  ) NSString<Optional>           *uid;
@property (nonatomic, strong  ) NSNumber<Optional>           *uid;
@property (nonatomic, copy  ) NSString<Optional> *url;

@property (nonatomic, strong) NSNumber<Optional>           *questions;  //回答问题的个数
@property (nonatomic, strong) NSNumber<Optional>           *inCome; //总收入
@property (nonatomic, strong) NSNumber<Optional>           *acceptNumber;   //认可的个数

@property (nonatomic, strong) NSNumber<Optional>           *cureCount;   //治愈的人数
@property   (nonatomic,strong)NSNumber<Optional> *searchType;//搜索的类型：1，心事；2，享问；3，专家；4，文章
@end
