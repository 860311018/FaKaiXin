//
//  FKXPublishCourseController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPublishCourseController.h"
#import "UITextView+Placeholder.h"

@interface FKXPublishCourseController ()<UITableViewDataSource, UITextFieldDelegate>
{
    UIView * myWindowView;     //覆盖屏幕的黑色透明图
    NSDate * selectDate;    //选中的时间
    NSString *methodName;
    BOOL isApplyCourse;
    BOOL isApplyShare;
}
@property (weak, nonatomic) IBOutlet UITextField *myCourseTitle;
@property (weak, nonatomic) IBOutlet UITextField *myShareTitle;
@property (weak, nonatomic) IBOutlet UITextView *myContent;
@property (strong, nonatomic) UIDatePicker *myDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *myPrice;
@property (weak, nonatomic) IBOutlet UITextField *weChatAcc;

@property (weak, nonatomic) IBOutlet UITextField *myTele;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseTime;
@property (weak, nonatomic) IBOutlet UIView *myContentView;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyCourse;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyShare;

@end

@implementation FKXPublishCourseController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.navTitle = @"申请课程";
    isApplyCourse = YES;
    //ui创建
    [self addSubviewsToMyContentView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 键盘弹出
- (void)didShowKey:(NSNotification *)notific {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UITextField *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    if ([firstResponder isEqual:_weChatAcc] ||[firstResponder isEqual:_myTele]) {
    }else{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
#pragma mark - 创建子视图
- (void)addSubviewsToMyContentView
{
    NSArray *array = @[@"家庭关系",
                       @"亲子沟通",
                       @"婚姻问题",
                       @"心理调整",
                       @"恋爱心理",
                       @"学业职场",
                       @"人际关系",
                       @"个人成长"];
    UIFont * font = [UIFont systemFontOfSize:12];
    for (int i = 0; i< array.count; i++)
    {
        NSString *title = array[i];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        button.titleLabel.font = font;
        UIImage *imageSelect = [UIImage imageNamed:@"img_type_select_selected"];
        UIImage *imageUnselect = [UIImage imageNamed:@"img_type_select_normal"];
        [button setImage:imageUnselect forState:UIControlStateNormal];
        [button setImage:imageSelect forState:UIControlStateSelected];
        CGFloat width = 71;
        CGFloat height = imageSelect.size.height;
        CGFloat margin = (self.view.width/2 - 6 - width*2)/3;
        //第一个按钮
        CGFloat btnX = 0;
        CGFloat btnY = 0;
        NSInteger row = 0;
        NSInteger col = 0;
        NSInteger cols = 2;
        col = i%cols;
        row = i/cols;
        btnX = margin + (margin + width)*col;
        btnY = 366 + (5 + height)*row;
        button.frame = CGRectMake(btnX, btnY, width, height);
        // 顶  左  底  右
        button.titleEdgeInsets = UIEdgeInsetsMake(8, 0, 0, 0);
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_myContentView addSubview:button];
    }
}
-(void)buttonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
}
#pragma mark - 点击事件
//- (IBAction)clickApplyBtn:(UIButton *)sender {
//    sender.selected = !sender.selected;
//    if (sender.selected) {
//        if ([sender isEqual:_btnApplyShare]) {
//            _btnApplyCourse.hidden = YES;
//            isApplyShare = YES;
//            isApplyCourse = NO;
//            
//        }else{
//            _btnApplyShare.hidden = YES;
//            isApplyShare = NO;
//            isApplyCourse = YES;
//        }
//    }else{
//        isApplyShare = NO;
//        isApplyCourse = NO;
//        _btnApplyCourse.hidden = NO;
//        _btnApplyShare.hidden = NO;
//    }
//}

- (IBAction)clickSubmit:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (!isApplyCourse && !isApplyShare) {
        [self showHint:@"请选择申请类型~"];
        return;
    }
    //点击选择开始时间
    [self.view endEditing:YES];
    NSString *courseTitle = [_myCourseTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *shareTitle = [_myShareTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *content = [_myContent.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *content2 = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (isApplyShare) {
        if (shareTitle.length < 8)
        {
            [self showHint:@"标题长度不少于8个字哦"];
            return;
        }
    }else if (isApplyCourse)
    {
        if (courseTitle.length < 8)
        {
            [self showHint:@"标题长度不少于8个字哦"];
            return;
        }
    }
    if (content2.length < 50)
    {
        [self showHint:@"内容不少于50字~ "];
        return;
    }
    if (isApplyCourse)
    {
        if (!_myPrice.text.length)
        {
            [self showHint:@"请输入费用"];
            return;
        }
    }
    if (!_btnTime.titleLabel.text.length)
    {
        [self showHint:@"请选择开始时间"];
        return;
    }
    else if (!_weChatAcc.text.length)
    {
        [self showHint:@"请输入微信号"];
        return;
    }else if (_myTele.text.length != 11)
    {
        [self showHint:@"手机格式不正确"];
        return;
    }
    [self showHudInView:self.view hint:@"正在提交"];
    NSDictionary *paramDic;
    if (isApplyCourse)
    {
        methodName = @"course/apply";
        paramDic = @{
                     @"title" : courseTitle,
                     @"content":content2,
                     @"startTime":_btnTime.titleLabel.text,
                     @"expectCost":@([_myPrice.text intValue]*100),
                     @"category":@(1),
                     @"weChat":_weChatAcc.text?_weChatAcc.text : @"",
                     @"phone":_myTele.text?_myTele.text:@""};
    }else if (isApplyShare)
    {
        methodName = @"meeting/apply";
        paramDic = @{
                     @"title" : shareTitle,
                     @"content":content2,
                     @"startTime":_btnTime.titleLabel.text,
                     @"category":@(1),
                     @"weChat":_weChatAcc.text?_weChatAcc.text : @"",
                     @"phone":_myTele.text?_myTele.text:@""};
    }
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            [self showAlertViewWithTitle:data[@"data"][@"detailMessage"]];
            [self.navigationController popViewControllerAnimated:YES];
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
- (IBAction)clickTime:(id)sender
{
    [self.view endEditing:YES];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (!myWindowView)
    {
        myWindowView = [[UIView alloc]initWithFrame:window.frame];
        myWindowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        myWindowView.alpha = 0.0;
        
        if (!self.myDatePicker)
        {
            self.myDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, (self.view.height - 200) /2,  self.view.width , 200)];
            self.myDatePicker.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
            self.myDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
            self.myDatePicker.backgroundColor = [UIColor whiteColor];
            self.myDatePicker.minimumDate = [NSDate date];
            [myWindowView addSubview:_myDatePicker];
            self.myDatePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:30*24*60*60];
        }
        UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:kColor_MainDarkGray() forState:UIControlStateNormal];
        cancelBtn.backgroundColor = [UIColor whiteColor];
        cancelBtn.tag = 201;
        [cancelBtn addTarget:self action:@selector(windowHidden:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.frame = CGRectMake(0, _myDatePicker.bottom + 1, (myWindowView.width - 1)/2, 40);
        [myWindowView addSubview:cancelBtn];
        
        UIButton * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn setTitleColor:kColor_MainDarkGray() forState:UIControlStateNormal];
        sureBtn.backgroundColor = [UIColor whiteColor];
        sureBtn.tag = 202;
        [sureBtn addTarget:self action:@selector(sureSetupTime:) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.frame = CGRectMake(cancelBtn.right + 1, cancelBtn.top, (myWindowView.width- 1)/2, 40);
        [myWindowView addSubview:sureBtn];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [window addSubview:myWindowView];
        myWindowView.alpha = 1.0;
    }];
}
-(void)windowHidden:(UIButton *)btn
{
    if(btn.tag == 201)
    {
        [UIView animateWithDuration:0.2 animations:^{
            myWindowView.alpha = 0;
        } completion:^(BOOL finished) {
            [myWindowView removeFromSuperview];
            myWindowView = nil;
            _myDatePicker = nil;
        }];
    }
}

#pragma mark - 确定时间段
-(void)sureSetupTime:(UIButton *)button
{
    //获得当前UIDatePicker显示的日期
    selectDate = [_myDatePicker date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    //NSDateFormatter 可以让表示日期和时间灵活使用预设格式风格或自定义格式的字符串
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString * dateAndTime = [dateFormatter stringFromDate:selectDate];
    
    if (dateAndTime)
    {
        [_btnTime setTitle:dateAndTime forState:UIControlStateNormal];
    }

    [UIView animateWithDuration:0.2 animations:^{
        myWindowView.alpha = 0;
    } completion:^(BOOL finished) {
        [myWindowView removeFromSuperview];
        myWindowView = nil;
        _myDatePicker = nil;
    }];
}
#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![string isEqualToString:@""])
    {
        if ([textField isEqual:_myPrice]) {
            const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
            if (*ch >57 || *ch < 48) {
                return NO;
            }
        }
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
