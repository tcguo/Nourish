//
//  NRBaseViewController.h
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"
#import "MBProgressHUD+Nourish.h"
#import "MJRefresh.h"
#import "NRLoginManager.h"

typedef enum : NSUInteger {
    NRBarStyleLeftMenu,
    NRBarStyleLeftBack,
    NRBarStyleLeftClose,
    NRBarStyleLeftNone,
} NRBarStyle;

@interface NRBaseViewController : UIViewController

@property (nonatomic, weak) AppDelegate *appdelegate;
@property (nonatomic, weak) MMDrawerController *drawerController;
@property (nonatomic, assign) BOOL notNetwokVisiable;

- (void)viewDidLoadWithBarStyle:(NRBarStyle)barStyle;
- (void)autoLayView:(UIView *)allView;
- (void)back:(id)sender;
- (void)processRequestError:(NSError *)error;
- (void)showLogoutViewWithTips:(NSString *)tips;
- (void)hideLogoutView;
- (void)setupRightNavButtonWithTitle:(NSString *)title action:(SEL)action;

@end
