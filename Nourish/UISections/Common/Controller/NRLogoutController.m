//
//  NROrderCurrLogoutVC.m
//  Nourish
//
//  Created by gtc on 15/7/17.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRLogoutController.h"
#import "BMButton.h"
#import "NRLoginViewController.h"
#import "NRNavigationController.h"
#import "NRLoginManager.h"

@interface NRLogoutController ()
{
    BMButton *_btnLogin;
    UIView *_startView;
    UILabel *_tipLabel;
}

@property (nonatomic, strong) NRNavigationController *navC;

@end

@implementation NRLogoutController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftMenu];
    self.view.backgroundColor = ColorViewBg;
    
    _startView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT)];
    _startView.backgroundColor = [UIColor clearColor];
    
    [self setupLoginControls];
}

- (void)setupLoginControls {
    [self.view addSubview:_startView];
    
    UIImageView *nullImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"null"]];
    [_startView addSubview:nullImgView];
    
    _tipLabel = [[UILabel alloc] init];
    [_startView addSubview:_tipLabel];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textColor = [UIColor blackColor];
    _tipLabel.font = NRFont(FontLabelSize);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.text = @"您还没有登录，请登录后查看订单";
    _tipLabel.text = self.tips;
    [_tipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_startView);
    }];
    
    [nullImgView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_startView.centerX);
        make.bottom.equalTo(_tipLabel.mas_top).offset(-20);
    }];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startView addSubview:loginButton];
    loginButton.layer.borderColor = ColorRed_Normal.CGColor;
    loginButton.layer.borderWidth = 0.5;
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = CornerRadius;
    loginButton.titleLabel.font  = NRFont(FontButtonTitleSize);
    [loginButton setTitle:@"登录/注册" forState:UIControlStateNormal];
    [loginButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [loginButton setBackgroundColorForState:[UIColor clearColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
    
    [loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tipLabel.mas_bottom).offset(20);
        make.centerX.equalTo(_startView.centerX);
        make.height.equalTo(ButtonDefaultHeight);
        make.width.equalTo(150);
    }];
    
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTips:(NSString *)tips {
    _tips = tips;
    _tipLabel.text = tips;
}

- (void)login:(id)sender {
    if (![NRLoginManager sharedInstance].isLogined) {
        NRLoginViewController *loginVC = [NRLoginViewController sharedInstance];
        self.navC = [[NRNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:self.navC animated:YES completion:nil];
    }
}


@end
