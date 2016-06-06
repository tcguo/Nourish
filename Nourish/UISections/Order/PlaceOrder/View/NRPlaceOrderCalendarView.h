//
//  NRPlaceOrderCalendarView.h
//  Nourish
//
//  Created by gtc on 15/3/4.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRActivityView.h"


@protocol NRPlaceOrderCalendarViewDelegate;
@interface NRPlaceOrderCalendarView : NRActivityView

@property (nonatomic, assign) id<NRPlaceOrderCalendarViewDelegate> delegate;

@end

@protocol NRPlaceOrderCalendarViewDelegate <NSObject>
@optional
- (void)placeOrderCalendarView:(NRPlaceOrderCalendarView*)calendarView didSelectDates:(NSDictionary *)userInfo;

@end