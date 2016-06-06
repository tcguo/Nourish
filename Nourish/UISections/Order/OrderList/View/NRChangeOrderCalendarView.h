//
//  NRChangeOrderCalendarView.h
//  Nourish
//
//  Created by gtc on 15/7/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRActivityView.h"
#import "NROrderInfoModel.h"
#import "NROrderListViewController.h"
#import "NROrderDetailController.h"
#import "NROrderListViewModel.h"

@interface NRChangeOrderCalendarView : NRActivityView

@property (nonatomic, strong) NROrderListViewModel *viewModel;
@property (nonatomic, strong) NSMutableSet *msetOrderDates; // 当前订单的日期
@property (nonatomic, strong) NROrderInfoModel *orderInfoMod;
@property (nonatomic, strong) RACCommand *changeCmd;

//@property (nonatomic, weak) NROrderListViewController *weakOrderListVC;
//@property (nonatomic, weak) NROrderDetailController   *weakOrderDetailVC;

- (void)getWorkdays;
@end
