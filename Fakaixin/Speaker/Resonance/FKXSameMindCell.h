//
//  FKXSameMindCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSameMindModel.h"
@class FKXSameMindCell;


@protocol  FKXSameMindCellDelegate<NSObject>
// 0 抱抱 1 同感
- (void)hugOrFeelDidSelect:(FKXSameMindModel*)cellModel type:(NSInteger)type;
- (void)clickToOpenDetail;

@end


@interface FKXSameMindCell : UITableViewCell

@property(nonatomic, assign)id<FKXSameMindCellDelegate> delegate;
@property(nonatomic, strong)FKXSameMindModel * model;

//@property (weak, nonatomic) IBOutlet UIButton *btnOpenDetail;

@end
