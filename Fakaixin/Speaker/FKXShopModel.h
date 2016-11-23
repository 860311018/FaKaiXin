//
//  FKXShopModel.h
//  Fakaixin
//
//  Created by liushengnan on 16/9/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "AFRequest.h"

@interface FKXShopModel : AFRequest
/*
 marketId:1,       //id  其余接口需要传的marketId
 image1:"img_headwear_big1@2x.png",    //大图  解忧杂货铺展示
 isOwn:0,    	//是否拥有
 love:25，		//购买所需爱心值
 image2:"img_headwear_small1@2x.png",
 element:1
 number:0，		//拥有的数量（仅限道具）
 inUse:1,    //1：使用中   0 拥有，但没使用
 */
@property (nonatomic, copy)   NSString<Optional> *image1;

@property (nonatomic, copy)   NSNumber<Optional> *element;
@property (nonatomic, strong) NSNumber<Optional> *marketId;
@property (nonatomic, strong) NSNumber<Optional> *isOwn;
@property (nonatomic, strong) NSNumber<Optional> *money;
@property (nonatomic, strong) NSNumber<Optional> *love;
@property (nonatomic, strong) NSNumber<Optional> *number;
@property (nonatomic, strong) NSNumber<Optional> *inUse;
@property (nonatomic, strong) NSNumber<Optional> *type;

@end
