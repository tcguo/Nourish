//
//  DSLCalendarDayInfo.h
//  Nourish
//
//  Created by gtc on 15/6/29.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSLCalendarDayView.h"

@interface DSLCalendarDayInfo : NSObject

- (instancetype)initWithGroup:(NSUInteger)groupID position:(DSLCalendarDayViewPositionInWeek)positionInWeek;

@property (nonatomic, assign) NSUInteger weekGroupID;
@property (nonatomic, assign) DSLCalendarDayViewPositionInWeek positionInWeek;

@end
