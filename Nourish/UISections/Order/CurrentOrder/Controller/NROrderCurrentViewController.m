//
//  NROrderCurrentViewController.m
//  Nourish
//
//  Created by gtc on 15/1/4.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderCurrentViewController.h"
#import "BMButton.h"
#import "Constants.h"
#import "NRPlaceOrderViewController.h"
#import "DSLCurrOrderCalendarView.h"
#import "NROrderCommentController.h"
#import "UIButton+Additions.h"
#import "NRLoginViewController.h"
#import "NRNavigationController.h"
#import "NROrderListContainerController.h"
#import "NROrderCurrentViewModel.h"
#import "NSDate+DSLCalendarView.h"
#import <POP.h>

// test
#import "NRFindBackPwdSetNewViewController.h"
#import "NRFindBackPwdPhoneNumViewController.h"
#import "NRFindBackPwdSMSCodeViewController.h"

@interface NROrderCurrentViewController ()<LoginDelegate, DSLCurrOrderCalendarViewDelegate>
{
    BMButton *_btnCancel;
    UIView *_nullView;
}

@property (nonatomic, strong) NROrderListContainerController *orderListVC;
@property (nonatomic, strong) DSLCurrOrderCalendarView *calendarView;
@property (nonatomic, strong) UILabel *weekplanNameLabel;
@property (nonatomic, strong) UILabel *orderStatusLabel;
@property (nonatomic, copy) NSString *orderId;

@property (nonatomic, strong) NSMutableArray *marrDates;
@property (nonatomic, strong) NSMutableArray *marrCommentDates;
@property (nonatomic, strong) NSArray *monthsArray;
@property (nonatomic, copy) NSString *wpName;
@property (nonatomic, copy) NSString *dispatchStatus;

@property (nonatomic, strong) UIView *nullView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NROrderCurrentViewModel *viewModel;
@property (nonatomic, assign) NSUInteger todayTimestamp;
@property (nonatomic, assign) NSUInteger preTimestamp;

@property (nonatomic, weak) NSURLSessionDataTask *currentTask;
@property (nonatomic, weak) NSURLSessionDataTask *dispatchTask;

@end

@implementation NROrderCurrentViewController

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kNotiName_LoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess) name:kNotiName_LogoutSuccess object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftMenu];
    self.navigationItem.title = @"订单";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupRightNavButtonWithTitle:@"订单列表" action:@selector(showHistoryOrder:)];
    self.preTimestamp = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.todayTimestamp = [self timeStampsAtZeroClock];
    if ((self.todayTimestamp > self.preTimestamp) && [NRLoginManager sharedInstance].isLogined) {
        [self requestOrderInfo];
    }
    
    if (STRINGHASVALUE(self.orderId)) {
        [self refreshDispatchStatus];
    }
}

- (void)setupCurrentOrderControls {
    if (self.bgView) {
        [self.bgView removeFromSuperview];
    }
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, SCREEN_HEIGHT-NAV_BAR_HEIGHT)];
    [self.view addSubview:self.bgView];
    
    UIImageView *containerView = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width-20, 340*kAppUIScaleY)];
    [self.bgView addSubview:containerView];
    containerView.backgroundColor =  RgbHex2UIColor(0x16, 0xd4, 0x98);
    [containerView setUserInteractionEnabled:YES];
//    [containerView setImage:[UIImage imageNamed:@"currorder-bg"]];
    
//    self.calendarView = [[DSLCurrOrderCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-20, 333*kAppUIScaleY) weekplanDate:self.marrDates];
    
    self.calendarView = [[DSLCurrOrderCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-20, 333*kAppUIScaleY) weekplanDate:self.marrDates commentDates:self.marrCommentDates];
    self.calendarView.delegate = self;
    
    //???:有问题
