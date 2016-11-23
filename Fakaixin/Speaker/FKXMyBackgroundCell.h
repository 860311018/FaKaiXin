//
//  FKXMyBackgroundCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXShopModel.h"
@class FKXMyBackgroundCell;

@protocol FKXMyBackgroundCellProtocol <NSObject>

- (void)clickCellBtn:(UIButton *)butt withCell:(FKXMyBackgroundCell *)cell;

@end

@interface FKXMyBackgroundCell : UITableViewCell

@property (assign,nonatomic) id<FKXMyBackgroundCellProtocol> delegate;

@property (nonatomic, strong) FKXShopModel *model;
@property (weak, nonatomic) IBOutlet UIButton *btnChange;

@end

