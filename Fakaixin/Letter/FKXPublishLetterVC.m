//
//  FKXPublishLetterVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPublishLetterVC.h"
#import "FKXCustomKeyboardUp.h"
#import <QiniuSDK.h>
#import "UITextView+Placeholder.h"
#import "FKXGetMoreLoveValueVC.h"
#import "FKXPasteStamp.h"

#define ImageSize 1024 * 500
#define kImageW 60
#define kImageHM 10 //图片的水平margin
#define kCusKeyBorH 90 //自定义视图的高

#define Screen  [UIScreen mainScreen].bounds.size

@interface FKXPublishLetterVC ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
{
    FKXCustomKeyboardUp *customKeyB;
    UIImage *imageSelected;
    
    UIView *transparentView;//删除图片透明视图
    
    NSMutableArray *imagesArr;
    NSMutableArray *imagesNamesArr;
    NSMutableDictionary *nameAndImage;  //存放图片和名字的对应关系
    UIImageView *imageToDelete;
    
    CGFloat keyboardHeight;
}
@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@end

@implementation FKXPublishLetterVC
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_myTextView becomeFirstResponder];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *conten = [def objectForKey:@"myLetterContent"];
    if (conten) {
        _myTextView.text = conten;
    }
    //基本赋值
    imagesArr = [NSMutableArray arrayWithCapacity:1];
    imagesNamesArr = [NSMutableArray arrayWithCapacity:1];
    nameAndImage = [NSMutableDictionary dictionaryWithCapacity:1];
    _myTextView.placeholder = @"把你的经历和困扰以信件的形式写给伐开心我们将会以文章的形式整理并匿名发布听听大家怎么说的同时，咨询师也会在第二天回信给你专业的建议（为了保证内容的完整性，请不少于200字）";
    //ui赋值
    _myTextView.textContainerInset = UIEdgeInsetsMake(16, 10, 10, 18);
    self.navTitle = @"写信";
    
    //子视图
    [self setUpBarButton];
    [self setUpCustomKeyB];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}
#pragma mark - 子视图
- (void)setUpBarButton
{
    UIImage *consultImage = [UIImage imageNamed:@"back"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
    [btn setBackgroundImage:consultImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIView *rightV = [[UIView alloc] initWithFrame:CGRectMake(0,0,110,18)];
    
    
    UIButton *saveB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, rightV.height)];
    [saveB setTitle:@"保存" forState:UIControlStateNormal];
    saveB.titleLabel.font = [UIFont systemFontOfSize:15];
    [saveB setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    [saveB addTarget:self action:@selector(saveLetter) forControlEvents:UIControlEventTouchUpInside];
    [rightV addSubview:saveB];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(saveB.right + 12, 0, 1, rightV.height)];
    line.backgroundColor = kColorMainBlue;
    [rightV addSubview:line];
    UIButton *sendB = [[UIButton alloc] initWithFrame:CGRectMake(line.right + 12, 0, 50, rightV.height)];
    [sendB setTitle:@"下一步" forState:UIControlStateNormal];
    sendB.titleLabel.font = [UIFont systemFontOfSize:15];
    [sendB setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    [sendB addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [rightV addSubview:sendB];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightV];
}
- (void)saveLetter
{
    [_myTextView resignFirstResponder];
    NSString *text = [_myTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *tex = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (!tex.length)
    {
        [self showHint:@"请输入信件内容再保存"];
        return;
    }
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:_myTextView.text forKey:@"myLetterContent"];
    if ([def synchronize]) {
        [self showAlertViewWithTitle:@"已保存为草稿，下次写信自动填充此内容"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)dismissSelf
{
    [_myTextView resignFirstResponder];
    NSString *text = [_myTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *tex = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (tex.length)
    {
        UIAlertController *contro = [UIAlertController alertControllerWithTitle:nil message:@"是否保存为草稿？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ac = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:_myTextView.text forKey:@"myLetterContent"];
            if ([def synchronize]) {
                [self showAlertViewWithTitle:@"已保存为草稿，下次写信自动填充此内容"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [contro addAction:ac];
        [contro addAction:ac2];
        [self presentViewController:contro animated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)not
{
    NSValue * value = [not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize size = [value CGRectValue].size;
    keyboardHeight = size.height;
    [UIView animateWithDuration:0.5 animations:^{
        customKeyB.frame = CGRectMake(0, self.view.height - kCusKeyBorH  - size.height, self.view.width, kCusKeyBorH);
        CGRect frame = _myTextView.frame;
        frame.size.height = customKeyB.top - _myTextView.top;
        _myTextView.frame = frame;
    }];
}
- (void)keyboardWillHide:(NSNotification *)not
{
    [UIView animateWithDuration:0.2 animations:^{
        customKeyB.frame = CGRectMake(0, self.view.height - kCusKeyBorH , self.view.width, kCusKeyBorH);
        CGRect frame = _myTextView.frame;
        frame.size.height = customKeyB.top;
        _myTextView.frame = frame;
    }];
}
#pragma mark - 自定义键盘
- (void)setUpCustomKeyB
{
    if (!customKeyB) {
        customKeyB = [[[NSBundle mainBundle] loadNibNamed:@"FKXCustomKeyboardUp" owner:nil options:nil] firstObject];
        customKeyB.myScrollview.contentSize = customKeyB.myScrollview.size;
        customKeyB.backgroundColor = [UIColor whiteColor];
        customKeyB.viewSwich.hidden = YES;
        customKeyB.labType.hidden = YES;
        customKeyB.btnType.hidden = YES;
        [customKeyB.photoBtn addTarget:self action:@selector(clickPhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:customKeyB];
    }
}
//-(void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    customKeyB.frame = CGRectMake(0, self.view.height - kCusKeyBorH, self.view.width, kCusKeyBorH);
//}
#pragma mark - 裁剪图片
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
//发送信件
- (void)nextStep
{
    [_myTextView resignFirstResponder];
    NSString *text = [_myTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *tex = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (tex.length < 200)
    {
        [self showHint:@"写信内容不能少于200字~"];
        return;
    }
//    else if (tex.length > 200)
//    {
//        [self showHint:@"字数超出500字了哦~"];
//        return;
//    }
    
    [self showHudInView:self.view hint:@"正在处理..."];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSDictionary *paramDic = @{
                               @"text":_myTextView.text,
                               @"imageArray":imagesNamesArr};
    [AFRequest sendGetOrPostRequest:@"write/add"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
//             [self showHint:data[@"data"][@"alert"]];
//             [self dismissViewControllerAnimated:YES completion:nil];
             FKXPasteStamp *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPasteStamp"];
             NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:1];
             [paraDic setObject:data[@"data"][@"writeId"] forKey:@"writeId"];
             vc.paraDic = paraDic;
             [self.navigationController pushViewController:vc animated:YES];
             
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
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
    [self showHudInView:self.view hint:@"正在上传"];
    
    UIImage * originalImage=[info  objectForKey:UIImagePickerControllerOriginalImage];
                             //UIImagePickerControllerEditedImage];
    imageSelected = originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:
     ^{
         
         NSData * originaData =UIImageJPEGRepresentation(originalImage, 0.7);
//         UIImageJPEGRepresentation(originalImage,0.7);
         
         UIImage *image;
         if (originaData.length > ImageSize)
         {
             image = [self reduceImage:originalImage toSize:CGSizeMake(originalImage.size.width * 0.9, originalImage.size.height * 0.9)];
             originaData = UIImageJPEGRepresentation(image,0.9);
         }
         
         [self sendIcon:originaData];
     }];
}
@end
