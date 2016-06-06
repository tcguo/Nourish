//
//  NRTestViewController.m
//  Nourish
//
//  Created by gtc on 14/12/27.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import "NRTestViewController.h"
#import "DSLCurrOrderCalendarView.h"

@interface NRTestViewController ()<DSLCurrOrderCalendarViewDelegate>

@property (nonatomic, strong) DSLCurrOrderCalendarView *calendarView;

@end

@implementation NRTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Test";
    self.view.backgroundColor = [UIColor whiteColor];
 
    NSMutableArray *arrDates = [NSMutableArray array];
    [arrDates addObject:[NSDate stringFromDate:[[NSDate date] offsetDay:-2] format:nil]];
    [arrDates addObject:[NSDate stringFromDate:[[NSDate date] offsetDay:-1] format:nil]];
    [arrDates addObject:[NSDate stringFromDate:[[NSDate date] offsetDay:-0] format:nil]];
    [arrDates addObject:[NSDate stringFromDate:[[NSDate date] offsetDay:1] format:nil]];
    [arrDates addObject:[NSDate stringFromDate:[[NSDate date] offsetDay:2] format:nil]];
    
    self.calendarView = [[DSLCurrOrderCalendarView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 150) weekplanDate:arrDates commentDates:nil];
    [self.view addSubview:_calendarView];
    self.calendarView.delegate = self;
    self.calendarView.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test123:) name:@"CurrentOrder" object:nil];
}


- (void)test123:(NSNotification *)sender
{
    NSDate *date =[[NSUserDefaults standardUserDefaults]  valueForKey:@"WillCommentDate"];
    NSLog(@"will date = %@", date);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCurrOrderCalendarView *)calendarView didSelectRange:(DSLCurrOrderCalendarRange *)range {
    if (range != nil) {
        NSLog( @"Selected %d/%d - %d/%d", range.startDay.day, range.startDay.month, range.endDay.day, range.endDay.month);
    }
    else {
        NSLog( @"No selection" );
    }
}

- (DSLCurrOrderCalendarRange*)calendarView:(DSLCurrOrderCalendarView *)calendarView didDragToDay:(NSDateComponents *)day selectingRange:(DSLCurrOrderCalendarRange *)range {
    if (NO) { // Only select a single day
        return [[DSLCurrOrderCalendarRange alloc] initWithStartDay:day endDay:day];
    }
    else if (YES) { // Don't allow selections before today
        NSDateComponents *today = [[NSDate date] dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
        
        NSDateComponents *startDate = range.startDay;
        NSDateComponents *endDate = range.endDay;
        
        if ([self day:startDate isBeforeDay:today] && [self day:endDate isBeforeDay:today]) {
            return nil;
        }
        else {
            if ([self day:startDate isBeforeDay:today]) {
                startDate = [today copy];
            }
            if ([self day:endDate isBeforeDay:today]) {
                endDate = [today copy];
            }
            
            return [[DSLCurrOrderCalendarRange alloc] initWithStartDay:startDate endDay:endDate];
        }
    }
    
    return range;
}

- (void)calendarView:(DSLCurrOrderCalendarView *)calendarView willChangeToVisibleMonth:(NSDateComponents *)month duration:(NSTimeInterval)duration {
    NSLog(@"Will show %@ in %.3f seconds", month, duration);
}

- (void)calendarView:(DSLCurrOrderCalendarView *)calendarView didChangeToVisibleMonth:(NSDateComponents *)month {
    NSLog(@"Now showing %@", month);
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2 {
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}


@end
