//
//  FKXWithIconCell.h
//  Fakaixin
//
//  Created by liushengnan on 16/9/26.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSameMindModel.h"

@interface FKXWithIconCell : UITableViewCell

@property(nonatomic, strong)FKXUserInfoModel * model;
@property(nonatomic, strong)FKXSameMindModel *mindModel;

@end
