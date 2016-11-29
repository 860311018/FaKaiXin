//
//  FKXPublishMindViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPublishMindViewController.h"
#import "FKXCustomKeyboardUp.h"
#import <QiniuSDK.h>
#import "UITextView+Placeholder.h"
#import "FKXGetMoreLoveValueVC.h"

#define ImageSize 1024 * 500
#define kImageW 60
#define kImageHM 10 //图片的水平margin
#define kCusKeyBorH 180 //自定义视图的高

#define Screen  [UIScreen mainScreen].bounds.size

@interface FKXPublishMindViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
{
    FKXCustomKeyboardUp *customKeyB;
    UIImage *imageSelected;
    
    UIView *transparentView;//删除图片透明视图
//    UIView *transViewRed;   //红包计划的透明图
    UIView *chooseTypeView;     //选择心事类型的视图

    NSMutableArray *imagesArr;
    NSMutableArray *imagesNamesArr;
    NSMutableDictionary *nameAndImage;  //存放图片和名字的对应关系
    UIImageView *imageToDelete;
    
    CGFloat keyboardHeight;
    NSInteger selectedType;
}
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIImageView *myCardBackground;

@end

@implementation FKXPublishMindViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_myTextView becomeFirstResponder];
    //基本赋值
    imagesArr = [NSMutableArray arrayWithCapacity:1];
    imagesNamesArr = [NSMutableArray arrayWithCapacity:1];
    nameAndImage = [NSMutableDictionary dictionaryWithCapacity:1];
    _myTextView.placeholder = @"描述困扰你的烦恼，得到咨询师的语音回复，获得更好地解决和安抚（不少于40个字）";
    //ui赋值
    _myTextView.textContainerInset = UIEdgeInsetsMake(35, 12, 15, 12);
    self.view.backgroundColor = kColor_MainBackground();
    self.navTitle = @"倾诉";
    
    //子视图
    [self setUpBarButton];
    [self setUpChooseTypeView];

    //加载背景卡片
    [self loadInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}