//    NSDateComponents *date = [NSDate dateComponentsForDate:[NSDate date]];
//    [self.calendarView setVisibleMonth:date animated:NO];
    
    [containerView addSubview:self.calendarView];
    
    UIView *runningContainerView = [[UIView alloc] init];
    runningContainerView.layer.borderColor = RgbHex2UIColor(0xe6, 0xe6, 0xe6).CGColor;
    runningContainerView.layer.borderWidth = 1.0f;
    runningContainerView.layer.cornerRadius = 20*self.appdelegate.autoSizeScaleY;
    runningContainerView.layer.masksToBounds = YES;
    
    [self.bgView addSubview:runningContainerView];
    runningContainerView.backgroundColor = [UIColor clearColor];
    [runningContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.right.equalTo(0);
        make.top.equalTo(containerView.mas_bottom).with.offset(12*self.appdelegate.autoSizeScaleY);
        make.height.equalTo(40*kAppUIScaleY);
    }];
    
    UIImageView *setmealImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"currorder-cup"]];
    [runningContainerView addSubview:setmealImgView];
    [setmealImgView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(runningContainerView.centerY).offset(-3);
        make.height.equalTo(21);
        make.width.equalTo(21);
        make.left.equalTo(18);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [runningContainerView addSubview:nameLabel];
    nameLabel.textColor = RgbHex2UIColor(0xfa, 0x2c, 0x2c);
    nameLabel.font = SysFont(FontLabelSize);
    nameLabel.text = @"正在进行:";
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(runningContainerView.centerY);
        make.height.equalTo(16);
        make.left.equalTo(setmealImgView.mas_right).offset(12);
        make.width.equalTo(@(66));
    }];
    
    self.weekplanNameLabel = [[UILabel alloc] init];
    [runningContainerView addSubview:_weekplanNameLabel];
    self.weekplanNameLabel.textColor = ColorBaseFont;
    self.weekplanNameLabel.font = SysFont(FontLabelSize);
    [self.weekplanNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(runningContainerView.centerY);
        make.left.equalTo(nameLabel.mas_right).with.offset(5);
        make.height.equalTo(16);
    }];
    
    // 物流跟踪
    UIView *orderStatusView = [[UIView alloc] init];
    orderStatusView.layer.borderColor = RgbHex2UIColor(0xe6, 0xe6, 0xe6).CGColor;
    orderStatusView.layer.borderWidth = 1.0f;
    orderStatusView.layer.cornerRadius = 20*self.appdelegate.autoSizeScaleY;
    orderStatusView.layer.masksToBounds = YES;
    [self.bgView addSubview:orderStatusView];
    orderStatusView.backgroundColor = [UIColor clearColor];
    [orderStatusView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.right.equalTo(0);
        make.top.equalTo(runningContainerView.mas_bottom).with.offset(10*self.appdelegate.autoSizeScaleY);
        make.height.equalTo(40*self.appdelegate.autoSizeScaleY);
    }];

    UIImageView *bicyleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"currorder-plane"]];
    [orderStatusView addSubview:bicyleImgView];
    [bicyleImgView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(orderStatusView.centerY);
        make.height.equalTo(21.5);
        make.width.equalTo(21.5);
        make.left.equalTo(18);
    }];
    
    UILabel *statusNameLabel = [[UILabel alloc] init];
    [orderStatusView addSubview:statusNameLabel];
    statusNameLabel.textColor = RgbHex2UIColor(0xf1, 0xbc, 0x3c);
    statusNameLabel.font = SysFont(FontLabelSize);
    statusNameLabel.text = @"送餐跟踪:";
    [statusNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(orderStatusView.centerY);
        make.height.equalTo(16);
        make.left.equalTo(bicyleImgView.mas_right).offset(12);
        make.width.equalTo(@(66));
    }];
    
    self.orderStatusLabel = [[UILabel alloc] init];
    self.orderStatusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.orderStatusLabel.textAlignment = NSTextAlignmentLeft;
    [orderStatusView addSubview:_orderStatusLabel];
    self.orderStatusLabel.textColor = RgbHex2UIColor(0xf1, 0xbc, 0x3c);
    self.orderStatusLabel.font = SysFont(FontLabelSize);
    [self.orderStatusLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(orderStatusView.centerY);
        make.left.equalTo(statusNameLabel.mas_right).with.offset(5);
        make.right.equalTo(orderStatusView.mas_right).offset(-5);
        make.height.equalTo(16);
    }];
}

