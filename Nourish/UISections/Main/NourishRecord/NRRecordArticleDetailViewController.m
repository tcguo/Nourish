//
//  NRRecordArticleDetailViewController.m
//  Nourish
//
//  Created by tcguo on 15/11/20.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordArticleDetailViewController.h"

@interface NRRecordArticleDetailViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation NRRecordArticleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.title = self.articleTitle;
    [self.view addSubview:self.webView];
    
//    self.webView.scalesPageToFit = YES;
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)] ;
    [self.activityIndicatorView setCenter: self.view.center] ;
    [self.activityIndicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleGray] ;
    [self.view addSubview: self.activityIndicatorView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = self.articleTitle;
    NSURL *url = [NSURL URLWithString:self.detailUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - Property

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT)];
        _webView.delegate = self;
    }
    return _webView;
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicatorView startAnimating] ;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicatorView stopAnimating] ;
}


@end
