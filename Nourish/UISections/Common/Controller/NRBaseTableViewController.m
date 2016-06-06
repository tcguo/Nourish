//
//  NRBaseTableViewController.m
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "Constants.h"

@interface NRBaseTableViewController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation NRBaseTableViewController

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.delegate = nil;
}

- (void)viewDidLoadWithBarStyle:(NRBarStyle)barStyle {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (barStyle == NRBarStyleLeftBack) {
        [self setupLeftBackButton];
    }
    
    if (barStyle == NRBarStyleLeftMenu) {
        [self setupLeftMenuButton];
    }
    
    if (barStyle == NRBarStyleLeftClose) {
        [self setupLeftCloseButton];
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

-(void)setupLeftMenuButton {
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

//适配不同屏幕
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

- (void)processRequestError:(NSError *)error {
    [MBProgressHUD hideActivityWithText:self.view animated:YES];
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
-(void)leftDrawerButtonPress:(id)sender{
    [self.tabBarController.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [MobClick event:NREvent_Click_Drawer_Open];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationController Delegate
//-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if ([navigationController   respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
//}

@end
