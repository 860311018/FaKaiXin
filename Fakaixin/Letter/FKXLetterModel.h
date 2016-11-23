//
//  FKXLetterModel.h
//  Fakaixin
//
//  Created by liushengnan on 16/10/26.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXLetterModel : AFRequest
/*
 text = "\U6d4b\U8bd5\U56de\U4fe1";
 uid = 219;
 valid = 0;
 writeid = 3;
 createTime = 1477390853000;
 id = 3;
 userName
 userHead
 */
@property(nonatomic, strong)NSString<Optional>*text;//写信内容
@property(nonatomic, strong)NSNumber<Optional> *uid;
@property(nonatomic, strong)NSNumber<Optional> *valid;
@property(nonatomic, strong)NSNumber<Optional> *writeId;
@property(nonatomic, strong)NSString<Optional> *userName;
@property(nonatomic, strong)NSString<Optional> *userHead;
@property(nonatomic, strong)NSArray<Optional> * imageArray;//写信图片


@end