#pragma mark - 子视图
- (void)setUpBarButton
{
    UIImage *consultImage = [UIImage imageNamed:@"back"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
    [btn setBackgroundImage:consultImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *sendB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 18)];
    [sendB setTitle:@"发送" forState:UIControlStateNormal];
    sendB.titleLabel.font = [UIFont systemFontOfSize:17];
    [sendB setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    [sendB addTarget:self action:@selector(sendMind) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendB];
}
- (void)dismissSelf
{
    [_myTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)not
{
    customKeyB.btnType.selected = NO;
    [customKeyB.btnType setImage:[UIImage imageNamed:@"btn_arrows_up"] forState:UIControlStateNormal];
    
    NSValue * value = [not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize size = [value CGRectValue].size;
    keyboardHeight = size.height;
    [UIView animateWithDuration:0.5 animations:^{
        chooseTypeView.frame = CGRectMake(0, self.view.height - kCusKeyBorH  - size.height, self.view.width, 400);
        CGRect frame = _myTextView.frame;
        frame.size.height = chooseTypeView.top - _myTextView.top;
        _myTextView.frame = frame;
    }];
}
//- (void)keyboardWillHide:(NSNotification *)not
//{
//    [UIView animateWithDuration:0.2 animations:^{
////        customKeyB.frame = CGRectMake(0, self.view.height - kCusKeyBorH , self.view.width, kCusKeyBorH);
//        CGRect frame = _myTextView.frame;
//        frame.size.height = chooseTypeView.top;
//        _myTextView.frame = frame;
//    }];
//}
#pragma mark - 自定义键盘
- (void)setUpChooseTypeView
{
    if (!chooseTypeView) {
        chooseTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - kCusKeyBorH - 64, self.view.width, 400)];
        chooseTypeView.backgroundColor = kColorBackgroundGray;
        [self.view addSubview:chooseTypeView];
        
        customKeyB = [[[NSBundle mainBundle] loadNibNamed:@"FKXCustomKeyboardUp" owner:nil options:nil] firstObject];
        customKeyB.myScrollview.contentSize = customKeyB.myScrollview.size;
        customKeyB.frame = CGRectMake(0, 0, chooseTypeView.width, kCusKeyBorH);
        [customKeyB.photoBtn addTarget:self action:@selector(clickPhoto) forControlEvents:UIControlEventTouchUpInside];
        [customKeyB.btnType addTarget:self action:@selector(clickMindType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseTypeView addSubview:customKeyB];
        
        [customKeyB.btnType setTitle:@"出轨" forState:UIControlStateNormal];
        
        NSArray *arr = @[
                         @"婚恋出轨",
                         @"失恋阴影",
                         @"夫妻相处",
                         @"婆媳关系"
                         ];//3,5,2,4,0,1
        CGFloat btnW = 82;
        CGFloat btnH = 30;
        CGFloat margin = 30;
        CGFloat y = 15 + kCusKeyBorH;//64
        for (int i = 0; i < arr.count; i++) {
            if (i == 3) {
                y += 20 + btnH;
            }
            //g按钮
            UIButton * gBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            gBtn.frame = CGRectMake((chooseTypeView.width - margin*2 - btnW*3)/2 + (btnW + margin)*(i%3), y, btnW, btnH);
            gBtn.backgroundColor = kColorBackgroundGray;
            gBtn.tag = 100 + i;
            gBtn.layer.borderWidth = 1.0;
            gBtn.layer.cornerRadius = 5;
            [gBtn setTitle:arr[i] forState:UIControlStateNormal];
            gBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            gBtn.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
            [gBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
            
            [gBtn addTarget:self action:@selector(clickedType:) forControlEvents:UIControlEventTouchUpInside];
            [chooseTypeView addSubview:gBtn];
        }
    }
}
- (void)clickMindType:(UIButton *)btn
{
    if ([_myTextView isFirstResponder]) {
        [_myTextView resignFirstResponder];
        return;
    }else{
        btn.selected = !btn.selected;
        if (!btn.selected) {
            [btn setImage:[UIImage imageNamed:@"btn_arrows_up"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5 animations:^{
                chooseTypeView.frame = CGRectMake(0, self.view.height - kCusKeyBorH  - keyboardHeight, self.view.width, 400);
                CGRect frame = _myTextView.frame;
                frame.size.height = chooseTypeView.top - _myTextView.top;
                _myTextView.frame = frame;
            }];
        }else{
            [btn setImage:[UIImage imageNamed:@"btn_arrows_down"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5 animations:^{
                chooseTypeView.frame = CGRectMake(0, self.view.height - kCusKeyBorH , self.view.width, 400);
                CGRect frame = _myTextView.frame;
                frame.size.height = chooseTypeView.top - _myTextView.top;
                _myTextView.frame = frame;
            }];
        }
    }
}
- (void)clickedType:(UIButton *)btn
{
    [customKeyB.btnType setImage:[UIImage imageNamed:@"btn_arrows_down"] forState:UIControlStateNormal];
    customKeyB.btnType.selected = YES;
    [UIView animateWithDuration:0.5 animations:^{
        chooseTypeView.frame = CGRectMake(0, self.view.height - kCusKeyBorH , self.view.width, 400);
        CGRect frame = _myTextView.frame;
        frame.size.height = chooseTypeView.top - _myTextView.top;
        _myTextView.frame = frame;
    }];
    selectedType = btn.tag - 100;
    [customKeyB.btnType setTitle:[btn.titleLabel.text substringToIndex:2] forState:UIControlStateNormal];
}
#pragma mark   UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001)
    {
        UIImagePickerControllerSourceType type;
        if (buttonIndex == 2)
        {
            return;
        }
        switch (buttonIndex)
        {
            case 0:
                type=UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                type=UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            default:
                type=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
        }
        
        if (![UIImagePickerController isSourceTypeAvailable:type] )
        {
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"抱歉，您的设备不支持" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        UIImagePickerController * pickerController=[[UIImagePickerController alloc]init];
        pickerController.sourceType=type;
        pickerController.delegate=self;
        pickerController.allowsEditing = NO;
        [self presentViewController:pickerController animated:YES completion:nil];
        
    }
}
#pragma mark  UIImagePickerControllerDelegate

//拍摄取消按钮点击
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//拍照完毕后或者照片选择完毕后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_myTextView resignFirstResponder];
    
    UIImage * originalImage=[info  objectForKey:UIImagePickerControllerOriginalImage];
    imageSelected = originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:
     ^{
         
         NSData * originaData = UIImageJPEGRepresentation(originalImage,0.7);
         
         UIImage *image;
         if (originaData.length > ImageSize)
         {
             image = [self reduceImage:originalImage toSize:CGSizeMake(originalImage.size.width * 0.9, originalImage.size.height * 0.9)];
             originaData = UIImageJPEGRepresentation(image,0.9);
         }
         
         [self sendIcon:originaData];
     }];
}
#pragma mark *** 裁剪图片
-(UIImage *)reduceImage:(UIImage *)image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData * data = UIImageJPEGRepresentation(newImage, 0.9);
    if (data.length > ImageSize)
    {
        [self reduceImage:newImage toSize:CGSizeMake(newImage.size.width * 0.9, newImage.size.height * 0.9)];
    }
    
    return newImage;
}
#pragma mark - 网络请求部分
- (void)loadInfo
{
    NSDictionary *paramDic = @{
                               @"uid" : @([FKXUserManager shareInstance].currentUserId)};
    [AFRequest sendGetOrPostRequest:@"loveMarket/own"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             NSString *back = data[@"data"][@"checkedBackground"];
             if (back.length) {
                 _myCardBackground.hidden = NO;
                 [_myCardBackground sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageBaseUrl, back]]];
             }else{
                 _myCardBackground.hidden = YES;
             }
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }
         else if ([data[@"code"] integerValue] == 11)
         {
             [self dismissViewControllerAnimated:YES completion:^{
                 //支付爱心值或者分享朋友圈
                 UIAlertController *alV = [UIAlertController alertControllerWithTitle:@"您的爱心值不足" message:nil preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"去获得爱心值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           FKXGetMoreLoveValueVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXGetMoreLoveValueVC"];
                                           vc.hidesBottomBarWhenPushed = YES;
                                           SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
                                           [tab.viewControllers[0] pushViewController:vc animated:YES];
                                       }];
                 [alV addAction:ac1];
                 SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
                 tab.selectedIndex = 0;
                 FKXBaseNavigationController *nav = tab.viewControllers[0];
                 [[nav viewControllers][0] presentViewController:alV animated:YES completion:nil];
             }];
         }
         
         else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
