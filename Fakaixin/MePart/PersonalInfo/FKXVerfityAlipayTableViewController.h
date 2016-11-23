//
//  FKXVerfityAlipayTableViewController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

//绑定支付宝
@interface FKXVerfityAlipayTableViewController : FKXBaseTableViewController

@property(nonatomic, assign)BOOL isFromWithDraw;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBtn;

@end
