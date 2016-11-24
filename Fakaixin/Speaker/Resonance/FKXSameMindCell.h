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
// 1 同感
- (void)hugOrFeelDidSelect:(FKXSameMindModel*)cellModel type:(NSInteger)type andCellType:(NSInteger)cellType;
- (void)clickToOpenDetail;

//抱抱
- (void)baobao:(FKXSameMindModel*)cellModel;

//跳转评论HTML
- (void)comment:(FKXSameMindModel*)cellModel;


//跳转语音HTML
- (void)voice:(FKXSameMindModel*)cellModel;

@end


@interface FKXSameMindCell : UITableViewCell

@property(nonatomic, assign)id<FKXSameMindCellDelegate> delegate;
@property(nonatomic, strong)FKXSameMindModel * model;

@property (nonatomic,assign)NSInteger type;

//@property (weak, nonatomic) IBOutlet UIButton *btnOpenDetail;

@end
