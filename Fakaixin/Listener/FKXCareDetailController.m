//
//  FKXCareDetailController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/24.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXCareDetailController.h"
#import <QiniuSDK.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "MyDrawView.h"
#import "CycleView.h"
#import "NSString+HeightCalculate.h"
#import "lame.h"
#import "UILabelTextInRect.h"
#import "FKXCareListController.h"

#define kFontOfContent 15

@interface FKXCareDetailController ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    NSData *rewordData;
    CycleView  *cycleView;
    CGFloat progress;
    MyDrawView *drawView;
}
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (nonatomic, weak) IBOutlet UILabel *consoleLabel;//时间控制
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

//录音
@property(nonatomic,strong)AVAudioRecorder *recorder;
//播放
@property(nonatomic,strong)AVAudioPlayer *player;
@property(nonatomic, strong)NSTimer *myTimer;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, copy) NSString *localFileName;//录音存储路径
@property (weak, nonatomic) IBOutlet UIView *viewSectionTwo;

@property (weak, nonatomic) IBOutlet UILabelTextInRect *labelRemind;
@property (weak, nonatomic) IBOutlet UILabel *labWarning;

@end

@implementation FKXCareDetailController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *imageName = @"user_guide_begin_record_6";
    [FKXUserManager showUserGuideWithKey:imageName];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //基础赋值
    self.navTitle = @"详情";
     progress = 0;
    [self setUpDatas];//子视图赋值

    //设置ui的展示
    _sendBtn.enabled = NO;
    _resetBtn.enabled = NO;
    [_resetBtn setTitleColor:UIColorFromRGB(0xd2d2d2) forState:UIControlStateNormal];
    _resetBtn.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
   _sendBtn.backgroundColor = UIColorFromRGB(0xd2d2d2);
    
    //记录本地的音频路径
    NSString *document =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _localFileName = [document stringByAppendingPathComponent:@"myVoice"];
    NSLog(@"路径：%@", _localFileName);
    if ([[NSFileManager defaultManager] fileExistsAtPath:_localFileName]) {
        NSError *err;
        [[NSFileManager defaultManager] removeItemAtPath:_localFileName error:&err];
    }
    NSString *mp3 = [document stringByAppendingPathComponent:@"myVoice.mp3"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mp3]) {
        NSError *err;
        [[NSFileManager defaultManager] removeItemAtPath:mp3 error:&err];
    }
    //创建进度条
    [self createCircleProgress];
    
    //添加警告小图标
    [self setUpSubviews];
    
