//
//  NRPlaceOrderViewController.h
//  Nourish
//  下单
//  Created by gtc on 15/3/2.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NRWeekPlanListItemModel.h"
#import "NRDistributionAddrModel.h"
#import "NRPlaceOrderViewModel.h"

@interface NRPlaceOrderViewController : NRBaseViewController

@property (strong, nonatomic) NRPlaceOrderViewModel     *viewModel;
@property (nonatomic, strong) NRWeekPlanListItemModel   *currentMod; //当前套餐的属性

@property (strong, nonatomic) NSString                  *invoiceString; //发票
@property (strong, nonatomic) NSString                  *noteString; //备注
@property (assign, nonatomic) NSUInteger                unitPrice; //周计划套餐单价
@property (assign, nonatomic) NSUInteger                wptID; // 周计划类型id

@end
