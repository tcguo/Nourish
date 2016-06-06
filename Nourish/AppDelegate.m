//
//  AppDelegate.m
//  Nourish
//
//  Created by gtc on 14/12/26.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import "AppDelegate.h"
#import "NRMainTableViewController.h"
#import "NRLeftMenuViewController.h"
#import "NROrderCurrentViewController.h"
#import "NRRecordTableViewController.h"
#import "NRRecordLogoutVC.h"

#import "NRCollectViewController.h"

#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"

//#import "MMExampleDrawerVisualStateManager.h"
#import "MMDrawerVisualState.h"
#import "BMBase64Helper.h"
#import "BPush.h"
//#import "BaiduMobStat.h"

#import "NRThirdLoginShareClient.h"
#import "NRBaiduPushProvider.h"

#import <AlipaySDK/AlipaySDK.h>
#import "NRIntroductionViewController.h"
#import "NRLoginManager.h"

@interface AppDelegate ()
{
    UIBackgroundTaskIdentifier _bgTask;
    UITabBarItem *_itemOrder;
    UITabBarItem *_itemRecord;
    MMDrawerController *_drawerController;
}

//@property (nonatomic, assign, getter=isLogined) BOOL isLogined;//是否已经登录
//@property (strong, nonatomic) NRNavigationController *navIdxController;
//@property (strong, nonatomic) NRNavigationController *navRecordController;
//@property (strong, nonatomic) NRNavigationController *navOrderController;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NRMainTableViewController *idxVC;
@property (weak, nonatomic) NRThirdLoginShareClient *loginShareClient;
@property (weak, nonatomic) NRLoginManager *loginManager;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //屏幕适配
    if(SCREEN_HEIGHT > 480){
        self.autoSizeScaleX = SCREEN_WIDTH/320;
        self.autoSizeScaleY = SCREEN_HEIGHT/568;
        
    }else {
        self.autoSizeScaleX = 1.0;
        self.autoSizeScaleY = 1.0;
    }
    
    self.loginManager = [NRLoginManager sharedInstance];
    [self.loginManager unarchivedData];
    
    //注册三方SDK
    self.loginShareClient = [NRThirdLoginShareClient shareInstance];
    self.loginShareClient.qqEnabled = YES;
    self.loginShareClient.wxEnabled = YES;
    self.loginShareClient.sinaWBEnabled = YES;
    [self.loginShareClient registerApp];
    
    //友盟统计
    [MobClick setAppVersion:NourishVersion];
    [MobClick startWithAppkey:kUMengAppkey reportPolicy:BATCH channelId:nil];
    
    //注册远程通知
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    // #warning 上线 AppStore 时需要修改 pushMode 需要修改Apikey为自己的Apikey
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey 无需绑定 accessToken
    [BPush registerChannel:launchOptions apiKey:kBaiduPushApiKey pushMode:BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil isDebug:YES];
    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"从消息启动:%@",userInfo);
        [BPush handleNotification:userInfo];
    }
    
    // 角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    //网络状态监控
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status ==  AFNetworkReachabilityStatusNotReachable) {
            [MBProgressHUD showTips:KeyWindow text:@"网络不给力呀"];
        }
    }];
    [networkManager startMonitoring];
    
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // 引导页
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : ColorRed_Normal,
                                                         NSFontAttributeName : SysFont(10)}
                                             forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : SysFont(10)}
                                             forState:UIControlStateNormal];
    
    
    self.idxVC = [[NRMainTableViewController alloc] init];
    self.navIdxController = [[NRNavigationController alloc] initWithRootViewController:self.idxVC];
    UIImage *tabIMG = [[UIImage imageNamed:@"tab1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *tabIMGSel = [[UIImage imageNamed:@"tab2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *itemIndex= [[UITabBarItem alloc] initWithTitle:@"周计划" image:tabIMG selectedImage:tabIMGSel];
    self.idxVC.tabBarItem = itemIndex;
    self.idxVC.tabBarItem.tag = 0;
    
    UIImage *img_tabOrder_unsel = [[UIImage imageNamed:@"tab-order-unsele"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img_tabOrder_sel = [[UIImage imageNamed:@"tab-order-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    NROrderCurrentViewController *currOrderVC = [[NROrderCurrentViewController alloc] init];
    if (self.loginManager.isLogined) {
        [currOrderVC hideLogoutView];
    }else {
        [currOrderVC showLogoutViewWithTips:@"您还没有登录，请登录后查看订单"];
    }
    
    self.navOrderController = [[NRNavigationController alloc] initWithRootViewController:currOrderVC];
    _itemOrder = [[UITabBarItem alloc] initWithTitle:@"订单" image:img_tabOrder_unsel selectedImage:img_tabOrder_sel];
    currOrderVC.tabBarItem = _itemOrder;
    currOrderVC.tabBarItem.tag = 1;
    
    UIImage *img_tabRecord_unsel = [[UIImage imageNamed:@"tab-record-unsele"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img_tabRecord_sel = [[UIImage imageNamed:@"tab-record-sele"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    NRRecordTableViewController *recordVC = [[NRRecordTableViewController alloc] init];
    self.navRecordController = [[NRNavigationController alloc] initWithRootViewController:recordVC];
    _itemRecord = [[UITabBarItem alloc] initWithTitle:@"诺食记" image:img_tabRecord_unsel selectedImage:img_tabRecord_sel];
    recordVC.tabBarItem.tag = 2;
    recordVC.tabBarItem = _itemRecord;
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:self.navIdxController, self.navOrderController, self.navRecordController, nil];
    
    NRLeftMenuViewController *leftVC = [[NRLeftMenuViewController alloc] init];
    leftVC.mainTab = self.tabBarController;
    
    _drawerController = [[MMDrawerController alloc] initWithCenterViewController:self.tabBarController
                                             leftDrawerViewController:leftVC
                                             rightDrawerViewController:nil];
    
    [_drawerController setMaximumLeftDrawerWidth:240.0*self.autoSizeScaleX];
    [_drawerController setShouldStretchDrawer:NO];
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
//    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//         MMDrawerControllerDrawerVisualStateBlock block;
//         block = [[MMExampleDrawerVisualStateManager sharedManager]
//                  drawerVisualStateBlockForDrawerSide:drawerSide];
//         if(block){
//             block(drawerController, drawerSide, percentVisible);
//         }
//     }];
    
    NSString *hasShowed = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefault_ShowIntroduction];
    if (!hasShowed) {
        NRIntroductionViewController *introdVC = [[NRIntroductionViewController alloc] init];
        self.window.rootViewController = introdVC;
        [[NSUserDefaults standardUserDefaults] setValue:@"showed" forKey:kUserDefault_ShowIntroduction];
    } else {
        self.window.rootViewController = _drawerController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)restoreRootViewController:(UIViewController *)rootViewController {
    
    typedef void (^Animation)(void);
    UIWindow* window = self.window;
    
    _drawerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    Animation animation = ^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        window.rootViewController = _drawerController;
        [UIView setAnimationsEnabled:oldState];
    };
    
    [UIView transitionWithView:window
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animation
                    completion:nil];
}

- (void)gotoMain {
    self.window.rootViewController = _drawerController;
    [self.window makeKeyAndVisible];
}		

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"Notification UserInfo = %@", userInfo);
    // 可以增加userInfo的字段，根据字段信息，跳转到具体的viewcontroller
     NSDictionary *aps = [userInfo objectForKey:@"aps"];
    
    // 获取导航控制器
    NRCollectViewController *collectVC = [[NRCollectViewController alloc] init];
    NRNavigationController *nav = [[NRNavigationController alloc] initWithRootViewController:collectVC];
    UIViewController *presentedController = self.window.rootViewController;
    [presentedController presentViewController:nav animated:YES completion:nil];
    completionHandler(UIBackgroundFetchResultNewData);

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"notif= %@", userInfo);
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"test:%@", deviceToken);
    self.loginManager.deviceToken = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        NSLog(@"%@", [NSString stringWithFormat:@"Method: %@\n%@", BPushRequestMethodBind, result]);
        NSString *channelid = [BPush getChannelId];
        if (channelid) {
            self.loginManager.channelId = channelid;
//            NRBaiduPushProvider *pushProvider = [[NRBaiduPushProvider alloc] init];
//            NSString *token = [BMBase64Helper encodeBase64StringWithData:deviceToken];
//            [pushProvider uploadBPushWithChannelId:channelid deviceToken:token];
        }
    }];
    
//        [self.viewController addLogString:[NSString stringWithFormat:@"Method: %@\n%@",BPushRequestMethodBind,result]];
    
    // 还可以按 tags 给用户分组
//    [BPush setTag:@"abc" withCompleteHandler:^(id result, NSError *error) {
//        
//    }];
    
    // 打印到日志 textView 中
//    [self.viewController addLogString:[NSString stringWithFormat:@"Register use deviceToken : %@",deviceToken]];
    
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"接收本地通知啦！！！");
    [BPush showLocalNotificationAtFront:notification identifierKey:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NRGlobalManager sharedInstance] getCustomerPhone];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    self.loginManager = [NRLoginManager sharedInstance];
    [self.loginManager archivedData];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.loginShareClient handleOpenURL:url type:ThirdLoginShareTypeWeiXin] ||
    [self.loginShareClient handleOpenURL:url type:ThirdLoginShareTypeQQ] ||
    [self.loginShareClient handleOpenURL:url type:ThirdLoginShareTypeSinaWB];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString hasPrefix:kWXAppID]) {
         return [self.loginShareClient handleOpenURL:url type:ThirdLoginShareTypeWeiXin];
    }
    else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"tencent%@", kQQAppID]]) {
        return [self.loginShareClient handleOpenURL:url type:ThirdLoginShareTypeQQ];
    }
    else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"wb%@", kWBAppKey]]) {
        return [self.loginShareClient handleOpenURL:url type:ThirdLoginShareTypeSinaWB];
    }
    else if ([url.host isEqualToString:@"safepay"] || [url.host isEqualToString:@"platformapi"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中,商户 app 在后台很可能被系统 kill 了,所以 pay 接口的 callback 就会失效,请商户对 standbyCallback 返回的回调结果进行处理,就是在这个方法里面处理跟 callback 一样的逻辑】
            NSLog(@"resultDic = %@", resultDic);
            NSString *resultStatus = [resultDic valueForKey:@"resultStatus"];
            
            if ([@"9000" isEqualToString:resultStatus]) {
                //支付结果页面，切换到订单列表
                [MBProgressHUD showAlert:@"提示" msg:@"支付成功" delegate:nil cancelBtnTitle:@"确定"];
            }
            else if  ([@"8000" isEqualToString:resultStatus]) {
                [MBProgressHUD showAlert:@"提示" msg:@"正在处理中" delegate:nil cancelBtnTitle:@"确定"];
            }
            else if ([resultStatus isEqualToString:@"4000"]) {
                [MBProgressHUD showAlert:@"提示" msg:@"用户中途取消" delegate:nil cancelBtnTitle:@"确定"];
            }
            else if ([resultStatus isEqualToString:@"6001"]) {
                [MBProgressHUD showAlert:@"提示" msg:@"网络连接出错" delegate:nil cancelBtnTitle:@"确定"];
            }
        }];
    }
    
    return YES;
}


