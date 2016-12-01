//
//  ChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ChatViewController.h"
#import "CustomMessageCell.h"
#import "FKXReportOneStepTableViewController.h"
#import "FKXTimeWarning.h"
#import "FKXCommitHtmlViewController.h"

#import "FKXChatTitleView.h"
#import "EMTextMessageBody.h"

@interface ChatViewController ()<UIAlertViewDelegate, EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource,
    UIActionSheetDelegate,
    EMChatManagerChatDelegate,
    UITextViewDelegate>//protocolFKXRewordView
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_transpondMenuItem;
    
    FKXUserInfoModel *senderUser;
    ChatUser *receiverUser;
    
    NSNotification *notificationContineueFee;
  
    UIView *toolView;   //工具view
    UIButton *rotateBtn;    //旋转按钮
    UIImage *rotateImg;     //旋转图片
    FKXTimeWarning *timeWarningV;   //时间警告框
    UIView *transparentView;
    BOOL isOpening; //工具条是否是展开的
    BOOL canShowEndBtn;//是否展示结束对话
    EMGroup *groupInfo;
    UILabel *labWarnOfEndingTalk;   //群组结束会话，用来挡住输入框
    NSString *ownerName;    //创建者名字
    UIButton *btnClose; //弹出评价的关闭按钮
    UIButton *btnSubmit;    //弹出评价的提交按钮
    
    FKXChatTitleView *titleView;
    CGFloat keyboardHeight;
}
@end

@implementation ChatViewController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"notification_type_end_talk" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpLabelWarnOfEndingTalk) name:@"notification_type_end_talk" object:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //环信赋值
    if (self.conversation.conversationType == eConversationTypeGroupChat)
    {
        //获取群组的信息
        EMError *groErr;
        groupInfo = [[EaseMob sharedInstance].chatManager fetchGroupInfo:self.conversation.chatter error:&groErr];
        NSLog(@"获取错误：%@", groErr);
        self.title = groupInfo.groupSubject;
        
        //创建悬浮的工具
        [self createToolView];
        [self validTheTime];//判断时间，是否展示等待界面和结束提醒
        [self loadOwnerInfo];//加载群主的信息
    }
}
- (void)loadOwnerInfo
{

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:groupInfo.owner forKey:@"uid"];
    [FKXUserInfoModel sendGetOrPostRequest:@"listener/info"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             FKXUserInfoModel *model = data;
             ownerName = model.name;
         } else if (errorModel)
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //对方结束会话的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpLabelWarnOfEndingTalk) name:@"notification_type_end_talk" object:nil];
    
    //单聊判断聊天是否结束
    if (self.conversation.conversationType == eConversationTypeChat) {
        [self browse];
//        [self validTalkIsFinish];//加载是否显示举报
       
    }
    
