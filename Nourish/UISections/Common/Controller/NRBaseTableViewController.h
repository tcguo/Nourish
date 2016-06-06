//
//  NRBaseTableViewController.h
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseViewController.h"
#import "MMDrawerController.h"
#import "MJRefresh.h"
#import "UITableView+BDSBottomPullToRefresh.h"
#import "NRNetworkClient.h"
#import "MBProgressHUD+Nourish.h"
#import "NRLoginManager.h"

@interface NRBaseTableViewController : UITableViewController

@property (weak, nonatomic) MMDrawerController *drawerController;
@property (weak, nonatomic) AppDelegate *appdelegate;
//@property (getter=hasLogined, assign, nonatomic) BOOL hasLogined;

- (void)back:(id)sender;
- (void)viewDidLoadWithBarStyle:(NRBarStyle)barStyle;
- (void)setupRightNavButtonWithTitle:(NSString *)title action:(SEL)action;
- (void)autoLayView:(UIView *)allView;
- (void)processRequestError:(NSError *)error;

@end
