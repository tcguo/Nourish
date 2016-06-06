//
//  NSDate+DSLCalendarView.m
//  DSLCalendarViewExample
//
//  Created by Pete Callaway on 16/08/2012.
//  Copyright 2012 Pete Callaway. All rights reserved.
//

#import "NSDate+DSLCalendarView.h"


@implementation NSDate (DSLCalendarView)

- (NSDateComponents*)dslCalendarView_dayWithCalendar:(NSCalendar*)calendar {
    return [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:self];
}

- (NSDateComponents*)dslCalendarView_monthWithCalendar:(NSCalendar*)calendar {
    return [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
}

- (int)year {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:self];
    return [components year];
}


- (int)month {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit fromDate:self];
    return [components month];
}

- (int)day {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self];
    return [components day];
}

- (int)hour {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSHourCalendarUnit fromDate:self];
    return [components hour];
}

- (NSDate *)offsetDay:(int)numDays {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    //    [gregorian setFirstWeekday:2]; //monday is first day
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:numDays];
    //[offsetComponents setHour:1];
    //[offsetComponents setMinute:30];
    
    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:self options:0];
}

- (BOOL)isToday
{
    return [[NSDate dateStartOfDay:self] isEqualToDate:[NSDate dateStartOfDay:[NSDate date]]];
}

+ (NSDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    return [gregorian dateFromComponents:components];
}

+ (NSDate *)dateStartOfDay:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components =
    [gregorian               components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                                         NSDayCalendarUnit) fromDate:date];
    return [gregorian dateFromComponents:components];
}

- (NSString *)weekString {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    switch (dateComponents.weekday) {
        case 1: {
            return NSLocalizedString(@"sunday", @"");
        }
            break;
            
        case 2: {
            return NSLocalizedString(@"monday", @"");
        }
            break;
            
        case 3: {
            return NSLocalizedString(@"tuesday", @"");
        }
            break;
            
        case 4: {
            return NSLocalizedString(@"wednesday", @"");
        }
            break;
            
        case 5: {
            return NSLocalizedString(@"thursday", @"");
        }
            break;
            
        case 6: {
            return NSLocalizedString(@"friday", @"");
        }
            break;
            
        case 7: {
            return NSLocalizedString(@"saturday", @"");
        }
            break;
            
        default:
            break;
    }
    
    return @"";
}

+ (int)dayBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSDayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:startDate toDate:endDate options:0];
    //    int months = [comps month];
    int days = [comps day];
    return days;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    if (!format)
        format = @"yyyy-MM-dd";
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    
    static NSDateFormatter *dateFormatter =  nil;
    if (dateFormatter == nil) {
       dateFormatter = [threadDictionary valueForKey:@"mydateformatter"];
    }
    if(!dateFormatter){
        @synchronized(self){
            if(!dateFormatter){
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
                [threadDictionary setObject:dateFormatter forKey:@"mydateformatter"];
            }
        }
    }
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    return [self dateFromStringBySpecifyTime:dateString hour:0 minute:0 second:0];
}

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    if (!format)
        format = @"yyyy-MM-dd";
    
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = [threadDictionary valueForKey:@"mydateformatter"];
    
    if(!dateFormatter){
        @synchronized(self){
            if(!dateFormatter){
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
                [threadDictionary setObject:dateFormatter forKey:@"mydateformatter"];
            }
        }
    }
    
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (NSDate *)dateFromStringBySpecifyTime:(NSString *)dateString hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSArray *arrayDayTime = [dateString componentsSeparatedByString:@" "];
    NSArray *arrayDay = [arrayDayTime[0] componentsSeparatedByString:@"-"];
    
    NSInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *tmpDateComponents = [calendar components:flags fromDate:[NSDate date]];
    tmpDateComponents.year = [arrayDay[0] intValue];
    tmpDateComponents.month = [arrayDay[1] intValue];
    tmpDateComponents.day = [arrayDay[2] intValue];
    if ([arrayDayTime count] > 1) {
        NSArray *arrayTime = [arrayDayTime[1] componentsSeparatedByString:@":"];
        tmpDateComponents.hour = [arrayTime[0] intValue];
        tmpDateComponents.minute = [arrayTime[1] intValue];
        tmpDateComponents.second = [arrayTime[2] intValue];
    }
    else {
        tmpDateComponents.hour = hour;
        tmpDateComponents.minute = minute;
        tmpDateComponents.second = second;
    }
    return [calendar dateFromComponents:tmpDateComponents];
}

+ (NSDateComponents *)nowDateComponents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    return [calendar components:flags fromDate:[NSDate date]];
}

+ (NSDateComponents *)dateComponentsForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSWeekdayCalendarUnit;
    return [calendar components:flags fromDate:date];
}

+ (NSDateComponents *)dateComponentsFromNow:(NSInteger)days {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    return [calendar components:flags fromDate:[[NSDate date] dateByAddingTimeInterval:days * 24 * 60 * 60]];
}

+ (NSArray *)datesBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSMutableArray *marrDates = [[NSMutableArray alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];


    for (NSDate *date = startDate; [date compare: endDate] <= 0; date = [date dateByAddingTimeInterval:24 * 60 * 60] ) {
        NSDate *middleDay = [date dateByAddingTimeInterval:(60.0 * 60.0 * 12.0)];
        NSDateComponents *dateComp = [middleDay dslCalendarView_dayWithCalendar:gregorian];
        
        if (dateComp.weekday != 1 && dateComp.weekday != 7) {
            [marrDates addObject:[NSDate stringFromDate:middleDay format:nil]];
        }
    }
    
    return [marrDates copy];
}

@end
