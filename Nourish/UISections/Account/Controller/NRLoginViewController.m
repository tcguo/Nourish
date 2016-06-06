//
//  NRLoginViewController.m
//  Nourish
//
//  Created by gtc on 14/12/25.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import "NRLoginViewController.h"
#import "BMButton.h"
#import "MBProgressHUD.h"
#import "NRNetworkClient.h"
#import "NRNavigationController.h"
#import "NRRegisterViewController.h"
#import "NRFindBackPwdPhoneNumViewController.h"
#import "NRPersonSexSettingController.h"
#import "NRLoginManager.h"

#import "NSString+FontAwesome.h"
#import "NSString+Validation.h"
#import "NRThirdLoginShareClient.h"

#import "NRFindBackPwdSetNewViewController.h"

@interface NRLoginViewController ()<UITextFieldDelegate, ThirdLoginShareDelegate>
{
    UITextField *_tfUserName;
    UITextField *_tfPassword;
    BMButton    *_btnLogin;
    UIButton    *_forgetPwdButton;
    UIImageView *_loginImgView;
    UIImageView *_tfbgImgView;
    UIButton    *_btnQQ;
    UIButton    *_btnWeixin;
    UIButton    *_btnWeibo;
}

@property (nonatomic, weak) NSURLSessionDataTask *loginDataTask;
@property (nonatomic, weak) NSURLSessionDataTask *saveDataTask;

@end

@implementation NRLoginViewController

+ (instancetype)sharedInstance {
    static NRLoginViewController *loginVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginVC = [[NRLoginViewController alloc] init];
        loginVC.hidesBottomBarWhenPushed = YES;
    });
    
    return loginVC;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftClose];
    self.navigationItem.title = @"登录";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupRightNavButtonWithTitle:@"注册" action:@selector(userRegister:)];
    [self addControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _tfUserName.text = @"";
    _tfPassword.text = @"";
}

- (void)addControls {
    _loginImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-login"]];
    _loginImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_loginImgView];
    _loginImgView.tag = ExceptTag;
    _loginImgView.frame = CGRectMake((self.view.bounds.size.width-87)/2, 20, 87, 80);
    
    _tfbgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-text-bg"]];
    _tfbgImgView.frame = CGRectMake(20, 120, TextFieldDefaultWidth, TextFieldDefaultHeight*2);
    _tfbgImgView.contentMode = UIViewContentModeScaleToFill;
    _tfbgImgView.userInteractionEnabled = YES;
    
    [self.view addSubview:_tfbgImgView];
    
    _tfUserName = [[UITextField alloc] initWithFrame:CGRectMake(32, 1, TextFieldDefaultWidth-32, TextFieldDefaultHeight-2)];
    _tfUserName.placeholder = @"请输入手机号";
    _tfUserName.layer.cornerRadius = CornerRadius;
    _tfUserName.keyboardType = UIKeyboardTypeNumberPad;
    _tfUserName.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _tfUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfUserName.backgroundColor = [UIColor clearColor];
    _tfUserName.delegate = self;
    [_tfbgImgView addSubview:_tfUserName];
    
    _tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(32, 41, TextFieldDefaultWidth-32, TextFieldDefaultHeight-2)];
    _tfPassword.placeholder = @"请输入密码";
    _tfPassword.layer.cornerRadius = CornerRadius;
    _tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
    _tfPassword.secureTextEntry = YES;
    _tfPassword.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfPassword.backgroundColor = [UIColor clearColor];
    _tfPassword.delegate = self;
    [_tfbgImgView addSubview:_tfPassword];
    
    
    _btnLogin = [BMButton buttonWithType:UIButtonTypeCustom];
    [_btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [_btnLogin.titleLabel setFont:NRFont(FontButtonTitleSize)];
    _btnLogin.frame = CGRectMake(20, 225, ButtonDefaultWidth, ButtonDefaultHeight);
    [_btnLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    _btnLogin.exclusiveTouch = YES;
    [self.view addSubview:_btnLogin];

    _forgetPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forgetPwdButton setTitle:@"忘记密码 ?" forState:UIControlStateNormal];
    _forgetPwdButton.titleLabel.font = NRFont(12);
    [_forgetPwdButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
    [_forgetPwdButton addTarget:self action:@selector(findbackPwd:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_forgetPwdButton];
    [_forgetPwdButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_btnLogin.mas_right).offset(-5);
        make.height.equalTo(@12);
        make.top.equalTo(_btnLogin.mas_bottom).offset(@12);
    }];
    
    // 三方login
    UILabel *linianLabel = [[UILabel alloc] init];
    linianLabel.text = @"第三方平台";
    linianLabel.font  = SysFont(14);
    linianLabel.textColor = RgbHex2UIColor(0xd3, 0xd3, 0xd3);
    [self.view addSubview:linianLabel];
    [linianLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-80*self.appdelegate.autoSizeScaleY);
    }];
    
    UIView *leftLineView = [UIView new];
    leftLineView.backgroundColor = RgbHex2UIColor(0xE2, 0xE2, 0xE2);
    [self.view addSubview:leftLineView];
    [leftLineView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(linianLabel.centerY);
        make.left.equalTo(10);
        make.right.equalTo(linianLabel.mas_left).offset(-15);
        make.height.equalTo(0.5);
    }];
    
    UIView *rightLineView = [UIView new];
    [self.view addSubview:rightLineView];
    rightLineView.backgroundColor = RgbHex2UIColor(0xE2, 0xE2, 0xE2);
    [rightLineView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(linianLabel.centerY);
        make.right.equalTo(-10);
        make.left.equalTo(linianLabel.mas_right).offset(15);
        make.height.equalTo(0.5);
    }];

    _btnWeixin = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnWeixin setImage:[UIImage imageNamed:@"login-appwx-logo"] forState:UIControlStateNormal];
