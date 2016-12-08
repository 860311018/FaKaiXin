//
//  FKXMyOrdersCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FKXOrderModel;
@interface FKXMyOrdersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@property (weak, nonatomic) IBOutlet UIButton *operationBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *shengyiTime;

@property (nonatomic,strong) FKXOrderModel *model;
@property (nonatomic,assign) BOOL isWorkBench;

@end
