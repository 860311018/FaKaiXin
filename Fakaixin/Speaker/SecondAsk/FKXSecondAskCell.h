//
//  FKXSecondAskCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSecondAskModel.h"


@protocol  FKXSecondAskCellDelegate<NSObject>

//- (void)playRecordBtnDidSelect:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender;
- (void)goToDynamicVC:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender;

@end

@interface FKXSecondAskCell : UITableViewCell

@property(nonatomic, assign)id<FKXSecondAskCellDelegate> delegate;
@property(nonatomic, strong)FKXSecondAskModel * model;
@property (weak, nonatomic) IBOutlet UIImageView *imgMargin;

@end