#pragma mark - Login

- (void)loginSuccess {
//    NROrderCurrentViewController *currOrderVC= [[NROrderCurrentViewController alloc] init];
//    currOrderVC.tabBarItem = _itemOrder;
//    currOrderVC.tabBarItem.tag = 1;
//    
//    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navOrderController.viewControllers];
//    [viewControllers replaceObjectAtIndex:0 withObject:currOrderVC];
//    [self.navOrderController setViewControllers:viewControllers animated:NO];
    
    //诺食记
//    NRRecordTableViewController *recordVC = [[NRRecordTableViewController alloc] init];
//    recordVC.tabBarItem.tag = 2;
//    recordVC.tabBarItem = _itemRecord;
//    
//    NSMutableArray *recordViewControllers = [NSMutableArray arrayWithArray:self.navRecordController.viewControllers];
//    [recordViewControllers replaceObjectAtIndex:0 withObject:recordVC];
//    [self.navRecordController setViewControllers:recordViewControllers animated:NO];
}

- (void)logoutSuccess {
    //当前订单
//    NROrderCurrLogoutVC *currOrderLogoutVC = [[NROrderCurrLogoutVC alloc] initWithTitle:@"当前订单"];
//    currOrderLogoutVC.tabBarItem = _itemOrder;
//    currOrderLogoutVC.tabBarItem.tag = 1;
//    
//    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navOrderController.viewControllers];
//    [viewControllers replaceObjectAtIndex:0 withObject:currOrderLogoutVC];
//    [self.navOrderController setViewControllers:viewControllers animated:NO];
}

@end
