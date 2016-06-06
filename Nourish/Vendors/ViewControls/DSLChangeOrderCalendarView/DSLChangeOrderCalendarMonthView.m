/*
 DSLCurrOrderCalendarMonthView.m
 
 Copyright (c) 2012 Dative Studios. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "DSLChangeOrderCalendarDayView.h"
#import "DSLChangeOrderCalendarMonthView.h"
#import "DSLCalendarRange.h"
#import "NSDate+DSLCalendarView.h"


@interface DSLChangeOrderCalendarMonthView ()

@property (nonatomic, strong) NSMutableDictionary *dayViewsDictionary;

@end


@implementation DSLChangeOrderCalendarMonthView {
    CGFloat _dayViewHeight;
    __strong Class _dayViewClass;
}

#pragma mark - Initialisation

// Designated initialiser
- (id)initWithMonth:(NSDateComponents*)month width:(CGFloat)width dayViewClass:(Class)dayViewClass dayViewHeight:(CGFloat)dayViewHeight
{
    self = [super initWithFrame:CGRectMake(0, 0, width, dayViewHeight)];
    if (self != nil) {
        // Initialise properties
        _month = [month copy];
        _dayViewHeight = dayViewHeight;
        self.dayViewsDictionary = [[NSMutableDictionary alloc] init];
        _dayViewClass = dayViewClass;
    }

    return self;
}

- (void)createDayViews {
    NSInteger const numberOfDaysPerWeek = 7;
    
    NSDateComponents *day = [[NSDateComponents alloc] init];
    day.calendar = self.month.calendar;
    day.day = 1;
    day.month = self.month.month;
    day.year = self.month.year;
    
    NSDate *firstDate = [day.calendar dateFromComponents:day];
    day = [firstDate dslCalendarView_dayWithCalendar:self.month.calendar];

    NSInteger numberOfDaysInMonth = [day.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[day date]].length;

    NSInteger startColumn = day.weekday - day.calendar.firstWeekday;
    if (startColumn < 0) {
        startColumn += numberOfDaysPerWeek;
    }

    NSArray *columnWidths = [self calculateColumnWidthsForColumnCount:numberOfDaysPerWeek];
    CGPoint nextDayViewOrigin = CGPointZero;
    for (NSInteger column = 0; column < startColumn; column++) {
        nextDayViewOrigin.x += [[columnWidths objectAtIndex:column] floatValue];
    }
    
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortArrayDates = [self.setAvaliableDates.allObjects sortedArrayUsingDescriptors:sortDesc];
    NSLog(@"array after = %@", sortArrayDates);
    
    NSDate *startDate = [NSDate dateFromString:[sortArrayDates firstObject] format:nil];
    NSDate *endDate = [NSDate dateFromString:[sortArrayDates lastObject] format:nil];

    do {
        for (NSInteger column = startColumn; column < numberOfDaysPerWeek; column++) {
            if (day.month == self.month.month) {
                CGRect dayFrame = CGRectZero;
                dayFrame.origin = nextDayViewOrigin;
                dayFrame.size.width = [[columnWidths objectAtIndex:column] floatValue];
                dayFrame.size.height = _dayViewHeight;
                
                DSLChangeOrderCalendarDayView *dayView = [[_dayViewClass alloc] initWithFrame:dayFrame];
                dayView.day = day;
                
                // 初始每日的状态
                NSString *dayViewString = [NSDate stringFromDate:dayView.dayAsDate format:@"yyyy-MM-dd"];
                dayView.dateString = dayViewString;
                
                if ([startDate compare:dayView.dayAsDate] == NSOrderedDescending ||
                    [endDate compare:dayView.dayAsDate] == NSOrderedAscending)
                {
                    dayView.selectionState= DSLChangeOrderCalendarDayViewDisable;
                }
                
                if ([self.setOrderDates containsObject:dayViewString]
                    && [dayView.dayAsDate compare:[NSDate new]]== NSOrderedDescending) {
                    dayView.selectionState = DSLChangeOrderCalendarDayViewSelected;
                }
                else if ([self.setAvaliableDates containsObject:dayViewString]) {
                    dayView.selectionState = DSLChangeOrderCalendarDayViewEnabled;
                }
                else {
                    dayView.selectionState = DSLChangeOrderCalendarDayViewDisable;
                }
                
                [self.dayViewsDictionary setObject:dayView forKey:[self dayViewKeyForDay:day]];
                [self addSubview:dayView];
            }
            
            day.day = day.day + 1;
            
            nextDayViewOrigin.x += [[columnWidths objectAtIndex:column] floatValue];
        }
        
        nextDayViewOrigin.x = 0;
        nextDayViewOrigin.y += _dayViewHeight;
        startColumn = 0;
    } while (day.day <= numberOfDaysInMonth);
    
    CGRect fullFrame = CGRectZero;
    fullFrame.size.height = nextDayViewOrigin.y;
    for (NSNumber *width in columnWidths) {
        fullFrame.size.width += width.floatValue;
    }
    self.frame = fullFrame;
}

- (void)updateDaySelectionStatesForRange:(DSLCalendarRange*)range {
    for (DSLChangeOrderCalendarDayView *dayView in self.dayViews) {
        
        /*
        if ([range containsDate:dayView.dayAsDate]) {
            BOOL isStartOfRange = [range.startDay isEqual:dayView.day];
            BOOL isEndOfRange = [range.endDay isEqual:dayView.day];
            
            if (dayView.day.weekday == 1 || dayView.day.weekday == 7) {
                dayView.selectionState = DSLCurrOrderCalendarDayViewDisable;;
            }
        }
        else {
            if ((_minAvailableDate && [dayView.day.date compare:_minAvailableDate] == NSOrderedAscending) ||
                (dayView.day.weekday == 1 || dayView.day.weekday == 7)) {
                dayView.selectionState = DSLCurrOrderCalendarDayViewDisable;
                dayView.userInteractionEnabled = NO;
            }
            else if ([self.arrWeekPlanDates containsObject:[NSDate stringFromDate:dayView.day.date format:nil]]) {
                if ([dayView.dayAsDate compare:[NSDate date]] == NSOrderedAscending) {
                    dayView.selectionState = DSLCurrOrderCalendarDayViewEated;
                }
                else
                    dayView.selectionState = DSLCurrOrderCalendarDayViewNotEated;
            }
            else {
                dayView.selectionState = DSLCurrOrderCalendarDayViewNotSelected;
                dayView.userInteractionEnabled = NO;
            }
        }
        
        */
    }
}

