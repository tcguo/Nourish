//
//  NRRecordViewController.m
//  Nourish
//  诺食记
//  Created by gtc on 14/12/26.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordTableViewController.h"
#import "NRLoginViewController.h"
#import "NRNavigationController.h"
#import "NRDayReportController.h"

#import "NRDayReportController.h"
#import "MZDayPicker.h"
#import "BMButton.h"
#import "LXActivity.h"

#import "NRRecordHeaderView.h"
#import "NRThirdLoginShareClient.h"
#import "NRRecordProvider.h"
#import "NRRecordArticleViewController.h"

#import "UIImage+Compress.h"
#import "UIImageView+WebCache.h"
#include "NRLoginManager.h"
#include "NRUserInfo.h"
#import "NRShareActivityView.h"
#import "NRRecordViewModel.h"

static NSString * const kcellIdentifier   = @"kcellIdentifier";
static NSString * const kheaderIdentifier = @"kheaderIdentifier";

@interface NRRecordTableViewController () <LoginDelegate, MZDayPickerDelegate, MZDayPickerDataSource, LXActivityDelegate>
{
    UIView *detailContainerView;
    CGFloat _padding_collectioncell;
    NSDate *_initDate;
}
@property (strong, nonatomic) NRRecordViewModel *viewModel;
@property (strong, nonatomic) MZDayPicker *dayPicker;
@property (strong, nonatomic) UIView *tipNeedView;
@property (strong, nonatomic) NRLoginViewController *loginVC;
@property (strong, nonatomic) NRDayReportController *dayReportVC;

@property (nonatomic, strong) NRRecordHeaderView *headerView;
@property (nonatomic, strong) NRRecordProvider *provider;
@property (nonatomic, strong) NRRecordInfo *recordInfo;
@property (nonatomic, strong) NRRecordArticleViewController *articleVC;
@property (nonatomic, weak) NRThirdLoginShareClient *shareClient;
@property (nonatomic, strong) NRShareActivityView *shareView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDate *displayDate;
@end

@implementation NRRecordTableViewController

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess) name:kNotiName_LogoutSuccess object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:kNotiName_UpdateNickName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserAvatar) name:kNotiName_UpdateUserAvatar object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftMenu];
    self.navigationItem.title = @"诺食记";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    _padding_collectioncell = 15.0;
    _provider = [[NRRecordProvider alloc] init];
    _recordInfo = [[NRRecordInfo alloc] init];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupShareBarItem];
    
    // 1.请求判断是否登录，新用户+注销用户显示诺小食
    // 2.登录过，是否下过有效订单，没有也显示诺小食，有则判断当天是否是订单日期，是则正常显示，不是则显示推荐软文。
    
    NSDate *today = [NSDate date];
    [self requestDailyRecordWithDate:today];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDate *date = [NSDate date];
        int year = date.year;
        int month = date.month;
        int day = date.day;
        _initDate = date;
        
        [self.dayPicker setStartDate:[NSDate dateFromDay:day month:month year:year-1] endDate:[NSDate dateFromDay:day month:month+3 year:year]];
        [self.dayPicker setCurrentDate:[NSDate dateFromDay:date.day month:date.month year:date.year] animated:NO];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.dayPicker == nil) {
        return;
    }
    
    NSDate *todayDate = [NSDate date];
    if ([todayDate isEqualToDate:_initDate]) {
        return;
    }
    
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:_initDate toDate:todayDate options:0];
    if (comps.month > 0 || comps.year > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int year = todayDate.year;
            int month = todayDate.month;
            int day = todayDate.day;
            [self.dayPicker setStartDate:[NSDate dateFromDay:day month:month year:year-1] endDate:[NSDate dateFromDay:day month:month+3 year:year]];
            _initDate = todayDate;
        });
    }
}

#pragma mark - Views
- (void)setupShareBarItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shareto:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 28, 28);
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:menuButton animated:YES];
}

