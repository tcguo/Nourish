//
//  NROrderInfoModel.h
//  Nourish

// 订单简要信息

//  Created by gtc on 15/3/26.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NROrderInfoModel : NSObject

@property (copy, nonatomic) NSString *orderID;
@property (assign, nonatomic) OrderStatus orderstatus; // 订单状态码
@property (copy, nonatomic) NSString *orderStatusDesc; // 订单状态描述
@property (assign, nonatomic) NSUInteger days; // 总天数

@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *startDate;
@property (copy, nonatomic) NSString *endDate;

@property (strong, nonatomic) NSArray *arrDates; // 订单所有日期
@property (strong, nonatomic) NSNumber *realPrice;
@property (strong, nonatomic) NSNumber *totalPrice;

@property (strong, nonatomic) NSArray *smwIds;
@property (copy, nonatomic) NSString *wpName;
@property (assign, nonatomic) NSInteger wptId;
@property (copy, nonatomic) NSString *wpThemeImgURL;

@end