//发送心事
- (void)sendMind
{
    [_myTextView resignFirstResponder];
    NSString *text = [_myTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *tex = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (tex.length < 40)
    {
        [self showHint:@"请说的再详细些哦~"];
        return;
    }else if (tex.length > 500)
    {
        [self showHint:@"字数超出500字了哦~"];
        return;
    }
    
    [self showHudInView:self.view hint:@"正在发布..."];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSDictionary *paramDic = @{
                               @"type" : @(selectedType),
                               @"text":_myTextView.text,
                               @"isPublic":@(customKeyB.mySwitch.on ? 0 : 1),
                               @"imageArray":imagesNamesArr};
    [AFRequest sendGetOrPostRequest:@"worry/add"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:data[@"data"][@"alert"]];
             [self dismissViewControllerAnimated:YES completion:nil];
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }
         else if ([data[@"code"] integerValue] == 11)
         {
             [self dismissViewControllerAnimated:YES completion:^{
                 //支付爱心值或者分享朋友圈
                 UIAlertController *alV = [UIAlertController alertControllerWithTitle:@"您的爱心值不足" message:nil preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"去获得爱心值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           FKXGetMoreLoveValueVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXGetMoreLoveValueVC"];
                                           vc.hidesBottomBarWhenPushed = YES;
                                           SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
                                           [tab.viewControllers[0] pushViewController:vc animated:YES];
                                       }];
                 [alV addAction:ac1];
                 SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
                 tab.selectedIndex = 0;
                 FKXBaseNavigationController *nav = tab.viewControllers[0];
                 [[nav viewControllers][0] presentViewController:alV animated:YES completion:nil];
             }];
         }
         
         else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
