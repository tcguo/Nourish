//
//  NRCouponCell.h
//  Nourish
//
//  Created by tcguo on 15/9/19.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRTableViewBaseCell.h"


typedef NS_ENUM(NSInteger, CouponState) {
    CouponStateExpired = -2,
    CouponStateAvailable = 1,
//    CouponStateOccupy = 2,
    CouponStateUsed = -1,
};

typedef NS_ENUM(NSUInteger, CouponType) {
    CouponTypeMoney = 1,    //代金券
    CouponTypeDiscount,     //折扣
};

@class NRCouponInfoModel;

@interface NRCouponCell : NRTableViewBaseCell

@property (nonatomic, strong) NRCouponInfoModel *model;

@end

@interface NRCouponInfoModel : NSObject

@property (nonatomic, assign) NSInteger couponID;
@property (nonatomic, assign) CouponType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *expiredDate;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *rate;
@property (nonatomic, copy) NSString *wptName;
@property (nonatomic, assign) NSInteger wptID;
@property (nonatomic, assign) CouponState state;
@property (nonatomic, copy) NSString *minConsumption;
@property (nonatomic, copy) NSString *tips;

@end


