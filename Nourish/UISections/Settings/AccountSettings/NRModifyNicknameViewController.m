//
//  NRModifyNicknameViewController.m
//  Nourish
//
//  Created by tcguo on 15/11/7.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRModifyNicknameViewController.h"
#import "BMTextField.h"
#import "BMButton.h"
#import "NSString+Validation.h"
#import "NRLoginManager.h"

@interface NRModifyNicknameViewController ()<UITextFieldDelegate>
{
    BMTextField *_nicknameField;
    BMButton    *_doneButton;
    UILabel     *_tipLabel;
}

@property (nonatomic, readwrite, copy) NSString *nickName;
@property (nonatomic, weak) NSURLSessionDataTask *sessionTask;

@end

@implementation NRModifyNicknameViewController

- (instancetype)initWithNickName:(NSString *)nickname {
    if (self = [super init]) {
        _nickName = nickname;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    [self setupConfirmButton];
    
    CGFloat spaceHeight = 20;
    CGFloat paddingLeft = 10;
    _nicknameField = [[BMTextField alloc] initWithFrame:CGRectMake(20, spaceHeight, SCREEN_WIDTH-40, TextFieldDefaultHeight)];
    _nicknameField.placeholder = self.nickName;
    [_nicknameField setPadding:YES left:paddingLeft top:0 right:0 bottom:0];
    _nicknameField.keyboardType = UIKeyboardTypeDefault;
    _nicknameField.returnKeyType = UIReturnKeyDone;
//    _nicknameField.delegate = self;
    [self.view addSubview:_nicknameField];
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.font = SysFont(10);
    _tipLabel.text = @"以英文或汉字开头，限4-22个字符，一个汉字2个字符";
    _tipLabel.textColor = ColorBaseFont;
    [self.view addSubview:_tipLabel];
    
    [_tipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nicknameField.mas_bottom).offset(paddingLeft);
        make.left.equalTo(spaceHeight+3);
        make.right.equalTo(-spaceHeight);
        make.height.equalTo(11);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setupConfirmButton
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
   
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem, nil];
}


- (void)confirm:(id)sender {
    [self hideKeyBoard];
    NSString *nickname = [_nicknameField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (nickname.length == 0) {
        [MBProgressHUD showErrormsgWithoutIcon:KeyWindow title:@"昵称不能为空" detail:nil];
        return;
    }
    
    if (![nickname isNickName]) {
        [MBProgressHUD showErrormsgWithoutIcon:KeyWindow title:@"昵称只能由中文、字母或数字组成" detail:nil];
        return;
    };
    
    int nLength = [nickname getCharLength];
    if (nLength < 4 || nLength > 22) {
        [MBProgressHUD showErrormsgWithoutIcon:KeyWindow title:@"昵称长度不合法" detail:nil];
        return;
    }
    if (self.sessionTask) {
        [self.sessionTask cancel];
    }
    
    NSDictionary *userInfo = @{ @"nickname": nickname };
    __weak typeof(self) weakSelf = self;
   self.sessionTask = [[NRNetworkClient sharedClient] sendPost:@"user/info/nickname/change" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        if (errorCode == 0) {
            [MBProgressHUD showDoneWithText:KeyWindow text:@"修改成功"];
            [NRLoginManager sharedInstance].nickName = nickname;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_UpdateNickName object:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
}

- (void)hideKeyBoard {
    [_nicknameField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
