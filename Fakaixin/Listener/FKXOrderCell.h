//
//  FKXOrderCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXOrderModel.h"

@protocol  FKXOrderCellDelegate<NSObject>
// 0 拒绝 1接受
- (void)rejectOrAcceptOrder:(FKXOrderModel*)cellModel sender:(UIButton *)sender;
- (void)goToDynamicVC:(FKXOrderModel*)cellModel sender:(UIButton*)sender;

@end

@interface FKXOrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnService;
@property(nonatomic, assign)id<FKXOrderCellDelegate> delegate;

@property(nonatomic, strong)FKXOrderModel * model;
@end
