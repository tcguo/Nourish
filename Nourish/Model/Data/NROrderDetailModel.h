//
//  NROrderDetailModel.h
//  Nourish

// 订单详情 model

//  Created by gtc on 15/7/23.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRDaySetmeal.h"
#import "NRWeekSetMeal.h"

@interface NROrderDetailModel : NSObject

@property (copy, nonatomic) NSString *orderId;
@property (assign, nonatomic) OrderStatus orderStatus;
@property (copy, nonatomic) NSString *statusDesc;
@property (copy, nonatomic) NSString *totalPrice;
@property (copy, nonatomic) NSString *startDate;
@property (copy, nonatomic) NSString *toName;
@property (copy, nonatomic) NSString *toPhone;

@property (strong, nonatomic) NSMutableArray *orderDates;
@property (strong, nonatomic) NSMutableArray *marrMeals;
@property (assign, nonatomic) PayType payType;

@property (copy, nonatomic) NSString *toAddr;
@property (copy, nonatomic) NSString *coupon;

@property (copy, nonatomic) NSString *createTime;

@end


