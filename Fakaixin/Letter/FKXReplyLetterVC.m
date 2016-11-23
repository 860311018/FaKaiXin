//
//  FKXReplyLetterVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXReplyLetterVC.h"
#import "UITextView+Placeholder.h"

@interface FKXReplyLetterVC ()
{
    BOOL isOpen;//是否是展开的
    BOOL isReplide;//已经回复过的
    BOOL isNeedReply;//需要回复
}
@property (weak, nonatomic) IBOutlet UITextView *incomingLetterTeW;
@property (weak, nonatomic) IBOutlet UITextView *replyLetterTeW;
@property (weak, nonatomic) IBOutlet UILabel *labOpen;

@end

@implementation FKXReplyLetterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"回信";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _replyLetterTeW.placeholder = @"回复TA的信件，用你的经验与爱心帮助他人。即可获得爱心值奖励和更多曝光赚取收入（为了保证回复得完整性，请不少于200字）";
    
    NSString *incoming = @"";
    NSString *reply;
    NSArray *imagesArr;
    if (_secondAskModel) {
        incoming = _secondAskModel.writeText;
        reply = _secondAskModel.backText;
        imagesArr = _secondAskModel.imageArray;
        if (reply) {
            isOpen = NO;
            isReplide = YES;
            _labOpen.text = @"来信内容（点击展开）";
        }else{
            _labOpen.text = @"来信内容（点击收起）";
            isOpen = YES;
        }
    }else if (_model) {
        isOpen = YES;
        isNeedReply = YES;
        _labOpen.text = @"来信内容（点击收起）";
        incoming = _model.text;
        imagesArr = _model.imageArray;
        [self setUpNavBar];//只有从来信列表进来的才展示item
    }else if (_dynamicModel) {
        incoming = _dynamicModel.replyText;
        reply = _dynamicModel.backText;
        imagesArr = _dynamicModel.imageArray;
    }else{
        isOpen = YES;
        _labOpen.text = @"来信内容（点击收起）";
    }
    
    if (reply) {
        _replyLetterTeW.text = reply;
        _replyLetterTeW.editable = NO;
    }
    // 创建一个富文本，添加图片
    NSMutableAttributedString *attS =     [[NSMutableAttributedString alloc] initWithString:incoming attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x999999), NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    
    for (int i = 0; i < imagesArr.count; i++) {
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.bounds = CGRectMake(35, 0, kScreenWidth - 70, 130);
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        [imgV sd_setImageWithURL:_model.imageArray[i] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
        
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        attach.image = imgV.image;
        NSAttributedString *subAttS = [NSAttributedString attributedStringWithAttachment:attach];
        [attS appendAttributedString:[[NSAttributedString alloc] initWithString:@"     \n\n"]];
        [attS appendAttributedString:subAttS];
    }
    
    [_incomingLetterTeW setAttributedText:attS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)setUpNavBar
{
    UIButton *saveB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 18)];
    [saveB setTitle:@"发送" forState:UIControlStateNormal];
    saveB.titleLabel.font = [UIFont systemFontOfSize:15];
    //有邮票了发送颜色是 51b5ff
    [saveB setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateNormal];
    [saveB addTarget:self action:@selector(saveLetter) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveB];
}
- (void)saveLetter
{
    [_replyLetterTeW resignFirstResponder];
    NSString *text = [_replyLetterTeW.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *tex = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (!tex.length)
    {
        [self showHint:@"请输入回信信息"];
        return;
    }
    else if (tex.length < 200)
    {
        [self showHint:@"回信内容不能少于200字~"];
        return;
    }
    
    [self showHudInView:self.view hint:@"正在回信..."];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:1];
    paraDic[@"text"] = _replyLetterTeW.text;
    paraDic[@"writeId"] = _model.writeId;
    [AFRequest sendGetOrPostRequest:@"write/back"param:paraDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showAlertViewWithTitle:@"信件已发出，等待审核"];
             [self.navigationController popViewControllerAnimated:YES];
             
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
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark - tableviewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            if (isOpen) {
               return 340;
            }else{
                return 0;
            }
            break;
        case 1:
            if (!isReplide && !isNeedReply) {
                return 0;
            }
            return 35;
            break;
        case 2:
            if (!isReplide&& !isNeedReply) {
                return 0;
            }
            return 21;
            break;
        case 3:
            if (!isReplide&& !isNeedReply) {
                return 0;
            }
            return self.view.height - 396;
            break;
            
        default:
            return 0;
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        isOpen = !isOpen;
        if (isOpen) {
            _labOpen.text = @"来信内容（点击收起）";
        }else{
            _labOpen.text = @"来信内容（点击展开）";
        }
        [self.tableView reloadData];
        
    }
}
@end
