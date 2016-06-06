/*
 DSLCurrOrderCalendarView.h
 
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


#import "DSLCalendarRange.h"
#import "NSDate+DSLCalendarView.h"

@protocol DSLChangeOrderCalendarViewDelegate;

@interface DSLChangeOrderCalendarView : UIView

@property (nonatomic, weak) id<DSLChangeOrderCalendarViewDelegate>delegate;
@property (nonatomic, copy) NSDateComponents *visibleMonth;
@property (nonatomic, strong) DSLCalendarRange *selectedRange;
@property (nonatomic, strong) NSSet *setOrderDates;//当前订单日期集合
@property (nonatomic, strong) NSSet *setAvaliableDates;//8周工作日期集合
@property (nonatomic, strong) NSMutableSet *msetNewOrderDates;//新的订单日期集合
@property (nonatomic, readonly, strong) NSMutableSet *msetAvaliableDateInOrderDates;//订单中还有可选的日期集合

//+ (Class)monthSelectorViewClass;
+ (Class)monthViewClass;
+ (Class)dayViewClass;

- (id)initWithFrame:(CGRect)frame orderDates:(NSSet*)orderDates avaliableDate:(NSSet*)avaliableDates;
- (void)setVisibleMonth:(NSDateComponents *)visibleMonth animated:(BOOL)animated;

@end


@protocol DSLChangeOrderCalendarViewDelegate <NSObject>

@optional

- (void)calendarView:(DSLChangeOrderCalendarView*)calendarView didSelectDates:(NSMutableSet*)newDates;
- (void)calendarView:(DSLChangeOrderCalendarView*)calendarView didSelectRange:(DSLCalendarRange*)range;
- (void)calendarView:(DSLChangeOrderCalendarView *)calendarView willChangeToVisibleMonth:(NSDateComponents*)month duration:(NSTimeInterval)duration;
- (void)calendarView:(DSLChangeOrderCalendarView *)calendarView didChangeToVisibleMonth:(NSDateComponents*)month;
- (DSLCalendarRange*)calendarView:(DSLChangeOrderCalendarView*)calendarView didDragToDay:(NSDateComponents*)day selectingRange:(DSLCalendarRange*)range;
- (BOOL)calendarView:(DSLChangeOrderCalendarView *)calendarView shouldAnimateDragToMonth:(NSDateComponents*)month;

@end
