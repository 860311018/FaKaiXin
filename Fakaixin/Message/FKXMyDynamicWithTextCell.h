//
//  FKXMyDynamicWithTextCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDynamicModel.h"

@protocol  FKXMyDynamicWithTextCellDelegate<NSObject>

- (void)goToDynamicVC:(MyDynamicModel*)cellModel sender:(UIButton*)sender;

@end
//有文本内容
@interface FKXMyDynamicWithTextCell : UITableViewCell

@property(nonatomic, assign)id<FKXMyDynamicWithTextCellDelegate> delegate;
@property(nonatomic, strong)MyDynamicModel * model;


@end
