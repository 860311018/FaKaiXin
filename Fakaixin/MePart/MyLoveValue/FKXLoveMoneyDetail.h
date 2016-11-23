//
//  FKXLoveMoneyDetail.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

//我的爱心值主页获取服务器的model的detail
@interface FKXLoveMoneyDetail : AFRequest

@property(nonatomic, strong)NSString<Optional> * amount;  //收支流水
@property(nonatomic, copy)NSString<Optional> * type;
//@property(nonatomic, copy)NSString * value;
@property(nonatomic, copy)NSNumber<Optional> * unit;
@property(nonatomic, copy)NSString<Optional> * user;
@property(nonatomic, copy)NSString<Optional> * time;



@end
