//
//  FKXChatListCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXChatListCell.h"

@interface FKXChatListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *messLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@end


@implementation FKXChatListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setConversation:(EMConversation *)conversation
{
    _conversation = conversation;
    //头像和昵称
    if (conversation.conversationType == eConversationTypeChat)
    {
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatUser"];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSError *fetchError;
        NSArray *usersArray = [ApplicationDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
        for (ChatUser *user in usersArray)
        {
            //接受方信息赋值
            if ([user.userId isEqualToString:conversation.chatter])
            {
                _nameLab.text = user.nick;
                [_iconImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",user.avatar,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                break;
            }
        }
    }else if (conversation.conversationType == eConversationTypeGroupChat)
    {
        EMGroup *groupInfo = [[EaseMob sharedInstance].chatManager fetchGroupInfo:conversation.chatter error:nil];
        NSString *headU = @"";
        if ([groupInfo.groupDescription containsString:@"分享会"]) {
            [_btnComeIn setTitle:@"进入分享会" forState:UIControlStateNormal];
            NSRange ran = [groupInfo.groupDescription rangeOfString:@"分享会"];
            headU = [groupInfo.groupDescription substringFromIndex:ran.length];
        }else if ([groupInfo.groupDescription containsString:@"课程"])
        {
            [_btnComeIn setTitle:@"进入课程" forState:UIControlStateNormal];
            NSRange ran = [groupInfo.groupDescription rangeOfString:@"课程"];
            headU = [groupInfo.groupDescription substringFromIndex:ran.length];
        }
        
        [_iconImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",headU,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        _nameLab.text = groupInfo.groupSubject;
    }
    //最新消息
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                latestMessageTitle = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                latestMessageTitle = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                latestMessageTitle = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                latestMessageTitle = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            case eMessageBodyType_File: {
                latestMessageTitle = NSLocalizedString(@"message.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    _messLab.text = latestMessageTitle;
    
    //最新时间
    NSString *latestMessageTime = @"";
    if (lastMessage) {
        latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    _timeLab.text = latestMessageTime;
}
@end
