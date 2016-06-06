//
//  NRMainTableViewController.m
//  Nourish
//
//  Created by gtc on 14/12/26.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import "NRMainTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "NRLeftMenuViewController.h"
#import "NRWeekPlanCell.h"
#import "NRWeekPlanPost.h"
#import "NRWeekPlanSelectViewController.h"
#import "BMDeviceInfo.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <MAMapKit/MAMapKit.h>

NSString * const MJTableViewCellIdentifier = @"NRMainWeekPlanCell";

#define MJRandomData [NSString stringWithFormat:@"随机数据---%d", arc4random_uniform(1000000)]

typedef NS_ENUM(NSInteger, MMCenterViewControllerSection){
    MMCenterViewControllerSectionLeftViewState,
    MMCenterViewControllerSectionLeftDrawerAnimation,
    MMCenterViewControllerSectionRightViewState,
    MMCenterViewControllerSectionRightDrawerAnimation,
};

@interface NRMainTableViewController ()<CLLocationManagerDelegate, MAMapViewDelegate>
{
    MAMapView *_mapView;
}

@property (readwrite, nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) MAMapView *mapView;
@property (strong, nonatomic) NSMutableArray *fakeData;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate2D;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) AMapReGeocode *regeocode; //逆地理编码结果
@property (nonatomic, weak) NSURLSessionDataTask *sessionTask;
@end

@implementation NRMainTableViewController

+ (instancetype)sharedInstance {
    static NRMainTableViewController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[NRMainTableViewController alloc] init];
    });
    
    return _sharedManager;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftMenu];
    self.navigationItem.title = @"周计划";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.view.tag = 1000;
    
    [self.tableView registerClass:[NRWeekPlanCell class] forCellReuseIdentifier:MJTableViewCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 2.集成刷新控件
    [self setupRefresh];
    
    //3.Load
    [self loaddata];
    
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    //---指定需要的精度级别
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    //---设置距离筛选器
//    self.locationManager.distanceFilter = 5.0;
    
    //gaode MAMapKitFramework
    [MAMapServices sharedServices].apiKey = kAMapKey;
    
    _mapView = [[MAMapView alloc] init];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    [_mapView clearDisk];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //---弹出请打开定位的提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务未开启" message:@"请在系统设置中开启定位服务\n设置->隐私->定位服务->诺食" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    NSInteger sysv = [[BMDeviceInfo instance].systemVersion integerValue];
    if (sysv >= 8) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //---启动位置管理器
//    [self.locationManager startUpdatingLocation];
}

- (void)setupRefresh {
    WeakSelf(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loaddata];
    }];
}

- (void)loaddata {
    __weak typeof(self) weakself = self;
    if (self.sessionTask) {
        [self.sessionTask cancel];
    }
    
    self.sessionTask = [NRWeekPlanPost getWeekPlanDataWithBlock:^(NSArray *posts, NSError *error) {
        [weakself.tableView.mj_header endRefreshing];
        if (!error) {
            weakself.posts = posts;
            [weakself.tableView reloadData];

        }else {
            [weakself processRequestError:error];
        }
    }];
}


#pragma mark - view life
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Handlers
//-(void)leftDrawerButtonPress:(id)sender{
//    NSLog(@"self.mm_drawerController = %@", self.mm_drawerController);
//    [self.tabBarController.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NRWeekPlanCell *cell = [tableView dequeueReusableCellWithIdentifier:MJTableViewCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[NRWeekPlanCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MJTableViewCellIdentifier];
    }
    
    cell.post = [self.posts objectAtIndex:(NSUInteger)indexPath.row];
    
    return cell;
}

#pragma mark -  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (CGFloat)433/2 *kAppUIScaleY;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NRWeekPlanCell *theCell = (NRWeekPlanCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NRWeekPlanSelectViewController *seleVC= [[NRWeekPlanSelectViewController alloc] init];
    
    seleVC.weekplanID = theCell.post.weekplanModel.weekplanID;
    seleVC.coordinate2D = self.coordinate2D;
    
    seleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:seleVC animated:YES];
    
    //打点
    if (indexPath.row == 0) {
        [MobClick event:NREvent_Click_Main_LoseWight];
    }
    else if (indexPath.row == 1) {
        [MobClick event:NREvent_Click_Main_StrongBuild];
    }
    else if (indexPath.row == 2) {
        
    }
    
    [MobClick event:NREvent_Click_SelWeekPlan];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorized:
            break;
        case kCLAuthorizationStatusDenied:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务未开启" message:@"请在系统设置中开启定位服务\n设置->隐私->定位服务->诺食" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            
            [alert show];
        }
            break;
        default:
            break;
    }
}

#pragma mark - MAMapLocation
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (!updatingLocation) {
        return;
    }
        
#ifdef DEBUG
//        NSLog(@"latitude : %f,longitude: %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
#endif
        
    self.coordinate2D = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:self.coordinate2D.longitude] forKey:keyLongitude];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:self.coordinate2D.latitude] forKey:keyLatitude];
}

@end
