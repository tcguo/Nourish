//
//  NRWeekSetMeal.m
//  Nourish
//
//  Created by gtc on 15/7/23.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekSetMeal.h"

@implementation NRWeekSetMeal


- (NSString *)displayWeekday {
    NSString *tmp = nil;
    
    switch (self.weekday) {
        case WeekDayMonday:
            tmp = @"MON 星期一";
            break;
        case WeekDayTuesday:
            tmp = @"TUE 星期二";
            break;
        case WeekDayWedensday:
            tmp = @"WED 星期三";
            break;
        case WeekDayThursday:
            tmp = @"THU 星期四";
            break;
        case WeekDayFirday:
            tmp = @"Fri 星期五";
            break;
        case WeekDaySaturday:
            tmp = @"SAT 星期六";
            break;
        case WeekDaySunday:
            tmp = @"SUN 星期日";
            break;
        default:
            break;
    }
    
    return tmp;
}

@end
