//
//  FKXProfessionInfoVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXProfessionInfoVC.h"
#import "ChatViewController.h"
#import "FKXCommitHtmlViewController.h"

#import "FKXTProfessionTitleCell.h"
#import "FKXZixunHelpCell.h"
#import "FKXAboutHimCell.h"
#import "FKXJianjieCell.h"
#import "FKXHisCommentCell.h"

#import "FKXdynamicsCell.h"
#import "FKXdynamicsTextCell.h"
#import "FKXdynamicsVoiceCell.h"

#import "MyDynamicModel.h"
#import "FKXPayView.h"

@interface FKXProfessionInfoVC ()<UITableViewDelegate,UITableViewDataSource,BeeCloudDelegate>
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
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIView *bottomView;

@property (nonatomic,strong) NSMutableArray *dongTaiArr ;


@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *userhead;
@property (nonatomic,copy) NSString *userProfession;
@property (nonatomic,copy) NSString *userDesc;

@property (nonatomic,copy) NSString *phonePrice;
@property (nonatomic,copy) NSString *chatPrice;
@property (nonatomic,copy) NSString *tuwenPrice;
@property (nonatomic,copy) NSString *phonePingFen;
@property (nonatomic,copy) NSString *chatPingFen;
@property (nonatomic,copy) NSString *tuwenPingFen;

@property (nonatomic,copy) NSString *jianjieID;
@property (nonatomic,copy) NSString *jianjie;

@property (nonatomic,copy) NSString *userOfEvaIcon;
@property (nonatomic,copy) NSString *userOfEvaName;
@property (nonatomic,copy) NSString *userOfEvaContent;

@end

@implementation FKXProfessionInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置支付代理,记得要在支付页面写上这句话，否则支付成功后不走代理方法
    [BeeCloud setBeeCloudDelegate:self];
    
    size = kRequestSize;
    start = 0;

    self.navTitle = @"个人主页";
    
    [self.view addSubview:self.bottomView];

    
    [self registerCell];//添加tableView;
   
    [self loadData];

}

