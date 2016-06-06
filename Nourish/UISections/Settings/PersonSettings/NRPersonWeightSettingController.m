//
//  NRPersonWeightSettingController.m
//  Nourish
//
//  Created by gtc on 15/3/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRPersonWeightSettingController.h"
#import "TRSDialScrollView.h"
#import "NRLoginViewController.h"
#import "NRLoginManager.h"

@interface NRPersonWeightSettingController ()<UIScrollViewDelegate>
{
    UIImageView *_avatarImgV;
}

@property (strong, nonatomic) TRSDialScrollView *dialView;
@property (strong, nonatomic) UILabel *currentWeightLabel;
@property (strong, nonatomic) UILabel *unitLabel;

@property (assign, nonatomic) BOOL isFromHeightSettingsVC;
@property (strong, nonatomic) NRUserInfoModel *userInfo;

@end

@implementation NRPersonWeightSettingController

#pragma mark - view cycle

- (id)initWithUserInfo:(NRUserInfoModel *)userInfo isFromHeightVC:(BOOL)fromHeightVC;
{
    self = [super init];
    if (self) {
        _userInfo = userInfo;
        _isFromHeightSettingsVC = fromHeightVC;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"体重";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *imagename = nil;
    if (self.isFromHeightSettingsVC) {
        [self setupBarButton];
    }
    
    _avatarImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imagename]];
    _avatarImgV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_avatarImgV];
    [_avatarImgV makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(@30);
        make.height.equalTo(@205);
        make.width.equalTo(@138);
    }];
    
    // 当前值
    self.currentWeightLabel = [UILabel new];
    [self.view addSubview:self.currentWeightLabel];
    self.currentWeightLabel.text = [NSString stringWithFormat:@"%li", (long)_dialView.currentValue];
    self.currentWeightLabel.textColor = RgbHex2UIColor(0xff, 0x6c, 0x00);
    self.currentWeightLabel.font = [UIFont fontWithName:@"Avenir" size:28];
    [self.currentWeightLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(_avatarImgV.mas_bottom).offset(@20);
        make.height.equalTo(@28);
    }];
    
//    self.dialView.transform = CGAffineTransformMakeRotation(-M_PI_2);//旋转90度
    
    self.unitLabel = [UILabel new];
    [self.view addSubview:self.unitLabel];
    self.unitLabel.textColor = ColorBaseFont;
    self.unitLabel.text = @"kg";
    self.unitLabel.font = [UIFont fontWithName:@"Avenir" size:14];
    [self.unitLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentWeightLabel.mas_right).offset(5);
//        make.top.equalTo(@30);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.currentWeightLabel.mas_bottom);
    }];

    // 体重标尺
    CGFloat yDial = self.currentWeightLabel.frame.origin.y + self.currentWeightLabel.bounds.size.height + 30;
    self.dialView = [[TRSDialScrollView alloc] initWithFrame:CGRectMake(20, yDial, self.view.bounds.size.width-40, 100)];
    
    [[TRSDialScrollView appearance] setMinorTicksPerMajorTick:10];
    [[TRSDialScrollView appearance] setMinorTickDistance:16];
    [[TRSDialScrollView appearance] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"setting-dialBackground"]]];
    
    //    [[TRSDialScrollView appearance] setBackgroundColor:[UIColor whiteColor]];
    //    [[TRSDialScrollView appearance] setOverlayColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"DialShadding"]]];
    
    [[TRSDialScrollView appearance] setLabelStrokeColor:[UIColor colorWithRed:0.400 green:0.525 blue:0.643 alpha:1.000]];
    [[TRSDialScrollView appearance] setLabelStrokeWidth:0.1f];
    [[TRSDialScrollView appearance] setLabelFillColor:[UIColor colorWithRed:0.098 green:0.220 blue:0.396 alpha:1.000]];
    
    [[TRSDialScrollView appearance] setLabelFont:[UIFont fontWithName:@"Avenir" size:20]];
    
    [[TRSDialScrollView appearance] setMinorTickColor:[UIColor colorWithRed:0.800 green:0.553 blue:0.318 alpha:1.000]];
    [[TRSDialScrollView appearance] setMinorTickLength:15.0];
    [[TRSDialScrollView appearance] setMinorTickWidth:1.0];
    
    [[TRSDialScrollView appearance] setMajorTickColor:[UIColor colorWithRed:0.098 green:0.220 blue:0.396 alpha:1.000]];
    [[TRSDialScrollView appearance] setMajorTickLength:33.0];
    [[TRSDialScrollView appearance] setMajorTickWidth:2.0];
    
    [[TRSDialScrollView appearance] setShadowColor:[UIColor colorWithRed:0.593 green:0.619 blue:0.643 alpha:1.000]];
    [[TRSDialScrollView appearance] setShadowOffset:CGSizeMake(0, 1)];
    [[TRSDialScrollView appearance] setShadowBlur:0.9f];
    
    [_dialView setDialRangeFrom:30 to:110];
    if (self.isFromHeightSettingsVC) {
        _dialView.currentValue = 50;//系统默认设置值
    }
    else
        _dialView.currentValue = self.userInfo.weight;

    self.currentWeightLabel.text = [NSString stringWithFormat:@"%li", (long)_dialView.currentValue];
    _dialView.delegate = self;
    _dialView.layer.masksToBounds = YES;
    _dialView.layer.cornerRadius = CornerRadius;
    _dialView.layer.borderWidth = 1.0;
    _dialView.layer.borderColor = ColorRed_Normal.CGColor;
    [self.view addSubview:self.dialView];
    
    [self.dialView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentWeightLabel.mas_bottom).offset(@20);
        make.width.equalTo(self.dialView.frame.size.width);
        make.left.equalTo(self.dialView.frame.origin.x);
        make.height.equalTo(self.dialView.bounds.size.height);
    }];
    
    UIView *redLine = [UIView new];
    redLine.frame = CGRectMake(_dialView.frame.size.width/2-1, 0, 2, _dialView.bounds.size.height-20);
    [_dialView addSubview:redLine];
    redLine.backgroundColor = ColorRed_Normal;
}

