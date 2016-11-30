//
//  FKXPaiHangModel.h
//  Fakaixin
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKXPaiHangModel : AFRequest

@property (nonatomic, strong) NSNumber<Optional> *commentDistance;
@property (nonatomic, strong) NSNumber<Optional> *commentFloat;
@property (nonatomic, strong) NSNumber<Optional> *commentNum;
@property (nonatomic, strong) NSNumber<Optional> *praiseDistance;
@property (nonatomic, strong) NSNumber<Optional> *praiseFloat;
@property (nonatomic, strong) NSNumber<Optional> *praiseNum;

@end
