//
//  FKXSameMindImgCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSameMindModel.h"
@class FKXSameMindImgCell;

@protocol  FKXSameMindImgCellDelegate<NSObject>
// 0 抱抱 1 同感
- (void)hugOrFeelImgDidSelect:(FKXSameMindModel*)cellModel type:(NSInteger)type;
- (void)clickToOpenDetail;
@end

@interface FKXSameMindImgCell : UITableViewCell

@property(nonatomic, assign)id<FKXSameMindImgCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *bacImage;
@property(nonatomic, strong)FKXSameMindModel * model;

//@property (weak, nonatomic) IBOutlet UIButton *btnOpenDetail;

@end
