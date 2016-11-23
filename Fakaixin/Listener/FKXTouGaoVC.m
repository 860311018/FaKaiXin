//
//  FKXTouGaoVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/21.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXTouGaoVC.h"
#import "FKXCustomKeyboardUp.h"
#import "UITextView+Placeholder.h"
#import "NSString+Extension.h"
#import <QiniuSDK.h>


#define ImageSize 1024 * 500
#define kImageW 60
#define kImageHM 10 //图片的水平margin
#define kCusKeyBorH 130 //自定义视图的高

#define Screen  [UIScreen mainScreen].bounds.size

@interface FKXTouGaoVC ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate>

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
    
    NSInteger selectedType;//是否允许转载

    CGFloat keyboardHeight;

}

@property (weak, nonatomic) IBOutlet UITextField *titleTF;

@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@end

@implementation FKXTouGaoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navTitle = @"投稿";
    [self setUpBarButton];
    [self setUpChooseTypeView];
    
    _titleTF.delegate = self;
    [_titleTF becomeFirstResponder];
    
    _myTextView.placeholder = @"想上首页热门么？好内容想被更多人看到么？把你的咨询经验和想法感受来投稿吧～入选文章会进一个队列挨个上首页得到更多曝光哦";
    _myTextView.delegate = self;
    
    //基本赋值
    imagesArr = [NSMutableArray arrayWithCapacity:1];
    imagesNamesArr = [NSMutableArray arrayWithCapacity:1];
    nameAndImage = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}

//发送
- (void)sendMind
{
    [_titleTF resignFirstResponder];
    [_myTextView resignFirstResponder];
    
    if ([NSString isEmpty:_titleTF.text]) {
        [self showHint:@"请输入题目"];
        return;
    }
    if ([NSString isEmpty:_myTextView.text]) {
        [self showHint:@"文稿内容不能为空哟"];
        return;
    }
    
    [self showHudInView:self.view hint:@"正在提交..."];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSDictionary *paramDic = @{
                               @"title" : _titleTF.text,
                               @"text":_myTextView.text,
                               @"imageArray":imagesNamesArr};
    [AFRequest sendGetOrPostRequest:@"contribute/insert"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"投稿成功"];
             [self.navigationController popViewControllerAnimated:YES];
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }
         else{
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [_myTextView resignFirstResponder];
    [_titleTF becomeFirstResponder];
    
    _titleTF.backgroundColor = [UIColor clearColor];
    _titleTF.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    _titleTF.borderStyle = UITextBorderStyleNone;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{

    [_titleTF resignFirstResponder];
    [_myTextView becomeFirstResponder];

    _titleTF.backgroundColor = [UIColor lightGrayColor];
    _titleTF.textColor = [UIColor whiteColor];
    _titleTF.borderStyle = UITextBorderStyleRoundedRect;
}

#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)not
{
    
    NSValue * value = [not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize size = [value CGRectValue].size;
    keyboardHeight = size.height;
    [UIView animateWithDuration:0.5 animations:^{
        chooseTypeView.frame = CGRectMake(0, kScreenHeight - kCusKeyBorH -keyboardHeight-64,kScreenWidth, kCusKeyBorH);
        _myTextView.frame = CGRectMake(8,49, kScreenWidth-16, kScreenHeight-49-kCusKeyBorH-keyboardHeight-64);

    }];
}
- (void)keyboardWillHide:(NSNotification *)not
{
    [UIView animateWithDuration:0.2 animations:^{
        chooseTypeView.frame = CGRectMake(0, 249 ,kScreenWidth, kCusKeyBorH);
        _myTextView.frame = CGRectMake(8, 49, kScreenWidth-16, 200);
    }];
}


- (void)setUpBarButton
{
//    UIImage *consultImage = [UIImage imageNamed:@"back"];
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
//    [btn setBackgroundImage:consultImage forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *sendB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 18)];
    [sendB setTitle:@"提交" forState:UIControlStateNormal];
    sendB.titleLabel.font = [UIFont systemFontOfSize:17];
    [sendB setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    [sendB addTarget:self action:@selector(sendMind) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendB];
}

#pragma mark - 自定义键盘

- (void)setUpChooseTypeView
{
    if (!chooseTypeView) {
        chooseTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, 249,kScreenWidth, kCusKeyBorH)];
        chooseTypeView.backgroundColor = kColorBackgroundGray;
        chooseTypeView.backgroundColor = [UIColor yellowColor];

        [self.view addSubview:chooseTypeView];
        
        customKeyB = [[[NSBundle mainBundle] loadNibNamed:@"FKXCustomKeyboardUp" owner:nil options:nil] firstObject];
        customKeyB.myScrollview.contentSize = customKeyB.myScrollview.size;
        customKeyB.frame = CGRectMake(0, 0, chooseTypeView.width, kCusKeyBorH);
        [customKeyB.photoBtn addTarget:self action:@selector(clickPhoto) forControlEvents:UIControlEventTouchUpInside];
        
        customKeyB.nimingL.text = @"权限设置";
        customKeyB.quanxianL.text = @"允许转载";
        customKeyB.quanxianL.hidden = NO;
        customKeyB.mySwitch.hidden = NO;
        customKeyB.btnType.hidden = YES;
        customKeyB.labType.hidden = YES;

        [chooseTypeView addSubview:customKeyB];
    }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
