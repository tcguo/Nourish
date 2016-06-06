//
//  NRPlaceOrderCalendarView.m
//  Nourish
//
//  Created by gtc on 15/3/4.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRPlaceOrderCalendarView.h"
#import "DSLCalendarView.h"
#import "NSDate+DSLCalendarView.h"
#import "DSLCalendarDayInfo.h"

@interface NRPlaceOrderCalendarView ()<DSLCalendarViewDelegate>

@property (nonatomic, strong) DSLCalendarView *calendarView;
@property (nonatomic, strong) NSMutableDictionary *mdicWorkWeeks;//分组的8个工作周
@property (nonatomic, strong) NSMutableDictionary *mdicAllWorkDays;//未分组的8个周的所有工作日
@property (nonatomic, strong) NSMutableArray *marrSelectDates;
@property (nonatomic, retain) UIActivityIndicatorView *act;
@property (nonatomic, weak) NSURLSessionDataTask *workDayTask;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGFloat heightOfCalendarView;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation NRPlaceOrderCalendarView

- (id)init {
    self = [super init];
    if (self) {
        _heightOfCalendarView = 350*self.appdelegate.autoSizeScaleY;
        _marrSelectDates = [NSMutableArray array];
        _mdicWorkWeeks = [NSMutableDictionary dictionaryWithCapacity:40];
    }
    
    return self;
}

- (void)setupUI {
    [super setupUI];
    _containerView = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.bounds.size.width, _heightOfCalendarView)];
    [self.contentView addSubview:_containerView];
    self.containerView.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
    self.contentView.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentViewHeight-50-SCREEN_SCALE, SCREEN_WIDTH, SCREEN_SCALE)];
    lineView.backgroundColor = RgbHex2UIColor(0x58, 0xF1, 0xb6);
    [self.contentView addSubview:lineView];
    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    _confirmButton.backgroundColor = [UIColor clearColor];
    _confirmButton.frame = CGRectMake(0, self.contentViewHeight-50, SCREEN_WIDTH, 50);
    [_confirmButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_confirmButton];
    
    self.act = [[UIActivityIndicatorView  alloc] initWithFrame:CGRectMake((self.bounds.size.width-50)/2,
                                                                          (_containerView.bounds.size.height-50)/2, 50, 50)];
    self.act.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.act.hidesWhenStopped = YES;
    [self.act startAnimating];
    [self.containerView addSubview:self.act];
    
    // 请求接口获取8周所有的工作日期
    [self getWorkdays];
    
}

- (void)getWorkdays {
    if (self.workDayTask) {
        [self.workDayTask cancel];
    }
    
    __weak typeof(self) weakSelf = self;
    NSString *dateNow = [NSDate stringFromDate:[NSDate date] format:nil];
    NSDictionary *dicParams = @{ @"dateNow": dateNow };
    
    self.workDayTask = [[NRNetworkClient sharedClient] sendPost:@"order/util/workdays"
                                                     parameters:dicParams
                                                        success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res)
    {
        [weakSelf.act stopAnimating];
        
        if (errorCode == 0) {
            NSArray *arrWeekGroup = [res valueForKey:@"workWeekGroup"];
            NSArray *arrChosenDates = [res valueForKey:@"chosen"];
            for (NSDictionary *dic in arrWeekGroup) {
                NSString *weekNo = [NSString stringWithFormat:@"%@", [dic valueForKey:@"weekNo"]];
                NSArray *workdays = [dic valueForKey:@"workdays"];
                [weakSelf.mdicWorkWeeks setValue:workdays forKey:weekNo];
            }
            
            weakSelf.mdicAllWorkDays = [NSMutableDictionary dictionary];
            for (NSString *item in arrChosenDates) {
                // 已选日期的group设定为0
                DSLCalendarDayInfo *dayInfo = [[DSLCalendarDayInfo alloc] initWithGroup:0 position:DSLCalendarDayViewMidWeek];
                [weakSelf.mdicAllWorkDays setValue:dayInfo forKey:item];
            }
            
            for (NSString *idx in weakSelf.mdicWorkWeeks.allKeys) {
                NSArray *arr = (NSArray *)[self.mdicWorkWeeks valueForKey:idx];
                NSUInteger groupID = [idx integerValue];
                
                for (NSString *date in arr) {
                    if ([weakSelf.mdicAllWorkDays valueForKey:date]) {
                        continue;
                    }
                    
                    DSLCalendarDayInfo *dayInfo = nil;
                    if ([[arr firstObject] isEqual:date]) {
                        dayInfo = [[DSLCalendarDayInfo alloc] initWithGroup:groupID position:DSLCalendarDayViewStartOfWeek];
                    }
                    else if ([[arr lastObject] isEqual:date]) {
                        dayInfo = [[DSLCalendarDayInfo alloc] initWithGroup:groupID position:DSLCalendarDayViewEndOfWeek];
                    }
                    else {
                        dayInfo = [[DSLCalendarDayInfo alloc] initWithGroup:groupID position:DSLCalendarDayViewMidWeek];
                    }
                    
                    [weakSelf.mdicAllWorkDays setValue:dayInfo forKey:date];
                    
                }
            }
            
            weakSelf.calendarView = [[DSLCalendarView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.bounds.size.width,weakSelf.heightOfCalendarView) workdays:weakSelf.mdicAllWorkDays];
            weakSelf.calendarView.delegate = weakSelf;
            weakSelf.calendarView.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
            [_containerView addSubview:weakSelf.calendarView];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [weakSelf.act stopAnimating];
         //后台请求8个工作日失败
        NSString *errorMsg = [error.userInfo valueForKey:@"errorMsg"];
        [MBProgressHUD showErrormsgWithoutIcon:weakSelf title:errorMsg detail:nil];
    }];
}