//    //删除聊天记录
//    [[EaseMob sharedInstance].chatManager removeConversationsByChatters:@[self.conversation.chatter] deleteMessages:YES append2Chat:YES];

    
    if (self.toZiXunShi) {
        //ui设置
        CGPoint origin = self.tableView.origin;
        origin.y = origin.y+150;
        self.tableView.origin = origin;
        
        CGSize size = self.tableView.size;
        size.height = size.height-150;
        self.tableView.size = size;
        
        titleView = [FKXChatTitleView creatChatTitle];
        titleView.frame = CGRectMake(0, 0, kScreenWidth, 150);
        [self.view addSubview:titleView];
        
        self.chatToolbar.inputTextView.placeHolder = @"今天您还能免费聊5句";
        
//        [self setUpChatView];
    }
    
    //发送方,接收方赋值
    senderUser = [FKXUserManager getUserInfoModel];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatUser"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSError *fetchError;
    NSArray *usersArray = [ApplicationDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (self.conversation.conversationType == eConversationTypeChat)
    {
        for (ChatUser *user in usersArray)
        {
            //接受方信息赋值
            if ([user.userId isEqualToString:self.conversation.chatter])
            {
                receiverUser = user;
                break;
            }
        }
    }
    
    [self _setupBarButtonItem];
    
    
    
    self.view.backgroundColor = kColor_MainBackground();
    
    self.tableView.backgroundColor = kColor_MainBackground();
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    
    //设置键盘代理
    //移除不必要的功能,比如发送语音,位置等
    for (int i = 4; i > 2; i--) {
        [self.chatBarMoreView removeItematIndex:i];
    }
    [self.chatBarMoreView removeItematIndex:1];
    
    //环信ui的赋值
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
    
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_sender_audio_playing_full"], [UIImage imageNamed:@"chat_sender_audio_playing_000"], [UIImage imageNamed:@"chat_sender_audio_playing_001"], [UIImage imageNamed:@"chat_sender_audio_playing_002"], [UIImage imageNamed:@"chat_sender_audio_playing_003"]]];
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing_full"],[UIImage imageNamed:@"chat_receiver_audio_playing000"], [UIImage imageNamed:@"chat_receiver_audio_playing001"], [UIImage imageNamed:@"chat_receiver_audio_playing002"], [UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    
    //通过会话管理者获取已收发消息,这个方法是处理聊天记录的
    [self tableViewDidTriggerHeaderRefresh];
    
    if (self.conversation.conversationType == eConversationTypeGroupChat) {
        [self loadHistory];
    }
    
    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:[EaseEmoji allEmoji]];
    [self.faceView setEmotionManagers:@[manager]];
    
    
   
}