- (void)setupHeaderView {
    if (self.recordInfo.isVisitor || self.recordInfo.isNewUser || self.recordInfo.isOrderDate) {
        //尼玛坑啊，必须要重现置为nil，再赋值才会显示
        self.articleVC.tableView.tableHeaderView = nil;
        [self.tableView removeFromSuperview];
        [self.articleVC.view removeFromSuperview];
      
        self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 280);
        self.headerView.userMod = self.recordInfo.userMod;
        self.headerView.dayMod  = self.recordInfo.dayMod;
       
        _tableView = [[HVTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT-TAB_BAR_HEIGHT)
                                      expandOnlyOneCell:YES
                                       enableAutoScroll:YES];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.HVTableViewDelegate = self;
        _tableView.HVTableViewDataSource = self;
        _tableView.clipsToBounds = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
        [_tableView setTableHeaderView:self.headerView];
    }
    else  {
        if (self.articleVC == nil) {
            self.articleVC = [[NRRecordArticleViewController alloc] init];
            
            [self addChildViewController:self.articleVC];
            [self.articleVC didMoveToParentViewController:self];
        }
        
        self.tableView.tableHeaderView = nil;
        [self.tableView removeFromSuperview];
        [self.articleVC.view removeFromSuperview];
        self.articleVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT-TAB_BAR_HEIGHT-25);
        self.articleVC.tableView.clipsToBounds = NO;
        [self.view addSubview:self.articleVC.view];
        
        [self.headerView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 280-120)];
        self.headerView.userMod = self.recordInfo.userMod;
        self.headerView.dayMod  = nil;
        
        [self.articleVC.tableView setTableHeaderView:self.headerView];
        self.articleVC.articles = self.recordInfo.articles;
    }
}

#pragma mark - Action
- (void)requestDailyRecordWithDate:(NSDate *)date {
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showActivityWithText:self.view text:Tips_Loading animated:YES];
    [self.provider requestDailyRecordWithDate:date completeBlock:^(id reslut, NSError *error) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        weakSelf.notNetwokVisiable = NO;
        
        if (error) {
            if (error.code == NRRequestErrorServiceError) {
                NSDictionary *userInfo = error.userInfo;
                NSString *errorMsg = [userInfo valueForKey:@"errorMsg"];
                [MBProgressHUD showErrormsgWithoutIcon:weakSelf.view title:errorMsg detail:nil];
            }
            else if (error.code == NRRequestErrorNetworkDisAvailablity) {
                if (self.notNetwokVisiable == YES) {
                    [MBProgressHUD showErrormsgWithoutIcon:weakSelf.view title:Tips_NoNetwork detail:nil];
                }
                else
                    self.notNetwokVisiable = YES;
            }
            else  {
                [MBProgressHUD showErrormsgWithoutIcon:weakSelf.view title:Tips_NetworkError detail:nil];
            }
            
            return;
        }
        
        self.recordInfo = (NRRecordInfo *)reslut;
        [self setupHeaderView];
    }];
}

- (void)requestShareInfoWithDate:(NSString *)date completionBlock:(void(^)(id userInfo))block{
    NSDictionary *params = @{ @"date": date };
    WeakSelf(self);
    [MBProgressHUD showActivityWithText:self.view text:@"获取链接..." animated:YES];
    [[self.viewModel fetchShareInfoWithParametres:params] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        if (block) {
            NSDictionary *userInfo = @{@"title": weakSelf.viewModel.shareTitle,
                                       @"desc": weakSelf.viewModel.shareDesc,
                                       @"url": weakSelf.viewModel.shareLink };
            block(userInfo);
        }
    } error:^(NSError *error) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        if (error.code == 44) {
            [MBProgressHUD showTips:KeyWindow text:@"您该天没有预定"];
        }else {
            [weakSelf processRequestError:error];
        }
    } completed:^{
    }];
}

