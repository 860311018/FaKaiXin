//
//  FKXBannerModel.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXBannerModel : AFRequest

@property(nonatomic, strong)NSNumber<Optional> * attachEventId;
@property(nonatomic, strong)NSNumber<Optional> * uid;
@property(nonatomic, strong)NSNumber<Optional> * type;//0:专题  1:分享会; 2: 课程; 3:心事; 4:相同心情评论页面;
@property(nonatomic, copy)NSString<Optional> * bannerUrl;

@end
