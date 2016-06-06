//
//  NRLeftViewController.m
//  Nourish
//
//  Created by gtc on 14/12/25.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import "NRLeftMenuViewController.h"
#import "NRMainTableViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "UIButton+Additions.h"
#import "AFNetworking.h"
#import "JSONKit.h"
#import "NSData+AES.h"
#import "BMBase64Helper.h"
#import "NRNetworkClient.h"
#import "UIImageView+WebCache.h"

#import "NRNavigationController.h"
#import "NRTestViewController.h"
#import "NROrderCurrentViewController.h"
#import "NRCouponViewController.h"
#import "NRMessageViewController.h"
#import "NRCollectViewController.h"
#import "NRSettingsIndexViewController.h"
#include "NRLoginManager.h"
#import "NRLeftMenuCell.h"
#import "NRLoginViewController.h"

#define BgColor  RgbHex2UIColor(0x07, 0x42, 0x47)

@interface NRLeftMenuViewController ()
{
    UITableView *_tableview;
    NSArray *_arrMenuItems;
    NSArray *_arrMenuIcons;
    UILabel *_lblUserName;
    NSURLSessionDataTask *task;
    UIImageView *_imgAvatar;
}

@property (strong, nonatomic) UIView *maskView;
@property (nonatomic, strong) NRNavigationController *navController;
@property (nonatomic, strong) NRCollectViewController *collectVC;
@property (nonatomic, strong) NRCouponViewController *couponVC;
@property (nonatomic, strong) NRMessageViewController *msgVC;
@property (nonatomic, strong) NRSettingsIndexViewController *settinsVC;

@end


@implementation NRLeftMenuViewController

#pragma mark - View Cycle

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:kNotiName_LoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess) name:kNotiName_LogoutSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:kNotiName_UpdateNickName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:kNotiName_UpdateUserAvatar object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RgbHex2UIColor(0x07, 0x42, 0x47);
    
    _arrMenuItems = @[ @"我的收藏", @"我的优惠券", @"诺食消息", @"设置" ];
    _arrMenuIcons = @[ [UIImage imageNamed:@"leftmenu-collection"],
                       [UIImage imageNamed:@"leftmenu-quan"],
                       [UIImage imageNamed:@"leftmenu-message"],
                       [UIImage imageNamed:@"leftmenu-settings"] ];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftmenu-bg"]];
    bgImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 120);
    [self.view addSubview:bgImageView];
    
    NRLoginManager  *loginManager = [NRLoginManager sharedInstance];
    _imgAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(20.f, 60.f, 67.5, 67.5)];
    _imgAvatar.layer.masksToBounds = YES;
    _imgAvatar.layer.cornerRadius = _imgAvatar.bounds.size.width/2;
    [self.view addSubview:_imgAvatar];
    
    if (OBJHASVALUE(loginManager) && STRINGHASVALUE(loginManager.avatarUrl)) {
        [_imgAvatar sd_setImageWithURL:[NSURL URLWithString:loginManager.avatarUrl] placeholderImage:[UIImage imageNamed:DefaultImageName_Avatar]];
    }
    else {
        _imgAvatar.image = [UIImage imageNamed:DefaultImageName_Avatar];
    }
    
    _lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(_imgAvatar.frame.origin.x +_imgAvatar.frame.size.width +15, _imgAvatar.frame.origin.y + (_imgAvatar.bounds.size.height - _lblUserName.bounds.size.height)/2-5, 130, LabelDefaultHeight +10)];
    _lblUserName.font = NRFont(FontLabelSize+2);
    _lblUserName.textColor = [UIColor whiteColor];
    [self.view addSubview:_lblUserName];
    if (loginManager.isLogined) {
        _lblUserName.text = loginManager.nickName;
    }
    else {
        _lblUserName.text = @"未登录";
    }
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(20, 355/2, 200, 240) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [_tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableview.scrollEnabled = NO;
    _tableview.backgroundColor = BgColor;
    [self.view addSubview:_tableview];
    
    UIView *footerLine = [[UIView alloc] initWithFrame:CGRectMake(20, _tableview.frame.origin.y-1, 220, 1)];
    footerLine.backgroundColor = RgbHex2UIColor(0x35, 0x5b, 0x5e);
    UIView *headerLine = [[UIView alloc] initWithFrame:CGRectMake(20, _tableview.frame.origin.y +_tableview.bounds.size.height+1, 220, 1)];
    headerLine.backgroundColor = RgbHex2UIColor(0x35, 0x5b, 0x5e);
    [self.view addSubview:headerLine];
    [self.view addSubview:footerLine];
    
    [self autoLayView:self.view];
     _imgAvatar.layer.cornerRadius = _imgAvatar.bounds.size.width/2;
}

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


