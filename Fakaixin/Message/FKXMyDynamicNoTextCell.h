//
//  FKXMyDynamicNoTextCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDynamicModel.h"

@protocol  FKXMyDynamicNoTextCellDelegate<NSObject>

- (void)goToDynamicVC:(MyDynamicModel*)cellModel sender:(UIButton*)sender;

@end
//没有文本内容
@interface FKXMyDynamicNoTextCell : UITableViewCell

@property(nonatomic, assign)id<FKXMyDynamicNoTextCellDelegate> delegate;
@property(nonatomic, strong)MyDynamicModel * model;

@end
