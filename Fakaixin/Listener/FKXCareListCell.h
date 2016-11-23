//
//  FKXCareListCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/25.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSameMindModel.h"

@class FKXCareListCell;

@protocol protocolFKXCareListCell <NSObject>

- (void)goToDynamicVC:(FKXSameMindModel*)cellModel sender:(UIButton*)sender;

@end
//关怀列表
@interface FKXCareListCell : UITableViewCell

@property(nonatomic, assign)id<protocolFKXCareListCell> delegate;
@property(nonatomic, strong)FKXSameMindModel * model;
@property(nonatomic, assign)CGFloat fontH; //文字的高

@end
