//
//  FKXRichDetailCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyRichItemsDelegate <NSObject>

- (void)selectTiXian;

@end

@interface FKXRichDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *tiXianBtn;
@property (weak, nonatomic) IBOutlet UILabel *zhichu;
@property (weak, nonatomic) IBOutlet UILabel *shouru;
@property (weak, nonatomic) IBOutlet UILabel *heji;

@property (weak, nonatomic) id<MyRichItemsDelegate>myRichItemsDelegate;

@end