//    [_btnWeixin setBackgroundImage:[UIImage imageNamed:@"login-appwx-logo"] forState:UIControlStateNormal];
    _btnWeixin.tag = 0;
    _btnWeixin.contentMode = UIViewContentModeScaleToFill;
    _btnWeixin.exclusiveTouch = YES;
    [_btnWeixin addTarget:self action:@selector(thirdLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnWeixin];
    [_btnWeixin makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX).offset(-self.view.bounds.size.width/4);
        make.bottom.equalTo(self.view.mas_bottom).offset(-25);
        make.height.and.width.equalTo(32*self.appdelegate.autoSizeScaleX);
    }];
    
    _btnQQ = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnQQ setImage:[UIImage imageNamed:@"login-qq"] forState:UIControlStateNormal];
//    [_btnQQ setBackgroundImage:[UIImage imageNamed:@"login-qq"] forState:UIControlStateNormal];
    _btnQQ.tag = 1;
    _btnQQ.contentMode = UIViewContentModeScaleToFill;
    _btnQQ.exclusiveTouch = YES;
    [_btnQQ addTarget:self action:@selector(thirdLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnQQ];
    [_btnQQ makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-25);
        make.height.and.width.equalTo(33*self.appdelegate.autoSizeScaleX);
    }];
    
    _btnWeibo = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnWeibo setImage:[UIImage imageNamed:@"login-weibo"] forState:UIControlStateNormal];
//    [_btnWeibo setBackgroundImage:[UIImage imageNamed:@"login-weibo"] forState:UIControlStateNormal];
    _btnWeibo.tag = 2;
    _btnWeibo.contentMode = UIViewContentModeScaleToFill;
    _btnWeibo.exclusiveTouch = YES;
    [_btnWeibo addTarget:self action:@selector(thirdLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnWeibo];
    [_btnWeibo makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX).offset(self.view.bounds.size.width/4);
        make.bottom.equalTo(self.view.mas_bottom).offset(-25);
        make.height.and.width.equalTo(32*self.appdelegate.autoSizeScaleX);
    }];
    
    
    [self autoLayView:self.view];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    [self.view addGestureRecognizer:tapGR];
}


#pragma mark - Action

