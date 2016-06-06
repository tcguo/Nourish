//
//  NRModifyPwdViewController.m
//  Nourish
//
//  Created by tcguo on 15/11/7.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRModifyPwdViewController.h"
#import "BMTextField.h"
#import "NSString+Validation.h"
#include "NRLoginManager.h"

@interface NRModifyPwdViewController ()<UITextFieldDelegate>
{
    BMTextField *_tfPwd;
    BMTextField *_tfNewPwd;
    BMTextField *_tfNewPwdRepeat;
}

@property (nonatomic, weak) NSURLSessionDataTask *sessionTask;

@end

@implementation NRModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.title = @"修改密码";
    [self setupConfirmButton];
    [self setupControls];
}

- (void)setupControls {
    CGFloat spaceHeight = 20;
    CGFloat paddingLeft = 10;
    
    _tfPwd = [[BMTextField alloc] initWithFrame:CGRectMake(20, spaceHeight, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfPwd.placeholder = @"请输入当前密码";
    [_tfPwd setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfPwd.keyboardType = UIKeyboardTypeASCIICapable;
    _tfPwd.returnKeyType = UIReturnKeyDone;
    _tfPwd.secureTextEntry = YES;
    _tfPwd.delegate = self;
    [self.view addSubview:_tfPwd];
    
    _tfNewPwd = [[BMTextField alloc] initWithFrame:CGRectMake(20, _tfPwd.frame.origin.y + _tfPwd.bounds.size.height + spaceHeight, SCREEN_WIDTH -40, TextFieldDefaultHeight)];
    _tfNewPwd.placeholder = @"请输入新密码(6~20位)";
    [_tfNewPwd setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfNewPwd.keyboardType = UIKeyboardTypeASCIICapable;
    _tfNewPwd.returnKeyType = UIReturnKeyDone;
    _tfNewPwd.secureTextEntry = YES;
    _tfNewPwd.delegate = self;
    [self.view addSubview:_tfNewPwd];

    _tfNewPwdRepeat = [[BMTextField alloc] initWithFrame:CGRectMake(20, _tfNewPwd.frame.origin.y + _tfNewPwd.bounds.size.height + spaceHeight, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _tfNewPwdRepeat.placeholder = @"请再次输入新密码(6~20位)";
    [_tfNewPwdRepeat setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _tfNewPwdRepeat.keyboardType = UIKeyboardTypeASCIICapable;
    _tfNewPwdRepeat.returnKeyType = UIReturnKeyDone;
    _tfNewPwdRepeat.delegate = self;
    _tfNewPwdRepeat.secureTextEntry = YES;
    [self.view addSubview:_tfNewPwdRepeat];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setupConfirmButton
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(resetDone:)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem, nil];
    
}

#pragma mark - Action

- (void)resetDone:(id)sender {
    [self hideKeyBoard];
    NSString *oldPwd = _tfPwd.text;
    NSString *newPwd = _tfNewPwd.text;
    NSString *reNewPwd = _tfNewPwdRepeat.text;
    
    if (oldPwd.length == 0 || newPwd.length == 0 || reNewPwd.length == 0) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"密码不能为空"];
        return;
    }
    
    if (![newPwd isPassWord] || ![reNewPwd isPassWord]) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"密码格式不合法"];
        return;
    }
    
    if (![newPwd isEqualToString:reNewPwd]) {
        [MBProgressHUD showErrormsg:self.view.window msg:@"两次密码不一致"];
        return;
    }
    
    if (self.sessionTask) {
        [self.sessionTask cancel];
    }
    
    NSDictionary *userInfo = @{ @"oldPswd": oldPwd,
                                @"newPswd1": newPwd,
                                @"newPswd2": reNewPwd };
    
    __weak typeof(self) weakSelf = self;
    self.sessionTask =  [[NRNetworkClient sharedClient] sendPost:@"user/info/pswd/change" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        if (errorCode == 0) {
            [MBProgressHUD showDoneWithText:KeyWindow text:@"修改成功"];
            NSString *token = [res valueForKey:@"token"];
            [[NRLoginManager sharedInstance] setToken:token];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
    
    
}


- (void)hideKeyBoard
{
    [_tfPwd resignFirstResponder];
    [_tfNewPwd resignFirstResponder];
    [_tfNewPwdRepeat resignFirstResponder];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