- (void)loadHistory {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:self.conversation.chatter forKey:@"groupId"];
    [AFRequest sendGetOrPostRequest:@"/user/groupChatMessage"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
//             FKXUserInfoModel *model = data;
//             ownerName = model.name;
         } else if (errorModel)
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 键盘处理
- (void)keyboardWillShow:(NSNotification *)not{
    NSValue * value = [not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize size2 = [value CGRectValue].size;
    keyboardHeight = size2.height;
    if (self.conversation.conversationType == eConversationTypeChat) {
        if (self.toZiXunShi) {
            CGPoint origin = self.tableView.origin;
            origin.y = origin.y+150;
            self.tableView.origin = origin;
            
            CGSize size = self.tableView.size;
            size.height = size.height-150;
            self.tableView.size = size;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)not{
    
    if (self.conversation.conversationType == eConversationTypeChat) {
        
        if (self.toZiXunShi) {
            CGPoint origin = self.tableView.origin;
            origin.y = origin.y+150;
            self.tableView.origin = origin;
            
            CGSize size = self.tableView.size;
            size.height = size.height-150;
            self.tableView.size = size;
        }
    }
}

#pragma mark - 判断是否可以结束对话
- (void)validTalkIsFinish
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"fromId"];
    [paramDic setValue:self.conversation.chatter forKey:@"toId"];
    
    [AFRequest sendGetOrPostRequest:@"talk/isFinish"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             if ([data[@"data"][@"canPrivateChat"] integerValue]) {//是可以私聊的
                 canShowEndBtn = NO;
             }else{
                 if ([data[@"data"][@"isFinish"] integerValue])
                 {
                     canShowEndBtn = NO;
                     [self setUpLabelWarnOfEndingTalk];
                 }
                 if ([data[@"data"][@"canFinish"] integerValue] && ![data[@"data"][@"isFinish"] integerValue]) {
                     canShowEndBtn = YES;
                 }else{
                     canShowEndBtn = NO;
                 }
             }
         }else if ([data[@"code"] integerValue] == 4)
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
#pragma mark - 判断时间
- (void)validTheTime
{
    NSInteger type = 1;
    if ([groupInfo.groupDescription containsString:@"分享会"])
    {
        type = 1;
    }else if ([groupInfo.groupDescription containsString:@"课程"])
    {
        type = 2;
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:groupInfo.groupId forKey:@"groupId"];
    [paramDic setValue:@(type) forKey:@"type"];
    [AFRequest sendGetOrPostRequest:@"sys/getstatus"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             if ([data[@"data"][@"status"] integerValue] == 0)
             {
                 [self createTimeWarningV];
                 NSString *cont = data[@"data"][@"startTime"];
                 timeWarningV.timeLab.text = [NSString stringWithFormat:@"请您%@准时参加", cont];
             }else if ([data[@"data"][@"status"] integerValue] == 2)
             {
                 [self setUpLabelWarnOfEndingTalk];
             }
         }else if ([data[@"code"] integerValue] == 4)
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
#pragma mark - 创建子视图
- (void)createTimeWarningV
{
    if (!transparentView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        //透明背景
        transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height - 64)];
        transparentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];//RGBACOLOR(0, 0, 0, 0.6);
//        transparentView.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:transparentView];
    }
    if (!timeWarningV)
    {
        timeWarningV = [[[NSBundle mainBundle] loadNibNamed:@"FKXTimeWarning" owner:nil options:nil] firstObject];
        CGRect frame = timeWarningV.frame;
        frame.origin.x = (self.view.width - timeWarningV.width)/2;
        frame.origin.y = (transparentView.height - timeWarningV.height)/2;
        timeWarningV.frame = frame;
//        timeWarningV.center = transparentView.center;
        [transparentView addSubview:timeWarningV];
    }
}
//6､创建手势处理方法：
- (void)hiddenTransparentView
{
    [UIView animateWithDuration:0.5 animations:^{
        [transparentView removeAllSubviews];
        [transparentView removeFromSuperview];
        transparentView = nil;
        timeWarningV = nil;
    }];
}
#pragma mark - textViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return  YES;
}
#pragma mark - 旋转按钮设置
- (void)openTheTool:(UIButton *)btn
{
//    btn.selected = !btn.selected;
    isOpening = !isOpening;
    [UIView animateWithDuration:0.3 animations:^{
        if (isOpening) {
            btn.transform = CGAffineTransformRotate(btn.transform, M_PI_4);
            toolView.frame = CGRectMake(self.view.width - 12 - 195, 0, 195, rotateImg.size.height);
        }else
        {
            toolView.frame = CGRectMake(btn.left, 0, rotateImg.size.width, rotateImg.size.height);
            btn.transform = CGAffineTransformRotate(btn.transform, -M_PI_4);
        }
    }];
}
-(void)clickedTool:(UIButton *)btn
{
    isOpening = !isOpening;
    [UIView animateWithDuration:0.3 animations:^{
        if (isOpening) {
            rotateBtn.transform = CGAffineTransformRotate(rotateBtn.transform, M_PI_4);
            toolView.frame = CGRectMake(self.view.width - 12 - 195, 0, 195, rotateImg.size.height);
        }else
        {
            toolView.frame = CGRectMake(0, 0, rotateImg.size.width, rotateImg.size.height);
            toolView.center = rotateBtn.center;
            rotateBtn.transform = CGAffineTransformRotate(rotateBtn.transform, -M_PI_4);
        }
    } completion:^(BOOL finished) {
        if (btn.tag == 100) {
            FKXUserInfoModel *model = [[FKXUserInfoModel alloc] init];
            model.uid = [NSNumber numberWithInteger:[groupInfo.owner integerValue]];
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            vc.shareType = @"user_center";
            vc.urlString = [NSString stringWithFormat:@"%@front/QA_home.html?uid=%@&loginUserId=%ld&token=%@",kServiceBaseURL, model.uid, [FKXUserManager shareInstance].currentUserId,[FKXUserManager shareInstance].currentUserToken];
            vc.pageType = MyPageType_people;
            vc.userModel = model;
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }else
        {
            [self.chatToolbar.inputTextView becomeFirstResponder];
            
            self.chatToolbar.inputTextView.text = [NSString stringWithFormat:@"@%@",ownerName];
        }
    }];
}
- (void)createToolView
{
    //添加展开功能按钮
    rotateImg = [UIImage imageNamed:@"btn_bac_chat_add_tool"];
    rotateBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 12 - rotateImg.size.width, 0, rotateImg.size.width, rotateImg.size.height)];
    [rotateBtn setBackgroundImage:rotateImg forState:UIControlStateNormal];
    rotateBtn.backgroundColor = [UIColor clearColor];
    [rotateBtn addTarget:self action:@selector(openTheTool:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotateBtn];
    
    rotateBtn.transform = CGAffineTransformMakeRotation(M_PI_4);
    
    toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rotateImg.size.width, rotateImg.size.height)];//self.view.width - 12 - 195
    toolView.center = rotateBtn.center;
    toolView.backgroundColor = kColorMainBlue;
    toolView.layer.cornerRadius = toolView.height/2;
    toolView.clipsToBounds = YES;
    [self.view addSubview:toolView];
    [self.view bringSubviewToFront:rotateBtn];
    //主页按钮
    UIButton * infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.frame = CGRectMake(rotateImg.size.width/2, 0, (195 - rotateImg.size.width/2*3)/2, toolView.height);
    infoBtn.backgroundColor = [UIColor clearColor];
    [infoBtn setTitle:@"主页" forState:UIControlStateNormal];
    infoBtn.tag = 100;
    infoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [infoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(clickedTool:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:infoBtn];
    
    //提问按钮
    UIButton * questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    questionBtn.frame = CGRectMake(infoBtn.right,0,infoBtn.width, infoBtn.height);
    questionBtn.backgroundColor = [UIColor clearColor];
    [questionBtn setTitle:@"提问" forState:UIControlStateNormal];
    questionBtn.tag = 101;
    questionBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [questionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [questionBtn addTarget:self action:@selector(clickedTool:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:questionBtn];
    
    //线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(infoBtn.right, 10, 1, toolView.height - 20)];
    line.backgroundColor = [UIColor whiteColor];
    [toolView addSubview:line];
}
#pragma mark - setup subviews  包括设置按钮
- (void)setUpLabelWarnOfEndingTalk
{
    [self.chatToolbar resignFirstResponder];
    self.chatToolbar.hidden = YES;
    if (self.conversation.conversationType == eConversationTypeChat) {
        if (!labWarnOfEndingTalk) {
            labWarnOfEndingTalk = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height - 50, self.view.width, 50)];
            labWarnOfEndingTalk.userInteractionEnabled = YES;
            labWarnOfEndingTalk.hidden = NO;
            labWarnOfEndingTalk.font = kFont_F4();
            labWarnOfEndingTalk.textColor = kColor_MainLightGray();
            labWarnOfEndingTalk.text = @"对话已结束，您暂时不能发送消息";
            labWarnOfEndingTalk.textAlignment = NSTextAlignmentCenter;
            labWarnOfEndingTalk.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:labWarnOfEndingTalk];
        }
    }else{
        NSString *content;
        if ([groupInfo.groupDescription containsString:@"分享会"])
        {
            content = @"分享会已结束";
        }else if ([groupInfo.groupDescription containsString:@"课程"])
        {
            content = @"课程已结束";
        }
        
        if (!labWarnOfEndingTalk) {
            labWarnOfEndingTalk = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height - 50, self.view.width, 50)];
            labWarnOfEndingTalk.userInteractionEnabled = YES;
            labWarnOfEndingTalk.hidden = NO;
            labWarnOfEndingTalk.font = kFont_F4();
            labWarnOfEndingTalk.textColor = kColor_MainLightGray();
            labWarnOfEndingTalk.text = content;
            labWarnOfEndingTalk.textAlignment = NSTextAlignmentCenter;
            labWarnOfEndingTalk.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:labWarnOfEndingTalk];
        }
    }
}
- (void)_setupBarButtonItem
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    //单聊
    UIImage *image = [UIImage imageNamed:@"img_nav_set"];
    UIButton * rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [rightBarBtn setImage:image forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(clickSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
}
- (void)endTheQunLiaoWithPara:(NSDictionary *)paraDic method:(NSString *)method//结束群聊
{
    [AFRequest sendGetOrPostRequest:method param:paraDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self setUpLabelWarnOfEndingTalk];
            
         }else if ([data[@"code"] integerValue] == 4)
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
- (void)clickSettingBtn
{
    [self.chatToolbar endEditing:YES];
    if (self.conversation.conversationType == eConversationTypeChat)
    {
        if (canShowEndBtn) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:@"结束对话", nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }else{
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
    }
    else{//群组
        FKXUserInfoModel *model = [FKXUserManager getUserInfoModel];
        if ([[model.uid stringValue] isEqualToString:groupInfo.owner])
        {
            NSString *title = @"";
            BOOL isShare = @"";
            if ([groupInfo.groupDescription containsString:@"分享会"])
            {
                isShare = YES;
                title = @"结束分享会";
            }else if ([groupInfo.groupDescription containsString:@"课程"])
            {
                isShare = NO;
                title = @"结束课程";
            }
            UIAlertController *alV = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *ac1 = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
            {
                NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:1];
                [para setValue:groupInfo.groupId forKey:@"groupId"];
                NSString *method;
                if (isShare)
                {
                    method = @"meeting/finish";
                    [self endTheQunLiaoWithPara:para method:method];
                }else{
                    method = @"course/finish";
                    [self endTheQunLiaoWithPara:para method:method];
                }
            }];
            UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){}];
            
            [alV addAction:ac1];
            [alV addAction:ac2];
            [self presentViewController:alV animated:YES completion:nil];
        }else if ([[model.uid stringValue] isEqualToString:@"24"])
        {
            UIAlertController *alV = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *ac1 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"群组人数%ld", groupInfo.occupants.count] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
            {}];
            UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){}];
            
            [alV addAction:ac1];
            [alV addAction:ac2];
            [self presentViewController:alV animated:YES completion:nil];
        }else
        {
            UIAlertController *alV = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"退出群组" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
            {
                [[EaseMob sharedInstance].chatManager asyncLeaveGroup:groupInfo.groupId
                                                           completion:
                 ^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
                     if (!error) {
                         UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您已退出群组" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                         [alert show];
                     }
                 } onQueue:nil];
            }];
            UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){}];

            [alV addAction:ac1];
            [alV addAction:ac2];
            [self presentViewController:alV animated:YES completion:nil];
        }
    }
}

