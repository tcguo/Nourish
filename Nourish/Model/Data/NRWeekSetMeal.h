//
//  NRWeekSetMeal.h
//  Nourish
//
//  Created by gtc on 15/7/23.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRWeekSetMeal : NSObject

@property (copy, nonatomic) NSString *date;
@property (strong, nonatomic) NSMutableDictionary *setMealsDic;
@property (assign, nonatomic) WeekDay weekday;
@property (copy, nonatomic) NSString *displayWeekday;
@property (copy, nonatomic) NSString *mealImageUrl;

@end
