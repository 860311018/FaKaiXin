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

#import "FKXEvaluateVC.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXNotifcationModel.h"

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

#pragma mark - 操作订单（拒绝、接受）
- (void)operationOrder:(FKXOrderModel *)model status:(NSNumber *)status {
    NSNumber *type = @0;
    if (model.callLength && [model.callLength integerValue]!=0) {
        type = @1;
    }
    NSDictionary *params = @{@"orderId":model.orderId,@"type":type,@"status":status};
    
    [AFRequest sendGetOrPostRequest:@"listener/updateOrders" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue]==0) {
            model.status = status;
            [self.tableView reloadData];
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

#pragma mark - 电话咨询（已经付款）
- (void)toCall:(FKXOrderModel *)model {

}

#pragma mark - 图文咨询（聊天页，已确认订单）
- (void)toTuWen:(FKXOrderModel *)model {
    
}

#pragma mark - 下电话订单 （再次预约）
- (void)callOrder:(FKXOrderModel *)model {
    
}

#pragma mark - 下图文订单 （再次预约）
- (void)tuwenOrder:(FKXOrderModel *)model {
    
}

#pragma mark - 私信（未确认订单）
- (void)toChatVC:(FKXOrderModel *)model {
    
}

#pragma mark - 去评价
- (void)toComment:(FKXOrderModel *)model {
    FKXEvaluateVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXEvaluateVC"];
    FKXNotifcationModel *noModel = [[FKXNotifcationModel alloc]init];
    noModel.fromId =model.listenerId;
    noModel.fromHeadUrl = model.headUrl;
    noModel.fromNickname = model.nickName;
    if (model.callLength && [model.callLength integerValue]!=0) {
        noModel.type = @2;
    }else {
        noModel.type = @1;
    }
    vc.model = noModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 去看评价
- (void)toCommenViewt:(FKXOrderModel *)model {
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"user_center_yu_yue";//预约
    vc.pageType = MyPageType_consult;
    FKXUserInfoModel *userModel = [FKXUserManager getUserInfoModel];
    vc.urlString = [NSString stringWithFormat:@"%@front/user_center.html?uid=%@&token=%@",kServiceBaseURL, userModel.uid, [FKXUserManager shareInstance].currentUserToken];
    vc.userModel = userModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 查看详情
- (void)toDetailVC:(FKXOrderModel *)model {
    FKXMyOderDetailVC *vc = [[FKXMyOderDetailVC alloc]initWithNibName:@"FKXMyOderDetailVC" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.isWorkBench = self.isWorkBench;
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 点击按钮
- (void)cancel:(UIButton *)btn {
    FKXOrderModel *model = self.tableData[btn.tag-2000];
    //拒绝订单
    [self operationOrder:model status:@3];
}

- (void)operation :(UIButton *)btn {
    FKXOrderModel *model = self.tableData[btn.tag-1000];
    if (self.isWorkBench) {
        if ([model.status integerValue] == 0){
            //确认订单
            [self operationOrder:model status:@1];
        }else if ([model.status integerValue] == 1){
            //去服务
            if (model.callLength && [model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:model];
            }else {
                //图文咨询
                [self toTuWen:model];
            }
        }else if ([model.status integerValue] == 2){
            //查看详情
            [self toDetailVC:model];
        }else if ([model.status integerValue] == 3){
            //查看详情
            [self toDetailVC:model];
        }else if ([model.status integerValue] == 4){
            //去看评价
            [self toCommenViewt:model];
        }
    }else{
        if ([model.status integerValue] == 0){
            //私信TA
            [self toChatVC:model];
        }else if ([model.status integerValue] == 1){
            //立即咨询
            if (model.callLength && [model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:model];
            }else {
                //图文咨询
                [self toTuWen:model];
            }
        }else if ([model.status integerValue] == 2){
            //立即评价
            [self toComment:model];
        }else if ([model.status integerValue] == 3){
            //查看详情
            [self toDetailVC:model];
        }else if ([model.status integerValue] == 4){
            //再次预约
            if (model.callLength && [model.callLength integerValue]!=0) {
                //电话咨询
                [self callOrder:model];
            }else {
                //图文咨询
                [self tuwenOrder:model];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FKXOrderModel *model = self.tableData[indexPath.row];
    [self toDetailVC:model];
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
    cell.operationBtn.tag = 1000+indexPath.row;
    [cell.operationBtn addTarget:self action:@selector(operation:) forControlEvents:UIControlEventTouchUpInside];
    cell.cancelBtn.tag = 2000+indexPath.row;
    [cell.cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
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
