//
//  NRBaseViewController.m
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "Constants.h"
#import "UIButton+Additions.h"
#import "NRLogoutController.h"

@interface NRBaseViewController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *nonetworkView;
@property (nonatomic, strong) NRLogoutController *logoutVC;

@end

@implementation NRBaseViewController

- (void)loadView {
    [super loadView];
//    self.navigationController.delegate = self;
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (id)init {
    if (self = [super init]) {
         self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
//        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return self;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.delegate = nil;
}

- (void)viewDidLoadWithBarStyle:(NRBarStyle)barStyle {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    switch (barStyle) {
        case NRBarStyleLeftBack:
             [self setupLeftBackButton];
            break;
        case NRBarStyleLeftMenu:
            [self setupLeftMenuButton];
            break;
        case NRBarStyleLeftClose:
            [self setupLeftCloseButton];
            break;
        case NRBarStyleLeftNone:
        default:
            break;
    }
}

- (void)setupLeftBackButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"bar-back"] forState:UIControlStateNormal];
    button.exclusiveTouch = YES;
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 28, 28);
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:menuButton animated:YES];
}

- (void)setupLeftMenuButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"bar-chouti"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 28, 28);
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:menuButton animated:YES];
}

- (void)setupLeftCloseButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"bar-close"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 28, 28);
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:menuButton animated:YES];
}

- (void)setupRightNavButtonWithTitle:(NSString *)title action:(nullable SEL)action {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:self action:action];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - Property
- (UIView *)nonetworkView {
    if (!_nonetworkView) {
        _nonetworkView = [[UIView alloc] initWithFrame:self.view.bounds];
        _nonetworkView.backgroundColor = ColorViewBg;
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"network-no"]];
        imgView.frame = CGRectMake((_nonetworkView.bounds.size.width-95)/2, 80, 95, 120);
        [_nonetworkView addSubview:imgView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = @"数据加载失败,请检查网络连接后点击重试";
        tipLabel.textColor = RgbHex2UIColor(0xa6, 0xa6, 0xa6);
        tipLabel.font = SysFont(14);
        [_nonetworkView addSubview:tipLabel];
        
        [tipLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nonetworkView);
            make.top.equalTo(imgView.mas_bottom).offset(25);
            make.height.equalTo(15);
        }];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshButton.layer.borderColor = ColorRed_Normal.CGColor;
        refreshButton.layer.borderWidth = 1;
        refreshButton.layer.cornerRadius = CornerRadius;
        refreshButton.layer.masksToBounds = YES;
        [refreshButton setTitle:@"重新加载" forState:UIControlStateNormal];
        [refreshButton setTitle:@"重新加载" forState:UIControlStateHighlighted];
        [refreshButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
        [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [refreshButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
        [refreshButton setBackgroundColorForState:[UIColor clearColor] forState:UIControlStateNormal];
        
        refreshButton.titleLabel.font = SysFont(16);
        [_nonetworkView addSubview:refreshButton];
        [refreshButton addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
        [refreshButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nonetworkView.centerX);
            make.height.equalTo(34);
            make.top.equalTo(tipLabel.mas_bottom).offset(20);
            make.width.equalTo(120);
        }];
    }
    
    return _nonetworkView;
}

- (void)setNotNetwokVisiable:(BOOL)notNetwokVisiable {
    [self.nonetworkView removeFromSuperview];
    
    if (notNetwokVisiable) {
        [self.view addSubview:self.nonetworkView];
    }
    
    _notNetwokVisiable = notNetwokVisiable;
}

// 适配屏幕
- (void)autoLayView:(UIView *)allView {
    for (UIView *temp in allView.subviews) {
        if (temp.tag != ExceptTag) {
            temp.frame = CGRectMakeNew(temp.frame.origin.x, temp.frame.origin.y, temp.frame.size.width, temp.frame.size.height);
            if (temp.subviews.count > 0) {
                [self autoLayView:temp];
            }
        }
    }
}


#pragma mark - Public Method
- (void)refreshData:(id)sender {
    //子类重写，无网络刷新
}

- (void)showLogoutViewWithTips:(NSString *)tips {
    self.logoutVC.tips = tips;
    [self addChildViewController:self.logoutVC];
    [self.logoutVC didMoveToParentViewController:self];
    [self.view addSubview:self.logoutVC.view];
}

- (void)hideLogoutView {
    [self.logoutVC.view removeFromSuperview];
    [self.logoutVC willMoveToParentViewController:nil];
    [self.logoutVC removeFromParentViewController];
}

- (void)processRequestError:(NSError *)error {
    WeakSelf(self);
    [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
    [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
    
    if (error.code == NRRequestErrorNetworkDisAvailablity) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NoNetwork];
    }
    else if (error.code == 2006) {
        //token失效重现登录
        [MBProgressHUD showAlert:nil msg:@"已在其他设备登录，请重新登录" delegate:nil cancelBtnTitle:@"确定"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_LogoutSuccess object:nil];
    }
    else if (error.code == NRRequestErrorParseJsonError) {
        [MBProgressHUD showTips:KeyWindow text:Tips_ServiceException];
    }
    else if (error.code == 404) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NetworkError];
    }
    else if (error.code == 503) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NetworkTimeOut];
    }
    else {
        if ([error.domain isEqualToString:NourishDomain]) {
            NSString *msg = [error.userInfo valueForKey:@"errorMsg"];
            [MBProgressHUD showTips:KeyWindow text:msg];
        }
        else {
            [MBProgressHUD showTips:KeyWindow text:Tips_NetworkError];
        }
    }
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender {
    [self.tabBarController.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [MobClick event:NREvent_Click_Drawer_Open];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Property
- (NRLogoutController *)logoutVC {
    if (!_logoutVC) {
        _logoutVC = [[NRLogoutController alloc] init];
    }
    return _logoutVC;
}

#pragma mark - UINavigationController Delegate

//-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if ([navigationController  respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
//}

@end
