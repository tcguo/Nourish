//
//  AppDelegate.h
//  Nourish
//
//  Created by gtc on 14/12/26.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NRNavigationController *navIdxController;
@property (strong, nonatomic) NRNavigationController *navRecordController;
@property (strong, nonatomic) NRNavigationController *navOrderController;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) CGFloat autoSizeScaleX;
@property (nonatomic, assign) CGFloat autoSizeScaleY;

- (void)restoreRootViewController:(UIViewController *)rootViewController;

@end