- (NSArray*)calculateColumnWidthsForColumnCount:(NSInteger)columnCount {
    static NSCache *widthsCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        widthsCache = [[NSCache alloc] init];
    });
    
    NSMutableArray *columnWidths = [widthsCache objectForKey:@(columnCount)];
    if (columnWidths == nil) {
        CGFloat width = floorf(self.bounds.size.width / (CGFloat)columnCount);
        
        columnWidths = [[NSMutableArray alloc] initWithCapacity:columnCount];
        for (NSInteger column = 0; column < columnCount; column++) {
            [columnWidths addObject:@(width)];
        }
        
        CGFloat remainder = self.bounds.size.width - (width * columnCount);
        CGFloat padding = 1;
        if (remainder > columnCount) {
            padding = ceilf(remainder / (CGFloat)columnCount);
        }
        
        for (NSInteger column = 0; column < columnCount; column++) {
            [columnWidths replaceObjectAtIndex:column withObject:@(width + padding)];
            
            remainder -= padding;
            if (remainder < 1) {
                break;
            }
        }
        
        [widthsCache setObject:columnWidths forKey:@(columnCount)];
    }
    
    return columnWidths;
}

#pragma mark - Properties

- (NSSet*)dayViews {
    return [NSSet setWithArray:self.dayViewsDictionary.allValues];
}

- (NSString*)dayViewKeyForDay:(NSDateComponents*)day {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    });

    return [formatter stringFromDate:[day date]];
}

- (DSLChangeOrderCalendarDayView*)dayViewForDay:(NSDateComponents*)day {
    return [self.dayViewsDictionary objectForKey:[self dayViewKeyForDay:day]];
}

@end
