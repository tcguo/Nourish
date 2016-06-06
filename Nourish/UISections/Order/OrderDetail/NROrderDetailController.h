//
//  NROrderDetailController.h
//  Nourish
//
//  Created by gtc on 15/3/27.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NROrderInfoModel.h"
#import "NROrderListViewController.h"
#import "NROrderListViewModel.h"

@interface NROrderDetailController : NRBaseViewController

@property (nonatomic, strong) NROrderListViewModel *viewModel;
@property (nonatomic, strong) NROrderInfoModel *orderSimpleInfoMod; // 订单列表的model
@property (nonatomic, assign) BOOL isChanged;

//@property (nonatomic, weak) NROrderListViewController *weakOrderListVC;
@property (nonatomic, strong) RACCommand *refreshCmd;

- (id)initWithOrderID:(NSString *)orderID;
- (void)requestDetailData;

@end
