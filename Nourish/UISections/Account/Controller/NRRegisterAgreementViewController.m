//
//  NRRegisterAgreementViewController.m
//  Nourish
//
//  Created by tcguo on 15/11/22.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRegisterAgreementViewController.h"

@interface NRRegisterAgreementViewController ()

@property (nonatomic, weak) UIWebView *webView;

@end

@implementation NRRegisterAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.title = @"服务协议";
    UIWebView *tmpWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT)];
    [self.view addSubview:tmpWebView];
    self.webView = tmpWebView;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ServiceAgreement" ofType:@"html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}



@end
