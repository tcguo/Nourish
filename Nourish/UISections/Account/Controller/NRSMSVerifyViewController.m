//
//  NRSMSVerifyViewController.m
//  Nourish
//
//  Created by gtc on 15/1/7.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSMSVerifyViewController.h"
#import "NRLoginViewController.h"
#import "Constants.h"
#import "BMButton.h"
#import "BMTextField.h"
#import "NRSetPwdViewController.h"

#define navSegmentHeighgt 41
#define tagCurrent 100

@interface NRSMSVerifyViewController ()
{
    BMTextField *_tfVerifyCode;
    BMButton *_btnEnsureVerifyCode;
    UILabel *_lblTipPhoneNum;
    UILabel *_lblPhoneNum;
}
@end

@implementation NRSMSVerifyViewController

- (id)initWithPhoneNum:(NSString *)phoneNum {
    self = [super init];
    if (self) {
        _phoneNum = phoneNum;
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
    UILabel *currentLabel = [secondSegment viewWithTag:tagCurrent];
    currentLabel.textColor = ColorRed_Normal;
    [secondSegment setFrame:CGRectMake(navWidth, 0, navWidth, navSegmentHeighgt)];
    
    UIView *thirdSegment = [self createNavSegmentViewWithWidth:navWidth title:@"3 设置密码"];
    [navView addSubview:thirdSegment];
    [thirdSegment setFrame:CGRectMake(navWidth*2, 0, navWidth, navSegmentHeighgt)];
    
    // 文本
    _lblTipPhoneNum = [[UILabel alloc] init];
    _lblTipPhoneNum.font = SysFont(FontLabelSize);
    _lblTipPhoneNum.text = @"短信验证码已发送到";
    _lblTipPhoneNum.textColor = ColorGragBorder;
    [self.view addSubview:_lblTipPhoneNum];
    [_lblTipPhoneNum makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(61);
        make.left.equalTo(35);
        make.height.equalTo(15);
    }];
    
    _lblPhoneNum = [[UILabel alloc] init];
    _lblPhoneNum.font = SysFont(FontLabelSize-1);
    _lblPhoneNum.text = self.phoneNum;
    _lblPhoneNum.textColor = ColorGragBorder;
    [self.view addSubview:_lblPhoneNum];
    [_lblPhoneNum makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lblTipPhoneNum.mas_right).offset(5);
        make.top.equalTo(61);
        make.height.equalTo(FontLabelSize);
    }];
    
    _tfVerifyCode = [[BMTextField alloc] init];
    _tfVerifyCode.placeholder = @"请输入验证码";
    _tfVerifyCode.keyboardType = UIKeyboardTypeNumberPad;
    _tfVerifyCode.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_tfVerifyCode];
    
    [_tfVerifyCode makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblTipPhoneNum.mas_bottom).offset(10);
        make.left.equalTo(20);
        make.right.equalTo(-20);
        make.height.equalTo(TextFieldDefaultHeight);
    }];
    
    _btnEnsureVerifyCode = [BMButton buttonWithType:UIButtonTypeCustom];
    _btnEnsureVerifyCode.frame = CGRectMake(20, _tfVerifyCode.frame.origin.y + TextFieldDefaultHeight +30, ButtonDefaultWidth, ButtonDefaultHeight);
    [_btnEnsureVerifyCode setTitle:@"输入验证码" forState:UIControlStateNormal];
    [_btnEnsureVerifyCode addTarget:self action:@selector(toSetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnEnsureVerifyCode];
    [_btnEnsureVerifyCode makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfVerifyCode.mas_bottom).offset(20);
        make.left.equalTo(20);
        make.right.equalTo(-20);
        make.height.equalTo(ButtonDefaultHeight);
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

- (void)toSetPassword:(id)sender {
    if (_tfVerifyCode.text.length == 0) {
        [MBProgressHUD showErrormsg:self.view msg:@"请输入验证码"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{ @"cellphone": self.phoneNum,
                           @"code": _tfVerifyCode.text };
    
    __weak typeof(self) weakSelf = self;
    [[NRNetworkClient sharedClient] sendPost:@"register/validCode" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (errorCode == 0) {
            NRSetPwdViewController *setPwdVC = [[NRSetPwdViewController alloc] initWithPhoneNum:weakSelf.phoneNum verfiyCode:_tfVerifyCode.text];
            [weakSelf.navigationController pushViewController:setPwdVC animated:NO];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

@end
