//
//  NRCollectViewController.h
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseTableViewController.h"

@class NRCollectWeekPlanInfo;

@interface NRCollectViewController : NRBaseTableViewController

@property (strong, nonatomic) UITabBarController *mainTab;

@end


@interface NRCollectWeekPlanInfo : NSObject

@property (nonatomic, assign) NSInteger collectID;
@property (nonatomic, copy) NSString *wpImage;
@property (nonatomic, copy) NSString *wptName;
@property (nonatomic, copy) NSString *wpName;
@property (nonatomic, copy) NSArray *smwIds;
@property (nonatomic, assign) NSInteger wptId;
@property (nonatomic, copy) NSString *price;

@end