- (void)login:(id)sender {
    NSString *userName  = _tfUserName.text;
    NSString *pwd =  _tfPassword.text;

    //1.校验
    if (userName.length == 0) {
        [MBProgressHUD showErrormsgOnWindow:@"请输入手机号"];
        return;
    }
    if (![userName isPhoneNum]) {
        [MBProgressHUD showErrormsgOnWindow:@"请输入正确的手机号"];
        return;
    }
    
    if (pwd.length == 0) {
        [MBProgressHUD showErrormsgOnWindow:@"请输入密码"];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showActivityWithText:self.view text:@"登录中..." animated:YES];
    NSString *channelId = @"";
    if (STRINGHASVALUE([NRLoginManager sharedInstance].channelId)) {
        channelId = [NRLoginManager sharedInstance].channelId;
    }
    NSString *device = @"";
    if (STRINGHASVALUE([NRLoginManager sharedInstance].deviceToken)) {
        device = [NRLoginManager sharedInstance].deviceToken;
    }
    NSDictionary *dic_userInfo = nil;
    dic_userInfo = @{ @"cellphone": userName,
                      @"password": pwd,
                      @"channelId":channelId,
                      @"deviceToken": device };

    if (self.loginDataTask) {
        [self.loginDataTask cancel];
    }
    
    self.loginDataTask = [[NRNetworkClient sharedClient] sendPost:@"user/login" parameters:dic_userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
         
         [MBProgressHUD hideActivityWithText:self.view animated:YES];
         if (errorCode == 0) {
             NSString *sessionID = [res valueForKey:@"sessionid"];
             NSString *token     = [res valueForKey:@"token"];
             NSString *nickname  = [res valueForKey:@"nickname"];
             NSString *avatarUrl = [res valueForKey:@"avatarUrl"];
             NSString *cellPhone = [res valueForKey:@"cellphone"];
             NSNumber *age = [res valueForKey:@"age"];
             NSNumber *height = [res valueForKey:@"height"];
             NSNumber *weight = [res valueForKey:@"weight"];
             NSNumber *numGender = [res valueForKey:@"gender"];
             
             [NRLoginManager sharedInstance].token = token;
             [NRLoginManager sharedInstance].sessionId = sessionID;
             
             [NRLoginManager sharedInstance].nickName = nickname;
             [NRLoginManager sharedInstance].avatarUrl = avatarUrl;
             [NRLoginManager sharedInstance].cellPhone = cellPhone;
             
             if (OBJHASVALUE(numGender) && [numGender integerValue] != GenderTypeUnknown) {
                 [NRLoginManager sharedInstance].genderType = [numGender integerValue];
                 if (OBJHASVALUE(age)) {
                     [NRLoginManager sharedInstance].age = age;
                 }
                 if (OBJHASVALUE(height)) {
                     [NRLoginManager sharedInstance].height = height;
                 }
                 if (OBJHASVALUE(weight)) {
                     [NRLoginManager sharedInstance].weight = weight;
                 }
#ifdef DEBUG
                 [[NRLoginManager sharedInstance] archivedData];
#endif
                 [weakSelf loginDidSuccess];
             }
             else {
                 //强制去设置性别，身高，体重
                [MBProgressHUD showDoneWithText:KeyWindow text:@"登录成功"];
                 NRPersonSexSettingController *sexVC = [[NRPersonSexSettingController alloc] initWithUserInfo:nil isfromRegister:YES];
                 [weakSelf.navigationController pushViewController:sexVC animated:YES];
             }
         }
        
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [weakSelf processRequestError:error];
     }];
}

- (void)thirdLogin:(id)sender {
    UIButton *btn = (UIButton*)sender;
    NSInteger tag = btn.tag;
    NRThirdLoginShareClient *client = [NRThirdLoginShareClient shareInstance];
    client.thirdLoginShareDelegate = self;
    
    if (tag == 0) {
        [client loginByWechat];
    }
    else if (tag == 1) {
        [client loginByQQ];
    }
    else if (tag == 2) {
        [client loginBySinaWeibo];
    }
}

