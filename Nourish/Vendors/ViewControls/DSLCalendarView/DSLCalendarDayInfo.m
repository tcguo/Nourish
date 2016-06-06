//
//  DSLCalendarDayInfo.m
//  Nourish
//
//  Created by gtc on 15/6/29.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "DSLCalendarDayInfo.h"

@implementation DSLCalendarDayInfo

- (instancetype)initWithGroup:(NSUInteger)groupID position:(DSLCalendarDayViewPositionInWeek)positionInWeek;
{
    self = [super init];
    if (self) {
        _weekGroupID = groupID;
        _positionInWeek = positionInWeek;
    }
    return self;
}

@end
