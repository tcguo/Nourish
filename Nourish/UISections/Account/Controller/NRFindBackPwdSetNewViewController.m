//
//  NRFindBackPwdSetNewViewController.m
//  Nourish
//
//  Created by gtc on 15/7/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRFindBackPwdSetNewViewController.h"
#import "BMTextField.h"
#import "BMButton.h"
#import "NRLoginViewController.h"

#define navSegmentHeighgt 41
#define tagCurrent 100

@interface NRFindBackPwdSetNewViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
{
    BMTextField *_tfPwd; //6-20位字符
    BMTextField *_tfRepeatPwd;
    BMButton *_btnDone;
}

@property (nonatomic, copy) NSString *cellphone;
@property (nonatomic, copy) NSString *verfiyCode;
@property (nonatomic, weak) NSURLSessionDataTask *resetTask;
@end

@implementation NRFindBackPwdSetNewViewController

- (id)initWithPhoneNum:(NSString *)phoneNum verifyCode:(NSString *)code {
    if (self = [super init]) {
        _cellphone = phoneNum;
        _verfiyCode = code;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"找回密码";
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
    CGFloat paddingLeft = 10;
    
    _tfPwd = [[BMTextField alloc] initWithFrame:CGRectMake(20, navSegmentHeighgt + spaceHeight, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfPwd.placeholder = @"请输入密码(6~20位)";
    [_tfPwd setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfPwd.keyboardType = UIKeyboardTypeASCIICapable;
    _tfPwd.returnKeyType = UIReturnKeyDone;
    _tfPwd.secureTextEntry = YES;
    _tfPwd.delegate = self;
    [self.view addSubview:_tfPwd];
    
    _tfRepeatPwd = [[BMTextField alloc] initWithFrame:CGRectMake(20, _tfPwd.frame.origin.y + _tfPwd.bounds.size.height + spaceHeight-10, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfRepeatPwd.placeholder = @"请再次输入密码(6~20位)";
    [_tfRepeatPwd setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfRepeatPwd.keyboardType = UIKeyboardTypeASCIICapable;
    _tfRepeatPwd.returnKeyType = UIReturnKeyDone;
    _tfRepeatPwd.secureTextEntry = YES;
    _tfRepeatPwd.delegate = self;
    [self.view addSubview:_tfRepeatPwd];
    
    _btnDone = [BMButton buttonWithType:UIButtonTypeCustom];
    _btnDone.frame = CGRectMake(20, _tfRepeatPwd.frame.origin.y+TextFieldDefaultHeight +spaceHeight+10, SCREEN_WIDTH-40, ButtonDefaultHeight);
    [_btnDone setTitle:@"完成" forState:UIControlStateNormal];
    [_btnDone addTarget:self action:@selector(resetDone:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)resetDone:(id)sender {
    NSString *strPwd = _tfPwd.text;
    NSString *strRePwd = _tfRepeatPwd.text;
    if (strPwd.length == 0) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"密码不能为空"];
        return;
    }
    if (strRePwd.length == 0) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"二次密码不能为空"];
        return;
    }
    
    NSDictionary *dic = @{ @"cellphone": self.cellphone,
                           @"password": strPwd,
                           @"repeatPswd": strRePwd,
                           @"validCode": self.verfiyCode};
    
    WeakSelf(self);
    if (self.resetTask) {
        [self.resetTask cancel];
    }
    [MBProgressHUD showActivityWithText:self.view text:@"正在重置..." animated:YES];
    self.resetTask = [[NRNetworkClient sharedClient] sendPost:@"register/find/pswd/reset" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        if (ISIOS8_OR_LATER) {
            UIAlertController *alertContr = [UIAlertController alertControllerWithTitle:@"密码重置成功" message:@"请重新登录" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_LogoutSuccess object:nil];
                NRLoginViewController *loginVC = [[NRLoginViewController alloc] init];
                [weakSelf.navigationController pushViewController:loginVC animated:YES];
            }];
            
            [alertContr addAction:confirmAction];
            [weakSelf presentViewController:alertContr animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"密码重置成功" message:@"请重新登录" delegate:self cancelButtonTitle:@"去登录" otherButtonTitles:nil];
            alertView.tag = 2000;
            [alertView show];
        }


        //返回主菜单
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_LogoutSuccess object:nil];
    NRLoginViewController *loginVC = [[NRLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)hideKeyBoard {
    [_tfPwd resignFirstResponder];
    [_tfRepeatPwd resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
