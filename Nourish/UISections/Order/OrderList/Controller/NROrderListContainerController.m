//
//  NROrderListContainerController.m
//  Nourish
//
//  Created by gtc on 15/8/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderListContainerController.h"
#import "SCNavTabBarController.h"
#import "NROrderListViewController.h"


@interface NROrderListContainerController ()<UIActionSheetDelegate>
{
    UIWebView *_webView;
    SCNavTabBarController *_navTabBarController;
}

@end

@implementation NROrderListContainerController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = @"订单列表";
    [self setupCallButton];
    
    NROrderListViewController *oneViewController = [[NROrderListViewController alloc] initWithOrderLabelType:OrderLabelTypeAll];
    oneViewController.title = @"全部";
    
    NROrderListViewController *twoViewController = [[NROrderListViewController alloc] initWithOrderLabelType:OrderLabelTypeNoPay];
    twoViewController.title = @"未付款";
    
    NROrderListViewController *threeViewController = [[NROrderListViewController alloc] initWithOrderLabelType:OrderLabelTypeRunning];
    threeViewController.title = @"正在执行";
    
    NROrderListViewController *fourViewController = [[NROrderListViewController alloc] initWithOrderLabelType:OrderLabelTypeWaitRun];
    fourViewController.title = @"待执行";
    
    NROrderListViewController *fiveViewController = [[NROrderListViewController alloc] initWithOrderLabelType:OrderLabelTypeWaitComment];
    fiveViewController.title = @"待评论";
    
    NROrderListViewController *sixViewController = [[NROrderListViewController alloc] initWithOrderLabelType:OrderLabelTypeCanceled];
    sixViewController.title = @"已取消";
    
    //容器
    _navTabBarController = [[SCNavTabBarController alloc] initWithShowArrowButton:NO];
    _navTabBarController.scrollAnimation = NO;
    _navTabBarController.navTabBarColor = [UIColor whiteColor];
    _navTabBarController.navTabBarLineColor = ColorRed_Normal;
    _navTabBarController.subViewControllers = @[oneViewController,
                                                twoViewController,
                                                threeViewController,
                                                fourViewController,
                                                fiveViewController,
                                                sixViewController];
    
    _navTabBarController.currentSubController = oneViewController;
    [_navTabBarController addParentController:self];
    if (_navTabBarController.currentSubController) {
        [_navTabBarController.currentSubController viewDidCurrentView];
    }
}

- (void)setupCallButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"customer-dianhua"] forState:UIControlStateNormal];
    button.exclusiveTouch = YES;
    [button addTarget:self action:@selector(telCustomer) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 28, 28);
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:menuButton animated:YES];
}


- (void)telCustomer {
    NSString *callTitle = [NSString stringWithFormat:@"客服: %@", [NRGlobalManager sharedInstance].customerPhone];
    if (ISIOS8_OR_LATER) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *callCustomerAction = [UIAlertAction actionWithTitle:callTitle
                                                                     style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self callCustomer];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"sheet closed");
        }];
        
        [alertController addAction:callCustomerAction];
        [alertController addAction:closeAction];
        [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:callTitle otherButtonTitles:nil];
    
        if (actionSheet) {
            actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
            [actionSheet showInView:self.view.window];
        }
    }
  }

- (void)callCustomer {
    // 提示：不要将webView添加到self.view，如果添加会遮挡原有的视图
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
    }
    
    NSString *phoneNum = [NSString stringWithFormat:@"tel://%@", [NRGlobalManager sharedInstance].customerPhone];
    NSURL *url = [NSURL URLWithString:phoneNum];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
}

#pragma mark Public Methods
- (void)refreshOrderList {
    if (_navTabBarController.currentSubController) {
        [_navTabBarController.currentSubController viewDidCurrentView];
    }
}

#pragma mark - UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self callCustomer];
    }
}

- (void)back:(id)sender {
    if (self.from == NROrderListFromPay) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
