//
//  FKXGetMoreLoveValueVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXGetMoreLoveValueVC.h"

@interface FKXGetMoreLoveValueVC ()
@property (weak, nonatomic) IBOutlet UILabel *labMyLove;

@end

@implementation FKXGetMoreLoveValueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"获取更多爱心值";
    _labMyLove.text = [NSString stringWithFormat:@"我的爱心值：%@", _love];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

@end
