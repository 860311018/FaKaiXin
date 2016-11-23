//
//  FKXSearchVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/26.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXSearchVC.h"
#import "FKXWithVoiceCell.h"
#import "FKXWithIconCell.h"
#import "FKXWithArticleCell.h"
#import "FKXResonance_homepage_model.h"
#import "FKXSecondAskModel.h"
#import "FKXUserInfoModel.h"
#import "FKXSameMindModel.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXProfessionInfoVC.h"

@interface FKXSearchVC ()<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource>
{
    //搜索的类型：1，心事；2，享问；3，专家；4，文章
    NSMutableArray *articleList;
    NSMutableArray *listenerList;
    NSMutableArray *voiceList;
    NSMutableArray *worryList;
    
    UIView *hiddenHotsView;//遮盖热门搜索按钮的视图
    NSArray *hotTitles;//热门搜索title

    NSMutableDictionary *allDataDic;//所有数据的字典
    UIButton *currentSelectedBtn;//当前点击的section的按钮
    
    BOOL isOpen; //是否展开
}
@property (weak, nonatomic) IBOutlet UITextField *myTF;//搜索框
@property (weak, nonatomic) IBOutlet UIImageView *imgEmpty;
@property (weak, nonatomic) IBOutlet UILabel *labEmpty;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@end

