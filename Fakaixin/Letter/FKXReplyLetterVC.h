//
//  FKXReplyLetterVC.h
//  Fakaixin
//
//  Created by liushengnan on 16/10/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseTableViewController.h"
#import "FKXLetterModel.h"
#import "MyDynamicModel.h"
#import "FKXSecondAskModel.h"

@interface FKXReplyLetterVC : FKXBaseTableViewController

@property(nonatomic, strong)FKXLetterModel *model;//来信列表的model，未回复的
@property(nonatomic, strong)MyDynamicModel * dynamicModel;//与我相关的，已回复的，
@property(nonatomic, strong)FKXSecondAskModel *secondAskModel;//我问列表，未回复和已回复的，未回复的只展示自己的信，已回复的要收起自己的来信

@end
