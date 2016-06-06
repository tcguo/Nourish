//
//  NRSwitchLocationViewController.h
//  Nourish
//
//  Created by gtc on 15/2/28.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NRBaseTableViewController.h"
#import "NRWeekPlanSelectViewController.h"

@interface NRSwitchLocationViewController : NRBaseViewController

@property (nonatomic, weak) NRWeekPlanSelectViewController *weakPlanSelectVC;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) NSString *cityCode;

@end
