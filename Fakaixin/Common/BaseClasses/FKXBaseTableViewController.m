//
//  FKXBaseTableViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseTableViewController.h"

@interface FKXBaseTableViewController ()<UIGestureRecognizerDelegate>

@end

@implementation FKXBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建返回按钮
    [self setUpBackBtn];
}
- (void)setUpBackBtn
{
    if ([self.navigationController viewControllers].count > 1) {
        UIImage *consultImage = [UIImage imageNamed:@"back"];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
        
        [btn setBackgroundImage:consultImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setNavTitle:(NSString *)navTitle
{
    [self setTitleViewOfNavigationItem:navTitle];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
#pragma mark - 保存会话的用户信息数据库
- (void)insertDataToTableWith:(EMMessage *)message managedObjectContext:(NSManagedObjectContext *)context
{
    //遍历会话列表,获取用户最新信息
    NSError *fetchError;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"ChatUser"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray * fetchArray = [context executeFetchRequest:request error:&fetchError];
    BOOL isContains = NO;
    for (ChatUser *user in fetchArray)
    {
        if ([user.userId isEqualToString:message.from])
        {
            isContains = YES;
            
            user.avatar = message.ext[@"head"];
            user.nick = message.ext[@"name"];            break;
        }
    }
    if (!isContains)
    {
        //遍历会话列表,获取用户最新信息
        ChatUser *chatUser = [NSEntityDescription insertNewObjectForEntityForName:@"ChatUser" inManagedObjectContext:context];
        
        chatUser.userId = message.from;
        chatUser.avatar = message.ext[@"head"];
        chatUser.nick = message.ext[@"name"];
    }
    
    if (context != nil) {
        NSError *error = nil;
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
