//
//  FKXPersonalViewController.h
//  Fakaixin
//
//  Created by Connor on 10/10/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//


#import "FKXChatListController.h"
//“我”界面，两个tabbar公用一个
@interface FKXPersonalViewController : FKXBaseTableViewController

@property(nonatomic, assign)FKXChatListController * chatListVC;

@property (weak, nonatomic) IBOutlet UIView *redViewAnswer;//我答红点
@property (weak, nonatomic) IBOutlet UIView *redViewAsk;//（cell－与我相关的）（以前是我问红点）
- (IBAction)clickOpenAsk:(id)sender;

- (void)loadUnreadRelMe;//给通知来了贡献出来
@end