#pragma  mark - Action
- (void)requestOrderInfo {
    __weak typeof(self) weakself = self;
    [MBProgressHUD showActivityWithText:self.view text:@"正在加载..." animated:YES];
    if (self.currentTask) {
        [self.currentTask cancel];
    }
    
    self.currentTask = [[NRNetworkClient sharedClient] sendPost:@"order/current"
                                  parameters:nil
                                   success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
         
         [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
                                       
         weakself.preTimestamp = weakself.todayTimestamp;
         weakself.notNetwokVisiable = NO;
         
         weakself.marrDates = [NSMutableArray array];
         weakself.marrCommentDates = [NSMutableArray array];
         NSString *dispatchStatus = [res valueForKey:@"dispatchStatus"];
         weakself.orderId = [res valueForKey:@"orderId"];
         NSString *name = [res valueForKey:@"wpName"];
         NSArray *arr = [res valueForKey:@"orderDates"];
         if (ARRAYHASVALUE(arr)) {
            [weakself.marrDates addObjectsFromArray:arr];
         }
         NSArray *commentedDates = [res valueForKey:@"commentedDates"];
         if (ARRAYHASVALUE(commentedDates)) {
            [weakself.marrCommentDates addObjectsFromArray:commentedDates];
         }
                                       
         [weakself setupCurrentOrderControls];
         weakself.weekplanNameLabel.text = name;
         weakself.orderStatusLabel.text = dispatchStatus;
                                       
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         weakself.orderId = nil; // 作为判断今天是否有订单
         [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
         
         if (error.code == NRRequestErrorNetworkDisAvailablity) {
             weakself.notNetwokVisiable = YES; // 初次无网
         } else if (error.code == 5001) { //暂无订单
             weakself.marrDates = nil;
             weakself.marrCommentDates = nil;
             weakself.preTimestamp = weakself.todayTimestamp;
             [weakself setupCurrentOrderControls];
             weakself.weekplanNameLabel.text = @"本周暂无周计划";
             weakself.orderStatusLabel.text = @"暂无配送信息";
         } else {
             [weakself processRequestError:error];
         }
     }];
}

- (void)refreshDispatchStatus {
    // 刷新当前天的配送状态
    [MBProgressHUD beginNetworkActivity];
    WeakSelf(self);
    [[self.viewModel refreshDispatchStatusWithParametres:nil] subscribeNext:^(id x) {
        NSString *dispatch = (NSString *)x;
        dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.orderStatusLabel.text = dispatch;
        });

    } error:^(NSError *error) {
        [MBProgressHUD endNetworkActivity];
    } completed:^{
        [MBProgressHUD endNetworkActivity];
    }];
}

- (void)selectWeekplan:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

- (void)commentWithDate:(NSString *)date {
    if (self.notNetwokVisiable) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NoNetwork];
        return;
    }
    
    WeakSelf(self);
    NROrderCommentController *orderCommVC = [[NROrderCommentController alloc] initWithDate:date];
    orderCommVC.orderId = self.orderId;
    orderCommVC.refreshCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [weakSelf requestOrderInfo];
        return [RACSignal empty];
    }];
    
    orderCommVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderCommVC animated:YES];
}

