//
//  FKXRecommendListener.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/20.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXRecommendListener.h"
#import "FKXConsulterPageVC.h"
#import "FKXSameMindViewController.h"
#import "FKXSecondAskController.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXSecondAskModel.h"
#import "FKXSameMindModel.h"
#import "FKXResonance_homepage_model.h"
#import "FKXProfessionInfoVC.h"

@interface FKXRecommendListener ()<UITableViewDelegate>
{
    NSMutableArray *voiceRecommend;
    NSMutableArray *worryRecommend;
    NSMutableArray *listenerRecommend;
    FKXResonance_homepage_model *articleModel;
    
    FKXSecondAskModel *secondModel1;
    FKXSecondAskModel *secondModel2;
 
    FKXSameMindModel *sameModel1;
    FKXSameMindModel *sameModel2;
}
@property (weak, nonatomic) IBOutlet UIImageView *listenerIconNo1;
@property (weak, nonatomic) IBOutlet UILabel *listenerNameNo1;
@property (weak, nonatomic) IBOutlet UILabel *listenerhelpNo1;
@property (weak, nonatomic) IBOutlet UIImageView *listenerIconNo2;
@property (weak, nonatomic) IBOutlet UILabel *listenerNameNo2;
@property (weak, nonatomic) IBOutlet UILabel *listenerhelpNo2;
@property (weak, nonatomic) IBOutlet UIImageView *secondAskIconNo1;
@property (weak, nonatomic) IBOutlet UILabel *secondAskNameNo1;
@property (weak, nonatomic) IBOutlet UILabel *secondAskProfessionNo1;
@property (weak, nonatomic) IBOutlet UILabel *secondAskContent1;
@property (weak, nonatomic) IBOutlet UILabel *secondAskLisented1;


@property (weak, nonatomic) IBOutlet UIImageView *secondAskIconNo2;
@property (weak, nonatomic) IBOutlet UILabel *secondAskNameNo2;
@property (weak, nonatomic) IBOutlet UILabel *secondAskProfessionNo2;
@property (weak, nonatomic) IBOutlet UILabel *secondAskContent2;
@property (weak, nonatomic) IBOutlet UILabel *secondAskLisented2;


@property (weak, nonatomic) IBOutlet UIImageView *sameMindIconNo1;
@property (weak, nonatomic) IBOutlet UILabel *sameMindNameNo1;
@property (weak, nonatomic) IBOutlet UILabel *sameMindContent1;
@property (weak, nonatomic) IBOutlet UIImageView *sameMindIconNo2;
@property (weak, nonatomic) IBOutlet UILabel *sameMindNameNo2;
@property (weak, nonatomic) IBOutlet UILabel *sameMindContent2;

@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *articleContent;
@property (weak, nonatomic) IBOutlet UIView *viewSameModel1;
@property (weak, nonatomic) IBOutlet UIView *viewSameModel2;
@end

