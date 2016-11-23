//
//  FKXResonance_homepage_model.h
//  Fakaixin
//
//  Created by 王莉 on 15/10/24.
//  Copyright © 2015年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFRequest.h"
//热门文章model
@interface FKXResonance_homepage_model : AFRequest

@property   (nonatomic,strong)NSString<Optional> *background;
@property   (nonatomic,strong)NSString<Optional> *title;
@property   (nonatomic,strong)NSString<Optional> *hotId;
@property   (nonatomic,strong)NSNumber<Optional> *commentNum;
@property   (nonatomic,strong)NSString<Optional> *text;
@property   (nonatomic,strong)NSNumber<Optional> *type;
@property   (nonatomic,strong)NSString<Optional> *url;

@property   (nonatomic,strong)NSNumber<Optional> *searchType;//搜索的类型：1，心事；2，享问；3，专家；4，文章
//文章列表第二个展示分享会或者课程，expectCost有值代表是课程
@property(nonatomic, strong)NSNumber<Optional> * expectCost;    //课程价格
@property   (nonatomic,strong)NSNumber<Optional> *status;
@property   (nonatomic,strong)NSNumber<Optional> *keyId;
@property(nonatomic, copy)NSString<Optional> * startTime;   //会议开始时间
@property   (nonatomic,strong)NSNumber<Optional> *uid;
@end
