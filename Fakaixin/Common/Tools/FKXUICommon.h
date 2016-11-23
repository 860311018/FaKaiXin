//
//  FMIUICommon.h
//  FengMi
//
//  Created by tian.liang on 15/3/19.
//  Copyright (c) 2015年 FengMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXUICommon : UIView

/**
 *  根据颜色生成图片
 *
 *  @param color 颜色
 *  @param size  大小
 *
 *  @return 图片
 */
UIImage *imageWithColorAndSize(UIColor *color,CGSize size);


/** 
 * 快速UIAlertView
 */
void QFAlert(NSString *title, NSString *msg, NSString *buttonText);

/**
 *  给view底部生成线
 *
 *  @param view targetView
 *  @param edge 偏移量
 *
 *  @return line (更改位置，mas_remakeConstraints);
 */
UIView *FMIAddBotttomAtViewAndEdgeInsets(UIView *view,UIEdgeInsets edge);

void hudWithStr(NSString *str);



BOOL iphone6P();
BOOL iphone6();




/**
 *  /////////////////////////////////////////////////    FM Color   ///////////////////////////////////////////////////////////
 */
UIColor *kColor_Red();

UIColor *kColor_Orange();

UIColor *kColor_White();

UIColor *kColor_Black();

UIColor *kColor_MidBlack();

UIColor *kColor_LightBlack();

UIColor *kColor_Gray();

UIColor *kColor_MidGray();

UIColor *kColor_LightGray();


UIColor *kColor_PrimaryBy();

UIColor *kColor_SecondaryBy();
UIColor *kColor_Aluminium();
UIColor *kColor_WhiteSmoke();
UIColor *kColor_LilyWhite();

UIColor *kColor_Rosewood();

UIColor *kColor_MainNavBarColor();
UIColor *kColor_MainOrange();
UIColor *kColor_MainDarkGray();
UIColor *kColor_MainBlackFont();
UIColor *kColor_MainGray();
UIColor *kColor_MainLightGray();
UIColor *kColor_MainRed();
UIColor *kColor_MainRed_Bac();
UIColor *kColor_MainBackground();
UIColor *kColor_MainLongSeparate();
UIColor *kColor_MainShortSeparate();
/**
 *  /////////////////////////////////////////////////    FM Font   ///////////////////////////////////////////////////////////
 */

UIFont *kFont_F1();

UIFont *kFont_F2();

UIFont *kFont_F3();

UIFont *kFont_F4();

UIFont *kFont_F5();

UIFont *kFont_F6();

UIFont *kFont_F7();

UIFont *kFont_F8();


@end