- (void)shareto:(id)sender {
    [MobClick event:NREvent_Click_Record_Share];
    if (!self.shareClient) {
        self.shareClient = [NRThirdLoginShareClient shareInstance];
    }
    
    [self.shareView setupUI];
    [self.shareView showInView:self.view.window];
}

- (void)refreshData:(id)sender {
    [self requestDailyRecordWithDate:[NSDate date]];
}

- (void)handleShareWithShareType:(NRShareType)type {
    NSString *dateStr = nil;
    if (!self.displayDate) {
        dateStr = [NSDate stringFromDate:_initDate format:nil];
    }else {
        dateStr = [NSDate stringFromDate:self.displayDate format:nil];
    }
    
    WeakSelf(self);
    self.shareClient = [NRThirdLoginShareClient shareInstance];
    [self requestShareInfoWithDate:dateStr completionBlock:^(id userInfo) {
        if (type == NRShareTypeWeiXin) {
            [weakSelf.shareClient shareToWeChatWithUserInfo:userInfo];
        }
        else if (type == NRShareTypeFriendCycle) {
            [weakSelf.shareClient shareToFriendCycleWithUserInfo:userInfo];
        }
        else if (type == NRShareTypeQQZone) {
            [weakSelf.shareClient shareToZoneWithUserInfo:userInfo];
        }
        else if (type == NRShareTypeSinaWB) {
            [weakSelf.shareClient shareToSinaWBWithUserInfo:userInfo];
        }
    }];
}

#pragma mark - Notification
- (void)logoutSuccess {
    
}

- (void)updateUserAvatar {
    if (!self.recordInfo.isVisitor && !self.recordInfo.isNewUser) {
        self.recordInfo.userMod.avatarurl = [NRLoginManager sharedInstance].avatarUrl;
        self.headerView.userMod = self.recordInfo.userMod;
    }
}


#pragma mark - MZDayPickerDelegate
- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day {
    if ([day.date timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]) {
        return;
    }
    
    self.displayDate = day.date;
    [self requestDailyRecordWithDate:day.date];
}

- (void)tapEventHandler:(MZDayPicker *)dayPicker {
    [MobClick event:NREvent_Click_Record_DayReport];
    if (self.recordInfo.dayMod == nil) {
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dinnerType == 2"];
    NSArray *results = [self.recordInfo.dinnerDetails filteredArrayUsingPredicate:predicate];
    
    //每日报告
    self.dayReportVC = [[NRDayReportController alloc] init];
    self.dayReportVC.currentDate = dayPicker.currentDate;
    self.dayReportVC.isNuoxiaoshi = self.recordInfo.isVisitor | self.recordInfo.isNewUser;
    if (ARRAYHASVALUE(results)) {
        NRRecordDetailModel *mod = (NRRecordDetailModel *)results.firstObject;
        self.dayReportVC.wuImageUrl = mod.setmealImageUrl;
    }
    self.dayReportVC.dayInfo = self.recordInfo.dayMod;
    self.dayReportVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:self.dayReportVC animated:YES];
}


#pragma mark - LXActivityDelegate
- (void)didClickOnImageIndex:(NSInteger)imageIndex {
  
}

- (void)didClickOnCancelButton:(NSDictionary *)data {
    NSLog(@"canceled");
}


#pragma mark - HVTableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isExpanded {
    static NSString *CellIdentifier = @"NRRecordDinnerCellIdentifier";
    NRRecordDinnerCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[NRRecordDinnerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil subTableTag:indexPath.section+1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor =  [UIColor clearColor];
    }
    
//    NSLog(@"section = %d row = %d isEX = %d", indexPath.section, indexPath.row, isExpanded);
    NRRecordDetailModel *model = [self.recordInfo.dinnerDetails objectAtIndex:indexPath.section];
    model.isExpanded = isExpanded;
//    cell.tableView.tag = indexPath.section+1;
    cell.model = model;
    
    return cell;
}