- (void)loadData {
    if (!_userId) {
        return;
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@(start) forKey:@"start"];
    [paramDic setValue:@(size) forKey:@"size"];
    [paramDic setValue:_userId forKey:@"userId"];
    
    [MyDynamicModel sendGetOrPostRequest:@"user/info" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        self.tableView.header.state = MJRefreshHeaderStateIdle;
        self.tableView.footer.state = MJRefreshFooterStateIdle;
        if ([data[@"code"] integerValue] == 0)
        {
            if (start == 0)
            {
                [self.dongTaiArr removeAllObjects];
            }
            
            userD = data[@"data"][@"users"];//当前这个人的信息
            userEvaluate = [data[@"data"][@"commentList"] firstObject];//第一个评价
            myUserInfoModel = [[FKXUserInfoModel alloc] init];
            myUserInfoModel.uid = _userId;
            myUserInfoModel.name = userD[@"nickname"];
            myUserInfoModel.head = userD[@"head"];
            myUserInfoModel.role = userD[@"role"];
            myUserInfoModel.price = userD[@"price"];
            myUserInfoModel.consultingFee = userD[@"consultingFee"];
//            myUserInfoModel.phonePrice = userD[@"consultingFee"];
            myUserInfoModel.clientNum = userD[@"clientNum"];
            self.role =[myUserInfoModel.role integerValue];

#pragma mark - 个人title
            self.userhead = [NSString stringWithFormat:@"%@%@", userD[@"head"],cropImageW];
            self.userName = userD[@"nickname"];
            self.userProfession = [NSString stringWithFormat:@"  %@  ",userD[@"profession"]];
            self.userDesc = [NSString stringWithFormat:@"治愈了%@人，好评%@%@",userD[@"cureCount"],userD[@"praiseRate"],@"%"];
            
#pragma mark - 服务
            self.phonePrice = [NSString stringWithFormat:@"￥%ld/小时", [userD[@"consultingFee"] integerValue]/100];
            self.phonePingFen = [NSString stringWithFormat:@"评分："];
            
            self.chatPrice = [NSString stringWithFormat:@"￥%ld/次", [userD[@"price"] integerValue]/100];
            self.chatPingFen = [NSString stringWithFormat:@"评分："];
            
            self.tuwenPrice = [NSString stringWithFormat:@"￥%ld/小时", [userD[@"consultingFee"] integerValue]/100];
            self.tuwenPingFen = [NSString stringWithFormat:@"评分："];
            
#pragma mark - 标签

#pragma mark - 简介
//            self.jianjieID = [NSString stringWithFormat:@"ID: %@",userD[@"nickname"]];
            self.jianjie = userD[@"profile"];
#pragma mark - 评价
            self.userOfEvaName = userEvaluate[@"nickName"];
            self.userOfEvaIcon = userEvaluate[@"headUrl"];
            self.userOfEvaContent = userEvaluate[@"text"];
#pragma mark - 动态
            NSError *err = nil;
            for (NSDictionary *dic in data[@"data"][@"list"])
            {
                MyDynamicModel * officalSources =  [[MyDynamicModel alloc] initWithDictionary:dic error:&err];
                officalSources.head = userD[@"head"];
                officalSources.nickname = userD[@"nickname"];
                [self.dongTaiArr addObject:officalSources];
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
        
    }];}

#pragma mark - 查看更多标签

#pragma mark - 折叠个人简介
- (void)openJianjie {
    static BOOL isOpen = NO;
    isOpen = !isOpen;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    FKXJianjieCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (isOpen) {
        cell.jianjie.numberOfLines = 0;
        cell.zhankaiImgV.image = [UIImage imageNamed:@"btn_arrows_up"];
    }else {
        cell.jianjie.numberOfLines = 1;
        cell.zhankaiImgV.image = [UIImage imageNamed:@"btn_arrows_down"];
    }
    [self.tableView reloadData];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];

//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 折叠评论标签
- (void)openComment {
    static BOOL isOpen = NO;
    isOpen = !isOpen;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    FKXHisCommentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (isOpen) {
        cell.commentL.numberOfLines = 0;
        cell.openImgV.image = [UIImage imageNamed:@"btn_arrows_up"];
    }else {
        cell.commentL.numberOfLines = 4;
        cell.openImgV.image = [UIImage imageNamed:@"btn_arrows_down"];
    }
    [self.tableView reloadData];

}

#pragma mark - 查看更多评论
- (void)moreCommentBtn:(UIButton *)btn {
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

#pragma mark - 点击头像
- (void)tapHead {
    
    if ([myUserInfoModel.role integerValue]) {
        return;
    }
    if (!_userId) {
        return;
    }
    //保存接收方的信息
    EMMessage *receiverMessage = [[EMMessage alloc] initWithReceiver:[_userId stringValue] bodies:nil];
    receiverMessage.to = [_userId stringValue];
    receiverMessage.from = [NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId];
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

#pragma mark - 关注
- (void)guanzhu {
    
}

#pragma mark - 预约
- (void)yuyue {
    [self bookConsultService];
}

#pragma mark - 选择咨询服务
- (void)selectTelHelp {
    
}

- (void)selectAskToMe {
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

- (void)selectTuwenHelp {
    [self bookConsultService];
}

#pragma mark - 点击动态
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        MyDynamicModel *dyModel = [self.dongTaiArr objectAtIndex:indexPath.row];
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
}


#pragma mark - tableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 32; //sectionHeaderHeight
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.role == 0) {
        if (section == 0) {
            return 1;
        }else if (section == 1) {
            return 0;
        }
        else if (section == 2) {
            return 0;
        }
        else if (section == 3) {
            return 0;//评价的数量
        }
        return self.dongTaiArr.count;//动态的数量
    }else {
        if (section == 0) {
            return 1;
        }else if (section == 1) {
            return 3;
        }
        else if (section == 2) {
            return 2;
        }
        else if (section == 3) {
            ////如果有评价
            if (userEvaluate) {
                return 1;//评价的数量
  
            }else {
                return 0;
            }
        }
        return self.dongTaiArr.count;//动态的数量
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   
    if (self.role == 0) {
        return 0;
    }else {
        if (section == 1 || section == 2 || section == 4) {
            return 32;
        }
        return 0;
    }
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 32)];
    view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, 100, 32)];
    label.textColor = [UIColor colorWithRed:79/255.0 green:183/255.0 blue:249/255.0 alpha:1];
    label.font = [UIFont systemFontOfSize:16];
    
    if (section == 1) {
        label.text = @"提供服务";
        [view addSubview:label];
  
    }else if (section == 2) {
        label.text = @"关于他";
        [view addSubview:label];

    }
    else if (section == 4) {
        
        UIView *viewBack = [[UIView alloc]initWithFrame:CGRectMake(26, 0, kScreenWidth-52, 32)];
        viewBack.backgroundColor = [UIColor whiteColor];
        
        UIView *lineV1 = [[UIView alloc]initWithFrame:CGRectMake(25, 0, 1, 32)];
        lineV1.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
        UIView *lineV2 = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth-26, 0, 1, 32)];
        lineV2.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        
        UIView *lineH1 = [[UIView alloc]initWithFrame:CGRectMake(26+42, 0, kScreenWidth-(68*2), 1)];
        lineH1.backgroundColor = [UIColor colorWithRed:0/255.0 green:147/255.0 blue:247/255.0 alpha:1];
        
        UIView *lineH2 = [[UIView alloc]initWithFrame:CGRectMake(26, 31, kScreenWidth-52, 1)];
        lineH2.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        
        UILabel *dongTai = [[UILabel alloc]initWithFrame:CGRectMake(26, 1, kScreenWidth-52, 30)];
        dongTai.text = @"动态";
        dongTai.textAlignment = NSTextAlignmentCenter;
        dongTai.font = [UIFont systemFontOfSize:14];
        dongTai.textColor = [UIColor colorWithRed:85/255.0 green:185/255.0 blue:250/255.0 alpha:1];
        
        [view addSubview:viewBack];
        [view addSubview:lineH1];
        [view addSubview:dongTai];
        [view addSubview:lineV1];
        [view addSubview:lineV2];
        [view addSubview:lineH2];

    }
    
    return view;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        FKXTProfessionTitleCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXTProfessionTitleCell" forIndexPath:indexPath];
        
        cell.nameL.text = self.userName;
        cell.profession.text = self.userProfession;
        [cell.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.userhead,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        [cell.headImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHead)]];
        
        if (self.userDesc) {
            NSMutableAttributedString *helpAtt = [[NSMutableAttributedString alloc] initWithString:self.userDesc];
            [helpAtt addAttribute:NSForegroundColorAttributeName value:kColorMainRed range:[self.userDesc rangeOfString:[NSString stringWithFormat:@"%@", userD[@"cureCount"]]]];
            [helpAtt addAttribute:NSForegroundColorAttributeName value:kColorMainRed range:[self.userDesc rangeOfString:[NSString stringWithFormat:@"%@%@", userD[@"praiseRate"],@"%"]]];
            
            [cell.zhiyuL setAttributedText:helpAtt];
 
        }
        
        return cell;
        
    }
    else if (indexPath.section == 1){
        FKXZixunHelpCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXZixunHelpCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            cell.phoneIcon.hidden = NO;
            cell.helpName.text = @"电话咨询";
            cell.priceL.text = self.phonePrice;
            cell.pingFenL.text = self.phonePingFen;
            [cell.helpBackV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTelHelp)]];
            
            
        }else if (indexPath.row == 1) {
            cell.phoneIcon.hidden = YES;
            cell.helpName.text = @"向我提问";
            cell.priceL.text = self.chatPrice;
            cell.pingFenL.text = self.chatPingFen;
            [cell.helpBackV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectAskToMe)]];
            
        }else {
            cell.phoneIcon.hidden = YES;
            cell.helpName.text = @"图文咨询";
            cell.priceL.text = self.tuwenPrice;
            cell.pingFenL.text = self.tuwenPingFen;
            [cell.helpBackV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTuwenHelp)]];
            
        }
        
        
        return cell;
    }
    
    //关于他
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            FKXAboutHimCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXAboutHimCell" forIndexPath:indexPath];
            if (userD.count !=0) {
                cell.userD = userD;
            }
            return cell;
        }else {
            FKXJianjieCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXJianjieCell" forIndexPath:indexPath];
//            cell.jianjieID.text = self.jianjieID;
            cell.jianjie.text = self.jianjie;
            [cell.zhankaiImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openJianjie)]];
            return cell;
        }
    }
    //评价
    else  if (indexPath.section == 3){
        FKXHisCommentCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXHisCommentCell" forIndexPath:indexPath];
        [cell.openImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openComment)]];
        [cell.moreCommentBtn addTarget:self action:@selector(moreCommentBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.headImgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.userOfEvaIcon,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        cell.commentL.text = self.userOfEvaContent;
        return cell;
        
    }
    //动态
    else  {
        //根据数据中的type 确定cell
        if (self.dongTaiArr.count >0) {
            MyDynamicModel *model = [self.dongTaiArr objectAtIndex:indexPath.row];
            // //  1评论     2抱    3 偷听    4 赞  5语音回复 6收到回信
            switch ([model.type integerValue]) {
                case 1:
                {
                    FKXdynamicsTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXdynamicsTextCell" forIndexPath:indexPath];
                    cell.model = model;
                    return cell;
                }
                    break;
                case 3:
                {
                    FKXdynamicsVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXdynamicsVoiceCell" forIndexPath:indexPath];
                    cell.model = model;
                    return cell;
                }
                    break;
                case 2:
                case 4:
                {
                    FKXdynamicsCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXdynamicsCell" forIndexPath:indexPath];
                    cell.model = model;
                    return cell;
                }
                    break;
                    
                default:
                    return nil;
                    break;
            }
            
        }
        else{
            return nil;
        }
        
    }
        
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-42-64, kScreenWidth, 42)];
        _bottomView.backgroundColor = [UIColor colorWithRed:73/255.0 green:182/255.0 blue:249/255.0 alpha:1];
        
        UIButton *guanzhuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        guanzhuBtn.frame = CGRectMake(0, 0, 75, 42);
        [guanzhuBtn setImage:[UIImage imageNamed:@"message_guanzhu"] forState:UIControlStateNormal];
        [guanzhuBtn addTarget:self action:@selector(guanzhu) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:guanzhuBtn];
        
        UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(75, 0, 3, 42)];
        lineV.backgroundColor = [UIColor whiteColor];
        [_bottomView addSubview:lineV];
        
        UIButton *yuyueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        yuyueBtn.frame = CGRectMake(78, 0, kScreenWidth-78, 42);
        [yuyueBtn setImage:[UIImage imageNamed:@"message_yuyue"] forState:UIControlStateNormal];
        [yuyueBtn setTitle:@"       立即预约" forState:UIControlStateNormal];
        [yuyueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        yuyueBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [yuyueBtn addTarget:self action:@selector(yuyue) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:yuyueBtn];
        
        
    }
    return _bottomView;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight-64-42) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray *)dongTaiArr {
    if (!_dongTaiArr) {
        _dongTaiArr = [[NSMutableArray alloc]init];
    }
    return _dongTaiArr;
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

- (void)registerCell {
    
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    
    [self headerRefreshEvent];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXTProfessionTitleCell" bundle:nil] forCellReuseIdentifier:@"FKXTProfessionTitleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXZixunHelpCell" bundle:nil] forCellReuseIdentifier:@"FKXZixunHelpCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXAboutHimCell" bundle:nil] forCellReuseIdentifier:@"FKXAboutHimCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXJianjieCell" bundle:nil] forCellReuseIdentifier:@"FKXJianjieCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXHisCommentCell" bundle:nil] forCellReuseIdentifier:@"FKXHisCommentCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXdynamicsCell" bundle:nil] forCellReuseIdentifier:@"FKXdynamicsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXdynamicsTextCell" bundle:nil] forCellReuseIdentifier:@"FKXdynamicsTextCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXdynamicsVoiceCell" bundle:nil] forCellReuseIdentifier:@"FKXdynamicsVoiceCell"];

}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
