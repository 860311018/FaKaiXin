//
//  FKXMyToolCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXShopModel.h"
@class FKXMyToolCell;

//补签卡100 ，置顶卡80，头饰25，背景30
@protocol FKXMyToolCellProtocol <NSObject>

- (void)clickCellBtn:(UIButton *)butt withCell:(FKXMyToolCell *)cell;

@end

//我的道具
@interface FKXMyToolCell : UITableViewCell

@property (assign,nonatomic) id<FKXMyToolCellProtocol> delegate;

@property (nonatomic, strong) FKXShopModel *model;

@property (weak, nonatomic) IBOutlet UIButton *btnChange;
@end
