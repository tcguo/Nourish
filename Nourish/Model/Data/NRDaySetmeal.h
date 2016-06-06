//
//  NRDaySetmeal.h
//  Nourish
//
//  Created by gtc on 15/7/23.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRDaySetmeal : NSObject

@property (assign, nonatomic) DinnerType dinnerType;
@property (strong, nonatomic) NSArray *arrSingleFoodNames;
@property (copy, nonatomic) NSString *foodsString;

@end
