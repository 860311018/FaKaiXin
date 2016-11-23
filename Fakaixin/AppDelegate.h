//
//  AppDelegate.h
//  Fakaixin
//
//  Created by Connor on 10/9/15.
//  Copyright © 2015 FengMi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FKXChatListController;
@class SpeakerTabBarViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong)FKXChatListController  * conversationListVCListener;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property(nonatomic,strong)UIImageView *launchIma;

- (void)beginRegisterRemoteNot; //注册通知

@end

