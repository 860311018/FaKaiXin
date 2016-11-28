

//
//  FKXFangkeVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/28.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXFangkeVC.h"
#import "FKXFangkeCell.h"

@interface FKXFangkeVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger start;
    NSInteger size;
    
    FKXEmptyData *emptyDataView;    //空数据
 
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *tableData;

@end

@implementation FKXFangkeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"访客";
    self.view.backgroundColor = [UIColor whiteColor];
   
    size = kRequestSize;

    self.tableData = [@[@"3",@"3",@"3"]mutableCopy];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXFangkeCell" bundle:nil] forCellReuseIdentifier:@"FKXFangkeCell"];

    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    self.tableView.tableFooterView.frame = CGRectZero;
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
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
    
//        if ([data count] < kRequestSize) {
//            self.tableView.footer.hidden = YES;
//        }else
//        {
//            self.tableView.footer.hidden = NO;
//        }
//        if (start == 0)
//        {
//            [_contentArr removeAllObjects];
//            if ([data count] == 0) {
//                [self createEmptyData];
//            }else{
//                if (emptyDataView) {
//                    [emptyDataView removeFromSuperview];
//                    emptyDataView = nil;
//                }
//            }
//        }
//        [_contentArr addObjectsFromArray:data];
//        
//        [self.tableView reloadData];
}


#pragma mark - 空数据
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        emptyDataView.btnDeal.hidden = YES;
        emptyDataView.titleLab.text = @"还没有来信";
        [self.tableView addSubview:emptyDataView];
    }
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
  
    FKXFangkeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXFangkeCell" forIndexPath:indexPath];
//    cell.isVip = isVip;
//    cell.model = model;

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
//        _tableView.estimatedRowHeight = 44;
//        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
