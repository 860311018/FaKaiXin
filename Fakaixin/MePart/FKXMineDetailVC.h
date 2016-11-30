//
//  FKXMineDetailVC.h
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MyDetailType) {
    MyDetailTypeHelp,
    MyDetailTypeZan,
};


@interface FKXMineDetailVC : FKXBaseViewController

@property(nonatomic,assign) MyDetailType type;

@property(nonatomic,copy)NSString *myhead;

@end
