//
//  NRWeekPlanPost.h
//  Nourish
//
//  Created by gtc on 15/1/14.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRWeekPlanModel.h"

@interface NRWeekPlanPost : NSObject

@property (nonatomic, strong) NRWeekPlanModel *weekplanModel;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)getWeekPlanDataWithBlock:(void (^)(NSArray *posts, NSError *error))block;

@end
