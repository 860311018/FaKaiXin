//
//  FKXConsulterCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol  FKXConsulterCellDelegate<NSObject>
//
//- (void)goToDynamicVC:(FKXUserInfoModel*)cellModel sender:(UIButton*)sender;
//
//@end
@interface FKXConsulterCell : UITableViewCell

@property(nonatomic, strong)FKXUserInfoModel * model;
@property (weak, nonatomic) IBOutlet UIImageView *imgVip;
@property(nonatomic, assign)BOOL isVip;
//@property(nonatomic, assign)id<FKXConsulterCellDelegate> delegate;


@end
