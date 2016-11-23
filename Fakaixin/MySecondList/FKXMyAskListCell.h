//
//  FKXMyAskListCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSecondAskModel.h"

/**
 *  我问
 未接已过期：-1   用的我答界面
 心事过期：-2
 待认可：0
 追问：1
 待回复：2      用的我答界面
 //去听：3
 */
/**
 *  我答
 已过期：-1
 待认可：0
 已回答：1
 待回答：2
 被追问：3
 */

@protocol  FKXMyAskListCellDelegate<NSObject>
//认可，追问
- (void)goToAgree:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender;
//举报，删除，置顶
- (void)goToReport:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender;
//我的主页，动态
- (void)goToDynamicVC:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender;

@end


@interface FKXMyAskListCell : UITableViewCell

@property(nonatomic, assign)id<FKXMyAskListCellDelegate> delegate;
@property(nonatomic, strong)FKXSecondAskModel * model;
@property (weak, nonatomic) IBOutlet UIButton *btnAgree;

@end
