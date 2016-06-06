//
//  NRFindBackPwdSMSCodeViewController.m
//  Nourish
//
//  Created by gtc on 15/7/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRFindBackPwdSMSCodeViewController.h"
#import "BMTextField.h"
#import "BMButton.h"
#import "NRFindBackPwdSetNewViewController.h"
#import "NSString+Validation.h"

#define navSegmentHeighgt 41
#define tagCurrent 100

@interface NRFindBackPwdSMSCodeViewController ()
{
    BMTextField *_tfVerifyCode;
    BMButton *_nextButton;
    BMButton *_getVerifyCodeButton;
    
    UILabel *_lblTipPhoneNum;
    UILabel *_lblPhoneNum;
    NSThread *_theThread;
    NSInteger _count;
    NSTimer *_countTimer;
}

@property (nonatomic, copy, readwrite) NSString *phoneNum;
@end

@implementation NRFindBackPwdSMSCodeViewController

- (id)initWithPhoneNum:(NSString *)phoneNum
{
    self = [super init];
    if (self) {
        _phoneNum = phoneNum;
        _count = 60;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"找回密码";
    [self setupControls];
    [self startThreadShutDown];
}

- (void)setupControls {
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
    UILabel *currentLabel = [secondSegment viewWithTag:tagCurrent];
    currentLabel.textColor = ColorRed_Normal;
    [navView addSubview:secondSegment];
    [secondSegment setFrame:CGRectMake(navWidth, 0, navWidth, navSegmentHeighgt)];
    
    UIView *thirdSegment = [self createNavSegmentViewWithWidth:navWidth title:@"3 设置密码"];
    [navView addSubview:thirdSegment];
    [thirdSegment setFrame:CGRectMake(navWidth*2, 0, navWidth, navSegmentHeighgt)];
    
    //文本
    _lblTipPhoneNum = [[UILabel alloc] initWithFrame:CGRectMake(35, navView.frame.origin.y + navView.bounds.size.height + 20, 145, LabelDefaultHeight)];
    _lblTipPhoneNum.font = SysFont(FontLabelSize-1);
    _lblTipPhoneNum.text = @"短信验证码已发送到";
    _lblTipPhoneNum.textColor = ColorGragBorder;
    [self.view addSubview:_lblTipPhoneNum];
    
    _lblPhoneNum = [[UILabel alloc] initWithFrame:CGRectMake(_lblTipPhoneNum.frame.origin.x +_lblTipPhoneNum.frame.size.width +5, navView.frame.origin.y + navView.bounds.size.height + 20, 100, LabelDefaultHeight)];
    _lblPhoneNum.font = NRFont(FontLabelSize-1);
    _lblPhoneNum.text = self.phoneNum;
    _lblPhoneNum.textColor = ColorGragBorder;
    [self.view addSubview:_lblPhoneNum];
    
    _tfVerifyCode = [[BMTextField alloc] init];
    _tfVerifyCode.placeholder = @"请输入验证码";
    _tfVerifyCode.keyboardType = UIKeyboardTypeNumberPad;
    _tfVerifyCode.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_tfVerifyCode];
    [_tfVerifyCode makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView.mas_bottom).offset(@46);
        make.left.equalTo(@20);
        make.height.equalTo(TextFieldDefaultHeight);
        make.width.equalTo(@170);
    }];
    
    _getVerifyCodeButton = [BMButton buttonWithType:UIButtonTypeCustom];
    _getVerifyCodeButton.frame = CGRectMake(20, _tfVerifyCode.frame.origin.y + TextFieldDefaultHeight +30, 100, TextFieldDefaultHeight);
    [_getVerifyCodeButton setTitle:@"重新获取(60s)" forState:UIControlStateNormal];
    [_getVerifyCodeButton.titleLabel setFont:NRFont(13)];
    [_getVerifyCodeButton addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getVerifyCodeButton];
    [_getVerifyCodeButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView.mas_bottom).offset(@46);
        make.left.equalTo(_tfVerifyCode.mas_right).offset(10);
        make.height.equalTo(TextFieldDefaultHeight);
        make.width.greaterThanOrEqualTo(@100);
    }];

    _nextButton = [BMButton buttonWithType:UIButtonTypeCustom];
    [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(toSetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
    [_nextButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(20);
        make.right.equalTo(-20);
        make.height.equalTo(ButtonDefaultHeight);
        make.top.equalTo(_getVerifyCodeButton.mas_bottom).offset(25);
    }];
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



#pragma mark - private Methods

- (void)startThreadShutDown
{
    _getVerifyCodeButton.enabled = NO;
    _theThread = [[NSThread alloc] initWithTarget:self selector:@selector(addTimerOnThread) object:nil];
    [_theThread start];
}

- (void)addTimerOnThread
{
    _countTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_countTimer forMode:NSDefaultRunLoopMode];
    [_countTimer fire];
    [[NSRunLoop currentRunLoop] run];
}

- (void)countDown {
    if (![NSThread currentThread].isCancelled) {
        _count-=1;
        if(_count == 0) {
            [_countTimer invalidate];
            _countTimer = nil;
        }
        
        [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
    }
}

- (void)updateUI
{
    if (_count == 0) {
        _getVerifyCodeButton.enabled = YES;
        [_theThread cancel];
        _count = 60;
    }
    
    [_getVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%lds)", _count] forState:UIControlStateDisabled];
}

- (void)getVerifyCode:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *dic = @{@"cellphone": self.phoneNum};
    __weak typeof(self) weakself = self;
    [[NRNetworkClient sharedClient] sendPost:@"register/find/pswd/send-valid-code" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        if (errorCode == 0) {
            [weakself startThreadShutDown];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}

- (void)toSetPassword:(id)sender
{
    //1.校验验证码
    NSString *verifyCode  = _tfVerifyCode.text;
    
    if (verifyCode.length == 0) {
        [MBProgressHUD showErrormsg:self.view msg:[NSString stringWithFormat:@"请输入验证码:%@", self.smsVCode]];
        return;
    }
    
    [MBProgressHUD showActivityWithText:self.view text:@"正在验证..." animated:YES];
    NSDictionary *dic = @{
                           @"cellphone": self.phoneNum,
                           @"code": verifyCode
                         };
    
    __weak typeof(self) weakself = self;
    [[NRNetworkClient sharedClient] sendPost:@"register/find/pswd/valid-code" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        
        NRFindBackPwdSetNewViewController *resetPwd = [[NRFindBackPwdSetNewViewController alloc] initWithPhoneNum:weakself.phoneNum  verifyCode:[dic valueForKey:@"code"]];
        [weakself.navigationController pushViewController:resetPwd animated:YES];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _theThread = nil;
}


@end
