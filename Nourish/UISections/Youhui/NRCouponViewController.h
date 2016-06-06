//
//  NRCouponViewController.h
//  Nourish
//
//  Created by tcguo on 15/9/18.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseTableViewController.h"

typedef NS_ENUM(NSUInteger, CouponFrom) {
    CouponFromOrder,       //订单-可用优惠券
    CouponFromMyAvailable, //优惠券-可用
    CouponFromMyExpired,   //优惠券-过期
};

@interface NRCouponViewController : NRBaseTableViewController

@property (nonatomic, assign) NSInteger wptID; //周计划类型id
@property (nonatomic, assign) CouponFrom fromWhere;
@property (nonatomic, strong) RACCommand *selectCouponCmd; //下单的时候选择

@end