- (void)setupBarButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveUserInfo:)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *_avatarImagename = nil;
    if (self.userInfo.gender == GenderTypeMale) {
        _avatarImagename = @"settings-person-boy";
    } else if (self.userInfo.gender == GenderTypeFemale) {
        _avatarImagename = @"settings-person-girl";
    }
    
    _avatarImgV.image = [UIImage imageNamed:_avatarImagename];
}

#pragma mark - Action
- (void)saveUserInfo:(id)sender {
    // 请求保存个人设置
    self.userInfo.weight = _dialView.currentValue;
    [MBProgressHUD showActivityWithText:self.view text:@"保存中..." animated:YES];
    
    NSMutableDictionary *mdicData = [NSMutableDictionary dictionary];
    [mdicData setValue:[NSNumber numberWithInteger:self.userInfo.gender] forKey:@"gender"];
    [mdicData setValue:[NSNumber numberWithUnsignedInteger:self.userInfo.birYear] forKey:@"age"];
    [mdicData setValue:[NSNumber numberWithUnsignedInteger:self.userInfo.height] forKey:@"height"];
    [mdicData setValue:[NSNumber numberWithUnsignedInteger:self.userInfo.weight] forKey:@"weight"];

    __weak typeof(self) weakself = self;
    [[NRNetworkClient sharedClient] sendPost:@"user/info/base/set" parameters:mdicData success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        
        if (errorCode == 0) {
            // 1.保存用户的信息
            [NRLoginManager sharedInstance].age = [NSNumber numberWithUnsignedInteger:self.userInfo.age];
            [NRLoginManager sharedInstance].height = [NSNumber numberWithUnsignedInteger:self.userInfo.height];
            [NRLoginManager sharedInstance].weight = [NSNumber numberWithUnsignedInteger:self.userInfo.weight];
            [NRLoginManager sharedInstance].genderType = weakself.userInfo.gender;
            
            // 2.通知更新用户信息
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_LoginSuccess object:nil];
            });
            
            [MBProgressHUD showDoneWithText:KeyWindow text:@"保存成功！"];
            
            // 3.返回主页面,通知所有登录成功
            [[NRLoginViewController sharedInstance] dismissViewControllerAnimated:YES completion:^{
                [weakself.navigationController popToRootViewControllerAnimated:NO];
            }];
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}

- (void)back:(id)sender {
    [super back:sender];
    self.userInfo.weight  = _dialView.currentValue;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 从中可以读取contentOffset属性以确定其滚动到的位置。
    self.currentWeightLabel.text = [NSString stringWithFormat:@"%li", (long)_dialView.currentValue];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
