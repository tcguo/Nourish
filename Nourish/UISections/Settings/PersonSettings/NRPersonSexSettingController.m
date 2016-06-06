//
//  NRPersonSexSettingController.m
//  Nourish
//
//  Created by gtc on 15/3/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRPersonSexSettingController.h"
#import "NRPersonAgeSettingController.h"

@interface NRPersonSexSettingController ()
{
    UILabel *_maleTitleCHLabel;
    UILabel *_maleTitleENLabel;
    
    UILabel *_femaleTitleCHLabel;
    UILabel *_femaleTitleENLabel;
}

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *maleButton;
@property (nonatomic, strong) UIButton *femaleButton;
@property (assign, nonatomic) BOOL isFromRegister;
@property (nonatomic, strong) NRUserInfoModel *userInfo;

@end

@implementation NRPersonSexSettingController

#pragma mark - Life cycle

- (id)initWithUserInfo:(NRUserInfoModel *)userInfo isfromRegister:(BOOL)isfromRegister {
    self = [super init];
    if (self) {
        _userInfo = userInfo;
        _isFromRegister = isfromRegister;
    }
    
    return self;
}

- (void)viewDidLoad {
    if (self.isFromRegister) {
        self.userInfo = [[NRUserInfoModel alloc] init];
        [super viewDidLoadWithBarStyle:NRBarStyleLeftNone];
        self.navigationItem.hidesBackButton = YES;
    }
    else
        [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"性别";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 提示
    self.tipLabel = [UILabel new];
    [self.view addSubview:self.tipLabel];
    self.tipLabel.text = @"请根据个人实际情况录入";
    self.tipLabel.font = NRFont(15);
    self.tipLabel.textColor = ColorBaseFont;
    [self.tipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo (self.view.centerX);
        make.top.equalTo(@32);
        make.height.greaterThanOrEqualTo(@15);
    }];
    
    self.femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.femaleButton.tag = -1;
    [self.femaleButton setImage:[UIImage imageNamed:@"settings-person-female"] forState:UIControlStateNormal];
    [self.view addSubview:self.femaleButton];
    [self.femaleButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.tipLabel.mas_bottom).offset(@30);
        make.height.equalTo(@94);
        make.width.equalTo(@280);
    }];
    [self.femaleButton addTarget:self action:@selector(selectSex:) forControlEvents:UIControlEventTouchUpInside];
    
    _femaleTitleCHLabel = [UILabel new];
    _femaleTitleCHLabel.text = @"女";
    _femaleTitleCHLabel.font = NRFont(20);
    [self.view addSubview:_femaleTitleCHLabel];
    [_femaleTitleCHLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.femaleButton.mas_bottom).offset(@20);
        make.height.equalTo(@20);
    }];
    _femaleTitleENLabel = [UILabel new];
    _femaleTitleENLabel.text = @"Female";
    _femaleTitleENLabel.font = NRFont(20);
    _femaleTitleENLabel.textColor = ColorBaseFont;
    [self.view addSubview:_femaleTitleENLabel];
    [_femaleTitleENLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_femaleTitleCHLabel.mas_bottom).offset(@10);
        make.height.equalTo(@20);
    }];
    
    
    self.maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.maleButton.tag = 1;
    [self.maleButton setImage:[UIImage imageNamed:@"settings-person-male"] forState:UIControlStateNormal];
    [self.view addSubview:self.maleButton];
    [self.maleButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_femaleTitleENLabel.mas_bottom).offset(@50);
        make.height.equalTo(@94);
        make.width.equalTo(@280);
    }];

    [self.maleButton addTarget:self action:@selector(selectSex:) forControlEvents:UIControlEventTouchUpInside];
    
    _maleTitleCHLabel = [UILabel new];
    _maleTitleCHLabel.text = @"男";
    _maleTitleCHLabel.font = NRFont(20);
    [self.view addSubview:_maleTitleCHLabel];
    [_maleTitleCHLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.maleButton.mas_bottom).offset(@20);
        make.height.equalTo(@20);
    }];
    
    _maleTitleENLabel = [UILabel new];
    _maleTitleENLabel.text = @"Male";
    _maleTitleENLabel.font = NRFont(20);
    _maleTitleENLabel.textColor = ColorBaseFont;
    [self.view addSubview:_maleTitleENLabel];
    [_maleTitleENLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_maleTitleCHLabel.mas_bottom).offset(@10);
        make.height.equalTo(@20);
    }];
}


#pragma mark - Action

- (void)selectSex:(UIButton *)sender {
    if (self.isFromRegister) {
        // 从注册来的
        self.userInfo.gender = (GenderType)sender.tag;
        NRPersonAgeSettingController *ageSettingsVC = [[NRPersonAgeSettingController alloc] initWithUserInfo:self.userInfo isFromSexVC:YES];
        [self.navigationController pushViewController:ageSettingsVC animated:YES];
    }
    else {
        // 从个人设置进来的
        self.userInfo.gender = (GenderType)sender.tag;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
