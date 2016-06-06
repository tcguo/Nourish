//
//  NRAddrSelectTableController.h
//  Nourish
//
//  Created by gtc on 15/3/25.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseTableViewController.h"
#import "NRPlaceOrderViewController.h"
#import "NRDistributionAddrModel.h"

@interface NRAddrSelectTableController : NRBaseTableViewController

@property (nonatomic, weak) NRPlaceOrderViewController *placeOrderVC;
@property (nonatomic, strong) NRDistributionAddrModel *selectedModel;

@end
