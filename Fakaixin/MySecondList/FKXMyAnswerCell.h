//
//  FKXMyAnswerCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSecondAskModel.h"

/**
 *  我问
 未接已过期：-1
 心事过期：-2
 待认可：0
 追问：1
 待回复：2      
 //去听：3
 信件4待回复
 信件5已回复
 */
/**
 *  我答
 已过期：-1
 待认可：0
 已回答：1
 待回答：2
 被追问：3
 */

@protocol  FKXMyAnswerCellDelegate<NSObject>
//去回答
- (void)goToAnswer:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender;
//我的个人主页
- (void)goToDynamicVC:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender;

@end

@interface FKXMyAnswerCell : UITableViewCell

@property(nonatomic, assign)id<FKXMyAnswerCellDelegate> delegate;
@property(nonatomic, strong)FKXSecondAskModel * model;
@property (weak, nonatomic) IBOutlet UIButton *btnAnswer;
@property (weak, nonatomic) IBOutlet UILabel *labStatus;
@property(nonatomic, assign)BOOL isAnswer;  //我答和我问列表都用这个cell了，但是展示状态的枚举不是一个


@end