#pragma mark --- UIActionSheetDelegate  处理结束对话或者举报
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        NSString *actionTitle =[actionSheet buttonTitleAtIndex:buttonIndex];
        if ([actionTitle isEqualToString:@"结束对话"])
        {
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"结束对话后您将不再收到对方发送的消息,也不能再给对方发送消息,确定结束对话吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 100;
            [alert show];
        }
        else
        
        if ([actionTitle isEqualToString:@"举报"])
        {
            FKXReportOneStepTableViewController *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXReportOneStepTableViewController"];
            vc.toUid = receiverUser.userId ? receiverUser.userId : @"";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
#pragma mark - 结束对话
- (void)beginEndTheTalk
{
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paraDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"fromId"];
    [paraDic setValue:self.conversation.chatter forKey:@"toId"];
    [self showHudInView:self.view hint:@"正在处理..."];
    [AFRequest sendGetOrPostRequest:@"talk/finish" param:paraDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            NSDictionary *dicExt = @{
                                     @"head" : senderUser.head,
                                     @"name": senderUser.name,
                                     };
            
            [EaseSDKHelper sendTextMessage:@"对话已结束，请到我的消息-通知中对我的服务进行评价。满意的话欢迎下次再来找我哦" to:self.conversation.chatter messageType:eMessageTypeChat requireEncryption:NO messageExt:dicExt];
            [self setUpLabelWarnOfEndingTalk];
        }else if ([data[@"code"] integerValue] == 4)
        {
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView.tag == 101) {
            self.messageTimeIntervalTag = -1;
            [self.conversation removeAllMessages];
            [self.dataArray removeAllObjects];
            [self.messsagesSource removeAllObjects];
            
            [self.tableView reloadData];
        }else if (alertView.tag == 100)
        {
            [self beginEndTheTalk];
        }
    }
}
#pragma mark - EaseMessageViewControllerDelegate
- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    if (self.toZiXunShi) {
        static int i=5;
        i--;
        if (i<=0) {
            return;
        }
        self.chatToolbar.inputTextView.placeHolder = [NSString stringWithFormat:@"今天您还能免费聊%d句",i];
        
    }
    
    //将自己的信息发送给对方
    ext = @{
            @"head" : senderUser.head,
            @"name": senderUser.name,
            };
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                     to:self.conversation.chatter
                                            messageType:[self _messageTypeFromConversationType]
                                      requireEncryption:NO
                                             messageExt:ext];
    [self addMessageToDataSource:message
                        progress:nil];
}

