//
//  FKXQingsuVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "FKXQingsuVC.h"
#import "FKXYuYueProCell.h"
#import "CycleScrollView.h"

#import "QingsuView.h"
#import "ScrllTitleView.h"
#import "FKXGrayView.h"

@interface FKXQingsuVC ()<UITableViewDelegate,UITableViewDataSource,CallProDelegate,FKXGrayDelegate>
{
    NSInteger start;
    NSInteger size;
    BOOL isVip;
    
    UIView *header;
}

@property (nonatomic,strong)NSMutableArray *contentArr;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIView *bottomView;

@property (nonatomic,strong)NSMutableArray *viewArr;

@property (nonatomic , retain) CycleScrollView *mainScorllView;

@property (nonatomic,strong) UIView *backView;

@end

@implementation FKXQingsuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navTitle = @"一键咨询";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_paraDic) {
        if ([_paraDic[@"role"] integerValue] == 1) {
            isVip = NO;
        }else{
            isVip = YES;
        }
    }
    
    
    [self setUpNavBar];
    if (self.showBack) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backView];
    }
    //初始化数据
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;

    [self.tableView  registerNib:[UINib nibWithNibName:@"FKXYuYueProCell" bundle:nil] forCellReuseIdentifier:@"FKXYuYueProCell"];
    
    //给tableview添加下拉刷新,上拉加载
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    //首次刷新加载页面数据
    [self headerRefreshEvent];
    
    [self.view addSubview:self.bottomView];

}

#pragma mark - UI
- (void)setUpNavBar
{
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

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 规则
- (void)guize{
    
}


#pragma mark - 一键倾诉
- (void)qingsu {
    
}

#pragma mark - ---网络请求---
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
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    paramDic[@"start"] = @(start);
    paramDic[@"size"] = @(size);
    paramDic[@"role"] = @3;
    
    [FKXUserInfoModel sendGetOrPostRequest:@"listener/listByRole" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
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
                 [_contentArr removeAllObjects];
                 
             }
             [_contentArr addObjectsFromArray:data];
             
             [self.tableView reloadData];
             
         }
         else if (errorModel)
         {
             NSInteger index = [errorModel.code integerValue];
             if (index == 4)
             {
                 [self showAlertViewWithTitle:errorModel.message];
                 [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             }else
             {
                 [self showHint:errorModel.message];
             }
         }
     }];
}



#pragma mark - tableViewDelegate


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.tableView)
//    {
//        CGFloat sectionHeaderHeight = 294; //sectionHeaderHeight
//        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//        }
//    }
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentArr.count;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[NSBundle mainBundle]loadNibNamed:@"QingsuView" owner:self options:nil].lastObject;
    
    
    NSMutableArray *viewsArray = [@[] mutableCopy];
    
    NSArray *arr = @[@"111111111111111111111",@"22222222222222222222",@"3333333333333333"];

    for (int i = 0; i < arr.count; ++i) {
        for (NSString *s in arr) {
           
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(64, 0, kScreenWidth-56, 98)];
            
            ScrllTitleView *view1 = [ScrllTitleView creatTitleView];
            view1.frame = CGRectMake(0, 0, kScreenWidth-56, 49);
            
           
            ScrllTitleView *view2 = [ScrllTitleView creatTitleView];
            view2.frame = CGRectMake(0, 49, kScreenWidth-56, 49);

            
            [view addSubview:view1];
            [view addSubview:view2];
            
            [viewsArray addObject:view];
        }
        
    }

    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(64, 0, 288, 98) animationDuration:2.5];
    self.mainScorllView.backgroundColor = [[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1] colorWithAlphaComponent:0.1];

    self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    self.mainScorllView.totalPagesCount = ^NSInteger(void){
        return arr.count;
    };
    
    [view addSubview:self.mainScorllView];

    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 294;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FKXUserInfoModel *model = [self.contentArr objectAtIndex:indexPath.row];

    FKXYuYueProCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXYuYueProCell" forIndexPath:indexPath];
    cell.model = model;
    cell.isVip = isVip;
    
    cell.callProDelegate = self;
    
    return cell;
}




- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50-64, kScreenWidth, 50)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.alpha = 0.85;
        
        UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        lineV.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        [_bottomView addSubview:lineV];
        
        UIButton *zixunBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        zixunBtn.frame = CGRectMake((kScreenWidth-160)/2, 6, 160, 37);
        zixunBtn.backgroundColor = [UIColor colorWithRed:46/255.0 green:227/255.0 blue:245/255.0 alpha:1];
        zixunBtn.layer.cornerRadius = 18;
        zixunBtn.layer.masksToBounds = YES;
//        [zixunBtn setBackgroundImage:[UIImage imageNamed:@"qingsu_btnBack"] forState:UIControlStateNormal];
        [zixunBtn setTitle:@"  一键倾诉" forState:UIControlStateNormal];
        [zixunBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [zixunBtn setImage:[UIImage imageNamed:@"free_yuyue"] forState:UIControlStateNormal];
        zixunBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [zixunBtn addTarget:self action:@selector(qingsu) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:zixunBtn];
    }
    return _bottomView;
}

- (NSMutableArray *)viewArr {
    if (!_viewArr) {
        _viewArr = [NSMutableArray arrayWithCapacity:1];
    }
    return _viewArr;
}

//- (QingsuView *)qingsuView {
//    if (!_qingsuView) {
//        _qingsuView = [[NSBundle mainBundle]loadNibNamed:@"QingsuView" owner:self options:nil].lastObject;
//    }
//    return _qingsuView;
//}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        UIImageView *imge = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back"]];
        [_backView addSubview:imge];
        
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)]];
    }
    return _backView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 打电话

- (void)callPro {
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    
    FKXGrayView *order = [[FKXGrayView alloc]initWithPoint:CGRectMake(0, kScreenHeight-285, kScreenWidth, 285)];
    order.grayDelegate = self;
    [order show];
}

- (void)adMinutes {
    
}

- (void)deMinutes {
    
}

- (void)bangDingMobile {
    
}

- (void)clickWeiXinPay {
    
}

- (void)clickZhiFuBaoPay {
    
}

- (void)clickConfirm {
    
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
