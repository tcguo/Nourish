//
//  NRBindPhoneViewController.m
//  Nourish
//
//  Created by tcguo on 15/11/7.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBindPhoneViewController.h"
#import "BMTextField.h"
#import "BMButton.h"
#import "NSString+Validation.h"
#import "NRLoginManager.h"

@interface NRBindPhoneViewController ()
{
    BMTextField  *_tfPhoneNum;
    BMTextField  *_tfVerifyCode;
    BMButton *_getVerifyCodeButton;
    NSThread *_theThread;
    NSInteger _count;
    NSTimer *_countTimer;
}

@property (nonatomic, weak) NSURLSessionDataTask *getVerifyCodeTask;
@property (nonatomic, weak) NSURLSessionDataTask *submitTask;

@end


@implementation NRBindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title  = @"绑定手机";
    _count = 60;
    [self setupConfirmButton];
    [self setupControls];
}

- (void)setupControls {
    _tfPhoneNum = [[BMTextField alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfPhoneNum.placeholder = @"请输入手机号";
    _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
    _tfPhoneNum.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_tfPhoneNum];
    
    _tfVerifyCode = [[BMTextField alloc] init];
    _tfVerifyCode.placeholder = @"请输入验证码";
    _tfVerifyCode.keyboardType = UIKeyboardTypeNumberPad;
    _tfVerifyCode.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_tfVerifyCode];
    [_tfVerifyCode makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfPhoneNum.mas_bottom).offset(@20);
        make.left.equalTo(@20);
        make.height.equalTo(TextFieldDefaultHeight);
        make.width.greaterThanOrEqualTo(@170);
    }];
    
    _getVerifyCodeButton = [BMButton buttonWithType:UIButtonTypeCustom];
    [_getVerifyCodeButton setTitle:@"重新获取(60s)" forState:UIControlStateNormal];
    [_getVerifyCodeButton.titleLabel setFont:NRFont(13)];
    [_getVerifyCodeButton addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getVerifyCodeButton];
    [_getVerifyCodeButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfPhoneNum.mas_bottom).offset(@20);
        make.left.equalTo(_tfVerifyCode.mas_right).offset(10);
        make.height.equalTo(TextFieldDefaultHeight);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setupConfirmButton
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(bindPhone:)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem, nil];
    
}

#pragma mark - Action


- (void)getVerifyCode:(id)sender {
    [self hideKeyBoard];
    
    NSString *phone = _tfPhoneNum.text;
    if (![phone isPhoneNum]) {
        [MBProgressHUD showTips:self.view text:@"手机格式不正确"];
        return;
    }
    
    if (self.getVerifyCodeTask) {
        [self.getVerifyCodeTask cancel];
    }
    
    NSDictionary *dic = @{ @"cellphone": phone };
    
    __weak typeof(self) weakSelf = self;
    self.getVerifyCodeTask = [[NRNetworkClient sharedClient] sendPost:@"user/info/cellphone/bind/sendValid" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [weakSelf startThreadShutDown];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
}

- (void)bindPhone:(id)sender {
    [self hideKeyBoard];
    
    NSString *phone = _tfPhoneNum.text;
    NSString *code = _tfVerifyCode.text;
    
    if (![phone isPhoneNum]) {
        [MBProgressHUD showTips:self.view text:@"手机格式不正确"];
        return;
    }
    
    if (code.length == 0) {
        [MBProgressHUD showTips:self.view text:@"验证码不能为空"];
        return;
    }
    
    if (self.submitTask) {
        [self.submitTask cancel];
    }
    
    NSDictionary *userInfo = @{ @"cellphone": phone,
                                @"code": code };
    
    __weak typeof(self) weakSelf = self;
    self.submitTask = [[NRNetworkClient sharedClient] sendPost:@"user/info/cellphone/bind/do" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD showDoneWithText:KeyWindow text:@"绑定成功"];
        [NRLoginManager sharedInstance].cellPhone = phone;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_UpdateBindPhone object:nil];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
    
}

- (void)hideKeyBoard {
    [_tfPhoneNum resignFirstResponder];
    [_tfVerifyCode resignFirstResponder];
}

#pragma mark - Private Methods

- (void)startThreadShutDown
{
    _count = 60;
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

- (void)countDown
{
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
    
    [_getVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%lds)", (long)_count] forState:UIControlStateDisabled];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
