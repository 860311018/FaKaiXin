//
//  FKXMyDynamicVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyDynamicVC.h"
#import "FKXMyDynamicNoTextCell.h"
#import "FKXMyDynamicWithTextCell.h"
#import "FKXMyDynamicWithVoiceCell.h"
#import "ChatViewController.h"
#import "FKXCommitHtmlViewController.h"
#import "MyDynamicModel.h"
#import "NSString+HeightCalculate.h"
#import "FKXPayView.h"

#define kFontOfContent 13
#define kMarginXTotal 62    //cell的边距加上textView的内边距 52 + 12 + 10 + 10
#define kLineSpacing 8  //段落的行间距
#define kTextVTopInset 15  //textV 的内容上下inset

@interface FKXMyDynamicVC ()<BeeCloudDelegate>//<FKXMyDynamicWithTextCellDelegate,FKXMyDynamicNoTextCellDelegate,FKXMyDynamicWithVoiceCellDelegate>
{
    NSInteger start;
    NSInteger size;
    CGFloat oneLineH;   //一行的高度
    FKXUserInfoModel *myUserInfoModel;
    NSDictionary *userD;
    NSDictionary *userEvaluate;//用户评价
    
    UIView *transViewPay;   //支付的透明图
    FKXPayView *payView;    //支付界面
    NSMutableDictionary *_payParameterDic;//支付参数
}
@property (weak, nonatomic) IBOutlet UILabel *labAskPrice;//提问费
@property (weak, nonatomic) IBOutlet UILabel *labConsultPrice;//咨询费
@property (strong, nonatomic) UITextView *tfProfession;
@property (strong, nonatomic) UITextView *tfIntroduce;
@property (strong, nonatomic) UITextView *tfGoodAt;
@property   (nonatomic,strong)NSMutableArray *contentArr;
@property (weak, nonatomic) IBOutlet UILabel *labFXKCertifi;
@property (weak, nonatomic) IBOutlet UIView *viewGuarantee;
@property (strong, nonatomic) UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UIView *viewAsk;
@property (weak, nonatomic) IBOutlet UIView *viewConsult;
@property (weak, nonatomic) IBOutlet UIView *viewEvaluate;
@property (weak, nonatomic) IBOutlet UIButton *myUserIcon;
@property (strong, nonatomic) UILabel *myUserName;
@property (strong, nonatomic) UIView *myHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePrivateMail;
@property (weak, nonatomic) IBOutlet UILabel *labHelpNum;//治愈人数
@property (weak, nonatomic) IBOutlet UILabel *labGoodEvaluate;//好评人数
@property (weak, nonatomic) IBOutlet UIImageView *userOfEvaIcon;
@property (weak, nonatomic) IBOutlet UILabel *userOfEvaName;
@property (weak, nonatomic) IBOutlet UILabel *userOfEvaContent;
@end

@implementation FKXMyDynamicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //设置支付代理,记得要在支付页面写上这句话，否则支付成功后不走代理方法
    [BeeCloud setBeeCloudDelegate:self];
    
    size = kRequestSize;
    self.navTitle = @"个人主页";
    
    //需要动态重写UI
    _myUserName = [[UILabel alloc] initWithFrame:CGRectMake(0, 78, 0, 25)];
    _myUserName.layer.cornerRadius = 10;
    _myUserName.clipsToBounds = YES;
    _myUserName.textAlignment = NSTextAlignmentCenter;
    _myUserName.textColor = [UIColor whiteColor];
    _myUserName.font = [UIFont systemFontOfSize:15];
    _myUserName.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    [self.tableView.tableHeaderView addSubview:_myUserName];
    
   
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = kLineSpacing;
    oneLineH = [@"哈" heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //ui设置
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    [self headerRefreshEvent];
    
    [_viewAsk addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginToAsk)]];
    [_viewConsult addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bookConsultService)]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //更新姓名的frame
//    [_myUserName sizeToFit];
//    CGRect nameF = _myUserName.frame;
//    nameF.size.width += 20;
//    nameF.size.height += 10;
//    _myUserName.frame = nameF;

    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark -创建子视图