#pragma mark 图片处理
- (void)clickPhoto
{
    [_myTextView resignFirstResponder];
    if (imagesNamesArr.count >= 9) {
        [self showHint:@"最多可上传9张"];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从手机相册中选择", nil];
    actionSheet.tag = 1001;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
//上传图片
- (void)sendIcon:(NSData *)dataImage
{
    __block  NSString *token = @"";
    [self showHudInView:self.view hint:@"正在上传"];

    NSDictionary *paramDic = @{};
    
    [AFRequest sendGetOrPostRequest:@"user/upload_image"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             token = data[@"data"][@"token"];
             [self uploadIconByData:dataImage token:token];

         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
         
         
     } failure:^(NSError *error) {
         [self showAlertViewWithTitle:@"网络出错"];
         [self hideHud];
     }];
}
- (void)uploadIconByData:(NSData *)data token:(NSString *)token
{
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putData:data key:nil token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  
                  NSLog(@"七牛上传图片info:%@", info);
                  NSLog(@"七牛上传图片resp:%@", resp);
                  if (resp[@"hash"])
                  {
                      customKeyB.labRemind.hidden = YES;
                      [_myTextView resignFirstResponder];
                      [self showHint:@"上传成功" yOffset:-160];
                      [imagesArr addObject:imageSelected];
                      [imagesNamesArr addObject:resp[@"hash"]];
                      [nameAndImage setObject:imageSelected forKey:resp[@"hash"]];
                      [self refreshScrollView];
                  }
                  
              } option:nil];
}
- (void)refreshScrollView
{
    [customKeyB.myScrollview removeAllSubviews];
    for (int i = 0; i < imagesArr.count; i++)
    {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(16 + (kImageW + 10)*i, 0, kImageW, kImageW)];
        image.image = imagesArr[i];
        image.userInteractionEnabled = YES;
        [image addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];

        [customKeyB.myScrollview addSubview:image];
    }
    CGSize size = CGSizeZero;
    CGPoint point = CGPointZero;
    CGFloat distance = imagesArr.count*(kImageW+kImageHM) - customKeyB.myScrollview.width;
    if (distance > 0)
    {
        size = CGSizeMake(imagesArr.count*(kImageW+kImageHM), customKeyB.myScrollview.height);
        point = CGPointMake(customKeyB.myScrollview.width / 2 + distance, 0);
    }
    
    customKeyB.myScrollview.contentSize = size;
    [customKeyB.myScrollview setContentOffset:point animated:YES];
}
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    UIImageView *image = (UIImageView *)tap.view;
    imageToDelete = image;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transparentView) {
        //透明背景
        transparentView = [[UIView alloc] initWithFrame:screenBounds];
        transparentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        transparentView.alpha = 0.0;
        [transparentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTransparentView)]];
        [[UIApplication sharedApplication].keyWindow addSubview:transparentView];
        //加image
        UIImageView *newI = [[UIImageView alloc] initWithFrame:CGRectMake(0, 120, Screen.width,Screen.height-120)];
        CGFloat scale = image.image.size.width/image.image.size.height;
        
        if (scale<(Screen.width/(Screen.height-120))) {
            newI.frame = CGRectMake(0, 120, scale*(Screen.height-120), Screen.height-120);
            [newI setContentMode:UIViewContentModeScaleAspectFit];

        }else {
            [newI setContentMode:UIViewContentModeScaleAspectFit];
        }
        newI.image = image.image;
        newI.center = transparentView.center;
        [transparentView addSubview:newI];
        
        //加删除按钮
        UIImage *image = [UIImage imageNamed:@"file_delete_icon"];
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.tag = 200;
        closeBtn.frame = CGRectMake(transparentView.width - 50, 30, image.size.width, image.size.height);
        [closeBtn setBackgroundImage:image forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [transparentView addSubview:closeBtn];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        transparentView.alpha = 1.0;
    }];
}
- (void)deleteImage:(UIButton *)btn
{
    [imagesArr removeObject:imageToDelete.image];
    for (NSString *key in [nameAndImage allKeys])
    {
        if ([imageToDelete.image isEqual:nameAndImage[key]])
        {
            [nameAndImage removeObjectForKey:key];
            break;
        }
    }
    [self hiddenTransparentView];
    [self refreshScrollView];
}
- (void)hiddenTransparentView
{
    [UIView animateWithDuration:0.1 animations:^{
        transparentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transparentView removeFromSuperview];
        transparentView = nil;
    }];
}

#pragma mark - textViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}
@end
