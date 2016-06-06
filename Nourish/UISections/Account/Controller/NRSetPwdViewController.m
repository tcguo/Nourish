//
//  NRSetPwdViewController.m
//  Nourish
//
//  Created by gtc on 15/1/7.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSetPwdViewController.h"
#import "NRLoginViewController.h"
#import "Constants.h"
#import "BMButton.h"
#import "BMTextField.h"
#import "NRPersonSexSettingController.h"
#import "NRLoginManager.h"
#import "NSString+Validation.h"

#define navSegmentHeighgt 41
#define tagCurrent 100

@interface NRSetPwdViewController ()<UITextFieldDelegate>
{
    BMTextField *_tfUsername; // 昵称4——22字符
    BMTextField *_tfPwd; //6-20位字符
    BMTextField *_tfRepeatPwd;
    BMButton *_btnDone;
}

@end

@implementation NRSetPwdViewController

- (id)initWithPhoneNum:(NSString *)phoneNum verfiyCode:(NSString *)code {
    self = [super init];
    if (self) {
        _phoneNum = phoneNum;
        _verfiyCode = code;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"注册";
    [self addControls];
}

- (void)addControls {
    UIView *navbgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, navSegmentHeighgt)];
    navbgView.backgroundColor = ColorGrayBg;
    [self.view addSubview:navbgView];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, navSegmentHeighgt)];
    navView.backgroundColor = [UIColor clearColor];
    [navbgView  addSubview:navView];
    
    CGFloat navWidth = (SCREEN_WIDTH-40)/3;
    UIView *firstSegment = [self createNavSegmentViewWithWidth:navWidth title:@"1 输入手机号"];
    [navView addSubview:firstSegment];
    [firstSegment setFrame:CGRectMake(0, 0, navWidth, navSegmentHeighgt)];
    
    UIView *secondSegment = [self createNavSegmentViewWithWidth:navWidth title:@"2 输入验证码"];
    [navView addSubview:secondSegment];
    [secondSegment setFrame:CGRectMake(navWidth, 0, navWidth, navSegmentHeighgt)];
    
    UIView *thirdSegment = [self createNavSegmentViewWithWidth:navWidth title:@"3 设置密码"];
    UILabel *currentLabel = [thirdSegment viewWithTag:tagCurrent];
    currentLabel.textColor = ColorRed_Normal;
    [navView addSubview:thirdSegment];
    [thirdSegment setFrame:CGRectMake(navWidth*2, 0, navWidth, navSegmentHeighgt)];
    
    CGFloat spaceHeight = 20;
    CGFloat paddingLeft = 35;
    _tfUsername = [[BMTextField alloc] initWithFrame:CGRectMake(20, navbgView.frame.origin.y + navView.bounds.size.height + 25, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfUsername.placeholder = @"请输入昵称(4~22)";
    [_tfUsername setTextFieldLeftImage:[UIImage imageNamed:@"reg-username"]];
    [_tfUsername setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfUsername.keyboardType = UIKeyboardTypeDefault;
    _tfUsername.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_tfUsername];
    
    _tfPwd = [[BMTextField alloc] initWithFrame:CGRectMake(20, _tfUsername.frame.origin.y + _tfUsername.bounds.size.height + spaceHeight, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfPwd.placeholder = @"请输入密码(6~20)";
    [_tfPwd setTextFieldLeftImage:[UIImage imageNamed:@"reg-password"]];
    [_tfPwd setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfPwd.keyboardType = UIKeyboardTypeASCIICapable;
    _tfPwd.returnKeyType = UIReturnKeyDone;
    _tfPwd.secureTextEntry = YES;
    _tfPwd.delegate = self;
    [self.view addSubview:_tfPwd];
    
    _tfRepeatPwd = [[BMTextField alloc] initWithFrame:CGRectMake(20, _tfPwd.frame.origin.y + _tfPwd.bounds.size.height + spaceHeight, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfRepeatPwd.placeholder = @"请再次输入密码(6~20)";
    [_tfRepeatPwd setTextFieldLeftImage:[UIImage imageNamed:@"reg-password"]];
    [_tfRepeatPwd setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfRepeatPwd.keyboardType = UIKeyboardTypeASCIICapable;
    _tfRepeatPwd.returnKeyType = UIReturnKeyDone;
    _tfRepeatPwd.secureTextEntry = YES;
    _tfRepeatPwd.delegate = self;
    [self.view addSubview:_tfRepeatPwd];
    
    _btnDone = [BMButton buttonWithType:UIButtonTypeCustom];
    _btnDone.frame = CGRectMake(20, _tfRepeatPwd.frame.origin.y + TextFieldDefaultHeight +spaceHeight+10, SCREEN_WIDTH-40, ButtonDefaultHeight);
    [_btnDone setTitle:@"完成" forState:UIControlStateNormal];
    [_btnDone addTarget:self action:@selector(submitRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnDone];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
}

- (UIView *)createNavSegmentViewWithWidth:(CGFloat)width title:(NSString *)title  {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, navSegmentHeighgt)];
    
    UILabel *lblPhone = [[UILabel alloc] init];
    lblPhone.text = title;
    lblPhone.tag = tagCurrent;
    lblPhone.backgroundColor = [UIColor clearColor];
    lblPhone.font = SysFont(FontLabelSize-2);
    [containerView addSubview:lblPhone];
    [lblPhone makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(FontLabelSize-2);
        make.centerY.equalTo(containerView.centerY);
        make.left.equalTo(0);
    }];
    
    UIImageView *imgNav = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reg-jiantou"]];
    [containerView addSubview:imgNav];
    [imgNav makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(10);
        make.height.equalTo(16);
        make.right.equalTo(containerView.mas_right).offset(-10);
        make.centerY.equalTo(containerView.centerY);
    }];
    
    return containerView;
}

- (void)hideKeyBoard {
    [_tfUsername resignFirstResponder];
    [_tfPwd resignFirstResponder];
    [_tfRepeatPwd resignFirstResponder];
}

#pragma mark - private Methods

- (void)submitRegister:(id)sender {
    NSString *nickName = [_tfUsername.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strPwd = _tfPwd.text;
    NSString *strRePwd = _tfRepeatPwd.text;
    
    if (nickName.length == 0) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"昵称不能为空"];
        return;
    }
    if (![nickName isNickName]) {
        [MBProgressHUD showErrormsgWithoutIcon:KeyWindow title:@"昵称只能由中文、字母或数字组成" detail:nil];
        return;
    };
    int nlength = [nickName getCharLength];
    if (nlength < 4 || nlength > 22) {
        [MBProgressHUD showErrormsgWithoutIcon:KeyWindow title:@"昵称长度不合法" detail:nil];
        return;
    }
    
    if (strPwd.length == 0) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"密码不能为空"];
        return;
    }
    if (![strPwd isPassWord]) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"密码格式不合法"];
        return;
    }
    
    if (strRePwd.length == 0) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"二次密码不能为空"];
        return;
    }
    
    if (![strRePwd isPassWord]) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"密码格式不合法"];
        return;
    }
    
    if (![strRePwd isEqualToString:strRePwd]) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"两次密码不一致"];
        return;
    }
    
    NSString *channelId = @"";
    if (STRINGHASVALUE([NRLoginManager sharedInstance].channelId)) {
        channelId = [NRLoginManager sharedInstance].channelId;
    }
    NSString *device = @"";
    if (STRINGHASVALUE([NRLoginManager sharedInstance].deviceToken)) {
        device = [NRLoginManager sharedInstance].deviceToken;
    }
    
    NSDictionary *dic = @{ @"cellphone": self.phoneNum,
                           @"nickname": nickName,
                           @"password": strRePwd,
                           @"validCode":self.verfiyCode,
                           @"channelId": channelId,
                           @"deviceToken": device};
    
    __weak typeof(self) weakself = self;
    [MBProgressHUD showActivityWithText:self.view text:@"正在保存..." animated:YES];
    [[NRNetworkClient sharedClient] sendPost:@"register/do" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {

        [MBProgressHUD hideActivityWithText:self.view animated:YES];
        if (errorCode == 0) {
            // 注册成功，返回新的sessionid和token
            NSString *token = [res valueForKey:@"token"];
            NSString *sessionid = [res valueForKey:@"sessionid"];
            [NRLoginManager sharedInstance].token = token;
            [NRLoginManager sharedInstance].sessionId = sessionid;
            [NRLoginManager sharedInstance].nickName = nickName;
            
            [MBProgressHUD showDoneWithText:KeyWindow text:@"注册成功！"];
            
            // 强制设置性别、身高、体重
            NRPersonSexSettingController *sexSettingsVC = [[NRPersonSexSettingController alloc] initWithUserInfo:nil isfromRegister:YES];
            [weakself.navigationController pushViewController:sexSettingsVC animated:YES];
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}

- (void)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
