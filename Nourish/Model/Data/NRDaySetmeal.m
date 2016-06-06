//
//  NRDaySetmeal.m
//  Nourish
//
//  Created by gtc on 15/7/23.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRDaySetmeal.h"

@implementation NRDaySetmeal

- (NSString *)foodsString {
    NSMutableString *ms = [[NSMutableString alloc] init];
    for (NSString *food in self.arrSingleFoodNames) {
        [ms appendString:food];
        if (![food isEqual:self.arrSingleFoodNames.lastObject]) {
            [ms appendString:@" + "];
        }
        
    }
    _foodsString = ms;
    
    return _foodsString;
}

@end
