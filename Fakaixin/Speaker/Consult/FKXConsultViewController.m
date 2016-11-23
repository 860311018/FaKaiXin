//
//  FKXConsultViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXConsultViewController.h"
#import "FKXConsulterCell.h"
#import "FKXCommitHtmlViewController.h"
#import "NSString+HeightCalculate.h"
#import "FKXProfessionInfoVC.h"

#import "FKXYuYueProCell.h"

@interface FKXConsultViewController ()<CallProDelegate>//<FKXConsulterCellDelegate>
{
    NSInteger start;
    NSInteger size;
    BOOL isVip;

    UILabel *newMessageLab;

}
@property   (nonatomic,strong)NSMutableArray *contentArr;

@end

@implementation FKXConsultViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //收到环信消息
    
    
    if ([_paraDic[@"role"] integerValue] == 1) {
        isVip = NO;
    }else{
        isVip = YES;
    }
    //初始化数据
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    
    [self setUpNavBar];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXYuYueProCell" bundle:nil] forCellReuseIdentifier:@"FKXYuYueProCell"];
    //给tableview添加下拉刷新,上拉加载
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    //首次刷新加载页面数据
    [self headerRefreshEvent];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    paramDic[@"role"] = _paraDic[@"role"];
    paramDic[@"priceRange"] = [_paraDic[@"priceRange"] integerValue] == -1 ? nil : _paraDic[@"priceRange"];
    paramDic[@"goodAt"] = [_paraDic[@"goodAt"] count]?_paraDic[@"goodAt"] : nil;
    
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

#pragma mark - 打电话给咨询师
- (IBAction)callZiXun:(id)sender {
    
}

- (void)callPro {
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
}

#pragma mark - separator insets 设置
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
//#pragma mark - cell自定义代理
//- (void)goToDynamicVC:(FKXUserInfoModel*)cellModel sender:(UIButton*)sender
//{
//    FKXMyDynamicVC *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil]instantiateViewControllerWithIdentifier:@"FKXMyDynamicVC"];
//    vc.userId = cellModel.uid;
//    [vc setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:vc animated:YES];
//}
#pragma mark - tableView代理
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXUserInfoModel *model = [self.contentArr objectAtIndex:indexPath.row];
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 7;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [model.profile heightForWidth:screen.size.width - 143 usingFont:[UIFont systemFontOfSize:14] style:sty];
    CGFloat unitH = [@"哈" heightForWidth:screen.size.width - 143 usingFont:[UIFont systemFontOfSize:14] style:nil];
    if (height > (unitH + 7)*2) {
        return 95 + (unitH + 7)*2;
    }
    return 95 + height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXUserInfoModel *model = [self.contentArr objectAtIndex:indexPath.row];

//    FKXConsulterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXConsulterCell" forIndexPath:indexPath];
    //    cell.delegate = self;

    FKXYuYueProCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXYuYueProCell" forIndexPath:indexPath];
    cell.isVip = isVip;
    cell.model = model;
    cell.callProDelegate = self;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXUserInfoModel *model = _contentArr[indexPath.row];
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = model.uid;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
    /*
    
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
        vc.pageType = MyPageType_people;
    if ([_paraDic[@"role"] integerValue] == 3) {
        vc.shareType = @"user_center_xinli";
        vc.urlString = [NSString stringWithFormat:@"%@front/QA_home.html?uid=%@&loginUserId=%ld&token=%@",kServiceBaseURL, model.uid, [FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    }else{
        vc.shareType = @"user_center_jinpai";
        vc.urlString = [NSString stringWithFormat:@"%@front/QA_home.html?uid=%@&loginUserId=%ld&token=%@",kServiceBaseURL, model.uid, [FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    }
    vc.userModel = model;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];*/
    
}

- (void)setUpNavBar
{
    UIImage *imageMind = [UIImage imageNamed:@"img_mine_message"];
    UIView *itemV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageMind.size.width/2 + 2 + 18,imageMind.size.width/2 + 2 + 18)];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, itemV.height - imageMind.size.height - 5, imageMind.size.width, imageMind.size.height)];
    imgV.image = imageMind;
    [itemV addSubview:imgV];
    
    newMessageLab = [[UILabel alloc] initWithFrame:CGRectMake(itemV.width - 18, 0, 18, 18)];
    newMessageLab.textAlignment = NSTextAlignmentCenter;
    newMessageLab.textColor = [UIColor whiteColor];
    [newMessageLab setAdjustsFontSizeToFitWidth:YES];
    newMessageLab.backgroundColor = UIColorFromRGB(0xfe9595);
    newMessageLab.font = [UIFont systemFontOfSize:12];
    newMessageLab.layer.cornerRadius = newMessageLab.width/2;
    newMessageLab.clipsToBounds = YES;
    [itemV addSubview:newMessageLab];
    
    newMessageLab.hidden = YES;
    
    [itemV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRightBtn)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:itemV];

}


@end
