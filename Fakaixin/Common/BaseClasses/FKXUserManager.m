//
//  FKXUserManager.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/23.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXUserManager.h"
#import "AppDelegate.h"

#define kCurrentUserId @"kCurrentUserId"
#define kCurrentUserToken @"kCurrentUserToken"
#define kDeviceTokenString @"kDeviceTokenString"
#define kDeviceTokenData @"kDeviceTokenData"

#define kCurrentUserPattern @"kCurrentUserPattern"

@implementation FKXUserManager

+ (instancetype)shareInstance {
    
    static FKXUserManager *singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[FKXUserManager alloc] init];
    });
    return singleton;
}

#pragma mark - 用户相关
-(NSString *)inviteCode
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults stringForKey:@"inviteCode"];
}
-(void)setInviteCode:(NSString *)inviteCode
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:inviteCode  forKey:@"inviteCode"];
    [userDefaults synchronize];
}
-(NSString *)currentUserPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults stringForKey:@"CurrentUserPassword"];
}
-(void)setCurrentUserPassword:(NSString *)currentUserPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:currentUserPassword  forKey:@"CurrentUserPassword"];
    [userDefaults synchronize];
}

+(BOOL)isUserPattern
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    NSString *pattern = [userDefaults stringForKey:kCurrentUserPattern];
    
    return [pattern isEqualToString:@"userPattern"] ? YES : NO;
}
+(void)setUserPatternToUser
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:@"userPattern"  forKey:kCurrentUserPattern];
    [userDefaults synchronize];
}
+(void)setUserPatternToListener
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:@"listenerPattern"  forKey:kCurrentUserPattern];
    [userDefaults synchronize];
}
+(FKXUserInfoModel *)getUserInfoModel
{
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserId];
    if (uid) {
       return [self unarchiverUserInfoByUid:uid];
    }
    return nil;
}
+(BOOL)needShowLoginVC
{
    FKXUserManager *userMan = [FKXUserManager shareInstance];
    return ![userMan isLogin];
}
- (BOOL)isLogin
{
    BOOL isL = self.currentUserId > 0 ? YES:NO;
    return isL;
}
-(NSInteger)currentUserId
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    NSInteger num = [userDefaults integerForKey:kCurrentUserId];
    return num;
}
-(void)setCurrentUserId:(NSInteger)currentUserId
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setInteger:currentUserId  forKey:kCurrentUserId];
    [userDefaults synchronize];
}

