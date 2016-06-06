//
//  NRRefundOrderView.h
//  Nourish

//  退款

//  Created by gtc on 15/7/22.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "LXActivity.h"
#import "NROrderInfoModel.h"
#import "NROrderListViewController.h"
#import "NROrderDetailController.h"
#import "NROrderListViewModel.h"
#import "UIView+BDSExtension.h"

@interface NRRefundOrderView : LXActivity

//@property (nonatomic, strong) NSSet *setOrderDates;//当前订单日期集合;

@property (nonatomic, weak) NROrderInfoModel *orderMod;
@property (nonatomic, strong) RACCommand *refundCmd;


@property (nonatomic, strong) NROrderListViewModel *viewModel;
@property (nonatomic, weak) NROrderListViewController *weakOrderListVC;
@property (nonatomic, weak) NROrderDetailController *weakOrderDetailVC;

@end
