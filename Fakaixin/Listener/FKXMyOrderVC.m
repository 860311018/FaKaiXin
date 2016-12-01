//
//  FKXMyOrderVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/23.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyOrderVC.h"
#import "OrderRegularV.h"
#import "FKXLisOrderV.h"

#import "FKXMyOrdersCell.h"
#import "FKXOrderModel.h"

#import "FKXMyOderDetailVC.h"

@interface FKXMyOrderVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
    NSInteger start;
    NSInteger size;

    FKXEmptyData *emptyDataView;    //空数据

    UIView *transViewRemind;//透明图
    OrderRegularV *mindRemindV;//每日提醒界面
    FKXLisOrderV *mindRemindV2;
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *tableData;


@end

@implementation FKXMyOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"我的订单";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpNav];
    
    size = kRequestSize;
   
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXMyOrdersCell" bundle:nil] forCellReuseIdentifier:@"FKXMyOrdersCell"];
    
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    self.tableView.tableFooterView.frame = CGRectZero;
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    
    [self headerRefreshEvent];
}


#pragma mark - seperator insets 设置

- (void)headerRefreshEvent
{
    start = 0;
    [self loadData];
}

- (void)footRefreshEvent
{
    start += size;
    [self loadData];
}

- (void)loadData
{
    self.tableView.header.state = MJRefreshHeaderStateIdle;
    self.tableView.footer.state = MJRefreshFooterStateIdle;
    NSDictionary *paramDic = @{@"start":@(start),@"size":@(size)};
    
    NSString *urlStr;
    if (self.isWorkBench) {
        urlStr = @"listener/orderByListener";
    }else {
        urlStr = @"listener/orderByUser";
    }
    
//    [AFRequest sendPostRequestTwo:urlStr param:paramDic success:^(id data) {
//        NSLog(@"%@",data);
//    } failure:^(NSError *error) {
//        
//    }];
    [FKXOrderModel sendGetOrPostRequest:urlStr param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             if ([data count] < kRequestSize) {
                 self.tableView.footer.hidden = YES;
             }else
             {
                 self.tableView.footer.hidden = NO;
             }
             if (start == 0)
             {
                 [self.tableData removeAllObjects];
                 if ([data count] == 0) {
                     [self createEmptyData];
                 }else{
                     if (emptyDataView) {
                         [emptyDataView removeFromSuperview];
                         emptyDataView = nil;
                     }
                 }
             }
             [self.tableData addObjectsFromArray:data];
             [self.tableView reloadData];
         } else if (errorModel)
         {
             [self showHint:errorModel.message];
             
         }
     }];
}



#pragma mark - 空数据
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        emptyDataView.btnDeal.hidden = YES;
        emptyDataView.titleLab.text = @"还没有订单";
        [self.tableView addSubview:emptyDataView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FKXMyOderDetailVC *vc = [[FKXMyOderDetailVC alloc]initWithNibName:@"FKXMyOderDetailVC" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXOrderModel *model = self.tableData[indexPath.row];
    FKXMyOrdersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyOrdersCell" forIndexPath:indexPath];
    cell.isWorkBench = self.isWorkBench;
    cell.model = model;
    return cell;
}

- (NSMutableArray *)tableData {
    if (!_tableData) {
        _tableData = [[NSMutableArray alloc]init];
    }
    return _tableData;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpNav {
    UIView *guizeV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 16)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 15)];
    label.text = @"规则";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = kColorMainBlue;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 15, 30, 1)];
    line.backgroundColor = kColorMainBlue;
    
    [guizeV addSubview:label];
    [guizeV addSubview:line];
    
    [guizeV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guize)]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:guizeV];
}

#pragma mark - 规则
- (void)guize{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (!transViewRemind)
    {
        //透明背景
        transViewRemind = [[UIView alloc] initWithFrame:screenBounds];
        transViewRemind.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewRemind.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewRemind];
        
        mindRemindV = [[[NSBundle mainBundle] loadNibNamed:@"OrderRegularV" owner:nil options:nil] firstObject];
        [mindRemindV.btnDone addTarget:self action:@selector(hiddentransViewRemind) forControlEvents:UIControlEventTouchUpInside];
        
        mindRemindV2 = [[[NSBundle mainBundle] loadNibNamed:@"FKXLisOrderV" owner:nil options:nil] firstObject];
        [mindRemindV2.btnClose addTarget:self action:@selector(hiddentransViewRemind) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.isWorkBench) {
            [transViewRemind addSubview:mindRemindV2];
        }else {
            [transViewRemind addSubview:mindRemindV];
        }
        
        mindRemindV.center = transViewRemind.center;
        mindRemindV2.center = transViewRemind.center;

        [UIView animateWithDuration:0.5 animations:^{
            transViewRemind.alpha = 1.0;
        }];
    }
}

- (void)hiddentransViewRemind
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewRemind.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewRemind removeFromSuperview];
        transViewRemind = nil;

    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