-(NSString *)currentUserToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults stringForKey:kCurrentUserToken]?[userDefaults stringForKey:kCurrentUserToken]:@"";
}
-(void)setCurrentUserToken:(NSString *)currentUserToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:currentUserToken  forKey:kCurrentUserToken];
    [userDefaults synchronize];
}
-(NSString<Optional> *)deviceTokenString
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults stringForKey:kDeviceTokenString];
}
-(void)setDeviceTokenString:(NSString<Optional> *)deviceTokenString
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:deviceTokenString  forKey:kDeviceTokenString];
    [userDefaults synchronize];
}
-(NSData<Optional> *)deviceTokenData
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults dataForKey:kDeviceTokenData];
}
-(void)setDeviceTokenData:(NSData<Optional> *)deviceTokenData
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:deviceTokenData  forKey:kDeviceTokenData];
    [userDefaults synchronize];
}
-(NSNumber *)noReadOrder
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults objectForKey:@"noReadOrder"];
}
-(void)setNoReadOrder:(NSNumber *)noReadOrder
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:noReadOrder  forKey:@"noReadOrder"];
    [userDefaults synchronize];
}
-(NSNumber *)unreadRelMe
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults objectForKey:@"unreadRelMe"];
}
-(void)setUnreadRelMe:(NSNumber *)unreadRelMe
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:unreadRelMe  forKey:@"unreadRelMe"];
    [userDefaults synchronize];
}
-(NSNumber *)unAcceptOrderTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults objectForKey:@"unAcceptOrderTime"];
}
-(void)setUnAcceptOrderTime:(NSNumber *)unAcceptOrderTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:unAcceptOrderTime  forKey:@"unAcceptOrderTime"];
    [userDefaults synchronize];
}
-(NSNumber *)unReadNotification
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults objectForKey:@"unReadNotification"];
}
-(void)setUnReadNotification:(NSNumber *)unReadNotification
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:unReadNotification  forKey:@"unReadNotification"];
    [userDefaults synchronize];
}
-(NSNumber *)unReadEaseMobMessage
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    return [userDefaults objectForKey:@"unReadEaseMobMessage"];
}
-(void)setUnReadEaseMobMessage:(NSNumber *)unReadEaseMobMessage
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults setObject:unReadEaseMobMessage  forKey:@"unReadEaseMobMessage"];
    [userDefaults synchronize];
}
+ (void)userLogout
{
    NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
    [userDefaults removeObjectForKey:kCurrentUserId];
    [userDefaults removeObjectForKey:kCurrentUserToken];
    [userDefaults removeObjectForKey:@"noReadOrder"];
    [userDefaults removeObjectForKey:@"inviteCode"];
    [userDefaults synchronize];
}
//+(void)updateUserInfoAndSaveByUid:(NSString *)Uid
//                           object:(id)object
//{
//    NSString *filePath = [[self getPathOfDocument] stringByAppendingPathComponent:Uid];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:filePath]) {
//        NSError *error;
//        BOOL isSuccess = [fileManager removeItemAtPath:filePath error:&error];
//        if (isSuccess) {
//            NSMutableData *data = [NSMutableData data];
//            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//            [archiver encodeObject:object forKey:Uid];
//            [archiver finishEncoding];
//            [data writeToFile:filePath atomically:YES];
//        }else
//        {
//            hudWithStr([NSString stringWithFormat:@"removeItemAtPath failed:%@", error.description]);
//
//        }
//    }else
//    {
//        hudWithStr(@"请先保存此文件,再更新");
//    }
//}

+(void)archiverUserInfo:(id)object
                  toUid:(NSString *)Uid
{
    NSString *filePath = [[self getPathOfDocument] stringByAppendingPathComponent:Uid];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *err;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
    }
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:object forKey:Uid];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
}

+(id)unarchiverUserInfoByUid:(NSString *)Uid
{
    NSString *filePath = [[self getPathOfDocument] stringByAppendingPathComponent:Uid];
    
    //从文件中读出personData
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id object = [unarchiver  decodeObjectForKey:Uid];
    [unarchiver finishDecoding];
    
    return object;
}
/**
 *  获取document路径
 *
 *  @return
 */
