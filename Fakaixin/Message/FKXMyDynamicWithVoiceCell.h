//
//  FKXMyDynamicWithVoiceCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDynamicModel.h"

@protocol  FKXMyDynamicWithVoiceCellDelegate<NSObject>

- (void)goToDynamicVC:(MyDynamicModel*)cellModel sender:(UIButton*)sender;

@end
//有语音内容
@interface FKXMyDynamicWithVoiceCell : UITableViewCell

@property(nonatomic, assign)id<FKXMyDynamicWithVoiceCellDelegate> delegate;
@property(nonatomic, strong)MyDynamicModel * model;

@end
