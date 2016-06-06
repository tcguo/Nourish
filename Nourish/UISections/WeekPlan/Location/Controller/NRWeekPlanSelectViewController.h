//
//  NRWeekPlanDetailViewController.h
//  Nourish
//
//  Created by gtc on 15/1/20.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchObj.h>

typedef NS_ENUM(NSUInteger, NRLocationType) {
    NRLocationTypeCurrerentLocation,
    NRLocationTypeSearchLocation,
    NRLocationTypeHistoryAddr,
};

@interface NRWeekPlanSelectViewController : NRBaseViewController

@property (nonatomic, assign) NSUInteger weekplanID;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;
@property (nonatomic, assign) NRLocationType currentLocationType;//当前定位方式

- (void)handCurrentLocation;
- (void)handLocationWith:(AMapGeoPoint*)amapGeoPoint address:(NSString *)address;
- (void)handHistoryAddrLocationWith:(CLLocationCoordinate2D)coordinate2D address:(NSString *)address;

@end