- (void)beginCreateAboutInfo
{
    /*
     createTime = "2016-09-02 19:17:27";
     degree = "\U6ee1\U610f";
     headUrl = "http://7xrrm3.com2.z0.glb.qiniucdn.com/FgPRxrtbljEsKVwa8BbZNGHY6czK";
     nickName = "\U624b\U673a\U5eb7\U6865http";
     score = 0;
     text = nonfood;
     uid = 212;
     */
    if (userEvaluate) {
        [_userOfEvaIcon sd_setImageWithURL:[NSURL URLWithString:userEvaluate[@"headUrl"]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        _userOfEvaName.text = userEvaluate[@"nickName"];
        _userOfEvaContent.text = userEvaluate[@"text"];
    }
    NSString *strPro = [NSString stringWithFormat:@"专业资格：\n%@",userD[@"profession"]];
    NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    NSAttributedString *attPro = [[NSAttributedString alloc] initWithString:strPro attributes:@{NSParagraphStyleAttributeName : style}];
   
    NSString *strIntro = [NSString stringWithFormat:@"个人简介：\n%@",userD[@"profile"]];
    NSAttributedString *attIntro = [[NSAttributedString alloc] initWithString:strIntro attributes:@{NSParagraphStyleAttributeName : style}];

    NSArray *goodArr = userD[@"goodAt"];
    NSMutableString *goodS = [NSMutableString stringWithCapacity:1];
    for (NSNumber *num in goodArr) {
        switch ([num integerValue]) {
            case 0:
                [goodS appendFormat:@"婚恋出轨；"];
                break;
            case 1:
                [goodS appendFormat:@"失恋阴影；"];
                break;
            case 2:
                [goodS appendFormat:@"夫妻相处；"];
                break;
            case 3:
                [goodS appendFormat:@"婆媳关系；"];
                break;
            default:
                break;
        }
    }
    NSString *strGoodat = @"擅长领域：";
    if (goodS.length >= 2) {
        strGoodat = [NSString stringWithFormat:@"擅长领域：\n%@",[goodS substringToIndex:goodS.length - 1]];
    }
    NSAttributedString *attGoodat = [[NSAttributedString alloc] initWithString:strGoodat attributes:@{NSParagraphStyleAttributeName : style}];
    
    _viewInfo = [[UIView alloc] initWithFrame:CGRectMake(13, 156, kScreenWidth - 156, 0)];
    _viewInfo.backgroundColor = [UIColor whiteColor];
    _viewInfo.layer.cornerRadius = 10;
    _viewInfo.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
    _viewInfo.layer.borderWidth = 1.0;
    [self.tableView.tableHeaderView addSubview:_viewInfo];
    
    _tfProfession = [[UITextView alloc] initWithFrame:CGRectZero];
    _tfProfession.editable = NO;
    _tfProfession.layer.cornerRadius = 5;
    _tfProfession.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
    _tfProfession.layer.borderWidth = 1.0;
    _tfProfession.textContainerInset = UIEdgeInsetsMake(6, 9, 8, 9);
    _tfProfession.textColor = UIColorFromRGB(0x676767);
    _tfProfession.font = [UIFont boldSystemFontOfSize:13];
    [_viewInfo addSubview:_tfProfession];
    [_tfProfession setAttributedText:attPro];
    
    _tfIntroduce = [[UITextView alloc] initWithFrame:CGRectZero];
    _tfIntroduce.editable = NO;
    _tfIntroduce.layer.cornerRadius = 5;
    _tfIntroduce.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
    _tfIntroduce.layer.borderWidth = 1.0;
    _tfIntroduce.textContainerInset = UIEdgeInsetsMake(6, 9, 8, 9);
    _tfIntroduce.textColor = UIColorFromRGB(0x676767);
    _tfIntroduce.font = [UIFont boldSystemFontOfSize:13];
    [_viewInfo addSubview:_tfIntroduce];
    [_tfIntroduce setAttributedText:attIntro];
    
    _tfGoodAt = [[UITextView alloc] initWithFrame:CGRectZero];
    _tfGoodAt.editable = NO;
    _tfGoodAt.layer.cornerRadius = 5;
    _tfGoodAt.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
    _tfGoodAt.layer.borderWidth = 1.0;
    _tfGoodAt.textContainerInset = UIEdgeInsetsMake(6, 9, 8, 9);
    _tfGoodAt.textColor = UIColorFromRGB(0x676767);
    _tfGoodAt.font = [UIFont boldSystemFontOfSize:13];
    [_viewInfo addSubview:_tfGoodAt];
    [_tfGoodAt setAttributedText:attGoodat];
    
    CGFloat width = _viewInfo.width - 20;
    UIFont * font = [UIFont boldSystemFontOfSize:13];
    CGFloat heightPro = [strPro heightForWidth:width usingFont:font style:style];
    CGFloat heightIntro = [strIntro heightForWidth:width usingFont:font style:style];
    CGFloat heightGoodat = [strGoodat heightForWidth:width usingFont:font style:style];
    _tfProfession.frame = CGRectMake(11, 16, _viewInfo.width - 20, heightPro + 14);
    _tfIntroduce.frame = CGRectMake(_tfProfession.left, _tfProfession.bottom + 10, _tfProfession.width, heightIntro + 14);
    _tfGoodAt.frame = CGRectMake(_tfProfession.left, _tfIntroduce.bottom + 10, _tfProfession.width, heightGoodat + 14);
  
    CGRect infoViewF = _viewInfo.frame;
    infoViewF.size.height = _tfGoodAt.bottom + 16;
    _viewInfo.frame = infoViewF;
    
    //开始重置UI
    //如果这个人role非0
    if ([myUserInfoModel.role integerValue]) {
        _imagePrivateMail.hidden = NO;
        _imagePrivateMail.image = [UIImage imageNamed:@"img_fakaixin_certification"];
        _labFXKCertifi.hidden = NO;
        _viewGuarantee.hidden = NO;
        _viewAsk.hidden = NO;
        _viewConsult.hidden = NO;
        _viewInfo.hidden = NO;
        _viewEvaluate.hidden = NO;
        _myHeaderView = self.tableView.tableHeaderView;
        if (_viewInfo.bottom < 359) {//当viewInfo的高度小于“图文咨询的底部”的话，
            if (userEvaluate) {//如果有评价
                _viewEvaluate.hidden = NO;
                _myHeaderView.height = 359 + 204;
            }else{
                _viewEvaluate.hidden = YES;
                _myHeaderView.height = 359 + 49;
            }
        }else{
            if (userEvaluate) {//如果有评价
                _viewEvaluate.hidden = NO;
                _myHeaderView.height = _viewInfo.bottom + 204;
            }else{
                _viewEvaluate.hidden = YES;
                _myHeaderView.height = _viewInfo.bottom + 49;
            }
        }
        [self.tableView setTableHeaderView:_myHeaderView];
    }
    else//如果这个人role是0
    {
        _labFXKCertifi.hidden = YES;
        _viewGuarantee.hidden = YES;
        _viewAsk.hidden = YES;
        _viewConsult.hidden = YES;
        _viewInfo.hidden = YES;
        _viewEvaluate.hidden = YES;
        
        if ([[FKXUserManager getUserInfoModel].role integerValue] == 0) {//双方都是倾诉者才能私信
            _imagePrivateMail.hidden = NO;
            _imagePrivateMail.image = [UIImage imageNamed:@"img_private_letter"];
        }else{
            _imagePrivateMail.hidden = YES;
        }
        _myHeaderView = self.tableView.tableHeaderView;
        _myHeaderView.height = 149;
        [self.tableView setTableHeaderView:_myHeaderView];
    }
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
    if (!_userId) {
        return;
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@(start) forKey:@"start"];
    [paramDic setValue:@(size) forKey:@"size"];
    [paramDic setValue:_userId forKey:@"userId"];

    [MyDynamicModel sendGetOrPostRequest:@"user/info" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
    {
        self.tableView.header.state = MJRefreshHeaderStateIdle;
        self.tableView.footer.state = MJRefreshFooterStateIdle;
        
        if ([data[@"code"] integerValue] == 0)
        {
            if (start == 0)
            {
                [_contentArr removeAllObjects];
            }
            userD = data[@"data"][@"users"];//当前这个人的信息
            userEvaluate = [data[@"data"][@"commentList"] firstObject];//第一个评价
            [_myUserIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", userD[@"head"],cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            _myUserName.text = userD[@"nickname"];
            _labAskPrice.text = [NSString stringWithFormat:@"￥%ld/次", [userD[@"price"] integerValue]/100];
            _labConsultPrice.text = [NSString stringWithFormat:@"￥%ld/小时", [userD[@"consultingFee"] integerValue]/100];
//            userD[@"cureCount"]
//            userD[@"praiseRate"]
            NSString *helpStr = [NSString stringWithFormat:@"治愈了%@人", userD[@"cureCount"]];
            NSMutableAttributedString *helpAtt = [[NSMutableAttributedString alloc] initWithString:helpStr];
            [helpAtt addAttribute:NSForegroundColorAttributeName value:kColorMainBlue range:[helpStr rangeOfString:[NSString stringWithFormat:@"%@", userD[@"cureCount"]]]];
            [_labHelpNum setAttributedText:helpAtt];
            
            NSString *evalStr = [NSString stringWithFormat:@"%@%@好评", userD[@"praiseRate"],@"%"];
            NSMutableAttributedString *evalAtt = [[NSMutableAttributedString alloc] initWithString:evalStr];
            [evalAtt addAttribute:NSForegroundColorAttributeName value:kColorMainBlue range:[evalStr rangeOfString:[NSString stringWithFormat:@"%@%@", userD[@"praiseRate"],@"%"]]];
            [_labGoodEvaluate setAttributedText:evalAtt];
            
            CGRect rect = [_myUserName.text boundingRectWithSize:CGSizeMake(100, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
            CGRect nameR = _myUserName.frame;
            nameR.size.width = rect.size.width + 20;
            nameR.origin.x = (self.view.width - nameR.size.width)/2;
            _myUserName.frame = nameR;
            
            myUserInfoModel = [[FKXUserInfoModel alloc] init];
            myUserInfoModel.uid = _userId;
            myUserInfoModel.name = userD[@"nickname"];
            myUserInfoModel.head = userD[@"head"];
            myUserInfoModel.role = userD[@"role"];
            myUserInfoModel.price = userD[@"price"];
            myUserInfoModel.consultingFee = userD[@"consultingFee"];
            
            //开始创建专业资格、个人简介、擅长领域
            [self beginCreateAboutInfo];
            NSError *err = nil;
            for (NSDictionary *dic in data[@"data"][@"list"])
            {
                MyDynamicModel * officalSources =  [[MyDynamicModel alloc] initWithDictionary:dic error:&err];
                officalSources.head = userD[@"head"];
                officalSources.nickname = userD[@"nickname"];
                [_contentArr addObject:officalSources];
            }
            if ([data[@"data"][@"list"] count] < kRequestSize) {
                self.tableView.footer.hidden = YES;
            }else
            {
                self.tableView.footer.hidden = NO;
            }
            [self.tableView reloadData];
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
    }];
    
}

#pragma mark - 点击事件
- (IBAction)clickMoreEvaluate:(id)sender {
    [self beginToConsult];
}
- (IBAction)beginPrivateMail:(UIButton *)sender {
    if ([myUserInfoModel.role integerValue]) {
        return;
    }
    if (!_userId) {
        return;
    }
    
    //保存接收方的信息
    EMMessage *receiverMessage = [[EMMessage alloc] initWithReceiver:[_userId stringValue] bodies:nil];
    receiverMessage.from = [_userId stringValue];
    receiverMessage.to = [NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId];
    receiverMessage.ext = @{
                            @"head" : myUserInfoModel.head,
                            @"name": myUserInfoModel.name,
                            };
    [self insertDataToTableWith:receiverMessage managedObjectContext:ApplicationDelegate.managedObjectContext];
    
    //    //进入聊天
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:[_userId stringValue]  conversationType:eConversationTypeChat];
    chatController.title = myUserInfoModel.name;
    [self.navigationController pushViewController:chatController animated:YES];
}
//提问
- (void)beginToAsk {
    if ([_userId integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不能提问自己"];
        return;
    }
    if (!_userId) {
        return;
    }
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.pageType = MyPageType_people;
    if ([myUserInfoModel.role integerValue] == 1) {
        vc.shareType = @"user_center_jinpai";
    }else{
        vc.shareType = @"user_center_xinli";
    }
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_home.html?uid=%@&loginUserId=%ld&token=%@",kServiceBaseURL, _userId, [FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    vc.userModel = myUserInfoModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
//咨询
- (void)beginToConsult {
    if ([_userId integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不能咨询自己"];
        return;
    }
    if (!_userId) {
        return;
    }
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"user_center_yu_yue";//预约
    vc.pageType = MyPageType_consult;
    vc.urlString = [NSString stringWithFormat:@"%@front/user_center.html?uid=%@&token=%@",kServiceBaseURL, _userId, [FKXUserManager shareInstance].currentUserToken];
    vc.userModel = myUserInfoModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIScrollViewDelegate
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////        NSLog(@"yyyy=%f",scrollView.contentOffset.y);
//    if ([myUserInfoModel.role integerValue]) {
//        if ([scrollView isMemberOfClass:[UITableView class]])
//        {
//            if (scrollView.contentOffset.y >= 270)
//            {
//                UIButton * myRightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40,22)];
//                [myRightBarButton setTitle:@"咨询" forState:UIControlStateNormal];
//                myRightBarButton.titleLabel.font = [UIFont systemFontOfSize:12];
//                [myRightBarButton setTitleColor:kColorMainBlue forState:UIControlStateNormal];
//                myRightBarButton.layer.borderColor = kColorMainBlue.CGColor;
//                myRightBarButton.layer.borderWidth = 1;
//                myRightBarButton.layer.cornerRadius = 3;
//                [myRightBarButton addTarget:self action:@selector(bookConsultService) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIButton * myRightBarButton2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40,22)];
//                [myRightBarButton2 setTitle:@"提问" forState:UIControlStateNormal];
//                myRightBarButton2.titleLabel.font = [UIFont systemFontOfSize:12];
//                [myRightBarButton2 setTitleColor:kColorMainRed forState:UIControlStateNormal];
//                myRightBarButton2.layer.borderColor = kColorMainRed.CGColor;
//                myRightBarButton2.layer.borderWidth = 1;
//                myRightBarButton2.layer.cornerRadius = 3;
//                [myRightBarButton2 addTarget:self action:@selector(beginToAsk) forControlEvents:UIControlEventTouchUpInside];
//                UIBarButtonItem *spacItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//                spacItem.width = 15;
//                self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:myRightBarButton2],spacItem, [[UIBarButtonItem alloc] initWithCustomView:myRightBarButton]];
//            }else
//            {
//                self.navigationItem.rightBarButtonItems = nil;
//            }
//        }
//    }
//}
#pragma mark - seperator insets 设置
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
//#pragma mark - cell自定义代理
//- (void)goToDynamicVC:(MyDynamicModel*)cellModel sender:(UIButton*)sender
//{
//    FKXMyDynamicVC *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil]instantiateViewControllerWithIdentifier:@"FKXMyDynamicVC"];
//    vc.userId = _userId;
//    [vc setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:vc animated:YES];
//}
#pragma mark - tableView代理
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDynamicModel *model = [self.contentArr objectAtIndex:indexPath.row];
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = kLineSpacing;
    NSString *theString = [NSString stringWithFormat:@"%@：%@",model.toNickname, model.replyText];

    CGFloat height = [theString heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    CGFloat heightA = oneLineH*3 + kLineSpacing*2;
    switch ([model.type integerValue]) {
        case 1://评论
        {
            if (height > heightA)//文字高度大于3行
            {
                CGFloat heightB = oneLineH*3 + kLineSpacing*2 + 111 + kTextVTopInset*2;
                return heightB;
            }else{
                CGFloat heightC = height + 111 + kTextVTopInset*2;
                return heightC;
            }
        }
            break;
        case 3:
        {
            return 170;
        }
            break;
        case 2:
        case 4:
        {
            if (height > heightA)//文字高度大于3行
            {
                CGFloat heightB = oneLineH*3 + kLineSpacing*2 + 78 + kTextVTopInset*2;
                return heightB;
            }else{
                CGFloat heightC = height + 78 + kTextVTopInset*2;
                return heightC;
            }
        }
            break;
        default:
            return 0;
            break;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDynamicModel *model = [self.contentArr objectAtIndex:indexPath.row];
    // //  1评论     2抱    3 偷听    4 赞  5语音回复 6收到回信
    switch ([model.type integerValue]) {
        case 1:
        {
            FKXMyDynamicWithTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyDynamicWithTextCell" forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }
            break;
        case 3:
        {
            FKXMyDynamicWithVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyDynamicWithVoiceCell" forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }
            break;
        case 2:
        case 4:
        {
            FKXMyDynamicNoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyDynamicNoTextCell" forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }
            break;
            
        default:
            return nil;
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDynamicModel *dyModel = [self.contentArr objectAtIndex:indexPath.row];
    switch ([dyModel.type integerValue]) {
        case 1:
        case 2:
        case 4:
        {
            FKXSameMindModel *model = [[FKXSameMindModel alloc] init];
            model.worryId = dyModel.worryId;
            model.text = dyModel.replyText;
            model.head = dyModel.head;
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            vc.shareType = @"comment";
            vc.pageType = MyPageType_nothing;
            vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,model.worryId, (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
            vc.sameMindModel = model;
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        case 3:
        {
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            vc.isNeedTwoItem = YES;
            FKXSecondAskModel *model = [[FKXSecondAskModel alloc] init];
            model.worryId = dyModel.worryId;
            model.text = dyModel.replyText;
            model.userHead = dyModel.head;
            model.userNickName = dyModel.nickname;
            model.listenerHead = dyModel.toHead;
            model.voiceId = dyModel.voiceId;
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
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark - 支付流程  --start
- (void)bookConsultService
{
    if ([FKXUserManager needShowLoginVC])
    {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
    }else
    {
//        if (![WXApi isWXAppInstalled]) {
//            [self showHint:@"当前不在线"];
//            return;
//        }else
            if (_userId == [FKXUserManager getUserInfoModel].uid)
            {
                [self showHint:@"不能咨询自己"];
                return;
            }
        
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setValue:_userId forKey:@"uid"];
        [self showHudInView:self.view hint:@"正在预约..."];
        [AFRequest sendGetOrPostRequest:@"talk/pay" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
         {
             [self hideHud];
             if ([data[@"code"] integerValue] == 0)
             {
                 if (!_payParameterDic) {
                     _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
                 }
                 [_payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
                 CGFloat money = [data[@"data"][@"money"] floatValue];
                 [_payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
                 NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
                 [_payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
                 //创建购买界面
                 [self setUpTransViewPay];
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
}
- (void)setUpTransViewPay
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transViewPay)
    {
        //透明背景
        transViewPay = [[UIView alloc] initWithFrame:screenBounds];
        transViewPay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewPay.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewPay];
        
        payView = [[[NSBundle mainBundle] loadNibNamed:@"FKXPayView" owner:nil options:nil] firstObject];
        [payView.btnClose addTarget:self action:@selector(hiddentransViewPay) forControlEvents:UIControlEventTouchUpInside];
        [payView.myPayBtn addTarget:self action:@selector(confirmToPay) forControlEvents:UIControlEventTouchUpInside];
        
        if (_payParameterDic[@"isAmple"]) {
            if (![_payParameterDic[@"isAmple"] integerValue]) {
                payView.btnRemain.enabled = NO;
                [payView.btnRemain setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
        
        [transViewPay addSubview:payView];
        payView.center = transViewPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewPay.alpha = 1.0;
        }];
        
        payView.labTitle.text = @"咨询";
        payView.labPrice.text = [NSString stringWithFormat:@"%.2f", [_payParameterDic[@"money"] doubleValue]/100];
    }
}
- (void)hiddentransViewPay
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewPay.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewPay removeFromSuperview];
        transViewPay = nil;
    }];
}
- (void)confirmToPay
{
    PayChannel channel = PayChannelWxApp;
    switch (payView.myPayChannel) {
        case MyPayChannel_weChat:
            channel = PayChannelWxApp;
            break;
        case MyPayChannel_Ali:
            channel = PayChannelAliApp;
            break;
        case MyPayChannel_remain:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
            NSString *methodName = @"sys/balancePay";
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     [self showHint:@"支付成功，等待对方确认"];
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
            [self hiddentransViewPay];
        }
            break;
        default:
            break;
    }
    if (payView.myPayChannel == MyPayChannel_remain) {
        return;
    }
    //除余额以外的支付
    [self doPay:channel billNo:_payParameterDic[@"billNo"] money:_payParameterDic[@"money"]];
    
    [self hiddentransViewPay];
}
//微信、支付宝
- (void)doPay:(PayChannel)channel billNo:(NSString *)billNo money:(NSNumber *)money {
    [self showHudInView:self.view hint:@"正在支付..."];
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"伐开心订单";
    payReq.totalFee = [NSString stringWithFormat:@"%ld",[money integerValue]];
    payReq.billNo = billNo;
    if (channel == PayChannelAliApp) {
        payReq.scheme = @"Zhifubaozidingyi001test";
    }
    payReq.billTimeOut = 360;
    payReq.viewController = self;
    payReq.optional = nil;
    [BeeCloud sendBCReq:payReq];
}
#pragma mark - 支付流程  --end
#pragma mark - BeeCloudDelegate
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    [self hideHud];
    switch (resp.type) {
        case BCObjsTypePayResp:
        {
            // 支付请求响应
            BCPayResp *tempResp = (BCPayResp *)resp;
            if (tempResp.resultCode == 0)
            {
                [self showHint:@"支付成功，等待对方确认"];
            }
            else
            {
                //支付取消或者支付失败,,或者取消支付都要再次提示用户购买
                [self showAlertViewWithTitle:[NSString stringWithFormat:@"%@", tempResp.errDetail]];
            }
        }
            break;
        default:
            NSLog(@"%@", @"不是支付响应的回调");
            break;
    }
}
@end