- (void)showHistoryOrder:(id)sender {
    
//    NROrderCommentController *orderCommVC = [[NROrderCommentController alloc] init];
//    orderCommVC.orderId = self.orderId;
//    orderCommVC.refreshCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        [self requestOrderInfo];
//        return [RACSignal empty];
//    }];
//    
//    orderCommVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:orderCommVC animated:YES];
//    return;
    
//    NRFindBackPwdSetNewViewController *pwd = [[NRFindBackPwdSetNewViewController alloc] init];
//    NRFindBackPwdPhoneNumViewController *pwd = [[NRFindBackPwdPhoneNumViewController alloc] init];
//    NRFindBackPwdSMSCodeViewController *pwd = [[NRFindBackPwdSMSCodeViewController alloc] init];
//    NRNavigationController *nav = [[NRNavigationController alloc] initWithRootViewController:pwd];
//    [self presentViewController:nav animated:YES completion:nil];
//    return;
    
    [MobClick event:NREvent_Click_OrderList];
    
    if (!self.orderListVC) {
        self.orderListVC = [[NROrderListContainerController alloc] init];
    }
    
    self.orderListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:self.orderListVC animated:YES];
    [self.orderListVC refreshOrderList];
}

- (void)refreshData:(id)sender {
    // 子类重写，无网络刷新
    [self requestOrderInfo];
}

#pragma mark - DSLCurrOrderCalendarViewDelegate
- (void)calendarView:(DSLCurrOrderCalendarView*)calendarView didSelectRange:(DSLCurrOrderCalendarRange*)range {
    NSString *startDateString = [NSDate stringFromDate:range.startDay.date format:nil];
    if ([self.marrDates containsObject:startDateString]) {
        // 判断是否已经评价
        [self commentWithDate:startDateString];
    }
}

- (void)calendarView:(DSLCurrOrderCalendarView *)calendarView willChangeToVisibleMonth:(NSDateComponents*)month duration:(NSTimeInterval)duration {
    self.monthsArray = @[@(month.month -1), @(month.month), @(month.month +1)];
}

#pragma mark - Notification
- (void)loginSuccess {
    [self hideLogoutView];
    [self requestOrderInfo];
}

- (void)logoutSuccess {
    // 重新登录
    self.orderListVC = nil;
    [self showLogoutViewWithTips:@"您还没有登录，请登录后查看订单"];
}

#pragma mark - Helper
- (NSUInteger)timeStampsAtZeroClock  {
    NSString *date = [NSDate stringFromDate:[NSDate date] format:@"yyy-MM-dd"];
    NSString *zeroStrDate = [NSString stringWithFormat:@"%@ 00:00:00", date];
    NSDate *zeroDate = [NSDate dateFromString:zeroStrDate format:@"yyyy-MM-dd HH:mm:ss"];
    return [zeroDate timeIntervalSince1970];
}

#pragma mark - Property
- (UIView *)nullView {
    if (!_nullView) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = 180;
        CGFloat y = (self.view.bounds.size.height - height)/2 - 100;
        CGFloat x = (self.view.bounds.size.width - width)/2;
        
        _nullView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _nullView.backgroundColor = [UIColor clearColor];
        
        UIImageView *nullImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"null"]];
        [_nullView addSubview:nullImgv];
        [nullImgv makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nullView.centerX);
            make.top.equalTo(_nullView.mas_top).offset(20);
        }];
        
        UILabel *nullLabel = [UILabel new];
        [_nullView addSubview:nullLabel];
        nullLabel.text = @"您现在还木有订单，赶紧订一周的吧~";
        nullLabel.textColor = ColorBaseFont;
        nullLabel.font = SysFont(16);
        
        [nullLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nullView.centerX);
            make.top.equalTo(nullImgv.mas_bottom).offset(10);
        }];
        
        BMButton *button = [BMButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"现在去订一周" forState:UIControlStateNormal];
        button.layer.cornerRadius = CornerRadius;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = SysFont(14);
        [button addTarget:self action:@selector(selectWeekplan:) forControlEvents:UIControlEventTouchUpInside];
        [_nullView addSubview:button];
        [button makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nullView.centerX);
            make.top.equalTo(nullLabel.mas_bottom).offset(10);
            make.height.equalTo(40);
            make.width.equalTo(120);
        }];
    }
    
    return _nullView;
}

- (NROrderCurrentViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NROrderCurrentViewModel alloc] init];
    }
    return _viewModel;
}

#pragma mark - Override
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
