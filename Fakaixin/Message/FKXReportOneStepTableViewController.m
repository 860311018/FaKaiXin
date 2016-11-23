//
//  FKXReportOneStepTableViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/6.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXReportOneStepTableViewController.h"
#import "FKXReportTwoStepController.h"

@interface FKXReportOneStepTableViewController ()
{
    NSArray *dataSource;
    NSMutableArray *arraySign;
}
@end

@implementation FKXReportOneStepTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"举报";
    dataSource = @[@"色情低俗", @"广告骚扰", @"政治敏感",@"谣言", @"欺诈骗钱",@"违法(暴力恐怖,违禁品等)",@"其它"];
    arraySign = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < dataSource.count; i++) {
        if (i == 0) {
            [arraySign addObject:@"1"];
            continue;
        }
        [arraySign addObject:@"0"];
    }
    
    //按钮
    UIButton * rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItem.frame = CGRectMake(0,0,45,12);
    rightItem.backgroundColor = [UIColor clearColor];
    [rightItem setTitle:@"下一步" forState:UIControlStateNormal];
    rightItem.titleLabel.font = kFont_F4();
    [rightItem setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    [rightItem addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItem];

    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

-(void)nextStep
{
    NSInteger index = 0;
    for (NSString *str in arraySign) {
        if ([str isEqual:@"1"]) {
            index = [arraySign indexOfObject:str];
            break;
        }
    }
    if (index == [arraySign count] - 1) {
        index = 0;
    }else{
        index++;
    }
    FKXReportTwoStepController *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXReportTwoStepController"];
    vc.reportType = index;
    vc.toUid = _toUid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reportCell"];
    }
    if ([arraySign[indexPath.row] isEqual:@"1"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = dataSource[indexPath.row];
    cell.textLabel.textColor = UIColorFromRGB(0x5a5a5a);
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0; i < arraySign.count; i++) {
        if (i == indexPath.row) {
            [arraySign replaceObjectAtIndex:indexPath.row withObject:@"1"];
        }else
        {
            [arraySign replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    [self.tableView reloadData];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"gotoReportTwoSegue"]) {
        NSInteger index = 0;
        for (NSString *str in arraySign) {
            if ([str isEqual:@"1"]) {
                index = [arraySign indexOfObject:str];
                break;
            }
        }
        if (index == [arraySign count] - 1) {
            index = 0;
        }else{
            index++;
        }
        FKXReportTwoStepController *vc = segue.destinationViewController;
        vc.reportType = index;
    }
}


@end
