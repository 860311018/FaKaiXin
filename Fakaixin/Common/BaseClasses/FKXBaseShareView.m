//
//  FKXBaseShareView.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseShareView.h"

@interface FKXBaseShareView ()
{
    UIVisualEffectView *effectView;
    UIButton * btnWechatCircle;  //倾诉按钮
    UIButton * btnWechat;  //咨询按钮
    UIButton * btnSina;  //共鸣按钮
    UIButton * btnQQ;  //倾诉按钮
    UIButton * btnQQSpace;  //咨询按钮
    UIButton * btnCopyLink;  //共鸣按钮

}
@end

@implementation FKXBaseShareView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)createSubviews
{
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.bounds;
    [self addSubview:effectView];
    [effectView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBlur)]];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    NSArray *titlesA = @[
                         @"微信好友",
                         @"朋友圈",
                         @"新浪微博",
                         @"QQ空间",
                         @"QQ",
                         @"复制链接"];
    NSArray *imagesA = @[
                         @"img_share_wechat",
                         @"img_share_wechat_circle",
                         @"img_share_sina",
                         @"img_share_qq_space",
                         @"img_share_qq",
                         @"img_share_copy_link"];
    //img_mind_close
    UIImage *imageWechat = [UIImage imageNamed:imagesA[0]];
    CGFloat buttonW = imageWechat.size.width + 60;
    CGFloat buttonH = imageWechat.size.height + 30;
    CGFloat margin = (effectView.width - buttonW*3)/4;
    //微信好友
    btnWechat = [UIButton buttonWithType:UIButtonTypeCustom];
    btnWechat.frame = CGRectMake(margin, effectView.height,buttonW,buttonH);
    btnWechat.tag = 100;
    btnWechat.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnWechat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnWechat setTitle:titlesA[0] forState:UIControlStateNormal];
    [btnWechat setImage:imageWechat forState:UIControlStateNormal];
    [btnWechat addTarget:self action:@selector(clickedBlurSub:) forControlEvents:UIControlEventTouchUpInside];
    [effectView addSubview:btnWechat];
    
    CGFloat buttonHeight = CGRectGetHeight(btnWechat.frame);
    CGFloat button_centerX =CGRectGetMidX(btnWechat.bounds);// bounds哦,不是frame
    CGFloat imageViewHeight = CGRectGetHeight(btnWechat.imageView.frame);
    CGFloat labelHeight = CGRectGetHeight(btnWechat.titleLabel.frame);
    CGFloat titleLabel_centerX =CGRectGetMidX(btnWechat.titleLabel.frame);
    CGFloat imageView_centerX =CGRectGetMidX(btnWechat.imageView.frame);
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(-(buttonHeight - imageViewHeight)/2,0 + (button_centerX - imageView_centerX),(buttonHeight - imageViewHeight)/2,0 - (button_centerX - imageView_centerX));
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsMake((buttonHeight - labelHeight)/2,0 - (titleLabel_centerX - button_centerX),-(buttonHeight - labelHeight)/2, 0 + (titleLabel_centerX - button_centerX));
    
    btnWechat.imageEdgeInsets = imageEdgeInsets;
    btnWechat.titleEdgeInsets = titleEdgeInsets;
    
    //朋友圈
    UIImage *imageWechatCircle = [UIImage imageNamed:imagesA[1]];
    btnWechatCircle = [UIButton buttonWithType:UIButtonTypeCustom];
    btnWechatCircle.frame = CGRectMake(btnWechat.right + margin, btnWechat.top, buttonW, buttonH);
    btnWechatCircle.tag = 101;
    btnWechatCircle.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnWechatCircle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnWechatCircle setTitle:titlesA[1] forState:UIControlStateNormal];
    [btnWechatCircle setImage:imageWechatCircle forState:UIControlStateNormal];
    CGFloat imageView_centerXCir =CGRectGetMidX(btnWechatCircle.imageView.frame);
    CGFloat titleLabel_centerXCir = CGRectGetMidX(btnWechatCircle.titleLabel.frame);
    UIEdgeInsets imageEdgeInsetsCir = UIEdgeInsetsMake(-(buttonHeight - imageViewHeight)/2,0 + (button_centerX - imageView_centerXCir),(buttonHeight - imageViewHeight)/2,0 - (button_centerX - imageView_centerXCir));
    UIEdgeInsets titleEdgeInsetsCir = UIEdgeInsetsMake((buttonHeight - labelHeight)/2,0 - (titleLabel_centerXCir - button_centerX),-(buttonHeight - labelHeight)/2, 0 + (titleLabel_centerXCir - button_centerX));
    btnWechatCircle.imageEdgeInsets = imageEdgeInsetsCir;
    btnWechatCircle.titleEdgeInsets = titleEdgeInsetsCir;
    [btnWechatCircle addTarget:self action:@selector(clickedBlurSub:) forControlEvents:UIControlEventTouchUpInside];
    [effectView addSubview:btnWechatCircle];
    
    //新浪微博
    UIImage *imageSina = [UIImage imageNamed:imagesA[2]];
    btnSina = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSina.frame = CGRectMake(btnWechatCircle.right + margin, btnWechat.top, buttonW, buttonH);
    btnSina.tag = 102;
    btnSina.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnSina setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSina setTitle:titlesA[2] forState:UIControlStateNormal];
    [btnSina setImage:imageSina forState:UIControlStateNormal];
    btnSina.imageEdgeInsets = imageEdgeInsets;
    btnSina.titleEdgeInsets = titleEdgeInsets;
    [btnSina addTarget:self action:@selector(clickedBlurSub:) forControlEvents:UIControlEventTouchUpInside];
    [effectView addSubview:btnSina];
    
    //QQ空间
    UIImage *imageQQSpace = [UIImage imageNamed:imagesA[3]];
    btnQQSpace = [UIButton buttonWithType:UIButtonTypeCustom];
    btnQQSpace.frame = CGRectMake(margin, btnWechat.bottom + 50,buttonW,buttonH);
    btnQQSpace.tag = 103;
    btnQQSpace.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnQQSpace setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnQQSpace setTitle:titlesA[3] forState:UIControlStateNormal];
    [btnQQSpace setImage:imageQQSpace forState:UIControlStateNormal];
    [btnQQSpace addTarget:self action:@selector(clickedBlurSub:) forControlEvents:UIControlEventTouchUpInside];
    [effectView addSubview:btnQQSpace];
    CGFloat imageView_centerXQQS =CGRectGetMidX(btnQQSpace.imageView.frame);
    CGFloat titleLabel_centerXQQS = CGRectGetMidX(btnQQSpace.titleLabel.frame);
    UIEdgeInsets imageEdgeInsetsQQS = UIEdgeInsetsMake(-(buttonHeight - imageViewHeight)/2,0 + (button_centerX - imageView_centerXQQS),(buttonHeight - imageViewHeight)/2,0 - (button_centerX - imageView_centerXQQS));
    UIEdgeInsets titleEdgeInsetsQQS = UIEdgeInsetsMake((buttonHeight - labelHeight)/2,0 - (titleLabel_centerXQQS - button_centerX),-(buttonHeight - labelHeight)/2, 0 + (titleLabel_centerXQQS - button_centerX));
    btnQQSpace.imageEdgeInsets = imageEdgeInsetsQQS;
    btnQQSpace.titleEdgeInsets = titleEdgeInsetsQQS;
    
    //QQ
    UIImage *imageQQ = [UIImage imageNamed:imagesA[4]];
    btnQQ = [UIButton buttonWithType:UIButtonTypeCustom];
    btnQQ.frame = CGRectMake(btnQQSpace.right + margin, btnQQSpace.top, buttonW, buttonH);
    btnQQ.tag = 104;
    btnQQ.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnQQ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnQQ setTitle:titlesA[4] forState:UIControlStateNormal];
    [btnQQ setImage:imageQQ forState:UIControlStateNormal];
    CGFloat imageView_centerXQQ =CGRectGetMidX(btnQQ.imageView.frame);
    CGFloat titleLabel_centerXQQ = CGRectGetMidX(btnQQ.titleLabel.frame);
    
    UIEdgeInsets imageEdgeInsetsQQ = UIEdgeInsetsMake(-(buttonHeight - imageViewHeight)/2,0 + (button_centerX - imageView_centerXQQ),(buttonHeight - imageViewHeight)/2,0 - (button_centerX - imageView_centerXQQ));
    UIEdgeInsets titleEdgeInsetsQQ = UIEdgeInsetsMake((buttonHeight - labelHeight)/2,0 - (titleLabel_centerXQQ - button_centerX),-(buttonHeight - labelHeight)/2, 0 + (titleLabel_centerXQQ - button_centerX));
    btnQQ.imageEdgeInsets = imageEdgeInsetsQQ;
    btnQQ.titleEdgeInsets = titleEdgeInsetsQQ;
    [btnQQ addTarget:self action:@selector(clickedBlurSub:) forControlEvents:UIControlEventTouchUpInside];
    [effectView addSubview:btnQQ];
    //复制链接
    UIImage *imageCopyLink = [UIImage imageNamed:imagesA[5]];
    btnCopyLink = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCopyLink.frame = CGRectMake(btnQQ.right + margin, btnQQSpace.top, buttonW, buttonH);
    btnCopyLink.tag = 105;
    btnCopyLink.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnCopyLink setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCopyLink setTitle:titlesA[5] forState:UIControlStateNormal];
    [btnCopyLink setImage:imageCopyLink forState:UIControlStateNormal];
    btnCopyLink.imageEdgeInsets = imageEdgeInsets;
    btnCopyLink.titleEdgeInsets = titleEdgeInsets;
    [btnCopyLink addTarget:self action:@selector(clickedBlurSub:) forControlEvents:UIControlEventTouchUpInside];
    [effectView addSubview:btnCopyLink];
    
    //关闭
    UIImage *imageClo = [UIImage imageNamed:@"img_mind_close"];
    UIButton *btnClo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClo.frame = CGRectMake((effectView.width - imageClo.size.width)/2, effectView.height -imageClo.size.height - 45, imageClo.size.width, imageClo.size.height);
    [btnClo setImage:imageClo forState:UIControlStateNormal];
    [btnClo addTarget:self action:@selector(closeBlur) forControlEvents:UIControlEventTouchUpInside];
    [effectView addSubview:btnClo];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
    CGFloat centerMargin = margin + buttonW/2;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnWechat.center = CGPointMake(centerMargin, effectView.frame.size.height - 200 - 150);
        btnQQSpace.center = CGPointMake(centerMargin, btnWechat.center.y + buttonH + 40);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnWechatCircle.center = CGPointMake(btnWechat.right + centerMargin, btnWechat.center.y);
        btnQQ.center = CGPointMake(btnQQSpace.right + centerMargin, btnQQSpace.center.y);
        
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnSina.center = CGPointMake(btnWechatCircle.right + centerMargin, btnWechat.center.y);
        btnCopyLink.center = CGPointMake(btnQQ.right + centerMargin, btnQQSpace.center.y);
        
    } completion:nil];
}
-(instancetype)initWithFrame:(CGRect)frame
                 imageUrlStr:(NSString *)imageUrlStr
                      urlStr:(NSString *)urlStr
                       title:(NSString *)title
                        text:(NSString *)text
{
    if (self = [super initWithFrame:frame])
    {
        _imageUrlStr = imageUrlStr;
        _urlStr = urlStr;
        _title = title;
        _text = text;
        self.alpha = 0;
        self.frame = frame;
    }
    return self;
}
- (void)closeBlur
{
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnSina.center = CGPointMake(btnSina.center.x, effectView.height + 240);
        btnCopyLink.center = CGPointMake(btnCopyLink.center.x, effectView.height + 240);
    } completion:nil];
    [UIView animateWithDuration:0.8 delay:0.01 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnWechatCircle.center = CGPointMake(btnWechatCircle.center.x, btnSina.center.y);
        btnQQ.center = CGPointMake(btnQQ.center.x, btnCopyLink.center.y);
    } completion:nil];
    
    [UIView animateWithDuration:0.9 delay:0.02 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnWechat.center = CGPointMake(btnWechat.center.x, btnSina.center.y);
        btnQQSpace.center = CGPointMake(btnQQSpace.center.x, btnCopyLink.center.y);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeAllSubviews];
        [self removeFromSuperview];
    }];
}
- (void)clickedBlurSub:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [effectView removeFromSuperview];
        [effectView removeAllSubviews];
        effectView = nil;
    }];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[NSURL URLWithString:_imageUrlStr]];
    [shareParams SSDKSetupShareParamsByText:_text
                                     images:imageArray
     
                                        url:[NSURL URLWithString:_urlStr ]
                                      title:_title
                                       type:SSDKContentTypeAuto];
    //单个分享
    SSDKPlatformType type = SSDKPlatformSubTypeWechatTimeline;
    
    switch (btn.tag) {
        case 100:
        {
            type = SSDKPlatformSubTypeWechatSession;
        }
            break;
        case 101:
        {
            type = SSDKPlatformSubTypeWechatTimeline;
        }
            break;
        case 102:
        {
            type = SSDKPlatformTypeSinaWeibo;
        }
            break;
        case 103:
        {
            type = SSDKPlatformSubTypeQZone;
        }
            break;
        case 104:
        {
            type = SSDKPlatformSubTypeQQFriend;
        }
            break;
        case 105:
        {
            UIPasteboard *pas = [UIPasteboard generalPasteboard];
            [pas setURL:[NSURL URLWithString:_urlStr]];
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"已拷贝至剪贴板" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
            break;
            
        default:
            break;
    }
    //单个分享
    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
    {
        switch (state)
        {
            case SSDKResponseStateSuccess:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                if (_needUpdateForwardNum) {
                    [self shareSuccessCallBack];
                }
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            case SSDKResponseStateCancel:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享取消"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
        }
    }];
}
#pragma mark - 分享成功回调 服务器
- (void)shareSuccessCallBack
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_hotId forKey:@"shareId"];
    [AFRequest sendGetOrPostRequest:@"share/updateForwardNum" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
    } failure:^(NSError *error) {
    }];
}
@end
