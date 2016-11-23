//
//  FKXProtocolViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXProtocolViewController.h"

@interface FKXProtocolViewController ()<UIWebViewDelegate>
{
    NSString *webUrl;
    NSString *itemTitle;
    
    UIWebView *myWebView;
}

@end

@implementation FKXProtocolViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url title:(NSString *)title
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        webUrl = url;
        itemTitle = title;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpBackBtn];
    [self setTitleViewOfNavigationItem:itemTitle];
    
    myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64)];
    myWebView.delegate = self;
    myWebView.backgroundColor = kColorBackgroundGray;
    [self.view addSubview:myWebView];
    
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:webUrl]];
        [myWebView loadRequest:request];
    }
    [self showHudInView:self.view hint:@"正在加载"];
    //3.加载本地html
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//    NSURL* url = [NSURL fileURLWithPath:path];
//    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
//    [webView loadRequest:request];
}
#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [webView stringByEvaluatingJavaScriptFromString:@"rewrite();"];

    [self hideHud];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error
{
    [self hideHud];
    
    [self showHint:@"网络出错"];
}
#pragma mark - UI
- (void)setUpBackBtn
{
    UIImage *consultImage = [UIImage imageNamed:@"back"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
        [btn setBackgroundImage:consultImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}
- (void)goBack
{
    if ([self.navigationController viewControllers].count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
