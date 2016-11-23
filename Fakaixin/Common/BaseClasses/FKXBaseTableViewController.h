//
//  FKXBaseTableViewController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMessage.h"

@interface FKXBaseTableViewController : UITableViewController

@property(nonatomic, strong)NSString * navTitle; //导航栏的标题

- (void)insertDataToTableWith:(EMMessage *)message managedObjectContext:(NSManagedObjectContext *)context;
@end
