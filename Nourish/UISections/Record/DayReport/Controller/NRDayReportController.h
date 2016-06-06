//
//  NRDayReportController.h
//  Nourish
//
//  Created by gtc on 15/1/30.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NRRecordDayInfo.h"

@interface NRDayReportEnergyInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *count;
@property (nonatomic, assign) BOOL isDayStar;

@end

@interface NRDayReportController : NRBaseViewController

@property (strong, nonatomic) NSDate *currentDate;
@property (assign, nonatomic) BOOL isNuoxiaoshi;//是否是诺小食的数据

@property (strong, nonatomic) NRRecordDayInfo *dayInfo;
@property (copy, nonatomic) NSString *wuImageUrl;

@end
