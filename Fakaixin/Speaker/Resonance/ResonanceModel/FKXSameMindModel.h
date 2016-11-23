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


@end