- (EMMessageType)_messageTypeFromConversationType
{
    EMMessageType type = eMessageTypeChat;
    switch (self.conversation.conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}


- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        [self _showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
    }
    return YES;
}
- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    if (messageModel.bodyType == eMessageBodyType_Text) {
        return [CustomMessageCell cellHeightWithModel:messageModel];
    }
    return 0.f;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController didSelectMessageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    return flag;
}

- (void)messageViewController:(EaseMessageViewController *)viewController
   didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
//    UserProfileViewController *userprofile = [[UserProfileViewController alloc] initWithUsername:messageModel.nickname];
    
//    if ([((EaseMessageModel *)messageModel).message.ext[@"identify"] isEqualToString:@"officialListener"]) {
//        FKXExpertSpaceViewController *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXExpertSpaceViewController"];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}


- (void)messageViewController:(EaseMessageViewController *)viewController
            didSelectMoreView:(EaseChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
}

- (void)messageViewController:(EaseMessageViewController *)viewController
          didSelectRecordView:(UIView *)recordView
                 withEvenType:(EaseRecordViewType)type
{
    switch (type) {
        case EaseRecordViewTypeTouchDown:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView  recordButtonTouchDown];
            }
        }
            break;
        case EaseRecordViewTypeTouchUpInside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
            }
            [self.recordView removeFromSuperview];
        }
            break;
        case EaseRecordViewTypeTouchUpOutside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
            }
            [self.recordView removeFromSuperview];
        }
            break;
        case EaseRecordViewTypeDragInside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragInside];
            }
        }
            break;
        case EaseRecordViewTypeDragOutside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragOutside];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - EaseMessageViewControllerDataSource
- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForMessageModel:(id<IMessageModel>)model
{
    if (model.bodyType == eMessageBodyType_Text) {
        NSString *CellIdentifier = [CustomMessageCell cellIdentifierWithModel:model];
        //发送cell
        CustomMessageCell *sendCell = (CustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (sendCell == nil) {
            sendCell = [[CustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        sendCell.model = model;
        
        return sendCell;
    }
    return nil;
}
- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    NSLog(@"消息是：%@\n", message);
    id<IMessageModel> model = nil;

    model = [[EaseMessageModel alloc] initWithMessage:message];
    if (((EaseMessageModel *)model).isSender)
    {
        ((EaseMessageModel *)model).avatarURLPath = senderUser.head;
        ((EaseMessageModel *)model).nickname = senderUser.name;
    }else
    {
        if (self.conversation.conversationType == eConversationTypeGroupChat) {
            NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatUser"];
            [fetchRequest setReturnsObjectsAsFaults:NO];
            NSError *fetchError;
            NSArray *usersArray = [ApplicationDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
            for (ChatUser *user in usersArray)
            {
                //接受方信息赋值
                if ([user.userId isEqualToString:message.groupSenderName])
                {
                    ((EaseMessageModel *)model).avatarURLPath = user.avatar;
                    ((EaseMessageModel *)model).nickname = user.nick;
                    break;
                }
            }
        }else if (self.conversation.conversationType == eConversationTypeChat)
        {
            ((EaseMessageModel *)model).avatarURLPath = receiverUser.avatar;
            ((EaseMessageModel *)model).nickname = receiverUser.nick;
        }
    }
    model.failImageName = @"imageDownloadFail";
    return model;
}
#pragma mark - EaseMob

#pragma mark - EMChatManagerLoginDelegate

- (void)didLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)didRemovedFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - action 返回

- (void)backAction
{
    [self hiddenTransparentView];
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:self.conversation.chatter deleteMessages:NO append2Chat:YES];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showGroupDetailAction
{
    [self.view endEditing:YES];
    if (self.conversation.conversationType == eConversationTypeGroupChat) {
//        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:self.conversation.chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
    }
    else if (self.conversation.conversationType == eConversationTypeChatRoom)
    {
//        ChatroomDetailViewController *detailController = [[ChatroomDetailViewController alloc] initWithChatroomId:self.conversation.chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
    }
}

- (void)deleteAllMessages:(id)sender
{
    if (self.dataArray.count == 0) {
        [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        BOOL isDelete = [groupId isEqualToString:self.conversation.chatter];
        if (self.conversation.conversationType != eConversationTypeChat && isDelete) {
            self.messageTimeIntervalTag = -1;
            [self.conversation removeAllMessages];
            [self.messsagesSource removeAllObjects];
            [self.dataArray removeAllObjects];
            
            [self.tableView reloadData];
            [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        }
    }
    else if ([sender isKindOfClass:[UIButton class]]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        alertView.tag = 101;
        [alertView show];
    }
}

- (void)transpondMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
//        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
//        ContactListSelectViewController *listViewController = [[ContactListSelectViewController alloc] initWithNibName:nil bundle:nil];
//        listViewController.messageModel = model;
//        [listViewController tableViewDidTriggerHeaderRefresh];
//        [self.navigationController pushViewController:listViewController animated:YES];
    }
    self.menuIndexPath = nil;
}

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation removeMessage:model.message];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - notification
- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessageToDataSource:message progress:nil];
        [[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
    }
}

- (void)handleCallNotification:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        //开始call
        self.isViewDidAppear = NO;
    } else {
        //结束call
        self.isViewDidAppear = YES;
    }
}

