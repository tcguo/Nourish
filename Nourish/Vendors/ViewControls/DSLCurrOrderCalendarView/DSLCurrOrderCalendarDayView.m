/*
 DSLCurrOrderCalendarDayView.h
 
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


#import "DSLCurrOrderCalendarDayView.h"
#import "NSDate+DSLCalendarView.h"  
#import "UIButton+Additions.h"

#define kDayColorForDisable RgbHex2UIColor(0x58, 0xF1, 0xb6)
#define kDayBgColor RgbHex2UIColor(0x16, 0xd4, 0x98)
//#define kDayBgColor RgbHex2UIColor(0x33, 0xcc, 0x99)
#define kTextHeight 40
#define PI 3.14159265358979323846


@interface DSLCurrOrderCalendarDayView ()

@property (strong, nonatomic) UIButton *textButton;

@end


@implementation DSLCurrOrderCalendarDayView {
    __strong NSCalendar *_calendar;
    __strong NSDate *_dayAsDate;
    __strong NSDateComponents *_day;
    __strong NSString *_labelText;
    BOOL _isToday;
}


#pragma mark - Initialisation


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
         self.backgroundColor = kDayBgColor;
        _positionInWeek = DSLCurrOrderCalendarDayViewMidWeek;
    }
    
    return self;
}

#pragma mark Properties

- (void)setSelectionState:(DSLCurrOrderCalendarDayViewSelectionState)selectionState {
    _selectionState = selectionState;
    [self setNeedsDisplay];
}

- (void)setDay:(NSDateComponents *)day {
    _calendar = [day calendar];
    _dayAsDate = [day date];
    _day = nil;
    _isToday = [day.date isToday];
    _labelText = [NSString stringWithFormat:@"%ld", (long)day.day];
}

- (NSDateComponents*)day {
    if (_day == nil) {
        _day = [_dayAsDate dslCalendarView_dayWithCalendar:_calendar];
    }
    return _day;
}

- (NSDate*)dayAsDate {
    return _dayAsDate;
}

- (void)setInCurrentMonth:(BOOL)inCurrentMonth {
    _inCurrentMonth = inCurrentMonth;
    [self setNeedsDisplay];
}


#pragma mark UIView methods

- (void)drawRect:(CGRect)rect {
    if ([self isMemberOfClass:[DSLCurrOrderCalendarDayView class]]) {
        // If this isn't a subclass of DSLCurrOrderCalendarDayView, use the default drawing
        [self drawBackground];
//        [self drawBorders];
        [self drawDayNumber];
    }
}


#pragma mark Drawing

- (void)drawBackground {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
   
    //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
    
    switch (self.selectionState) {
        case DSLCurrOrderCalendarDayViewDisable:
            break;
            
        case DSLCurrOrderCalendarDayViewEated:
        {
            CGContextSetRGBStrokeColor(context,1,1,1,1.0); //画笔线的颜色
            CGContextSetLineWidth(context, 0.5); // 线的宽度
            CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-8, 0, 2*PI, 0); //添加一个圆
            CGContextDrawPath(context, kCGPathStroke);
        }
            break;
        case DSLCurrOrderCalendarDayViewCommented: {
            CGContextSetRGBStrokeColor(context,1,1,1,1.0); //画笔线的颜色
            CGContextSetLineWidth(context, 0.5); // 线的宽度
            CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-8, 0, 2*PI, 0); //添加一个圆
            CGContextDrawPath(context, kCGPathStroke);
        }
            break;
        case DSLCurrOrderCalendarDayViewNotEated:
        {
            CGContextSetRGBStrokeColor(context, 0x08/255.0, 0xac/255.0, 0x77/255.0, 1.0); //画笔线的颜色
            CGContextSetLineWidth(context, 0.5); // 线的宽度
            CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-8, 0, 2*PI, 0); //添加一个圆
            
            UIColor *aColor = RgbHex2UIColor(0x08, 0xac, 0x77);
            CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
        }
            break;
        default:
        break;
    }
    
    if (_isToday) {
        CGContextSetRGBStrokeColor(context,1,1,1,1.0); //画笔线的颜色
        CGContextSetLineWidth(context, 0.5); // 线的宽度
        CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-8, 0, 2*PI, 0); //添加一个圆
        
        UIColor *bColor = [UIColor whiteColor];
        CGContextSetFillColorWithColor(context, bColor.CGColor);//填充颜色
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
    }
}

- (void)drawBorders {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:255.0/255.0 alpha:1.0].CGColor);
    CGContextMoveToPoint(context, 0.5, self.bounds.size.height - 0.5);
    CGContextAddLineToPoint(context, 0.5, 0.5);
    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    if (self.isInCurrentMonth) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:205.0/255.0 alpha:1.0].CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:185.0/255.0 alpha:1.0].CGColor);
    }
    CGContextMoveToPoint(context, self.bounds.size.width - 0.5, 0.0);
    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, self.bounds.size.height - 0.5);
    CGContextAddLineToPoint(context, 0.0, self.bounds.size.height - 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawDayNumber {
    NSDictionary *attributes = nil;
    switch (self.selectionState) {
        case DSLCurrOrderCalendarDayViewDisable:
        {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          kDayColorForDisable, NSForegroundColorAttributeName,
                          SysFont(16), NSFontAttributeName, nil];
        }
            break;
            
        case DSLCurrOrderCalendarDayViewEated:
        {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          kDayColorForDisable, NSForegroundColorAttributeName,
                          SysFont(16), NSFontAttributeName, nil];
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetRGBStrokeColor(context,1,1,1,1.0); //画笔线的颜色
            CGContextSetLineWidth(context, 0.5); // 线的宽度
            CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height-2, 1.8, 0, 2*PI, 0); //添加一个圆
            
            UIColor *bColor = [UIColor whiteColor];
            CGContextSetFillColorWithColor(context, bColor.CGColor);//填充颜色
            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
        }
            break;
        case DSLCurrOrderCalendarDayViewCommented:
        {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          kDayColorForDisable, NSForegroundColorAttributeName,
                          SysFont(16), NSFontAttributeName, nil];
    
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextSetRGBStrokeColor(context,1,1,1,1.0); //画笔线的颜色
//            CGContextSetLineWidth(context, 0.5); // 线的宽度
//            CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height-2, 1.8, 0, 2*PI, 0); //添加一个圆
//            
//            UIColor *bColor = [UIColor whiteColor];
//            CGContextSetFillColorWithColor(context, bColor.CGColor);//填充颜色
//            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径

        }
            break;
            
        case DSLCurrOrderCalendarDayViewNotEated:
        {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor], NSForegroundColorAttributeName,
                          SysFont(16), NSFontAttributeName, nil];
        }
            break;
        default:
            break;
    }

    if (_isToday) {
        attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                      kDayBgColor, NSForegroundColorAttributeName,
                      SysFont(16), NSFontAttributeName, nil];
    }
    
    CGSize textSize =  [_labelText sizeWithAttributes:attributes];
    CGRect textRect = CGRectMake(floorf(CGRectGetMidX(self.bounds) - (textSize.width/2.0)),
                                 floorf(CGRectGetMidY(self.bounds) - (textSize.height/2.0)),
                                 textSize.width,
                                 textSize.height);

    [_labelText drawInRect:textRect withAttributes:attributes];
}

@end
