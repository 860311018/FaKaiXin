//
//  FKXSecondAskModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/28.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AFRequest.h"

//userId:75,		//发心事人的id
//
//userNickName:"鲔爱亟夯",	//发心事人的昵称
//
//text:"心事内容",		//心事内容
//listenNum:0,          /	/多少人听过
//
//praiseNum:0,       //多少人认同
//
//listenerId:74,       	//倾听者的id
//
//listenerNickName:"坚强的宝宝",   //倾听者的昵称
//
//listenerProfession:"伐开心",    //倾听者的职业
//listenerHead:" ",          //倾听者的头像
//
//
//price:1,	//多少元付费听
//
//
//voiceId:2,		//当前录音的id
//
//worryId:2380	//心事的id
//voiceUrl  语音路径


/**
 *  我问
 未接已过期：-1
 心事过期：-2
 待认可：0
 追问：1
 待回复：2
 //去听：3
 信件4待回复
 信件5已回复
 */
/**
 *  我答
 已过期：-1
 待认可：0
 已回答：1
 待回答：2
 被追问：3
 */


@interface FKXSecondAskModel : AFRequest

@property(nonatomic, strong)NSNumber<Optional> * userId;//发心事或提问者的id
@property(nonatomic, strong)NSNumber<Optional> * listenNum;////多少人偷听
@property(nonatomic, strong)NSNumber<Optional> * praiseNum;
@property(nonatomic, strong)NSNumber<Optional> * listenerId;
@property(nonatomic, strong)NSNumber<Optional> * price;
@property(nonatomic, strong)NSNumber<Optional> * voiceId;
@property(nonatomic, strong)NSNumber<Optional> * worryId;
@property(nonatomic, strong)NSString<Optional> * userNickName;
@property(nonatomic, strong)NSString<Optional> * text;
@property(nonatomic, strong)NSString<Optional> * listenerNickName;
@property(nonatomic, strong)NSString<Optional> * listenerProfession;
@property(nonatomic, strong)NSString<Optional> * listenerHead;
@property(nonatomic, strong)NSString<Optional> * voiceUrl;
@property(nonatomic, strong)NSString<Optional> * userBackground;

@property(nonatomic, strong)NSNumber<Optional> *lqId;//个人主页付费提问的问题id
@property(nonatomic, strong)NSNumber<Optional> *topicId;//专题的id
@property(nonatomic, strong)NSNumber<Optional> *acceptMoney;//认可的价格
@property(nonatomic, strong)NSNumber<Optional> *isPublic;//心事是否公开（匿名）
@property(nonatomic, strong)NSNumber<Optional> *isAccept;//含义在上边
@property(nonatomic, strong)NSNumber<Optional> *questionType;
@property(nonatomic, strong)NSString<Optional> *userHead;//发心事或提问者的头像"
@property(nonatomic, strong)NSString<Optional> *title;//专题标题,只有专题才有哦",
@property(nonatomic, strong)NSString<Optional> *content;//专题的内容,只有专题才有哦",
@property(nonatomic, copy)NSString<Optional> * createTime;
@property   (nonatomic,strong)NSNumber<Optional> *searchType;//搜索的类型：1，心事；2，享问；3，专家；4，文章
@property(nonatomic, copy)NSString<Optional> *voiceTime;
@property(nonatomic, copy)NSString<Optional> *voiceUrl30s;//是否有30的语音

//来信需要的字段
@property(nonatomic, copy)NSString<Optional> *writeText;//写信内容
@property   (nonatomic,strong)NSNumber<Optional> *writeId;
@property(nonatomic, copy)NSArray<Optional> *imageArray;//写信图片
@property(nonatomic, copy)NSString<Optional> *backText;//回信内容

//
@property   (nonatomic,strong)NSNumber<Optional> *commentNum;


@end
