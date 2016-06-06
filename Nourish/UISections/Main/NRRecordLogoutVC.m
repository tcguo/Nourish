//
//  NRRecordLogoutVC.m
//  Nourish
//
//  Created by gtc on 15/7/17.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordLogoutVC.h"
#import "UIButton+Additions.h"
#import "NRLoginViewController.h"
#import "NRNavigationController.h"
#import "NRLoginManager.h"

@interface NRRecordLogoutVC()
{
     UIView *_startView;
}

@property (nonatomic, copy, readwrite) NSString *navTitle;

@end

@implementation NRRecordLogoutVC

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.navTitle = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftMenu];
    self.navigationItem.title = self.navTitle;
    self.view.backgroundColor = ColorViewBg;
    
    _startView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _startView.backgroundColor = ColorViewBg;
    
    [self setupLoginControls];
}

- (void)setupLoginControls
{
    [self.view addSubview:_startView];
    
    UIImageView *nullImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"null"]];
    [_startView addSubview:nullImgView];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startView addSubview:loginButton];
    loginButton.layer.borderColor = ColorRed_Normal.CGColor;
    loginButton.layer.borderWidth = 0.5;
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = CornerRadius;
    loginButton.titleLabel.font  = NRFont(FontButtonTitleSize);
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [loginButton setBackgroundColorForState:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_startView.centerY).offset(-20);
        make.centerX.equalTo(_startView.centerX);
        make.height.equalTo(ButtonDefaultHeight);
        make.width.equalTo(150);
    }];
    
    [nullImgView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(loginButton.mas_top).offset(-15);
        make.centerX.equalTo(_startView.centerX);
    }];
    
    UIButton *weekplanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startView addSubview:weekplanButton];
    weekplanButton.layer.borderColor = ColorRed_Normal.CGColor;
    weekplanButton.layer.borderWidth = 0.5;
    weekplanButton.layer.masksToBounds = YES;
    weekplanButton.layer.cornerRadius = CornerRadius;
    weekplanButton.titleLabel.font  = NRFont(FontButtonTitleSize);
    [weekplanButton setTitle:@"挑选周计划" forState:UIControlStateNormal];
    [weekplanButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
    [weekplanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [weekplanButton setBackgroundColorForState:[UIColor whiteColor] forState:UIControlStateNormal];
    [weekplanButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
    [weekplanButton addTarget:self action:@selector(selectWeekPlan:) forControlEvents:UIControlEventTouchUpInside];
    [weekplanButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_startView.centerY).offset(40);
        make.centerX.equalTo(_startView.centerX);
        make.height.equalTo(ButtonDefaultHeight);
        make.width.equalTo(150);
    }];
}

- (void)login:(id)sender
{
    if (![NRLoginManager sharedInstance].isLogined) {
        NRLoginViewController *loginVC = [NRLoginViewController sharedInstance];
        NRNavigationController *navC = [[NRNavigationController alloc] initWithRootViewController:loginVC];
        [self.view.window.rootViewController presentViewController:navC animated:YES completion:nil];
    }
}

- (void)selectWeekPlan:(id)sender
{
    self.tabBarController.selectedIndex = 0;
}

@end
