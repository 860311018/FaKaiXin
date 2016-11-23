//
//  FKXPsyListModel.m
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPsyListModel.h"

@implementation FKXPsyListModel

+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"psyId"}];
}

@end
