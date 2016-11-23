//
//  FKXPsyListModel.h
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXPsyListModel : AFRequest

@property(nonatomic, strong)NSNumber<Optional> * psyId;

@property(nonatomic, strong)NSString<Optional> * testTitle;  //标题
@property(nonatomic, copy)NSString<Optional> * testBackground;
@property(nonatomic, copy)NSNumber<Optional> * testNum;//测试人数
@property(nonatomic, copy)NSNumber<Optional> * praiseNum;//觉得准的人数
@property(nonatomic, copy)NSString<Optional> * startTestBackground;
@property(nonatomic, copy)NSString<Optional> * testDescribe;
@property(nonatomic, copy)NSNumber<Optional> * questionNum;
@property(nonatomic, copy)NSNumber<Optional> * createTime;
@property(nonatomic, copy)NSNumber<Optional> * valid;

@end
