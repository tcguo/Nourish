/*
 DSLCurrOrderCalendarView.m
 
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
#import "DSLCurrOrderCalendarMonthSelectorView.h"
#import "DSLChangeOrderCalendarMonthView.h"
#import "DSLChangeOrderCalendarView.h"
#import "DSLChangeOrderCalendarDayView.h"


@interface DSLChangeOrderCalendarView ()

@property (nonatomic, copy) NSDateComponents *draggingFixedDay;
@property (nonatomic, copy) NSDateComponents *draggingStartDay;
@property (nonatomic, assign) BOOL draggedOffStartDay;
@property (nonatomic, strong) NSMutableDictionary *monthViews;
@property (nonatomic, strong) UIView *monthContainerView;
@property (nonatomic, strong) UIView *monthContainerViewContentView;
@property (nonatomic, strong) DSLCurrOrderCalendarMonthSelectorView *monthSelectorView;

@property (nonatomic, readwrite, strong) NSMutableSet *msetAvaliableDateInOrderDates;//订单中还有可选的日期集合
@property (nonatomic, strong) NSMutableSet *msetAllAvaliableDateInOrderDates;//所有可选的日期
@property (nonatomic, strong) NSArray *arrAllAvaliableDateInOrderDates;//排序后所有可选的日期
@property (nonatomic, weak) AppDelegate *appDelegate;

@end


@implementation DSLChangeOrderCalendarView
{
    CGFloat _dayViewHeight;
    NSDateComponents *_visibleMonth;
}


#pragma mark - Memory management

- (void)dealloc {
}


#pragma mark - Initialisation

// Designated initialisers
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame orderDates:(NSSet*)orderDates avaliableDate:(NSSet*)avaliableDates {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.setOrderDates = orderDates;
        self.setAvaliableDates = avaliableDates;
        self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        [self commonInit];
        
        UISwipeGestureRecognizer *upRecognizer;
        upRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        [upRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self addGestureRecognizer:upRecognizer];
        
        UISwipeGestureRecognizer *downRecognizer;
        downRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        [downRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
        [self addGestureRecognizer:downRecognizer];
    }

    return self;
}

- (void)commonInit {
     _dayViewHeight = 44 *self.appDelegate.autoSizeScaleY;
    
    _visibleMonth = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSCalendarCalendarUnit fromDate:[NSDate date]];
    _visibleMonth.day = 1;
    
//    self.monthSelectorView = [[[self class] monthSelectorViewClass] view];
    
    self.monthSelectorView = [[DSLCurrOrderCalendarMonthSelectorView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 71*self.appDelegate.autoSizeScaleY)];
    self.monthSelectorView.backgroundColor = [UIColor clearColor];
    self.monthSelectorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.monthSelectorView];
    
//    self.monthSelectorView = [[DSLChangeOrderCalendarMonthSelectorView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 71)];
//    self.monthSelectorView.backgroundColor = [UIColor clearColor];
//    self.monthSelectorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    [self addSubview:self.monthSelectorView];
    
    [self.monthSelectorView.backButton addTarget:self action:@selector(didTapMonthBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.monthSelectorView.forwardButton addTarget:self action:@selector(didTapMonthForward:) forControlEvents:UIControlEventTouchUpInside];

    // Month views are contained in a content view inside a container view - like a scroll view, but not a scroll view so we can have proper control over animations
    CGRect frame = self.bounds;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(self.monthSelectorView.frame);
    frame.size.height -= frame.origin.y;
    self.monthContainerView = [[UIView alloc] initWithFrame:frame];
    self.monthContainerView.clipsToBounds = YES;
    [self addSubview:self.monthContainerView];
    
    self.monthContainerViewContentView = [[UIView alloc] initWithFrame:self.monthContainerView.bounds];
    [self.monthContainerView addSubview:self.monthContainerViewContentView];
    
    self.monthViews = [[NSMutableDictionary alloc] init];

    [self updateMonthLabelMonth:_visibleMonth];
    [self positionViewsForMonth:_visibleMonth fromMonth:_visibleMonth animated:NO];
}


#pragma mark - Properties

//+ (Class)monthSelectorViewClass {
//    return [DSLChangeOrderCalendarMonthSelectorView class];
//}

+ (Class)monthViewClass {
    return [DSLChangeOrderCalendarMonthView class];
}

+ (Class)dayViewClass {
    return [DSLChangeOrderCalendarDayView class];
}

- (void)setSelectedRange:(DSLCalendarRange *)selectedRange {
    _selectedRange = selectedRange;
    
//    for (DSLChangeOrderCalendarMonthView *monthView in self.monthViews.allValues) {
//        [monthView updateDaySelectionStatesForRange:self.selectedRange];
//    }
    
}

- (void)setDraggingStartDay:(NSDateComponents *)draggingStartDay {
    _draggingStartDay = [draggingStartDay copy];
    if (draggingStartDay == nil) {
    }
}

- (NSDateComponents*)visibleMonth {
    return [_visibleMonth copy];
}

- (void)setVisibleMonth:(NSDateComponents *)visibleMonth {
    [self setVisibleMonth:visibleMonth animated:NO];
}

- (void)setVisibleMonth:(NSDateComponents *)visibleMonth animated:(BOOL)animated {
    NSDateComponents *fromMonth = [_visibleMonth copy];
    _visibleMonth = [visibleMonth.date dslCalendarView_monthWithCalendar:self.visibleMonth.calendar];

    [self updateMonthLabelMonth:_visibleMonth];
    [self positionViewsForMonth:_visibleMonth fromMonth:fromMonth animated:animated];
}


#pragma mark - Events

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{

    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        [self didTapMonthForward:nil];
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        [self didTapMonthBack:nil];
    }
}

- (void)didTapMonthBack:(id)sender {
    NSDateComponents *newMonth = self.visibleMonth;
    newMonth.month--;

    [self setVisibleMonth:newMonth animated:YES];
}

- (void)didTapMonthForward:(id)sender {
    NSDateComponents *newMonth = self.visibleMonth;
    newMonth.month++;
    
    [self setVisibleMonth:newMonth animated:YES];
}

//处理选中日期
- (void)didTapDayViewSelected:(DSLCalendarRange *)range dayView:(DSLChangeOrderCalendarDayView*)selectDayView {
    if (selectDayView == nil) {
        return;
    }
    if (selectDayView.selectionState == DSLChangeOrderCalendarDayViewDisable) {
        return;
    }
    
    // 判断选择的日期的长度，是否大于可选的长度
    // 整理出所有可选日期的并集
    
    NSString *date = [NSDate stringFromDate:range.startDay.date format:nil];
    NSLog(@"selected date = %@", date);
    
    self.msetAvaliableDateInOrderDates = [NSMutableSet set];
    
    NSDate *today = [NSDate new];//今天
    if (today.hour >= 21) {
        //判断当前时间是否超过21点，如果未超过，明天的可变更，超过从后天开始可变更
        today = [today dateByAddingTimeInterval:24*60*60];
    }
    
    for (NSString *dateString in self.setOrderDates) {
        NSDate *date = [NSDate dateFromString:dateString format:nil];
        if ([date compare:today] == NSOrderedDescending) {
            [self.msetAvaliableDateInOrderDates addObject:dateString];
        }
    }
    
    NSLog(@"self.msetAvaliableDateInOrderDates = %@", self.msetAvaliableDateInOrderDates);
    
    self.msetAllAvaliableDateInOrderDates = [NSMutableSet setWithSet:self.msetAvaliableDateInOrderDates];
    [self.msetAllAvaliableDateInOrderDates unionSet:self.setAvaliableDates];
    
    if (![self.msetAllAvaliableDateInOrderDates containsObject:date])
        return;
        
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    self.arrAllAvaliableDateInOrderDates = [self.msetAllAvaliableDateInOrderDates.allObjects sortedArrayUsingDescriptors:sortDesc];
    
    NSInteger idx = -1;
    for (NSString *item in self.arrAllAvaliableDateInOrderDates) {
        if ([item isEqualToString:date]) {
            idx = [self.arrAllAvaliableDateInOrderDates indexOfObject:item];
            break;
        }
    }
    
    NSInteger length = self.arrAllAvaliableDateInOrderDates.count - idx;
    NSUInteger moveCount = self.msetAvaliableDateInOrderDates.count;
    if (length < moveCount) {
        //可选长度不够，弹出提示
        
        if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDates:)]) {
            [self.delegate calendarView:self didSelectDates:nil];
        }
        
        return;
    }
    
    self.msetNewOrderDates = [NSMutableSet set];
    for (int i = idx; i< idx+moveCount; i++) {
        NSString *willSelectDate = [self.arrAllAvaliableDateInOrderDates objectAtIndex:i];
        [self.msetNewOrderDates addObject:willSelectDate];
    }
        
    for (DSLChangeOrderCalendarMonthView *monthView in self.monthViews.allValues) {
        if (monthView == nil) {
            continue;
        }
        
        for (DSLChangeOrderCalendarDayView *dayView in monthView.dayViews) {
            if ([self.msetAllAvaliableDateInOrderDates containsObject:dayView.dateString]) {
                
                if ([self.msetNewOrderDates containsObject:dayView.dateString]) {
                    dayView.selectionState = DSLChangeOrderCalendarDayViewSelected;
                }
                else
                    dayView.selectionState = DSLChangeOrderCalendarDayViewEnabled;
            }
            else
                dayView.selectionState = DSLChangeOrderCalendarDayViewDisable;
            
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDates:)]) {
        [self.delegate calendarView:self didSelectDates:self.msetNewOrderDates];
    }
}


#pragma mark -  CreatedMonthView

- (void)updateMonthLabelMonth:(NSDateComponents*)month {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM yyyy";
    
    NSDate *date = [month.calendar dateFromComponents:month];
    self.monthSelectorView.titleLabel.text = [formatter stringFromDate:date];
}

- (NSString*)monthViewKeyForMonth:(NSDateComponents*)month {
    month = [month.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:month.date];
    return [NSString stringWithFormat:@"%ld.%ld", (long)month.year, (long)month.month];
}

- (DSLChangeOrderCalendarMonthView*)cachedOrCreatedMonthViewForMonth:(NSDateComponents*)month {
    month = [month.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSCalendarCalendarUnit fromDate:month.date];

    NSString *monthViewKey = [self monthViewKeyForMonth:month];
    DSLChangeOrderCalendarMonthView *monthView = [self.monthViews objectForKey:monthViewKey];
    
    if (monthView == nil) {
        monthView = [[[[self class] monthViewClass] alloc] initWithMonth:month width:self.bounds.size.width dayViewClass:[[self class] dayViewClass] dayViewHeight:_dayViewHeight];
    
        //月份
        monthView.setOrderDates = self.setOrderDates;
        monthView.setAvaliableDates = self.setAvaliableDates;
        [monthView createDayViews];
        
        [self.monthViews setObject:monthView forKey:monthViewKey];
        [self.monthContainerViewContentView addSubview:monthView];
//        [monthView updateDaySelectionStatesForRange:self.selectedRange];
    }
    
    return monthView;
}

- (void)positionViewsForMonth:(NSDateComponents*)month fromMonth:(NSDateComponents*)fromMonth animated:(BOOL)animated {
    fromMonth = [fromMonth copy];
    month = [month copy];
    
    CGFloat nextVerticalPosition = 0;
    CGFloat startingVerticalPostion = 0;
    CGFloat restingVerticalPosition = 0;
    CGFloat restingHeight = 0;
    
    NSComparisonResult monthComparisonResult = [month.date compare:fromMonth.date];
    NSTimeInterval animationDuration = (monthComparisonResult == NSOrderedSame || !animated) ? 0.0 : 0.5;
    
    NSMutableArray *activeMonthViews = [[NSMutableArray alloc] init];
    
    // Create and position the month views for the target month and those around it
    for (NSInteger monthOffset = -1; monthOffset <= 1; monthOffset += 1) {
        NSDateComponents *offsetMonth = [month copy];
        offsetMonth.month = offsetMonth.month + monthOffset;
        offsetMonth = [offsetMonth.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSCalendarCalendarUnit fromDate:offsetMonth.date];
        
        // Check if this month should overlap the previous month
        if (![self monthStartsOnFirstDayOfWeek:offsetMonth]) {
            nextVerticalPosition -= _dayViewHeight;
        }
        
        // Create and position the month view
        DSLChangeOrderCalendarMonthView *monthView = [self cachedOrCreatedMonthViewForMonth:offsetMonth];
        [activeMonthViews addObject:monthView];
        [monthView.superview bringSubviewToFront:monthView];

        CGRect frame = monthView.frame;
        frame.origin.y = nextVerticalPosition;
        nextVerticalPosition += frame.size.height;
        monthView.frame = frame;

        // Check if this view is where we should animate to or from
        if (monthOffset == 0) {
            // This is the target month so we can use it to determine where to scroll to
            restingVerticalPosition = monthView.frame.origin.y;
            restingHeight += monthView.bounds.size.height;
        }
        else if (monthOffset == 1 && monthComparisonResult == NSOrderedAscending) {
            // This is the month we're scrolling back from
            startingVerticalPostion = monthView.frame.origin.y;
            
            if ([self monthStartsOnFirstDayOfWeek:offsetMonth]) {
                startingVerticalPostion -= _dayViewHeight;
            }
        }
        else if (monthOffset == -1 && monthComparisonResult == NSOrderedDescending) {
            // This is the month we're scrolling forward from
            startingVerticalPostion = monthView.frame.origin.y;
            
            if ([self monthStartsOnFirstDayOfWeek:offsetMonth]) {
                startingVerticalPostion -= _dayViewHeight;
            }
        }

        // Check if the active or following month start on the first day of the week
        if (monthOffset == 0 && [self monthStartsOnFirstDayOfWeek:offsetMonth]) {
            // If the active month starts on a monday, add a day view height to the resting height and move the resting position up so the user can drag into that previous month
            restingVerticalPosition -= _dayViewHeight;
            restingHeight += _dayViewHeight;
        }
        else if (monthOffset == 1 && [self monthStartsOnFirstDayOfWeek:offsetMonth]) {
            // If the month after the target month starts on a monday, add a day view height to the resting height so the user can drag into that month
            restingHeight += _dayViewHeight;
        }
    }
    
    // Size the month container to fit all the month views
    CGRect frame = self.monthContainerViewContentView.frame;
    frame.size.height = CGRectGetMaxY([[activeMonthViews lastObject] frame]);
    self.monthContainerViewContentView.frame = frame;
    
    // Remove any old month views we don't need anymore
    NSArray *monthViewKeyes = self.monthViews.allKeys;
    for (NSString *key in monthViewKeyes) {
        UIView *monthView = [self.monthViews objectForKey:key];
        if (![activeMonthViews containsObject:monthView]) {
            [monthView removeFromSuperview];
            [self.monthViews removeObjectForKey:key];
        }
    }
    
    // Position the content view to show where we're animating from
    if (monthComparisonResult != NSOrderedSame) {
        CGRect frame = self.monthContainerViewContentView.frame;
        frame.origin.y = -startingVerticalPostion;
        self.monthContainerViewContentView.frame = frame;
    }
    
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        for (NSInteger index = 0; index < activeMonthViews.count; index++) {
            DSLChangeOrderCalendarMonthView *monthView = [activeMonthViews objectAtIndex:index];
             for (DSLChangeOrderCalendarDayView *dayView in monthView.dayViews) {
                 // Use a transition so it fades between states nicely
                 [UIView transitionWithView:dayView duration:animationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                     dayView.inCurrentMonth = (index == 2);
                 } completion:NULL];
             }
        }
        
        // Animate the content view to show the target month
        CGRect frame = self.monthContainerViewContentView.frame;
        frame.origin.y = -restingVerticalPosition;
        self.monthContainerViewContentView.frame = frame;
        
        // Resize the container view to show the height of the target month
        frame = self.monthContainerView.frame;
        frame.size.height = restingHeight;
        self.monthContainerView.frame = frame;
        
        // Resize the our frame to show the height of the target month
        frame = self.frame;
        frame.size.height = CGRectGetMaxY(self.monthContainerView.frame);
        self.frame = frame;
        
        // Tell the delegate method that we're about to animate to a new month
        if (monthComparisonResult != NSOrderedSame && [self.delegate respondsToSelector:@selector(calendarView:willChangeToVisibleMonth:duration:)]) {
            [self.delegate calendarView:self willChangeToVisibleMonth:[month copy] duration:animationDuration];
        }
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;

        if (finished) {
            // Tell the delegate method that we've animated to a new month
            if (monthComparisonResult != NSOrderedSame && [self.delegate respondsToSelector:@selector(calendarView:didChangeToVisibleMonth:)]) {
                [self.delegate calendarView:self didChangeToVisibleMonth:[month copy]];
            }
        }
    }];
}

- (BOOL)monthStartsOnFirstDayOfWeek:(NSDateComponents*)month {
    // Make sure we have the components we need to do the calculation
    month = [month.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSCalendarCalendarUnit fromDate:month.date];
    
    return (month.weekday - month.calendar.firstWeekday == 0);
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches begin");
    DSLChangeOrderCalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    self.draggingStartDay = touchedView.day;
    self.draggingFixedDay = touchedView.day;
    self.draggedOffStartDay = NO;
    
    DSLCalendarRange *newRange = self.selectedRange;
    if (self.selectedRange == nil) {
        newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    else if (![self.selectedRange.startDay isEqual:touchedView.day] && ![self.selectedRange.endDay isEqual:touchedView.day]) {
        newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    else if ([self.selectedRange.startDay isEqual:touchedView.day]) {
        self.draggingFixedDay = self.selectedRange.endDay;
    }
    else {
        self.draggingFixedDay = self.selectedRange.startDay;
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didDragToDay:selectingRange:)]) {
        newRange = [self.delegate calendarView:self didDragToDay:touchedView.day selectingRange:newRange];
    }
    self.selectedRange = newRange;
    
    // 把事件传递下去给父View或包含他的ViewController
//    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touche ended");
    if (self.draggingStartDay == nil) {
        return;
    }
    
    DSLChangeOrderCalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    if (!self.draggedOffStartDay && [self.draggingStartDay isEqual:touchedView.day]) {
        self.selectedRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    
    self.draggingStartDay = nil;
    
    // Check if the user has dragged to a day in an adjacent month
    if (touchedView.day.year != _visibleMonth.year || touchedView.day.month != _visibleMonth.month) {
        // Ask the delegate if it's OK to animate to the adjacent month
        BOOL animateToAdjacentMonth = YES;
        if ([self.delegate respondsToSelector:@selector(calendarView:shouldAnimateDragToMonth:)]) {
            animateToAdjacentMonth = [self.delegate calendarView:self shouldAnimateDragToMonth:[touchedView.dayAsDate dslCalendarView_monthWithCalendar:_visibleMonth.calendar]];
        }
        
        if (animateToAdjacentMonth) {
            if ([touchedView.dayAsDate compare:_visibleMonth.date] == NSOrderedAscending) {
                [self didTapMonthBack:nil];
            }
            else {
                [self didTapMonthForward:nil];
            }
        }
    }
    
    //知道选择的是哪一天了
    
    [self didTapDayViewSelected:self.selectedRange dayView:touchedView];
    
    // 把事件传递下去给父View或包含他的ViewController
//    [self.nextResponder touchesBegan:touches withEvent:event];
    
//    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectRange:)]) {
//        [self.delegate calendarView:self didSelectRange:self.selectedRange];
//    }
    
}

- (DSLChangeOrderCalendarDayView*)dayViewForTouches:(NSSet*)touches {
    if (touches.count != 1) {
        return nil;
    }

    UITouch *touch = [touches anyObject];
    
    // Check if the touch is within the month container
    if (!CGRectContainsPoint(self.monthContainerView.frame, [touch locationInView:self.monthContainerView.superview])) {
        return nil;
    }
    
    // Work out which day view was touched. We can't just use hit test on a root view because the month views can overlap
    for (DSLChangeOrderCalendarMonthView *monthView in self.monthViews.allValues) {
        UIView *view = [monthView hitTest:[touch locationInView:monthView] withEvent:nil];
        if (view == nil) {
            continue;
        }
        while (view != monthView) {
            if ([view isKindOfClass:[DSLChangeOrderCalendarDayView class]]) {
                return (DSLChangeOrderCalendarDayView*)view;
            }
            
            view = view.superview;
        }
    }
    
    return nil;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    return YES;
//}
//
//- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    return self;
//}


@end