#pragma mark - private

- (void)_showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(MessageBodyType)messageType
{
    if (self.menuController == nil) {
        self.menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
    }
    
    if (_transpondMenuItem == nil) {
        _transpondMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"transpond", @"Transpond") action:@selector(transpondMenuAction:)];
    }
    
    if (messageType == eMessageBodyType_Text) {
        [self.menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem,_transpondMenuItem]];
    } else if (messageType == eMessageBodyType_Image){
        [self.menuController setMenuItems:@[_deleteMenuItem,_transpondMenuItem]];
    } else {
        [self.menuController setMenuItems:@[_deleteMenuItem]];
    }
    [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
    [self.menuController setMenuVisible:YES animated:YES];
}

- (void)setUpChatView {
    
    NSString *name = self.userModel.name;
    NSArray *goodsAt = self.userModel.goodAt;
    for (NSString *goodStr in goodsAt) {
        
    }
    
    EMChatText *txt2 = [[EMChatText alloc] initWithText:@"下单流程：下单付款--等待确认--接听来电--正式咨询\n\n小贴士：您可以先通过私信联系我确定时间，如果您的问题复杂或需要长期疏导陪伴，请选择套餐【立减折扣】，方便随时联系"];
    EMTextMessageBody *body2 = [[EMTextMessageBody alloc] initWithChatObject:txt2];
    
    EMMessage *message = [[EMMessage alloc] initWithReceiver:[NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId] bodies:@[body2]];
    message.from = [self.userModel.uid stringValue];
    message.to = [NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId];
    message.ext = @{@"head":self.userModel.head,@"name":self.userModel.name};
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    message.deliveryState = eMessageDeliveryState_Delivered;
    [[EaseMob sharedInstance].chatManager insertMessageToDB:message];
    [[FKXBaseViewController alloc] insertDataToTableWith:message managedObjectContext:ApplicationDelegate.managedObjectContext];

}


- (void)browse {
    NSInteger t = [[FKXUserManager shareInstance]currentUserId];
    NSDictionary *params = @{@"fromId":@(t),@"toId":self.conversation.chatter};
    [AFRequest sendGetOrPostRequest:@"user/browse" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
    } failure:^(NSError *error) {
        
    }];
}
@end
