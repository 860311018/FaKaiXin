//
//  FKXRichTitleCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyRichSelectDelegate <NSObject>

- (void)selectLove;
- (void)selectIncome;

@end

@interface FKXRichTitleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *aixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *shouruBtn;
@property (weak, nonatomic) IBOutlet UILabel *myLoveL;
@property (weak, nonatomic) IBOutlet UILabel *myIncomeL;
@property (weak, nonatomic) IBOutlet UIView *loveBackV;
@property (weak, nonatomic) IBOutlet UIView *incomeBackV;

//选择的三角图标
@property (weak, nonatomic) IBOutlet UIButton *selectLove;
@property (weak, nonatomic) IBOutlet UIButton *selectIncome;


@property (weak, nonatomic) id<MyRichSelectDelegate>myRichSelectDelegate;

- (void)reloadCell;

@end
