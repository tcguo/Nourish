//
//  NRRegisterViewController.m
//  Nourish
//
//  Created by gtc on 14/12/25.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import "NRRegisterViewController.h"
#import "NRSMSVerifyViewController.h"
#import "Constants.h"
#import "BMTextField.h"
#import "BMButton.h"
#import "MBProgressHUD.h"
#import "NSString+Validation.h"
#import "NRRegisterAgreementViewController.h"

#define navSegmentHeighgt 41
#define tagCurrent 100

@interface NRRegisterViewController ()
{
    BMTextField *_tfPhoneNum;
    BMButton *_btnGetVerifyCode;
    UIButton *_btnCheck;
    BOOL _isChecked;
}
@end

@implementation NRRegisterViewController

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
    
    _btnCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCheck setImage:[UIImage imageNamed:@"reg-checked"] forState:UIControlStateNormal];
    _isChecked = YES;
    [_btnCheck addTarget:self action:@selector(switchCheck:) forControlEvents:UIControlEventTouchUpInside];
    _btnCheck.frame = CGRectMake(30, _btnGetVerifyCode.frame.origin.y+ButtonDefaultHeight+30, 20, 20);
    [self.view addSubview:_btnCheck];
    
    UILabel *lblAgree = [[UILabel alloc] initWithFrame:CGRectMake(60, _btnGetVerifyCode.frame.origin.y +ButtonDefaultHeight+30, 125, 16)];
    lblAgree.font = SysFont(FontLabelSize);
    lblAgree.text = @"我已经阅读并同意";
    lblAgree.textColor = ColorBaseFont;
    [self.view addSubview:lblAgree];
    
    UIButton *btnLook = [UIButton buttonWithType:UIButtonTypeCustom];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"诺食用户协议"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:ColorRed_Normal range:strRange];
    [str addAttribute:NSFontAttributeName value:SysFont(FontLabelSize) range:strRange];
    [btnLook setAttributedTitle:str forState:UIControlStateNormal];
    btnLook.frame = CGRectMake(lblAgree.frame.origin.x +lblAgree.frame.size.width +5, lblAgree.frame.origin.y+1, 100, 16);
    [btnLook addTarget:self action:@selector(lookAgreement:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLook];
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
    if (phone.length == 0) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"请输入手机号"];
        return;
    }
    if (![phone isPhoneNum]) {
        [MBProgressHUD showErrormsgOnWindow:@"请输入正确的手机号"];
        return;
    }
    
    [MBProgressHUD showActivityWithText:self.view text:@"获取验证码..." animated:YES];
    NSDictionary *dic = @{@"cellphone": phone};
    
    __weak typeof(self) weakself = self;
    [[NRNetworkClient sharedClient] sendPost:@"register/sendValidCode" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD hideActivityWithText:self.view animated:YES];
        
        if (errorCode == 0) {
            NRSMSVerifyViewController *smsVC = [[NRSMSVerifyViewController alloc] initWithPhoneNum:phone];
            smsVC.smsVCode = [NSString stringWithFormat:@"%@", res];
            [weakself.navigationController pushViewController:smsVC animated:NO];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}

- (void)switchCheck:(id)sender {
    if (_isChecked) {
        [_btnCheck setImage:[UIImage imageNamed:@"reg-unchecked"] forState:UIControlStateNormal];
        _isChecked = NO;
    }
    else {
        [_btnCheck setImage:[UIImage imageNamed:@"reg-checked"] forState:UIControlStateNormal];
        _isChecked = YES;
    }
}

- (void)lookAgreement:(id)sender {
    NRRegisterAgreementViewController *agreeVC = [[NRRegisterAgreementViewController alloc] init];
    agreeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:agreeVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


@end
