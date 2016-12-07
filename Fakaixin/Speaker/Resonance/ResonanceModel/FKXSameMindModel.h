//
//  FKXSameMindModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/20.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AFRequest.h"

//相同心情的人model
@interface FKXSameMindModel : AFRequest


//worryId : 38888,                                        //心事id
//isHug : true,                                            //我是否已经抱过
//sorryNum : 3,                                           //当前的同感的数量
//uid : 10001,  //发布心事的用户id
//text : “我的小三和我的老婆私奔了”          //心事内容

//新增字段
@property(nonatomic, strong)NSNumber<Optional> *commentNum;

@property(nonatomic, copy)NSString<Optional> * head;
@property(nonatomic, strong)NSNumber<Optional> *hug;
@property(nonatomic, copy)NSString<Optional> * nickName;
@property(nonatomic, strong)NSNumber<Optional> *sex;
@property(nonatomic, strong)NSNumber<Optional> *sorryNum;
@property(nonatomic, copy)NSString<Optional> * text;
@property(nonatomic, copy)NSString<Optional> * talkId;  //方便给聊天界面传值
@property(nonatomic, copy)NSString<Optional> * checkedBackground;//当前正在使用的卡片背景
@property(nonatomic, copy)NSString<Optional> * checkedPendant;//当前正在使用的头饰
@property(nonatomic, strong)NSNumber<Optional> * uid;
@property(nonatomic, strong)NSNumber<Optional> *worryId;
@property(nonatomic, strong)NSArray<Optional> * imageArray;
@property(nonatomic, assign)NSNumber<Optional> *isOpen;
@property(nonatomic, assign)NSNumber<Optional> *isPublic;//心事是否不公开（匿名）
@property(nonatomic, copy)NSString<Optional> * createTime;
@property(nonatomic, strong)NSNumber<Optional> * worryType;
@property   (nonatomic,strong)NSNumber<Optional> *searchType;//搜索的类型：1，心事；2，享问；3，专家；4，文章

//享问
@property(nonatomic, strong)NSNumber<Optional> * userId;//发心事或提问者的id
@property(nonatomic, strong)NSNumber<Optional> * listenNum;////多少人偷听
@property(nonatomic, strong)NSNumber<Optional> * praiseNum;
@property(nonatomic, strong)NSNumber<Optional> * listenerId;
@property(nonatomic, strong)NSNumber<Optional> * price;
@property(nonatomic, strong)NSNumber<Optional> * voiceId;
//@property(nonatomic, strong)NSNumber<Optional> * worryId;
@property(nonatomic, strong)NSString<Optional> * userNickName;
//@property(nonatomic, strong)NSString<Optional> * text;
@property(nonatomic, strong)NSString<Optional> * listenerNickName;
@property(nonatomic, strong)NSString<Optional> * listenerProfession;
@property(nonatomic, strong)NSString<Optional> * listenerHead;
@property(nonatomic, strong)NSString<Optional> * voiceUrl;


@property(nonatomic, strong)NSString<Optional> *userBackground;//用户背景
@property(nonatomic, strong)NSString<Optional> *userPendant;//用户挂件
@property(nonatomic, strong)NSString<Optional> *listenerPendant;//挂件
@property(nonatomic, strong)NSString<Optional> *listenerBackground;//背景


@property(nonatomic, strong)NSNumber<Optional> *lqId;//个人主页付费提问的问题id
@property(nonatomic, strong)NSNumber<Optional> *topicId;//专题的id
@property(nonatomic, strong)NSNumber<Optional> *acceptMoney;//认可的价格
//@property(nonatomic, strong)NSNumber<Optional> *isPublic;//心事是否公开（匿名）
@property(nonatomic, strong)NSNumber<Optional> *isAccept;//含义在上边
@property(nonatomic, strong)NSNumber<Optional> *questionType;
@property(nonatomic, strong)NSString<Optional> *userHead;//发心事或提问者的头像"
@property(nonatomic, strong)NSString<Optional> *title;//专题标题,只有专题才有哦",
@property(nonatomic, strong)NSString<Optional> *content;//专题的内容,只有专题才有哦",
//@property(nonatomic, copy)NSString<Optional> * createTime;
//@property   (nonatomic,strong)NSNumber<Optional> *searchType;//搜索的类型：1，心事；2，享问；3，专家；4，文章
@property(nonatomic, copy)NSString<Optional> *voiceTime;
@property(nonatomic, copy)NSString<Optional> *voiceUrl30s;//是否有30的语音

//来信需要的字段
@property(nonatomic, copy)NSString<Optional> *writeText;//写信内容
@property   (nonatomic,strong)NSNumber<Optional> *writeId;
//@property(nonatomic, copy)NSArray<Optional> *imageArray;//写信图片
@property(nonatomic, copy)NSString<Optional> *backText;//回信内容

@end
