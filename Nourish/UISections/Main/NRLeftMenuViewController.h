//
//  NRLeftViewController.h
//  Nourish
//
//  Created by gtc on 14/12/25.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MLTransition.h"

@interface NRLeftMenuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITabBarController *mainTab;
@property (copy, nonatomic) NSString *username;

@end
