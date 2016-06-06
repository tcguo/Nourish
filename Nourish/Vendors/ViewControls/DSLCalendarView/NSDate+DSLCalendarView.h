//
//  NSDate+DSLCalendarView.h
//  DSLCalendarViewExample
//
//  Created by Pete Callaway on 16/08/2012.
//  Copyright 2012 Pete Callaway. All rights reserved.
//


@interface NSDate (DSLCalendarView)

- (NSDateComponents*)dslCalendarView_dayWithCalendar:(NSCalendar*)calendar;
- (NSDateComponents*)dslCalendarView_monthWithCalendar:(NSCalendar*)calendar;

- (int)year;
- (int)month;
- (int)day;
- (int)hour;
- (NSString *)weekString;
- (NSDate *)offsetDay:(int)numDays;
- (BOOL)isToday;

+ (NSDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year;
+ (NSDate *)dateStartOfDay:(NSDate *)date;
+ (int)dayBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSDate *)dateFromStringBySpecifyTime:(NSString *)dateString hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
+ (NSDateComponents *)nowDateComponents;
+ (NSDateComponents *)dateComponentsForDate:(NSDate *)date;
+ (NSDateComponents *)dateComponentsFromNow:(NSInteger)days;

+ (NSArray *)datesBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
