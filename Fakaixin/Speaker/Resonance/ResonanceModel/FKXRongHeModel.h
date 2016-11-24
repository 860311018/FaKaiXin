//
//  FKXRongHeModel.h
//  Fakaixin
//
//  Created by apple on 2016/11/24.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FKXSameMindModel;
@class FKXSecondAskModel;

@interface FKXRongHeModel : AFRequest

@property(nonatomic, strong)NSNumber<Optional> * type;

@property(nonatomic, strong)FKXSameMindModel<Optional> * worryVO;
@property(nonatomic, strong)FKXSameMindModel<Optional> * sendsAskVO;

@end
