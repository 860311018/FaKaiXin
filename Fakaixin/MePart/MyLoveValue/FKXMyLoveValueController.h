//
//  FKXMyLoveValue.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//


typedef NS_ENUM(NSInteger, MyRichType) {
    MyRichTypeLove,
    MyRichTypeIncome,
};

//我的爱心值主页
@interface FKXMyLoveValueController : FKXBaseViewController

@property (nonatomic,assign)MyRichType richType;

@end