@implementation FKXSearchVC
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_myTF becomeFirstResponder];
    articleList = [NSMutableArray arrayWithCapacity:1];
    worryList = [NSMutableArray arrayWithCapacity:1];
    voiceList = [NSMutableArray arrayWithCapacity:1];
    listenerList = [NSMutableArray arrayWithCapacity:1];
    allDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    //热门搜索关键字
    [self hotSearch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 热门搜索
- (void)hotSearch
{
    NSDictionary *paramDic = @{};
    [AFRequest sendGetOrPostRequest:@"sys/hotSearch"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         if ([data[@"code"] integerValue] == 0)
         {
             hotTitles = data[@"data"][@"list"];
             CGFloat btnX = 23;//第一个按钮的x
             CGFloat btnY = 101;//第一个按钮的y
             CGFloat marginX = 14;//间隙
             CGFloat marginY = 23;//间隙
             for (int i = 0; i < hotTitles.count; i++)
             {
                 NSString *subT = hotTitles[i];
                 UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
                 butt.tag = 200 + i;
                 butt.layer.cornerRadius = 10;
                 butt.backgroundColor = UIColorFromRGB(0xb6c1c8);
                 [butt setTitle:subT forState:UIControlStateNormal];
                 [butt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                 butt.titleLabel.font = [UIFont systemFontOfSize:15];
                 [butt addTarget:self action:@selector(clickHotSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
                 [self.view addSubview:butt];
                 //计算文字宽度
                 NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
                 CGSize labelSize = (CGSize){1000, FLT_MAX};
                 CGRect rect = [subT boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:context];
                 CGFloat btnW = rect.size.width + 30;
                 CGFloat btnH = rect.size.height + 16;
                 //获取上个按钮
                 UIView *preView = [self.view viewWithTag:200 + i - 1];
                 if (i > 0) {
                     btnX += (preView.width + marginX);
                 }
                 if (btnX + btnW + 23 > self.view.width)
                 {
                     btnX = 23;
                     btnY += marginY + btnH;
                 }
                 butt.frame = CGRectMake(btnX, btnY, btnW, btnH);
             }
             
             hiddenHotsView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.width, self.view.height - 60)];
             hiddenHotsView.backgroundColor = kColorBackgroundGray;
             hiddenHotsView.hidden = YES;
             [self.view addSubview:hiddenHotsView];
         }
         else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
- (void)clickHotSearchBtn:(UIButton *)butt
{
    _myTF.text = butt.titleLabel.text;
    [self textFieldShouldReturn:_myTF];
}
#pragma mark - 点击事件
- (IBAction)goBack:(UIButton *)sender {
    [_myTF resignFirstResponder];
    //这是用来控制点击返回按钮刷新tableview时，UI的转换
    if (!isOpen) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        isOpen = NO;
        currentSelectedBtn.selected = NO;
        [_detailTableView reloadData];
    }
}
- (IBAction)clickSearch:(UIButton *)sender {
    [_myTF resignFirstResponder];
}
- (IBAction)clickClearTF:(UIButton *)sender {
    _myTF.text = nil;
}
#pragma mark - uitextFieldDelegate 开始搜索
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString *text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!text.length) {
        [self showHint:@"请输入搜索内容"];
        return YES;
    }
    currentSelectedBtn = nil;
    [worryList removeAllObjects];
    [articleList removeAllObjects];
    [listenerList removeAllObjects];
    [voiceList removeAllObjects];
    [allDataDic removeAllObjects];

    [self showHudInView:self.view hint:@"正在搜索..."];
    NSDictionary *paramDic = @{
                               @"uid" : @([FKXUserManager shareInstance].currentUserId),
                               @"text":text};
    [AFRequest sendGetOrPostRequest:@"sys/search"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         /*
          worryList:[],     	//心事list
          voiceList:[],		//享问list
          listenerList[],		//专家list
          articleList[]		//文章list
          */
         
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             for (NSDictionary *subDic in data[@"data"][@"worryList"]) {
                 FKXSameMindModel *model = [[FKXSameMindModel alloc] initWithDictionary:subDic error:nil];
                 model.searchType = @(1);
                 [worryList addObject:model];
             }
             if (worryList.count) {
                 [allDataDic setObject:worryList forKey:@"worryList"];
             }
             for (NSDictionary *subDic in data[@"data"][@"voiceList"]) {
                 FKXSecondAskModel *model = [[FKXSecondAskModel alloc] initWithDictionary:subDic error:nil];
                 model.searchType = @(2);
                 [voiceList addObject:model];
             }
             if (voiceList.count) {
                 [allDataDic setObject:voiceList forKey:@"voiceList"];
             }
             for (NSDictionary *subDic in data[@"data"][@"listenerList"]) {
                 FKXUserInfoModel *model = [[FKXUserInfoModel alloc] initWithDictionary:subDic error:nil];
                 model.searchType = @(3);
                 [listenerList addObject:model];
             }
             if (listenerList.count) {
                 [allDataDic setObject:listenerList forKey:@"listenerList"];
             }
             for (NSDictionary *subDic in data[@"data"][@"articleList"]) {
                 FKXResonance_homepage_model *model = [[FKXResonance_homepage_model alloc] initWithDictionary:subDic error:nil];
                 model.searchType = @(4);
                 [articleList addObject:model];
             }
             if (articleList.count) {
                 [allDataDic setObject:articleList forKey:@"articleList"];
             }
             NSInteger allCount = articleList.count + worryList.count + listenerList.count + voiceList.count;
             if (allCount == 0) {
                 hiddenHotsView.hidden = YES;
                 _detailTableView.hidden = YES;
                 _labEmpty.hidden = NO;
                 _imgEmpty.hidden = NO;
             }else{
                 hiddenHotsView.hidden = NO;
                 _detailTableView.hidden = NO;
                 [self.view bringSubviewToFront:_detailTableView];
                 //刷新数据
                 [_detailTableView reloadData];
                 _labEmpty.hidden = YES;
                 _imgEmpty.hidden = YES;
             }
         }
         else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
        
         [self hideHud];
         [self showAlertViewWithTitle:@"网络出错"];
     }];
    return YES;
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    if ([self.detailTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.detailTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.detailTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.detailTableView setSeparatorInset:UIEdgeInsetsZero];
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
#pragma mark - tableviewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [allDataDic allKeys].count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //拍好序，方便处理数据
    NSArray *keysAsc = [[allDataDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
//    UIView *view = [self.detailTableView footerViewForSection:section];
//    UIButton *button  = [view viewWithTag:100 + section];
   
    if (section == currentSelectedBtn.tag - 100 && currentSelectedBtn.selected == YES) {
        if (isOpen) {//这个是为了使点击返回按钮时修改isOpen的时候能起作用
            NSInteger row = [[allDataDic objectForKey:keysAsc[section]] count];
            if (row > 1) {
                isOpen = YES;
                return row;
            }else
            {
                isOpen = NO;
                return 1;
            }
        }else{
            return 1;
        }
    }
    return 1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keysAsc = [[allDataDic allKeys] sortedArrayUsingSelector:@selector(compare:)];

    NSString *key = keysAsc[indexPath.section];
    NSArray *dataArray = [allDataDic objectForKey:key];
    /*
     worryList:[],     	//心事list
     voiceList:[],		//享问list
     listenerList[],		//专家list
     articleList[]		//文章list
     */
    if ([key isEqualToString:@"worryList"]) {
        FKXSameMindModel *model = dataArray[indexPath.row];
        FKXWithIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXWithIconCell" forIndexPath:indexPath];
        cell.mindModel = model;
        return cell;
    }else if ([key isEqualToString:@"voiceList"]) {
        FKXSecondAskModel *model = dataArray[indexPath.row];
        FKXWithVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXWithVoiceCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else if ([key isEqualToString:@"listenerList"]) {
        FKXUserInfoModel *model = dataArray[indexPath.row];
        FKXWithIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXWithIconCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else if ([key isEqualToString:@"articleList"]) {
        FKXResonance_homepage_model *model = dataArray[indexPath.row];
        FKXWithArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXWithArticleCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 34;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 34)];
    footerV.backgroundColor = [UIColor clearColor];
    
    UIImageView *imV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, footerV.width, 25)];
    imV.image = [UIImage imageNamed:@"img_search_footer_view"];
    [footerV addSubview:imV];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(footerV.width - 87, 0, 80, 23);
    button.tag = 100 + section;
    if (button.tag == currentSelectedBtn.tag) {
        button.selected = currentSelectedBtn.selected;
    }
    [button setTitle:@"查看更多" forState:UIControlStateNormal];
    [button setTitle:@"收起更多" forState:UIControlStateSelected];
    [button setTitleColor:UIColorFromRGB(0x64bcfc) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickLookMore:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [footerV addSubview:button];
    return footerV;
}
- (void)clickLookMore:(UIButton *)button
{
    //这是用来控制点击返回按钮刷新tableview时，UI的转换
    button.selected = !button.selected;
    if (button.selected) {
        isOpen = YES;
    }else{
        isOpen = NO;
    }
    currentSelectedBtn = button;
    //不是点击返回按钮的时候就刷新，否则，和点击返回的刷新UI冲突
    [self.detailTableView reloadData];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *keysAsc = [[allDataDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *key = keysAsc[section];
    NSArray *dataArray = [allDataDic objectForKey:key];
    NSString *title = @"";
    if ([key isEqualToString:@"worryList"]) {
        title = [NSString stringWithFormat:@"心事(%ld条)", dataArray.count];
    }else if ([key isEqualToString:@"voiceList"]) {
        title = [NSString stringWithFormat:@"享问(%ld条)", dataArray.count];
    }else if ([key isEqualToString:@"listenerList"]) {
        title = [NSString stringWithFormat:@"专家(%ld条)", dataArray.count];
    }else if ([key isEqualToString:@"articleList"]) {
        title = [NSString stringWithFormat:@"文章(%ld条)", dataArray.count];
    }
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 34)];
    headerV.backgroundColor = [UIColor clearColor];
    
    UIImageView *imV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 9, headerV.width, 25)];
    imV.image = [UIImage imageNamed:@"img_search_header_view"];
    [headerV addSubview:imV];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(23, 11, 120, 20)];
    titleL.text = title;
    titleL.font = [UIFont boldSystemFontOfSize:15];
    titleL.textColor = UIColorFromRGB(0x333333);
    [headerV addSubview:titleL];
    
    UIView *line= [[UIView alloc] initWithFrame:CGRectMake(0, headerV.height - 1, self.view.width, 1)];
    line.backgroundColor = UIColorFromRGB(0xd2d2d2);
    [headerV addSubview:line];
    
    return headerV;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keysAsc = [[allDataDic allKeys] sortedArrayUsingSelector:@selector(compare:)];

    NSString *key = keysAsc[indexPath.section];
    NSArray *dataArray = [allDataDic objectForKey:key];
    if ([key isEqualToString:@"worryList"]) {
        FKXSameMindModel *model = dataArray[indexPath.row];
        FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
        vc.shareType = @"comment";
        vc.pageType = MyPageType_nothing;
        vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,model.worryId, (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
        vc.sameMindModel = model;
        [self.navigationController pushViewController:vc animated:YES];

    }else if ([key isEqualToString:@"voiceList"]) {
        FKXSecondAskModel *model = dataArray[indexPath.row];
        FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
        vc.isNeedTwoItem = YES;
        //这里都是已经被认可的，直接传1
        vc.pageType = MyPageType_nothing;
        vc.shareType = @"second_ask";
        NSString *paraStr = @"worryId";//默认传worryId
        NSNumber *paraId;
        if (model.worryId) {
            paraId = model.worryId;
        }
        if (model.topicId) {
            paraStr = @"topicId";
            paraId = model.topicId;
        }
        if (model.lqId) {
            paraStr = @"lqId";
            paraId = model.lqId;
        }
        vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=1&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, model.voiceId, [FKXUserManager shareInstance].currentUserToken];
        vc.secondModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([key isEqualToString:@"listenerList"]) {
        FKXUserInfoModel *model = dataArray[indexPath.row];
        FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
        vc.userId = model.uid;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([key isEqualToString:@"articleList"]) {
        FKXResonance_homepage_model *model = dataArray[indexPath.row];
        FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
        vc.shareType = @"mind";
        vc.urlString = [NSString stringWithFormat:@"%@?shareId=%@&uid=%ld&token=%@",model.url, model.hotId, (long)[FKXUserManager shareInstance].currentUserId,[FKXUserManager shareInstance].currentUserToken];
        vc.pageType = MyPageType_hot;
        vc.resonanceModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
