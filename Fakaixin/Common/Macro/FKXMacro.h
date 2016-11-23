//
//  Macro.h
//  FengMi
//
//  Created by Connor on 3/11/15.
//  Copyright (c) 2015 FengMi. All rights reserved.
//

#ifndef FengMi_Macro_h
#define FengMi_Macro_h

//Color
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBLOG(RGBValue) NSLog(@"%f %f %f",((float)((RGBValue & 0xFF0000) >> 16)),((float)((RGBValue & 0xFF00) >> 8)),((float)(RGBValue & 0xFF)))
////主灰
#define kColorBackgroundGray  UIColorFromRGB(0xf7f7f7)
//主蓝色
#define kColorMainBlue  UIColorFromRGB(0x51b5ff)
//主红色
#define kColorMainRed  UIColorFromRGB(0xfe9595)
//主长割线色
#define kColorMainLongLine  UIColorFromRGB(0xd2d2d2)

#pragma mark -
#pragma mark - Devices functions

#define iOS8_OR_HIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define iOS7_OR_HIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)


#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)



//屏幕的高
#define CURRENTHEIGHT   ([UIScreen mainScreen].bounds.size.height)
//屏幕的宽
#define CURRENTWIDTH    ([UIScreen mainScreen].bounds.size.width)

#define SYSTEM_DPI      (CURRENTHEIGHT == 736 ? 3 : 2)
//用于计算
#define DEVICE_MULT (CURRENTWIDTH > 375 ? 1.5:1)

#define kPAGE_SPACING   8

#define DIVIDER_LINE     1

//Reset API
#define ResetAppId   @"c369cfe9148a40b998323b8e4d00d902"

#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

#define iOS_Version [UIDevice currentDevice].systemVersion
#define isFisrtLaunch [[NSUserDefaults standardUserDefaults] boolForKey:@"alreadyFirstLaunch"]
#define isQPOSUser !IS_NULL_STRING([QFUser shared].session)

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kStatusBarHeight 20.0f
#define kNavigationBarHeight 44.0f

#define kLeftSpaceWidth 13.f

#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])


#pragma mark -
#pragma mark Common Define

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define AppVersionShort [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define AppVersionBuild [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define AppVersion      [NSString stringWithFormat:@"%@.%@",AppVersionShort,AppVersionBuild]

#define Device  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"iPad":@"iPhone"

#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]

#define ImageFromRAM(_pointer) [UIImage imageNamed:_pointer]
#define ImageFromFile(_pointer) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:_pointer ofType:nil]]


#define GCDBACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define GCDMAIN(block) dispatch_async(dispatch_get_main_queue(),block)
#define GCDAFTER(time,block) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((time) * NSEC_PER_SEC)), dispatch_get_main_queue(),(block))


#define KXHGridItemWidth (145.0 * 1)

#define kXHLargeGridItemPadding 10

#define kXHScreen [[UIScreen mainScreen] bounds]
#define kXHScreenWidth CGRectGetWidth(kXHScreen)

#define XH_CELL_IDENTIFIER @"XHWaterfallCell"

#define XH_CELL_COUNT 12

//我的财富--我的爱心值Tag  100~105
#define myLoveTag     100


// device verson float value
#define CURRENT_SYS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// iPad
#define kIsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// image STRETCH
#define XH_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])

//Documents Path
#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

//kit width
#define AdaptWidth(__width) (__width/320.f)*kScreenWidth
#define AdaptHeight(__height) (__height/568.f)*kScreenHeight


#define kNotNameSomeOneCare @"kNotNameSomeOneCare"

#ifdef DEBUG
#define NER_App_Push_Type_Company @"301"
#else
#define NER_App_Push_Type_Company @"312"
#endif

#endif