#pragma mark - Action
- (void)writeToFile:(UIImage *)image {
    NSData *imagedata = UIImagePNGRepresentation(image);
    
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath =[documentsDirectory stringByAppendingPathComponent:@"saveFore.png"];
    
    [imagedata writeToFile:savedImagePath atomically:YES];
}

- (UIImage *)readImageFromFile {
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *savedImagePath =[documentsDirectory stringByAppendingPathComponent:@"saveFore.png"];
    NSData *data = [NSData dataWithContentsOfFile:savedImagePath];
    
    UIImage *img = [UIImage imageWithData:data];
    return img;
}


#pragma mark - Notification
- (void)updateUserInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        _lblUserName.text = [NRLoginManager sharedInstance].nickName;
        if (!STRINGHASVALUE([NRLoginManager sharedInstance].avatarUrl)) {
            _imgAvatar.image = [UIImage imageNamed:DefaultImageName_Avatar];
        } else {
            [_imgAvatar sd_setImageWithURL:[NSURL URLWithString:[NRLoginManager sharedInstance].avatarUrl] placeholderImage:[UIImage imageNamed:DefaultImageName_Avatar]];
        }
    });
}

- (void)logoutSuccess {
    _lblUserName.text = @"未登录";
    _imgAvatar.image = [UIImage imageNamed:DefaultImageName_Avatar];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return 60*appdelegate.autoSizeScaleY;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WeakSelf(self);
    UITabBarController *tabM = (UITabBarController*)self.mm_drawerController.centerViewController;
    self.navController = (NRNavigationController *)tabM.selectedViewController;
    if (![NRLoginManager sharedInstance].isLogined) {
        NRNavigationController *loginNav = [[NRNavigationController alloc] initWithRootViewController:[NRLoginViewController sharedInstance]];
        [self.navController presentViewController:loginNav animated:YES completion:^{
            [weakSelf.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
                [weakSelf.maskView removeFromSuperview];
            }];
        }];
       
        return;
    }
    
    if (indexPath.row  == 0) {
        [MobClick event:NREvent_Click_Collect_Enter];
        self.collectVC = [[NRCollectViewController alloc] initWithStyle:UITableViewStylePlain];
        self.collectVC.drawerController = self.mm_drawerController;
        self.collectVC.hidesBottomBarWhenPushed = YES;
        [self.navController pushViewController:self.collectVC animated:NO];
    }
    else if (indexPath.row == 1) {
        [MobClick event:NREvent_Click_Coupon_Enter];
        self.couponVC = [[NRCouponViewController alloc] initWithStyle:UITableViewStylePlain];
        self.couponVC.fromWhere = CouponFromMyAvailable;
//        self.couponVC.drawerController = self.mm_drawerController;
        self.couponVC.hidesBottomBarWhenPushed = YES;
        [self.navController pushViewController:self.couponVC animated:NO];
    }
    else if (indexPath.row == 2) {
        [MobClick event:NREvent_Click_SysMessage_Enter];
        self.msgVC = [[NRMessageViewController alloc] init];
        self.msgVC.drawerController = self.mm_drawerController;
        self.msgVC.hidesBottomBarWhenPushed = YES;
        [self.navController pushViewController:self.msgVC animated:NO];
    }
    else if (indexPath.row == 3) {
        [MobClick event:NREvent_Click_Settings_Enter];
        self.settinsVC = [[NRSettingsIndexViewController alloc] initWithStyle:UITableViewStyleGrouped];
        self.settinsVC.hidesBottomBarWhenPushed = YES;
        self.settinsVC.drawerController = self.mm_drawerController;
        [self.navController pushViewController:self.settinsVC animated:NO];
    }
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrMenuItems count];
}

- (NRLeftMenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell";
    NRLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    
    if (cell == nil) {
        cell = [[NRLeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellWithIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor =  [UIColor clearColor];
        cell.textLabel.font = NRFont(18);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [_arrMenuItems objectAtIndex:row];
    cell.imageView.image = [_arrMenuIcons objectAtIndex:row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NRLeftMenuCell *cell = (NRLeftMenuCell *) [tableView cellForRowAtIndexPath:indexPath];
    [self.maskView removeFromSuperview];
    [self.view addSubview:self.maskView];
    self.maskView.frame = CGRectMake(0, tableView.frame.origin.y + cell.frame.origin.y, SCREEN_WIDTH, cell.bounds.size.height);
    self.maskView.hidden = NO;
}

#pragma mark - Property
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor whiteColor];
        _maskView.alpha = 0.25;
    }
    
    return _maskView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_LogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_LoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_UpdateNickName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_UpdateUserAvatar object:nil];
}

@end