+(NSString *)getPathOfDocument
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
#pragma mark - 记录接收方用户的信息
+(void)addExtMessageWithEMMessage:(EMMessage *)message
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:message.ext];
    [dic setObject:message.from forKey:@"uid"];
    NSMutableArray *array = [self arrayOfAllExtMessage];
    for (NSDictionary *dictionary in array)
    {
        if ([dictionary[@"uid"] isEqualToString:message.from])
        {
            [array removeObject:dictionary];
            break;
        }
    }
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [array addObject:dic];
    
    [archiver encodeObject:array forKey:@"arrayOfAllExtMessage"];
    
    [archiver finishEncoding];
    
    //找到存储路径,存起来
    NSString * dicFilePath = [[self getPathOfDocument] stringByAppendingPathComponent:@"AllExtMessage"];
    //将data写入磁盘
    
    BOOL isSuccess = [data writeToFile:dicFilePath atomically:YES];
    if (!isSuccess) {
        NSLog(@"写入拓展消息文件错误");
    }else
    {
        NSLog(@"拓展消息文件路径:%@", dicFilePath);
    }
}
+(NSMutableArray *)arrayOfAllExtMessage
{
    NSData *data = [NSData dataWithContentsOfFile:[[self getPathOfDocument] stringByAppendingPathComponent:@"AllExtMessage"]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSMutableArray *array = [unarchiver  decodeObjectForKey:@"arrayOfAllExtMessage"];
    
    [unarchiver finishDecoding];
    if (!array) {
        return [NSMutableArray array];
    }
    return array;
}
+(NSMutableDictionary *)getExtMessageByUid:(NSString *)Uid
{
    NSMutableArray *array = [self arrayOfAllExtMessage];
    for (NSMutableDictionary *dic in array)
    {
        if ([dic[@"uid"] isEqualToString:Uid])
        {
            return dic;
        }
    }
    return nil;
}
#pragma mark - 用户指引
+ (void)showUserGuideWithKey:(NSString *)key withTarget:(id)target action:(SEL)action
{
    NSString *versionKey = [NSString stringWithFormat:@"%@%@",key, AppVersionBuild];
    if (![[NSUserDefaults standardUserDefaults] stringForKey:versionKey]) {
      
        NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
        [userDefaults setObject:versionKey forKey:versionKey];
        [userDefaults synchronize];

        // 这里判断是否第一次
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        imageView.image = [UIImage imageNamed:key];
        imageView.contentMode = UIViewContentModeScaleToFill;
        [ApplicationDelegate.window addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
        [imageView addGestureRecognizer:tap];
    }
}
+ (void)showUserGuideWithKey:(NSString *)key
{
    NSString *versionKey = [NSString stringWithFormat:@"%@%@",key, AppVersionBuild];

    if (![[NSUserDefaults standardUserDefaults] stringForKey:versionKey]) {

        NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
        [userDefaults setObject:versionKey forKey:versionKey];
        [userDefaults synchronize];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        imageView.image = [UIImage imageNamed:key];
        imageView.contentMode = UIViewContentModeScaleToFill;
        [ApplicationDelegate.window addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(windowHiddenGuide:)];
        [imageView addGestureRecognizer:tap];
    }
    
}
+ (void)windowHiddenGuide:(UITapGestureRecognizer *)tap
{
    [tap.view removeFromSuperview];
}


- (NSArray *)caluteHeight:(FKXUserInfoModel *)model {
    NSString *name = model.name;

    if (!model.name) {
        name = model.nickname;
    }
    NSString *profile = model.profile;
    NSString *cureCount = [model.cureCount stringValue];
    
    NSString *goodStr = @"";
    NSArray *goodAt = model.goodAt;
    //婚恋出轨   失恋阴影  夫妻相处  婆媳关系
    for (int i=0; i<goodAt.count; i++) {
        NSString *str = @"";
        if (i==0) {
            if ([goodAt[i] integerValue]==0) {
                str = @"婚恋出轨";
            }else if ([goodAt[i] integerValue]==1) {
                str = @"失恋阴影";
            }else if ([goodAt[i] integerValue]==2) {
                str = @"夫妻相处";
            }else if ([goodAt[i] integerValue]==3) {
                str = @"婆媳关系";
            }
            
        }else{
            if ([goodAt[i] integerValue]==0) {
                str = [NSString stringWithFormat:@"、%@",@"婚恋出轨"];
            }else if ([goodAt[i] integerValue]==1) {
                str = [NSString stringWithFormat:@"、%@",@"失恋阴影"];
            }else if ([goodAt[i] integerValue]==2) {
                str = [NSString stringWithFormat:@"、%@",@"夫妻相处"];
            }else if ([goodAt[i] integerValue]==3) {
                str = [NSString stringWithFormat:@"、%@",@"婆媳关系"];
            }
        }
        goodStr = [goodStr stringByAppendingString:str];
    }
    
    NSString *introStr = [NSString stringWithFormat:@"你好，我是%@ 心理咨询专家，资深婚恋情感咨询师,%@。 擅长%@类的问题，已经在伐开心中成功治愈了%@人，在这里聆听解决你的烦恼，给出中肯的建议",name,profile,goodStr,cureCount];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 20)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:15];
    label.text = introStr;
    [label sizeToFit];
    
    CGFloat height = CGRectGetHeight(label.frame);
    //    CGSize titleSize = [label boundingRectWithSize:CGSizeMake(170, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    //    NSLog(@"%f",tit)
    //    NSLog(@"%f",height);
//    self.headerH = height+250;
//    self.introStr = introStr;
    CGFloat headerH = 250+height;
    return @[introStr,@(headerH)];
}


@end
