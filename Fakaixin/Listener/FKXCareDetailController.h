//
//  FKXCareDetailController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/24.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSameMindModel.h"
#import "FKXCourseModel.h"
#import "FKXSecondAskModel.h"

typedef enum : NSUInteger {
    care_detail_type_people,    //个人主页的提问
    care_detail_type_special,   //专题
    care_detail_type_mind,   //心事
    care_detail_type_continue_ask   //追问
} CARE_DETAIL_TYPE;

//语音回复界面
@interface FKXCareDetailController : FKXBaseTableViewController

@property(nonatomic, strong)FKXSameMindModel * sameModel;
@property(nonatomic, strong)FKXSecondAskModel * askModel;

@property(nonatomic, strong)FKXCourseModel * courseModel;   //从专题进来的  “我也来答”

@property(nonatomic, assign)CARE_DETAIL_TYPE careDetailType;

@end
