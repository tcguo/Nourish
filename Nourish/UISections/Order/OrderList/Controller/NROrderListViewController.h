//
//  NROrderListViewController.h
//  Nourish
//
//  Created by gtc on 15/8/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NRHistoryOrderCell.h"
#import "MJRefresh.h"
#import "SCNavTabBarController.h"

typedef NS_OPTIONS(NSUInteger, OrderLabelType) {
    OrderLabelTypeAll = 1 << 0,
    OrderLabelTypeNoPay = 1 << 1,
    OrderLabelTypeRunning = 1 << 2,
    OrderLabelTypeWaitRun = 1 << 3,
    OrderLabelTypeWaitComment = 1 << 4,
    OrderLabelTypeCanceled = 1 << 5,
};

@interface NROrderListViewController : UIViewController<SCNavTabBarControllerDelegate>

@property (nonatomic, strong) UITableView *tableViewList;
@property (nonatomic, assign) OrderLabelType orderLabelType;

- (id)initWithOrderLabelType:(OrderLabelType)orderType;

- (void)viewDidCurrentView;

//- (void)refreshOrderWithOrderID:(NSString *)orderID; // Todo :刷新单个订单状态

- (void)showOperateSheetList:(NSIndexPath *)indexPath;
- (void)processRequestError:(NSError *)error;
@end
