//
//  FKXMyLoveValue.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/4.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyLoveValueController.h"
#import "FKXLoveValueTableViewCell.h"
#import "FKXLoveMoney.h"
#import "FKXLoveMoneyDetail.h"
#import "FKXWithDrawTableViewController.h"
#import "FKXBinddingTelephoneController.h"
#import "FKXVerfityAlipayTableViewController.h"

#import "FKXRichTitleCell.h"
#import "FKXRichDetailCell.h"
#import "FKXLoveDetailCell.h"

@interface FKXMyLoveValueController ()<UITableViewDataSource,MyRichSelectDelegate,MyRichItemsDelegate,UITableViewDelegate>
{
    NSMutableArray<FKXLoveMoneyDetail *> *dataSource;
    NSInteger start;
    NSInteger size;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
//@property (weak, nonatomic) IBOutlet UILabel *labLoveValue;
//@property (weak, nonatomic) IBOutlet UILabel *labelIncome;

@property (nonatomic,copy) NSString *loveStr;
@property (nonatomic,copy) NSString *incomeStr;

@property (nonatomic,copy) NSString *expend;
@property (nonatomic,copy) NSString *inCome;
@property (nonatomic,copy) NSString *total;

@property (nonatomic,assign)BOOL addWorry;
@property (nonatomic,assign)BOOL checkIn;
@property (nonatomic,assign)BOOL comment;
@property (nonatomic,assign)BOOL payVoice;
@property (nonatomic,assign)BOOL shareApp;
@property (nonatomic,assign)BOOL thank;

@end

@implementation FKXMyLoveValueController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self headerRefreshEvent];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"我的财富";
    self.richType = MyRichTypeLove;

    _myTableView.estimatedRowHeight = 44;
    _myTableView.rowHeight = UITableViewAutomaticDimension;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    size = kRequestSize;
    dataSource = [NSMutableArray arrayWithCapacity:1];
    
    [_myTableView registerNib:[UINib nibWithNibName:@"FKXRichTitleCell" bundle:nil] forCellReuseIdentifier:@"FKXRichTitleCell"];
    
    [_myTableView registerNib:[UINib nibWithNibName:@"FKXRichDetailCell" bundle:nil] forCellReuseIdentifier:@"FKXRichDetailCell"];
    
    [_myTableView registerNib:[UINib nibWithNibName:@"FKXLoveDetailCell" bundle:nil] forCellReuseIdentifier:@"FKXLoveDetailCell"];
    
    [_myTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [_myTableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 选择爱心或收入
- (void)selectLove {
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
    self.richType = MyRichTypeLove;
    [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)selectIncome {
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
    self.richType = MyRichTypeIncome;
    [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 刷新 + 请求部分
- (void)loadMyMoney
{
    NSDictionary *paramDic = @{};
    
    [AFRequest sendGetOrPostRequest:@"account/current" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
    {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
//            _labLoveValue.text = [data[@"data"][@"love"] stringValue];
//            _labelIncome.text = [NSString stringWithFormat:@"%.2f", [data[@"data"][@"money"] doubleValue]/100];
            
            self.loveStr = [data[@"data"][@"love"] stringValue];
            self.addWorry = [data[@"data"][@"addWorry"] boolValue];
            self.checkIn = [data[@"data"][@"checkIn"] boolValue];
            self.comment = [data[@"data"][@"comment"] boolValue];
            self.payVoice = [data[@"data"][@"payVoice"] boolValue];
            self.shareApp = [data[@"data"][@"shareApp"] boolValue];
            self.thank = [data[@"data"][@"thank"] boolValue];

            self.incomeStr = [NSString stringWithFormat:@"%.2f", [data[@"data"][@"money"] doubleValue]/100];
            self.expend = [NSString stringWithFormat:@"¥%.2f", [data[@"data"][@"expend"] doubleValue]/100];
            self.inCome = [NSString stringWithFormat:@"¥%.2f", [data[@"data"][@"inCome"] doubleValue]/100];
            self.total = [NSString stringWithFormat:@"¥%.2f", [data[@"data"][@"total"] doubleValue]/100];
            
            [_myTableView reloadData];
        }
        else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];
}
- (void)loadData
{
    NSDictionary *paramDic = @{@"start" : @(start), @"size": @(size)};

    [FKXLoveMoneyDetail  sendGetOrPostRequest:@"account/trace" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
    {
        [self hideHud];
        _myTableView.header.state = MJRefreshHeaderStateIdle;
        _myTableView.footer.state = MJRefreshFooterStateIdle;
        if (data)
        {
            [self hideHud];
            
            if ([data count] < kRequestSize) {
                _myTableView.footer.hidden = YES;
            }else
            {
                _myTableView.footer.hidden = NO;
            }
            
            if (start == 0)
            {
                [dataSource removeAllObjects];
                
            }
            [dataSource addObjectsFromArray:data];
            [_myTableView reloadData];
            
        }
        else if (errorModel)
        {
            NSInteger index = [errorModel.code integerValue];
            if (index == 4)
            {
                [self showAlertViewWithTitle:data[@"message"]];
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
            }else
            {
                [self showHint:errorModel.message];
            }
        }
    }];
}
- (void)headerRefreshEvent
{
    [self loadMyMoney];//加载财富和收入
    start = 0;
    [self loadData];
}
- (void)footRefreshEvent
{
    start += size;
    [self loadData];
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([_myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_myTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([_myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_myTableView setSeparatorInset:UIEdgeInsetsZero];
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
#pragma mark - tableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else if (section == 1) {
        return dataSource.count+1;
    }
    return 0;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    
////    if (dataSource.count > 0) {
//        return dataSource.count + 1;
////    }
////    return 0;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 8;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == 0) {
//        return 29;
//    }else
//    {
//        return 60;
//    }
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _myTableView.frame.size.width, 6)];
//    view.backgroundColor = RGBACOLOR(243, 243, 243, 1.0);
//    return view;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            FKXRichTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXRichTitleCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
            
            cell.myLoveL.text = self.loveStr;
            cell.myIncomeL.text = self.incomeStr;
            
            cell.myRichSelectDelegate = self;
            
            return cell;
        }else if (indexPath.row == 1) {
            if (self.richType == MyRichTypeLove) {
                FKXLoveDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXLoveDetailCell" forIndexPath:indexPath];

                    cell.sendImgV.alpha = 1;
                    cell.shadow6.alpha = 0;
                    cell.qianDaoImgV.alpha = 1;
                    cell.shadow1.alpha = 0;
                    cell.qianDaoImgV.alpha = 1;
                    cell.shadow2.alpha = 0;
                    cell.wenDaImgV.alpha = 1;
                    cell.shadow5.alpha = 0;
                    cell.shareImgV.alpha = 1;
                    cell.shadow4.alpha = 0;
                    cell.thanksImgV.alpha = 1;
                    cell.shadow3.alpha = 0;

                if (self.addWorry) {
                    cell.sendImgV.alpha = 0.2;
                    cell.shadow6.alpha = 1;
                }if (self.checkIn) {
                    cell.qianDaoImgV.alpha = 0.2;
                    cell.shadow1.alpha = 1;
                }if (self.comment) {
                    cell.qianDaoImgV.alpha = 0.2;
                    cell.shadow2.alpha = 1;
                }if (self.payVoice) {
                    cell.wenDaImgV.alpha = 0.2;
                    cell.shadow5.alpha = 1;
                }if (self.shareApp) {
                    cell.shareImgV.alpha = 0.2;
                    cell.shadow4.alpha = 1;
                }if (self.thank) {
                    cell.thanksImgV.alpha = 0.2;
                    cell.shadow3.alpha = 1;
                }

                return cell;
            }else if (self.richType == MyRichTypeIncome) {
                FKXRichDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXRichDetailCell" forIndexPath:indexPath];
                cell.myRichItemsDelegate = self;
                
                cell.zhichu.text = self.expend;
                cell.shouru.text = self.inCome;
                cell.heji.text = self.total;
                
                return cell;
            }
        }
    }
    else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"richCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.text = @"收支明细";
            cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            return cell;
        }else {
            FKXLoveValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loveValueCell"];
            cell.model = dataSource[indexPath.row - 1];
            return cell;
            
        }
        
    }
    return nil;
}

#pragma mark - 点击事件
- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)selectTiXian{
    
    if ([self.incomeStr doubleValue] < 50) {
        [self showAlertViewWithTitle:@"收入值大于等于50才能提现"];
        return;
    }
    
    NSDictionary *paramDic = @{};
    [self showHudInView:self.view hint:@"正在校验..."];
    [AFRequest sendGetOrPostRequest:@"sys/validatetocash" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
    {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            BOOL isBindingMobile = [data[@"data"][@"mobile"] boolValue];
            BOOL isBindingAlipay = [data[@"data"][@"alipay"] boolValue];
            if (isBindingMobile && isBindingAlipay) {
                
                FKXWithDrawTableViewController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXWithDrawTableViewController"];
                vc.money = self.incomeStr;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if(isBindingMobile && !isBindingAlipay)
            {
                FKXVerfityAlipayTableViewController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXVerfityAlipayTableViewController"];
                FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
                vc.isFromWithDraw = YES;
                [self presentViewController:nav animated:YES completion:nil];
            }
            else
            {
                FKXBinddingTelephoneController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXBinddingTelephoneController"];
                FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
                vc.isFromWithDraw = YES;
                [self presentViewController:nav animated:YES completion:nil];
            }

        }
        else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

@end
