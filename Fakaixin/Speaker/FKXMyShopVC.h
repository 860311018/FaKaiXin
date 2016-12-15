//
//  FKXMyShopVC.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//


//解忧杂货铺的pageVC
@interface FKXMyShopVC : FKXBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *labLoveValue;
@property (nonatomic, strong) NSNumber *love;//爱心值
@property(nonatomic, assign)NSInteger status;
- (IBAction)clickTool:(UIButton *)sender;
- (IBAction)clickStamp:(id)sender ;
@end