#pragma mark - UITableViewDataSource
//perform your expand stuff (may include animation) for cell here. It will be called when the user touches a cell
- (void)tableView:(UITableView *)tableView expandCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NRRecordDinnerCell *newcell = (NRRecordDinnerCell *)cell;
    newcell.imgv.frame = newcell.bounds;
    [newcell addViews];
}

// perform your collapse stuff (may include animation) for cell here. It will be called when the user touches an expanded cell so it gets collapsed or the table is in the expandOnlyOneCell satate and the user touches another item, So the last expanded item has to collapse
- (void)tableView:(UITableView *)tableView collapseCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NRRecordDinnerCell *newcell = (NRRecordDinnerCell *)cell;
    newcell.imgv.frame = newcell.bounds;
    [newcell removeViews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.recordInfo.dinnerDetails.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isexpanded {
    //you can define different heights for each cell. (then you probably have to calculate the height or e.g. read pre-calculated heights from an array
    if (isexpanded)
        return 300;
    
    return 150;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0.01;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        return 0.01;
    }
    
    return 10;
}


#pragma mark - Property
- (NRShareActivityView *)shareView {
    if (!_shareView) {
        _shareView = [[NRShareActivityView alloc] init];
        __weak typeof(NRShareActivityView) *weakShareView = _shareView;
        __weak typeof(self) weakSelf = self;
        _shareView.dataArray = [[NSMutableArray alloc] initWithCapacity:4];
        NSShareViewItem *wechatItem = [[NSShareViewItem alloc]  initWithTitle:@"微信" imageName:@"share-wechat" shareBlock:^{
            [weakSelf handleShareWithShareType:NRShareTypeWeiXin];
            [weakShareView dismiss];
        }];
        NSShareViewItem *friendItem = [[NSShareViewItem alloc] initWithTitle:@"朋友圈" imageName:@"share-wechatfriend" shareBlock:^{
            [weakSelf handleShareWithShareType:NRShareTypeFriendCycle];
            [weakShareView dismiss];
        }];
        NSShareViewItem *qzoneItem = [[NSShareViewItem alloc] initWithTitle:@"QQ空间" imageName:@"share-qzone" shareBlock:^{
             [weakSelf handleShareWithShareType:NRShareTypeQQZone];
            [weakShareView dismiss];
        }];
        NSShareViewItem *sweibItem = [[NSShareViewItem alloc] initWithTitle:@"新浪微博" imageName:@"share-sweibo" shareBlock:^{
            [weakSelf handleShareWithShareType:NRShareTypeSinaWB];
            [weakShareView dismiss];
        }];
        
        [_shareView.dataArray addObject:wechatItem];
        [_shareView.dataArray addObject:friendItem];
        [_shareView.dataArray addObject:qzoneItem];
        [_shareView.dataArray addObject:sweibItem];
    }
    
    return _shareView;
}

- (MZDayPicker *)dayPicker {
    if (!_dayPicker) {
        _dayPicker = [[MZDayPicker alloc] initWithFrame:CGRectMake(0, 3, SCREEN_WIDTH, 62) dayCellSize:CGSizeMake(62, 62) dayCellFooterHeight:0];
        _dayPicker.backgroundColor = [UIColor clearColor];
        _dayPicker.dayNameLabelFontSize = 10.0f;
        _dayPicker.dayLabelFontSize = 16.0f;
        _dayPicker.delegate = self;
        _dayPicker.dataSource = self;
    }
    
    return _dayPicker;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[NRRecordHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 280)];
        _headerView.backgroundColor = [UIColor whiteColor];
        _headerView.dayPicker = self.dayPicker;
    }
    
    return _headerView;
}

- (NRRecordViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NRRecordViewModel alloc] init];
    }
    
    return _viewModel;
}

#pragma mark - Override
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_LogoutSuccess object:nil];
}

@end