//    //温馨提示：设置录音配置（不写这个配置录完没法播放）
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    NSError *sessionError;
//    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];//
//    //判断后台有没有播放
//    if(session == nil)
//    {
//        NSLog(@"设置录音配置（不写这个配置录完没法播放）：Error creating sessing:%@", [sessionError description]);
//    }else
//    {
//        [session setActive:YES error:nil];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpSubviews
{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:_labelRemind.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    UIImage *im = [UIImage imageNamed:@"img_look_info"];
    attch.image = im;
    attch.bounds = CGRectMake(0, 0, im.size.width, im.size.height);
    NSAttributedString *attS = [NSAttributedString attributedStringWithAttachment:attch];
    [attStr appendAttributedString:attS];
    [_labelRemind setAttributedText:attStr];
}
- (void)goBack
{
    if (_isPlaying) {
        [self showHint:@"请先结束播放"];
        return;
    }
    if (_isRecording) {
        [self showHint:@"请先结束录制"];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 子视图布局
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    drawView.center = _consoleLabel.center;
    
    CGRect frame = drawView.frame;
    frame.origin.x = self.view.width/2 - 63/2 - 3;
    drawView.frame = frame;
    cycleView.frame = drawView.frame;
}
#pragma mark - 给子视图赋值
- (void)setUpDatas
{
    switch (_careDetailType) {
        case care_detail_type_mind:
        {
            [_imgIcon sd_setImageWithURL:[NSURL URLWithString:_sameModel.head] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            _labTime.text = _sameModel.createTime;
            
            NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
            sty.lineSpacing = 5;
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:_sameModel.text ? _sameModel.text : @"" attributes:@{NSParagraphStyleAttributeName : sty, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
            _labContent.attributedText = attStr;
            _userName.text = _sameModel.nickName;
        }
            break;
        case care_detail_type_people:
        {
            [_imgIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_askModel.userHead, cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            _labTime.text = _askModel.createTime;
            
            NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
            sty.lineSpacing = 5;
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:_askModel.text ? _askModel.text : @"" attributes:@{NSParagraphStyleAttributeName : sty, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
            _labContent.attributedText = attStr;
            _userName.text = _askModel.userNickName;
        }
            break;
        case care_detail_type_continue_ask:
        {
            [_imgIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_askModel.userHead, cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            _labTime.text = _askModel.createTime;
            
            NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
            sty.lineSpacing = 5;
            NSString *con = [NSString stringWithFormat:@"被追问：%@", _askModel.text];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:con attributes:@{NSParagraphStyleAttributeName : sty, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
            _labContent.attributedText = attStr;
            _userName.text = _askModel.userNickName;
        }
            break;
        case care_detail_type_special:
        {
            _imgIcon.image = [UIImage imageNamed:@"img_order_logo"];
            _labTime.text = @"";
            _labContent.text = @"";
            _userName.text = _courseModel.title;
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 创建圆形进度条
- (void)createCircleProgress
{
    drawView = [[MyDrawView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)];
    
    drawView.backgroundColor = [UIColor clearColor];
    [_viewSectionTwo addSubview:drawView];
    
    cycleView = [[CycleView alloc] initWithFrame:drawView.frame];
    cycleView.backgroundColor = [UIColor clearColor];
    [_viewSectionTwo addSubview:cycleView];
}

#pragma mark - 自定义事件 倒计时
- (void)beginCountDown
{
    if (progress == 120) {
        self.isRecording = NO;
        [_myTimer invalidate];
        _myTimer = nil;
        self.isRecording = NO;
        _resetBtn.enabled = YES;
        [_resetBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
        _resetBtn.layer.borderColor = kColorMainBlue.CGColor;
        _sendBtn.backgroundColor = kColorMainBlue;
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_bac_pause"] forState:UIControlStateNormal];
        [_recordButton setImage:nil forState:UIControlStateNormal];
        
        //停止录音
        [_recorder stop];
        _recorder = nil;
        return;
    }
    [cycleView drawProgress:++progress/120];
    _consoleLabel.text = [NSString stringWithFormat:@"%ld′′", [_consoleLabel.text integerValue]+1];
}
#pragma mark - 压缩mp3
- (void)audio_PCMtoMP3
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString * myMp3File = [document stringByAppendingPathComponent:@"myVoice.mp3"];
    @try {
        int read, write;
        
        FILE *pcm = fopen([_localFileName cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([myMp3File cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        _localFileName = myMp3File;
        rewordData = [NSData dataWithContentsOfFile:_localFileName];
         _sendBtn.enabled = YES;
        NSLog(@"MP3生成成功: %@",myMp3File);
        
        if (!_player)
        {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            NSError *err = nil;
            [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
            
            NSURL *playUrl = [NSURL URLWithString:_localFileName];
            //初始化播放类
            NSError *playError;
            self.player = [[AVAudioPlayer alloc] initWithData:rewordData error:&playError];//[[AVAudioPlayer alloc] initWithContentsOfURL:playUrl error:&playError];
//            [self.player peakPowerForChannel:0];//获取分贝
            NSLog(@"播放路径：%@，url：%@", _localFileName, playUrl);
            _player.volume = 1;
            //当播放录音为空,打印错误信息
            if(self.player == nil)
            {
                NSLog(@"Error crenting player: %@", [playError description]);
            }
            self.player.delegate = self;
            BOOL succ = [self.player prepareToPlay];
            NSLog(@"准备播放值：%d", succ);
        }
    }
}
#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [NSThread detachNewThreadSelector:@selector(audio_PCMtoMP3) toTarget:self withObject:nil];
}
/*
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    
    if (_isRecording)//暂停录音
    {
        _labWarning.text = @"播放试听";
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_bac_pause"] forState:UIControlStateNormal];
        [_recordButton setImage:nil forState:UIControlStateNormal];
        
        [_myTimer invalidate];
        _myTimer = nil;
        self.isRecording = NO;
        _resetBtn.enabled = YES;
        [_resetBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
        _resetBtn.layer.borderColor = kColorMainBlue.CGColor;
        _sendBtn.backgroundColor = kColorMainBlue;
        
        //停止录音
        [_recorder stop];
        _recorder = nil;
        
        return;
    }
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags
{
    
}*/
#pragma mark - AVAudioPlayerDelegate
/*
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    _labWarning.text = @"播放试听";
    self.isPlaying = NO;
    [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_bac_pause"] forState:UIControlStateNormal];
    [_recordButton setImage:nil forState:UIControlStateNormal];
    _resetBtn.enabled = YES;
    _sendBtn.enabled = YES;
    [_resetBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    _resetBtn.layer.borderColor = kColorMainBlue.CGColor;
    _sendBtn.backgroundColor = kColorMainBlue;
    //暂停播放
    [_player pause];
}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    
}
 */
//播放结束后调用方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _labWarning.text = @"播放试听";
    self.isPlaying = NO;
    _resetBtn.enabled = YES;
    _sendBtn.enabled = YES;
    [_resetBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    _resetBtn.layer.borderColor = kColorMainBlue.CGColor;
    _sendBtn.backgroundColor = kColorMainBlue;
    [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_bac_pause"] forState:UIControlStateNormal];
    [_recordButton setImage:nil forState:UIControlStateNormal];
}
#pragma mark - 点击事件
- (IBAction)clickResetRecord:(UIButton *)sender
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:_localFileName]){
        [_myTimer invalidate];
        _myTimer = nil;
        _sendBtn.enabled = NO;
        _resetBtn.enabled = NO;
        [_resetBtn setTitleColor:UIColorFromRGB(0xd2d2d2) forState:UIControlStateNormal];
        _resetBtn.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
       _sendBtn.backgroundColor = UIColorFromRGB(0xd2d2d2);
        [_recordButton setImage:[UIImage imageNamed:@"btn_begin_record"] forState:UIControlStateNormal];
        [_recordButton setBackgroundImage:nil forState:UIControlStateNormal];
        self.isRecording = NO;
        self.isPlaying = NO;
        NSError *err;
        [[NSFileManager defaultManager]
         removeItemAtPath:_localFileName error:&err];
        progress = 0;
        _labWarning.text = @"点击开始录音,最多120秒";
        _consoleLabel.text = @"0′′";
        [cycleView drawProgress:0/120];
        NSString *document =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *fileName = [document stringByAppendingPathComponent:@"myVoice"];
        _localFileName = fileName;
        [[NSFileManager defaultManager]
         removeItemAtPath:fileName error:&err];
    }
}
- (IBAction)clickSend:(UIButton *)sender
{
    NSRange range = [_consoleLabel.text rangeOfString:@"′′"];
    NSString *time = [_consoleLabel.text substringToIndex:range.location];
    if ([time integerValue] < 30) {
        [self showHint:@"录制时间需要大于30秒，小于2分钟哟"];
        return;
    }
    __block  NSString *token = @"";
    
    NSDictionary *paramDic = @{};
    [self showHudInView:self.view hint:@"正在处理语音..."];
    
    [AFRequest sendGetOrPostRequest:@"user/upload_image"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             token = data[@"data"][@"token"];
             
             [self uploadVoiceByData:rewordData token:token];
             
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
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
- (void)uploadVoiceByData:(NSData *)data token:(NSString *)token
{
    [self showHudInView:self.view hint:@"正在上传语音..."];
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    //    NSData *data = [@"Hello, World!" dataUsingEncoding: NSUTF8StringEncoding];
    NSString *voiceName = [NSString stringWithFormat:@"%.f-%ld.mp3",[[NSDate date] timeIntervalSince1970]*1000,(long)[FKXUserManager shareInstance].currentUserId];
    
    [upManager putData:data key:voiceName token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
    {
        [self hideHud];
        NSLog(@"七牛上传图片info:%@", info);
        NSLog(@"七牛上传图片resp:%@", resp);
        NSRange range = [_consoleLabel.text rangeOfString:@"′′"];
        NSString *time = [_consoleLabel.text substringToIndex:range.location];
        NSNumber *paraId;
        NSString *paraN;
        switch (_careDetailType) {
            case care_detail_type_special:
            {
                paraId = _courseModel.keyId;
                paraN = @"topicId";
            }
                break;
            case care_detail_type_people:
            case care_detail_type_continue_ask:
                paraId = _askModel.lqId;
                paraN = @"questionId";
                break;
            case care_detail_type_mind:
            {
                paraId = _sameModel.worryId;
                paraN = @"worryId";
            }
                break;
            default:
                paraId = @(0);  //默认
                paraN = @"";
                break;
        }
        [self showHudInView:self.view hint:@"正在上传语音..."];
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setValue:paraId forKey:paraN];
        [paramDic setValue:@([time integerValue]) forKey:@"voiceTime"];
        [paramDic setValue:resp[@"key"] forKey:@"key"];
        [paramDic setValue:@(1) forKey:@"type"];
        [AFRequest sendGetOrPostRequest:@"voice/insert_voice"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
        {
            [self hideHud];
            if ([data[@"code"] integerValue] == 0)
            {
                if (!_courseModel) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"voiceReplySuccess" object:nil];
                }
                [self.navigationController popViewControllerAnimated:YES];
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
              [self showAlertViewWithTitle:@"网络出错"];
        }];
    } option:nil];
}
- (IBAction)clickBeginReword:(UIButton *)sender
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:_localFileName])//已经存在音频文件
    {
        if (_isRecording)//暂停录音
        {
            _labWarning.text = @"播放试听";
            [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_bac_pause"] forState:UIControlStateNormal];
            [_recordButton setImage:nil forState:UIControlStateNormal];

            [_myTimer invalidate];
            _myTimer = nil;
            self.isRecording = NO;
            _resetBtn.enabled = YES;
            [_resetBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
            _resetBtn.layer.borderColor = kColorMainBlue.CGColor;
           _sendBtn.backgroundColor = kColorMainBlue;
            
            //停止录音
            [_recorder stop];
            _recorder = nil;
            
            return;
        }
        if (!self.isPlaying)//开始播放
        {
            _labWarning.text = @"播放中";
            self.isPlaying = YES;
            _resetBtn.enabled = NO;
            _sendBtn.enabled = NO;
            [_resetBtn setTitleColor:UIColorFromRGB(0xd2d2d2) forState:UIControlStateNormal];
            _resetBtn.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
           _sendBtn.backgroundColor = UIColorFromRGB(0xd2d2d2);
            [_recordButton setImage:[UIImage imageNamed:@"btn_playing"] forState:UIControlStateNormal];
            [_recordButton setBackgroundImage:nil forState:UIControlStateNormal];
            //开始播放
            [_player play];
        }
        else//停止播放
        {
            _labWarning.text = @"播放试听";
            self.isPlaying = NO;
            [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_bac_pause"] forState:UIControlStateNormal];
            [_recordButton setImage:nil forState:UIControlStateNormal];
            _resetBtn.enabled = YES;
            _sendBtn.enabled = YES;
            [_resetBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
            _resetBtn.layer.borderColor = kColorMainBlue.CGColor;
           _sendBtn.backgroundColor = kColorMainBlue;
            //暂停播放
            [_player pause];
        }
        return;
    }
    else//不存在音频文件
    {
        if (!self.isRecording)//开始录音
        {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
//            UInt32 doChangeDefault = 1;
//            AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
            
            if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
                [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                    if (granted) {
                        
                        // 用户同意获取麦克风
                        //录制中，再次点击停止录制
                        //播放试听
                        //播放中
                        _labWarning.text = @"录制中，再次点击停止录制";
                        self.isRecording = YES;
                        _consoleLabel.hidden = NO;
                        _resetBtn.enabled = NO;
                        _sendBtn.enabled = NO;
                        [_resetBtn setTitleColor:UIColorFromRGB(0xd2d2d2) forState:UIControlStateNormal];
                        _resetBtn.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
                        _sendBtn.backgroundColor = UIColorFromRGB(0xd2d2d2);
                        [_recordButton setImage:[UIImage imageNamed:@"btn_playing"] forState:UIControlStateNormal];
                        [_recordButton setBackgroundImage:nil forState:UIControlStateNormal];
                        //倒计时
                        _myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginCountDown) userInfo:nil repeats:YES];

                        //LinearPCM 是iOS的一种无损编码格式,但是体积较为庞大
                        //录音设置
                        NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
                        //录音格式 无法使用
                        [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
                        //采样率
                        [recordSettings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
                        //通道数
                        [recordSettings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
                        //线性采样位数
                        //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];  
                        //音频质量,采样质量  
                        [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
                        //开始录音,将所获取到的录音存到文件里
                        
                        NSError *recErr;
                        NSURL *recoUrl = [NSURL URLWithString:_localFileName];
                        self.recorder = [[AVAudioRecorder alloc] initWithURL:recoUrl settings:recordSettings error:&recErr];
            
//                        [self.recorder peakPowerForChannel:0];//获取分贝
                        self.recorder.delegate = self;
                        NSLog(@"录音的路径：%@, url:%@", _localFileName, recoUrl);
                        //准备记录录音
                        [_recorder prepareToRecord];
                        //启动或者回复记录的录音文件
                        [_recorder record];
                        _player = nil;
                    }
                    else
                    {
                        [self showAlertViewWithTitle:@"请到【设置】-【隐私】-【麦克风】中允许访问"];
                    }
                }];  
            }
        }
        else//暂停录音
        {
            _labWarning.text = @"播放试听";
            [_myTimer invalidate];
            _myTimer = nil;
            self.isRecording = NO;
            _resetBtn.enabled = YES;
            [_resetBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
            _resetBtn.layer.borderColor = kColorMainBlue.CGColor;
           _sendBtn.backgroundColor = kColorMainBlue;
            
            //停止录音
            [_recorder stop];
            _recorder = nil;
        }
    }
}
#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            CGRect screen = [UIScreen mainScreen].bounds;
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 5;
            CGFloat height = [_sameModel.text heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
            return 100 + height + 10;
        }
            break;
        case 1:
            return 400;
            break;
        default:
            return 0;
            break;
    }
}
@end
