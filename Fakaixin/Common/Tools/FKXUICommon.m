//
//  FMIUICommon.m
//  FengMi
//
//  Created by tian.liang on 15/3/19.
//  Copyright (c) 2015年 FengMi. All rights reserved.
//

#import "FKXUICommon.h"
#import "UIDeviceHardware.h"
#import "MBProgressHUD.h"
@interface FMIProgressHUD :MBProgressHUD
@end
@implementation FMIProgressHUD

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
    
}
@end
@implementation FKXUICommon
UIImage *imageWithColorAndSize(UIColor *color,CGSize size){
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0];
    path.lineWidth = 0;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


/** 快速UIAlertView*/
void QFAlert(NSString *title, NSString *msg, NSString *buttonText){
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:nil
                                     cancelButtonTitle:buttonText
                                     otherButtonTitles:nil];
    [av show];
}
/*
UIView *FMIAddBotttomAtViewAndEdgeInsets(UIView *view,UIEdgeInsets edge){
    UIView *line = [UIView new];
    line.backgroundColor = kColor_LightGray();
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5f);
        make.bottom.equalTo(view.mas_bottom).offset(edge.bottom);
        make.left.equalTo(view.mas_left).offset(edge.left);
        make.right.equalTo(view.mas_right).offset(edge.right);;
    }];
    return line;
}
*/
void hudWithStr(NSString *str){
//   MBProgressHUD *hud = [[FMIProgressHUD alloc] initWithView:[[UIApplication sharedApplication].delegate window]];
    
//    [[[UIApplication sharedApplication].delegate window] addSubview:hud];
    MBProgressHUD *hud = [FMIProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] lastObject] animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = str;
    hud.detailsLabelFont = kFont_F2();
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.color = kColor_MidGray();
    [hud hide:YES afterDelay:1.f];
//    [hud show:YES];
}


BOOL iphone6P(){
    return [[UIDeviceHardware platform] isEqualToString:@"iPhone7,1"];
}
BOOL iphone6(){
    return [[UIDeviceHardware platform] isEqualToString:@"iPhone7,2"];
}



/**
 *  /////////////////////////////////////////////////    Weidian Color   ///////////////////////////////////////////////////////////
 */
UIColor *WDColorRGB(NSInteger r,NSInteger g,NSInteger b, CGFloat a){
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a];
}
UIColor *WDColorRGBString(NSString* str){
    NSArray *array = [str componentsSeparatedByString:@"/"];
    NSCAssert(array.count ==3,@"array.count not legal");
    return WDColorRGB([array[0] integerValue], [array[1] integerValue], [array[2] integerValue], 1);
}

UIColor *kColor_Red(){
    return WDColorRGBString(@"255/83/89");
}
UIColor *kColor_Orange(){
    return WDColorRGBString(@"254/155/32");
}
UIColor *kColor_White(){
    return WDColorRGBString(@"255/255/255");
}
UIColor *kColor_Black(){
    return WDColorRGBString(@"47/50/58");
}
UIColor *kColor_MidBlack(){
    return WDColorRGBString(@"78/80/87");
}
UIColor *kColor_LightBlack(){
    return WDColorRGBString(@"96/100/112");
}
UIColor *kColor_Gray(){
    return WDColorRGBString(@"167/169/174");
}
UIColor *kColor_MidGray(){
    return WDColorRGBString(@"216/216/216");
}
UIColor *kColor_LightGray(){
    return WDColorRGBString(@"229/229/229");
}
UIColor *kColor_PrimaryBy(){
    return WDColorRGBString(@"239/239/239");
}
UIColor *kColor_SecondaryBy(){
    return WDColorRGBString(@"255/255/255");
}

UIColor *kColor_Aluminium(){
    return WDColorRGBString(@"138/140/146");
}
UIColor *kColor_WhiteSmoke(){
    return WDColorRGBString(@"248/248/248");
}
UIColor *kColor_LilyWhite(){
    return WDColorRGBString(@"235/235/235");
}

UIColor *kColor_Rosewood() {
    return WDColorRGBString(@"104/7/19");
}

UIColor *kColor_MainNavBarColor() {
    return WDColorRGBString(@"246/246/247");
}
UIColor *kColor_MainOrange() {//255, 142, 23
    return WDColorRGBString(@"255/142/23");
}
UIColor *kColor_MainDarkGray() {
    return WDColorRGBString(@"60/60/60");
}
UIColor *kColor_MainBlackFont() {
    return WDColorRGBString(@"51/51/51");
}
UIColor *kColor_MainGray() {
    return WDColorRGBString(@"90/90/90");
}
UIColor *kColor_MainLightGray() {
    return WDColorRGBString(@"152/152/152");
}
UIColor *kColor_MainRed() {
    return WDColorRGBString(@"255/70/100");
}
UIColor *kColor_MainRed_Bac() {
    return WDColorRGBString(@"254/149/149");
}
UIColor *kColor_MainBackground() {
    return WDColorRGBString(@"238/238/238");
}
UIColor *kColor_MainLongSeparate() {
    return WDColorRGBString(@"210/210/210");
}
UIColor *kColor_MainShortSeparate() {
    return WDColorRGBString(@"220/220/220");
}
/**
 *  /////////////////////////////////////////////////    Weidian Font   ///////////////////////////////////////////////////////////
 */
UIFont *WDFontSize(CGFloat size){
    return [UIFont systemFontOfSize:size];
}

UIFont *kFont_F1(){
    return WDFontSize(17.f);
}

UIFont *kFont_F2(){
    return WDFontSize(16.f);
}

UIFont *kFont_F3(){
    return WDFontSize(15.f);
}

UIFont *kFont_F4(){
    return WDFontSize(14.f);
}

UIFont *kFont_F5(){
    return WDFontSize(13.f);
}

UIFont *kFont_F6(){
    return WDFontSize(12.f);
}

UIFont *kFont_F7(){
    return WDFontSize(11.f);
}

UIFont *kFont_F8(){
    return WDFontSize(10.f);
}

@end
