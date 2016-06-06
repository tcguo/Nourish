//
//  NRFindBackPwdPhoneNumViewController.m
//  Nourish
//
//  Created by gtc on 15/7/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRFindBackPwdPhoneNumViewController.h"
#import "BMTextField.h"
#import "BMButton.h"
#import "NRFindBackPwdSMSCodeViewController.h"
#import "NSString+Validation.h"

#define navSegmentHeighgt 41
#define tagCurrent 100

@interface NRFindBackPwdPhoneNumViewController ()
{
    BMTextField *_tfPhoneNum;
    BMButton *_btnGetVerifyCode;
}

@end

@implementation NRFindBackPwdPhoneNumViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"找回密码";
    [self setupControls];
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
    UILabel *currentLabel = [firstSegment viewWithTag:tagCurrent];
    currentLabel.textColor = ColorRed_Normal;
    [navView addSubview:firstSegment];
    [firstSegment setFrame:CGRectMake(0, 0, navWidth, navSegmentHeighgt)];
    
    UIView *secondSegment = [self createNavSegmentViewWithWidth:navWidth title:@"2 输入验证码"];
    [navView addSubview:secondSegment];
    [secondSegment setFrame:CGRectMake(navWidth, 0, navWidth, navSegmentHeighgt)];
    
    UIView *thirdSegment = [self createNavSegmentViewWithWidth:navWidth title:@"3 设置密码"];
    [navView addSubview:thirdSegment];
    [thirdSegment setFrame:CGRectMake(navWidth*2, 0, navWidth, navSegmentHeighgt)];
    
    _tfPhoneNum = [[BMTextField alloc] initWithFrame:CGRectMake(20, navbgView.frame.origin.y + navView.bounds.size.height + 20, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfPhoneNum.placeholder = @"请输入手机号";
    _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
    _tfPhoneNum.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_tfPhoneNum];
    
    _btnGetVerifyCode = [BMButton buttonWithType:UIButtonTypeCustom];
    _btnGetVerifyCode.frame = CGRectMake(20, _tfPhoneNum.frame.origin.y + TextFieldDefaultHeight +25, SCREEN_WIDTH-40, ButtonDefaultHeight);
    [_btnGetVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_btnGetVerifyCode addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnGetVerifyCode];
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

- (void)getVerifyCode:(id)sender {
    NSString *phone = _tfPhoneNum.text;
    NSString *trimPhone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (trimPhone && trimPhone.length == 0) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"请输入手机号"];
        return;
    }
    
    if (![phone isPhoneNum]) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"手机号格式不正确"];
        return;
    }
    
    NSDictionary *paramDic = @{@"cellphone": phone};
    
    WeakSelf(self);
    [[NRNetworkClient sharedClient] sendPost:@"register/find/pswd/send-valid-code" parameters:paramDic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD showDoneWithText:KeyWindow text:@"验证码已下发"];
        NRFindBackPwdSMSCodeViewController *smsVC = [[NRFindBackPwdSMSCodeViewController alloc] initWithPhoneNum:phone];
        NSString *smsCode = [NSString stringWithFormat:@"%@", res];
        smsVC.smsVCode = smsCode;
        [weakSelf.navigationController pushViewController:smsVC animated:NO];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
