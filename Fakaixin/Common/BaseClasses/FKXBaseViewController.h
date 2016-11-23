//
//  FKXBaseViewController.h
//  Fakaixin
//
//  Created by Connor on 10/10/15.
//  Copyright © 2015 FengMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMessage.h"

@interface FKXBaseViewController : UIViewController

@property(nonatomic, strong)NSString * navTitle;    //导航栏的标题

- (void)insertDataToTableWith:(EMMessage *)message managedObjectContext:(NSManagedObjectContext *)context;
@end
