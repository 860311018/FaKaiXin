//
//  FKXChatListCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
//会话列表
@interface FKXChatListCell : UITableViewCell

@property(nonatomic, strong)EMConversation * conversation;
@property (weak, nonatomic) IBOutlet UIButton *btnComeIn;
@property (weak, nonatomic) IBOutlet UIButton *showBadge;
@end
