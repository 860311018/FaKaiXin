//
//  FKXAboutMeCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDynamicModel.h"

@protocol  FKXAboutMeCellDelegate<NSObject>

- (void)goToDynamicVC:(MyDynamicModel*)cellModel sender:(UIButton*)sender;

@end

@interface FKXAboutMeCell : UITableViewCell

@property(nonatomic, strong)MyDynamicModel * model;

@property(nonatomic, assign)id<FKXAboutMeCellDelegate> delegate;

@end