- (void)userRegister:(id)sender {
    self.hidesBottomBarWhenPushed = YES;
    NRRegisterViewController *registerVC = [[NRRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)findbackPwd:(id)sender {
    self.hidesBottomBarWhenPushed = YES;
//    NRFindBackPwdSetNewViewController *findBackPWD = [[NRFindBackPwdSetNewViewController alloc] initWithPhoneNum:@"18612839407" verifyCode:@"525937"];
    
    NRFindBackPwdPhoneNumViewController *findBackPWD = [[NRFindBackPwdPhoneNumViewController alloc] init];
    [self.navigationController pushViewController:findBackPWD animated:YES];
}

- (void)hideKeyBoard:(id)sender {
    if([_tfPassword isFirstResponder]) {
        [_tfPassword resignFirstResponder];
    }
    if ([_tfUserName isFirstResponder]) {
        [_tfUserName resignFirstResponder];
    }
}


#pragma mark - ThirdLoginDelegate
- (void)loginDidSuccess {
    [MBProgressHUD showDoneWithText:KeyWindow text:@"登录成功"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_LoginSuccess object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginDidFailure:(NSString *)errorMsg {
    
}

- (void)requestSaveThirdUserInfo:(NSMutableDictionary *)data {
    // 保存三方用户信息
    __weak typeof(self) weakself = self;
    NSString *channelId = @"";
    if (STRINGHASVALUE([NRLoginManager sharedInstance].channelId)) {
        channelId = [NRLoginManager sharedInstance].channelId;
    }
    NSString *device = @"";
    if (STRINGHASVALUE([NRLoginManager sharedInstance].deviceToken)) {
        device = [NRLoginManager sharedInstance].deviceToken;
    }
    [data setValue:channelId forKey:@"channelId"];
    [data setValue:device forKey:@"deviceToken"];
    
    if (self.saveDataTask) {
        [self.saveDataTask cancel];
    }
    
    self.saveDataTask = [[NRNetworkClient sharedClient] sendPost:@"register/third/do" parameters:data success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        //取消NRThirdLoginClient中发起的加载
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        if (errorCode == 0) {
            //在NSUserDefault中保存值
            NSString *sessionID = [res valueForKey:@"sessionid"];
            NSString *token     = [res valueForKey:@"token"];
            NSString *nickname  = [res valueForKey:@"nickname"];
            NSString *avatarUrl = [res valueForKey:@"avatarUrl"];
            NSString *cellPhone = [res valueForKey:@"cellphone"];
            
            NSNumber *numGender = [res valueForKey:@"gender"];
            NSNumber *age = [res valueForKey:@"age"];
            NSNumber *height = [res valueForKey:@"height"];
            NSNumber *weight = [res valueForKey:@"weight"];
            
            [NRLoginManager sharedInstance].sessionId = sessionID;
            [NRLoginManager sharedInstance].token = token;
            
            [NRLoginManager sharedInstance].nickName = nickname;
            [NRLoginManager sharedInstance].avatarUrl = avatarUrl;
            [NRLoginManager sharedInstance].cellPhone = cellPhone;
        
            // 用户尚未设置性别、身高、体重
            if (OBJHASVALUE(numGender) && [numGender integerValue] != GenderTypeUnknown) {
                [NRLoginManager sharedInstance].genderType = [numGender integerValue];
                if (OBJHASVALUE(age)) {
                    [NRLoginManager sharedInstance].age = age;
                }
                if (OBJHASVALUE(height)) {
                    [NRLoginManager sharedInstance].height = height;
                }
                if (OBJHASVALUE(weight)) {
                    [NRLoginManager sharedInstance].weight = weight;
                }
                
                [weakself loginDidSuccess];
            } else {
                [MBProgressHUD showDoneWithText:KeyWindow text:@"登录成功"];
                NRPersonSexSettingController *sexVC = [[NRPersonSexSettingController alloc] initWithUserInfo:nil isfromRegister:YES];
                [weakself.navigationController pushViewController:sexVC animated:YES];
            }
            
        } else {
            [MBProgressHUD showErrormsg:self.view msg:@"登录出错了" completionBlock:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        [weakself processRequestError:error];
    }];
}


#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
