//
//  ChatUser+CoreDataProperties.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/1.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSNumber *hasStop;
@property (nullable, nonatomic, retain) NSNumber *isListenerReply;
@property (nullable, nonatomic, retain) NSNumber *isPayTalk;
@property (nullable, nonatomic, retain) NSDate *lastPeplayTimeMillisecond;
@property (nullable, nonatomic, retain) NSString *nick;
@property (nullable, nonatomic, retain) NSNumber *roleType;
@property (nullable, nonatomic, retain) NSNumber *startChat;
@property (nullable, nonatomic, retain) NSDate *startTimeMillisecond;
@property (nullable, nonatomic, retain) NSString *talkId;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSNumber *consultPrice;

@end

NS_ASSUME_NONNULL_END
