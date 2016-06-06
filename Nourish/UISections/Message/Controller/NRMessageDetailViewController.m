//
//  NRMessageDetailViewController.m
//  Nourish
//
//  Created by tcguo on 15/12/19.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRMessageDetailViewController.h"

@interface NRMessageDetailViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation NRMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.title = @"消息详情";
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    
    CGFloat rectY = self.webView.frame.origin.y + (self.webView.frame.size.height - 60)/2;
    CGRect avtivityRect = CGRectMake((self.webView.bounds.size.width-60)/2, rectY, 60, 60);
    self.activityView = [[UIActivityIndicatorView  alloc] initWithFrame:avtivityRect];
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray; // 设置活动指示器的颜色
    self.activityView.hidesWhenStopped = YES; // hidesWhenStopped默认为YES，会隐藏活动指示器。要改为NO
    [self.activityView startAnimating];
    [self.view addSubview:self.activityView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.linkUrl]];
    [self.webView loadRequest:request];
}

#pragma mark -UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [self.activityView stopAnimating];
    [MBProgressHUD showTips:KeyWindow text:@"加载失败"];
}


- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT)];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
    }
    return _webView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