#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCalendarView*)calendarView didSelectWeekGroup:(NSMutableSet*)weekGroupIDs {
    // 判断weekGroupIDs是否连续；判断是否已经有重复的日期了
    NSString *title = nil;
    
    if ([weekGroupIDs count] == 0) {
        title = @"";
    }
    else {
        // 计算总天数
        [self.marrSelectDates removeAllObjects];
        
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
        NSArray *sortSetArray = [weekGroupIDs sortedArrayUsingDescriptors:sortDesc];
        for (NSNumber *groupID in sortSetArray) {
            NSArray *arrWorkdays = [self.mdicWorkWeeks valueForKey:[NSString stringWithFormat:@"%@", groupID]];
            if (arrWorkdays && arrWorkdays.count != 0) {
                [self.marrSelectDates addObjectsFromArray:arrWorkdays];
            }
        }
        
        title = [NSString stringWithFormat:@"(%lu周共%lu天)",(unsigned long)[weekGroupIDs count], (unsigned long)[self.marrSelectDates count]];
    }
   
    [self changeCancelButtonTitle: title];
}

- (void)calendarView:(DSLCalendarView*)calendarView didSelectRange:(DSLCalendarRange *)range {
    if (range != nil) {
        NSString *date = [NSDate stringFromDate:range.startDay.date format:nil];
        NSLog(@"selected date = %@", date);
        
        DSLCalendarDayInfo *dayInfo = [self.mdicAllWorkDays valueForKey:date];
        if (dayInfo.weekGroupID != 0) {
            // 已选的就不处理了
            [self.calendarView selectOneWorkWeek:[NSNumber numberWithUnsignedInteger:dayInfo.weekGroupID]];
        }
    }
    else {
        NSLog( @"No selection" );
    }
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2 {
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}


#pragma mark - private Methods

- (void)changeCancelButtonTitle:(NSString *)title {
    [self.confirmButton setTitle:[NSString stringWithFormat:@"确定%@", title] forState:UIControlStateNormal];
}

- (void)save {
    if ([self.calendarView.msetSelectedGroupID count] != 0) {
        // 排序weekGroupIDs
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
        NSArray *sortSetArray = [self.calendarView.msetSelectedGroupID sortedArrayUsingDescriptors:sortDesc];
        
        //判断周期是否连续
        for (int i = 0; i < [sortSetArray count]; i++) {
            NSNumber *currentID = [sortSetArray objectAtIndex:i];
            int j = i + 1;
            if (j < sortSetArray.count) {
                NSNumber *nextID = [sortSetArray objectAtIndex:j];
                
                if ([currentID integerValue] != ([nextID integerValue] -1) ) {
                    [MBProgressHUD showTips:KeyWindow text:@"选择周期不连续"];
                    return;
                }
            }
        }
        
        NSString *firstGroupID = [NSString stringWithFormat:@"%@",[sortSetArray firstObject]];
        NSString *lastGroupID = [NSString stringWithFormat:@"%@",[sortSetArray lastObject]];
        
        NSDate *startDate = [NSDate dateFromString:[[self.mdicWorkWeeks valueForKey:firstGroupID] firstObject] format:nil] ;
        NSDate *endDate =  [NSDate dateFromString:[[self.mdicWorkWeeks valueForKey:lastGroupID] lastObject] format:nil] ;
        
        NSMutableDictionary *mdicData = [NSMutableDictionary dictionary];
        [mdicData setValue:startDate forKey:@"start"];
        [mdicData setValue:endDate forKey:@"end"];
        [mdicData setValue:self.marrSelectDates forKey:@"selectDates"];

        if ([self.delegate respondsToSelector:@selector(placeOrderCalendarView:didSelectDates:)]) {
            [self.delegate placeOrderCalendarView:self didSelectDates:mdicData];
        }
    }
    
    [self dismiss];
}

@end