@implementation FKXRecommendListener

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    switch (_type) {
        case 0:
            self.navTitle = @"婚恋出轨";
            break;
        case 1:
            self.navTitle = @"失恋阴影";
            break;
        case 2:
            self.navTitle = @"夫妻相处";
            break;
        case 3:
            self.navTitle = @"婆媳关系";
            break;
            
        default:
            break;
    }
    
    voiceRecommend = [NSMutableArray arrayWithCapacity:1];
    listenerRecommend = [NSMutableArray arrayWithCapacity:1];
    worryRecommend = [NSMutableArray arrayWithCapacity:1];
    
    //加载数据
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 加载数据
- (void)loadData
{
    [self showHudInView:self.view hint:@"正在加载..."];
    NSDictionary *paramDic = @{@"type" : @(_type), @"uid": @([FKXUserManager shareInstance].currentUserId)};
    
    [AFRequest sendGetOrPostRequest:@"listener/recommendByType" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         if ([data[@"code"] integerValue] == 0)
         {
             NSError *err = nil;
             NSInteger index = 0;
             //关怀师赋值
             for (NSDictionary *subDic in data[@"data"][@"ListenerRecommend"]) {
                 FKXUserInfoModel *model = [[FKXUserInfoModel alloc] initWithDictionary:subDic error:&err];
                 [listenerRecommend addObject:model];
                 if (index == 0) {
                     _listenerIconNo1.userInteractionEnabled = YES;
                     _listenerIconNo1.tag = 101;
                     [_listenerIconNo1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDynamic:)]];
                     [_listenerIconNo1 sd_setImageWithURL:[NSURL URLWithString:model.head] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                     _listenerNameNo1.text = model.name;
                     NSString *str = [NSString stringWithFormat:@"治愈了%@人", model.cureCount];
                     NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
                     [attStr addAttribute:NSForegroundColorAttributeName value:kColorMainBlue range:[str rangeOfString:[NSString stringWithFormat:@"%@",model.cureCount]]];
                     [_listenerhelpNo1 setAttributedText:attStr];
                 }else if (index == 1)
                 {
                     _listenerIconNo2.userInteractionEnabled = YES;
                     _listenerIconNo2.tag = 102;
                     [_listenerIconNo2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDynamic:)]];
                     [_listenerIconNo2 sd_setImageWithURL:[NSURL URLWithString:model.head] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                     _listenerNameNo2.text = model.name;
                     NSString *str = [NSString stringWithFormat:@"治愈了%@人", model.cureCount];
                     NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
                     [attStr addAttribute:NSForegroundColorAttributeName value:kColorMainBlue range:[str rangeOfString:[NSString stringWithFormat:@"%@",model.cureCount]]];
                     [_listenerhelpNo2 setAttributedText:attStr];
                 }
                 index++;
             }
             //享问赋值
             index = 0;
             for (NSDictionary *subDic in data[@"data"][@"voiceRecommend"]) {
                 FKXSecondAskModel *model = [[FKXSecondAskModel alloc] initWithDictionary:subDic error:&err];
                 [voiceRecommend addObject:model];
                 if (index == 0) {
                     secondModel1 = model;
                     _secondAskIconNo1.userInteractionEnabled = YES;
                     _secondAskIconNo1.tag = 201;
                     [_secondAskIconNo1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDynamic:)]];
                     [_secondAskIconNo1 sd_setImageWithURL:[NSURL URLWithString:model.listenerHead] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                     _secondAskNameNo1.text = model.listenerNickName;
                     _secondAskProfessionNo1.text = model.listenerProfession;
                     
                     NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                     style.lineSpacing = 8;
                     NSAttributedString *attS =[[NSAttributedString alloc] initWithString:model.text?model.text:@"" attributes:@{NSParagraphStyleAttributeName : style}];
                     [_secondAskContent1 setAttributedText:attS];

                 }else if (index == 1)
                 {
                     secondModel2 = model;
                     _secondAskIconNo2.userInteractionEnabled = YES;
                     _secondAskIconNo2.tag = 202;
                     [_secondAskIconNo2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDynamic:)]];

                     [_secondAskIconNo2 sd_setImageWithURL:[NSURL URLWithString:model.listenerHead] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                     _secondAskNameNo2.text = model.listenerNickName;
                     _secondAskProfessionNo2.text = model.listenerProfession;
                     NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                     style.lineSpacing = 8;
                     NSAttributedString *attS =[[NSAttributedString alloc] initWithString:model.text?model.text:@"" attributes:@{NSParagraphStyleAttributeName : style}];
                     [_secondAskContent2 setAttributedText:attS];
                 }
                 index++;
             }
             //共鸣赋值
             index = 0;
             for (NSDictionary *subDic in data[@"data"][@"worryRecommend"])
             {
                 FKXSameMindModel *model = [[FKXSameMindModel alloc] initWithDictionary:subDic error:&err];
                 [worryRecommend addObject:model];
                 if (index == 0) {
                     sameModel1 = model;
                     [_viewSameModel1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSameMindHtml:)]];
                     _sameMindIconNo1.userInteractionEnabled = YES;
                     _sameMindIconNo1.tag = 301;
                     [_sameMindIconNo1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDynamic:)]];

                     [_sameMindIconNo1 sd_setImageWithURL:[NSURL URLWithString:model.head] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                     _sameMindNameNo1.text = model.nickName;
                     NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                     style.lineSpacing = 8;
                     NSAttributedString *attS =[[NSAttributedString alloc] initWithString:model.text?model.text:@"" attributes:@{NSParagraphStyleAttributeName : style}];
                     [_sameMindContent1 setAttributedText:attS];
                 }else if (index == 1)
                 {
                     sameModel2 = model;
                     [_viewSameModel2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSameMindHtml:)]];
                     _sameMindIconNo2.userInteractionEnabled = YES;
                     _sameMindIconNo2.tag = 302;
                     [_sameMindIconNo2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDynamic:)]];

                     [_sameMindIconNo2 sd_setImageWithURL:[NSURL URLWithString:model.head] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                     _sameMindNameNo2.text = model.nickName;
                     NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                     style.lineSpacing = 8;
                     NSAttributedString *attS =[[NSAttributedString alloc] initWithString:model.text?model.text:@"" attributes:@{NSParagraphStyleAttributeName : style}];
                     [_sameMindContent2 setAttributedText:attS];
                 }
                 index++;
             }
             for (NSDictionary *subDic in data[@"data"][@"shareRecommend"]) {
                 articleModel = [[FKXResonance_homepage_model alloc] initWithDictionary:subDic error:&err];
                 NSAttributedString *attS =[[NSAttributedString alloc] initWithString:articleModel.title?articleModel.title:@"" attributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
                 [_articleTitle setAttributedText:attS];
                 _articleContent.text = articleModel.text;
                 break;
             }
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else{
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self hideHud];
         [self showHint:@"网络出错"];
     }];
}
#pragma mark - 手势事件
- (void)goToSameMindHtml:(UITapGestureRecognizer *)gesture;
{
    FKXSameMindModel *model;
    if (gesture.view.tag == 400) {
        model = sameModel1;
    }else{
        model = sameModel2;
    }
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"comment";
    vc.pageType = MyPageType_nothing;
    vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,model.worryId, (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
    vc.sameMindModel = model;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 跳转到咨询师个人页面
- (void)goToDynamic:(UITapGestureRecognizer *)tapGes
{
    NSNumber *uid;
    UIView *view = tapGes.view;
    switch (view.tag) {
        case 101:
        {
            FKXUserInfoModel *model = listenerRecommend[0];
            uid = model.uid;
        }
            break;
        case 102:
        {
            FKXUserInfoModel *model = listenerRecommend[1];
            uid = model.uid;
        }
            break;
        case 201:
        {
            FKXSecondAskModel *model = voiceRecommend[0];
            uid = model.listenerId;
        }
            break;
        case 202:
        {
            FKXSecondAskModel *model = voiceRecommend[1];
            uid = model.listenerId;
        }
            break;
        case 301:
        {
            FKXSameMindModel *model = worryRecommend[0];
            uid = model.uid;
        }
            break;
        case 302:
        {
            FKXSameMindModel *model = worryRecommend[1];
            uid = model.uid;
        }
            break;
            
        default:
            break;
    }
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    
    vc.userId = uid;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 点击事件  专家查看更多
- (void)goToListeners {
    FKXConsulterPageVC * vc =  [[FKXConsulterPageVC alloc] init];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    [arr addObject:@(_type)];
    vc.goodAtsArr = arr;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        
             //查看更多成功案例(将要和共鸣融合)
        case 0:
//            [self goToListeners];
        {
//            [self.navigationController popViewControllerAnimated:NO];
//            SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectMindType" object:@(_type)];
//            tab.selectedIndex = 1;
            FKXSecondAskController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSecondAskController"];
            vc.passMindType = @(_type);
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            if (!secondModel1) {
                return;
            }
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            vc.isNeedTwoItem = YES;
            FKXSecondAskModel *model = secondModel1;
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
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            if (!secondModel2) {
                return;
            }
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            vc.isNeedTwoItem = YES;
            FKXSecondAskModel *model = secondModel2;
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
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        
            //查看更多共鸣
        case 3:
        {
            [self.navigationController popViewControllerAnimated:NO];
            SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectMindType" object:@(_type)];
            tab.selectedIndex = 1;

        }
            break;
//        case 4:
//        {
//            FKXSecondAskController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSecondAskController"];
//            vc.passMindType = @(_type);
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
            
//        case 6:
//        {
//            FKXSameMindViewController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSameMindViewController"];
//            vc.passMindType = @(_type);
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
            
            //点击文章
        case 7:
        {
            if (articleModel) {
                FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
                vc.shareType = @"mind";
                vc.urlString = [NSString stringWithFormat:@"%@?shareId=%@&uid=%ld&token=%@",articleModel.url, articleModel.hotId, (long)[FKXUserManager shareInstance].currentUserId,[FKXUserManager shareInstance].currentUserToken];
                vc.pageType = MyPageType_hot;
                vc.resonanceModel = articleModel;
                //push的时候隐藏tabbar
                [vc setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
