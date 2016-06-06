/*
 DSLCalendarDayView.h
 
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


#import "DSLCalendarDayView.h"
#import "NSDate+DSLCalendarView.h"

//$$$ test
#import "DSLCalendarRange.h"

#define kDayColorForDisable RgbHex2UIColor(0x58, 0xF1, 0xb6)
#define kDayBgColor RgbHex2UIColor(0x16, 0xd4, 0x98)

#define kTextHeight 40
#define PI 3.14159265358979323846

@interface DSLCalendarDayView ()

@property (nonatomic, assign) CGContextRef context;

@end


@implementation DSLCalendarDayView {
    __strong NSCalendar *_calendar;
    __strong NSDate *_dayAsDate;
    __strong NSDateComponents *_day;
    __strong NSString *_labelText;
    __strong NSString *_tipText;
    BOOL _isToday;
}


#pragma mark - Initialisation

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
    }
    
    return self;
}

#pragma mark Properties

- (void)setSelectionState:(DSLCalendarDayViewSelectionState)selectionState {
    _selectionState = selectionState;
    [self setNeedsDisplay];
}

- (void)setDay:(NSDateComponents *)day {
    _calendar = [day calendar];
    _dayAsDate = [day date];
    _day = nil;
    _labelText = [NSString stringWithFormat:@"%ld", (long)day.day];
    _isToday = [day.date isToday];
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
    [self drawBackground];
    [self setNeedsDisplay];
}


#pragma mark UIView methods

- (void)drawRect:(CGRect)rect {
    if ([self isMemberOfClass:[DSLCalendarDayView class]]) {
        // If this isn't a subclass of DSLCalendarDayView, use the default drawing
      
        [self drawBackground];
//        [self drawBorders];
        [self drawDayNumber];
        
    }
}

#pragma mark Drawing

- (void)drawBackground {
    
    CGRect newRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y +4, self.bounds.size.width, self.bounds.size.height -8);
    switch (self.selectionState) {
        case DSLCalendarDayViewDisable:
            break;
        
      
        case DSLCalendarDayViewNotSelected:
            
            break;
          
        case DSLCalendarDayViewOrdered:
        case DSLCalendarDayViewSelected:
        {
            
            switch (self.positionInWeek) {
                case DSLCalendarDayViewStartOfWeek:
                {
//                    UIImage *originImage = [UIImage imageNamed:@"DSLCalendarDaySelection-left"];
//                    UIGraphicsBeginImageContext(newRect.size);
//                     UIImage *newImage = [originImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
//                    [newImage drawInRect:newRect];
//                    UIGraphicsEndImageContext();
//                    
                    [[[UIImage imageNamed:@"DSLCalendarDaySelection-left"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] drawInRect:newRect];

                }
                    break;
                case DSLCalendarDayViewMidWeek:
                    if (!_isToday) {
                         [[[UIImage imageNamed:@"DSLCalendarDaySelection-middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] drawInRect:newRect];
                    }
                    break;
                case DSLCalendarDayViewEndOfWeek:
                    [[[UIImage imageNamed:@"DSLCalendarDaySelection-right"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] drawInRect:newRect];
                    break;
                default:
                    break;
            }

        }
            
        break;
            
        default:
            break;
    }
    
    
    if (_isToday) {
        //$$$ 报错误异常
        self.context = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(self.context);
        CGContextSetRGBStrokeColor(self.context,1,1,1,1.0);//画笔线的颜色
        CGContextSetLineWidth(self.context, 0.5);//线的宽度
        //添加一个圆
        CGContextAddArc(self.context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-5, 0, 2*PI, 0);
        
        //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充

        UIColor *aColor = [UIColor whiteColor];
        CGContextSetFillColorWithColor(self.context, aColor.CGColor);//填充颜色
        CGContextDrawPath(self.context, kCGPathFillStroke); //绘制路径
        UIGraphicsPopContext();//恢复上下文
    }
    
}

/*
- (void)drawBackgroundOld {

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetRGBStrokeColor(context,1,1,1,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 0.5);//线的宽度
    //添加一个圆
    CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-2, 0, 2*PI, 0);
   
    //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
    
    
    switch (self.selectionState) {
        case DSLCalendarDayViewDisable:
            break;
            
        case DSLCalendarDayViewNotSelected:
        {
            UIColor *aColor = [UIColor whiteColor];
            CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
            CGContextDrawPath(context, kCGPathStroke); //绘制路径
        }
            break;
            
        
        case DSLCalendarDayViewStartOfSelection:
            break;
            
        case DSLCalendarDayViewEndOfSelection:
            break;
            
        case DSLCalendarDayViewWithinSelection:
//        {
//            UIColor *aColor = RgbHex2UIColor(0xe2, 0xab, 0x35);
//            CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
//            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
//        }
            break;
            
        case DSLCalendarDayViewSelected:
        {
            UIColor *aColor = ColorRed_Normal;
            aColor = RgbHex2UIColor(0xe2, 0xab, 0x35);
            
            CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
        }
            break;
    }
    
    if (_isToday) {
        UIColor *aColor = [UIColor whiteColor];
        CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
    }
    
}
 
*/

//- (void)drawBorders {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetLineWidth(context, 1.0);
//    
//    CGContextSaveGState(context);
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:255.0/255.0 alpha:1.0].CGColor);
//    CGContextMoveToPoint(context, 0.5, self.bounds.size.height - 0.5);
//    CGContextAddLineToPoint(context, 0.5, 0.5);
//    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, 0.5);
//    CGContextStrokePath(context);
//    CGContextRestoreGState(context);
//    
//    CGContextSaveGState(context);
//    if (self.isInCurrentMonth) {
//        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:205.0/255.0 alpha:1.0].CGColor);
//    }
//    else {
//        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:185.0/255.0 alpha:1.0].CGColor);
//    }
//    CGContextMoveToPoint(context, self.bounds.size.width - 0.5, 0.0);
//    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, self.bounds.size.height - 0.5);
//    CGContextAddLineToPoint(context, 0.0, self.bounds.size.height - 0.5);
//    CGContextStrokePath(context);
//    CGContextRestoreGState(context);
//}

- (void)drawDayNumber {

    NSDictionary *attributes = nil;
    NSDictionary *attributesOfTipText = nil;
    NSDictionary *attributesOfOrdered = nil;
    
    switch (self.selectionState) {
        case DSLCalendarDayViewDisable:
        {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          kDayColorForDisable, NSForegroundColorAttributeName, SysFont(17), NSFontAttributeName, nil];
            
            if (self.weekGroupID == 0) {
                if (self.day.weekday != 7 && self.day.weekday != 1) {
                    attributesOfTipText = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor redColor], NSForegroundColorAttributeName, SysFont(8), NSFontAttributeName, nil];
                    _tipText  = @"假";
                }
            }
            
        }
            break;
        case DSLCalendarDayViewOrdered:
        {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor], NSForegroundColorAttributeName, SysFont(17), NSFontAttributeName, nil];
            attributesOfTipText = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor redColor], NSForegroundColorAttributeName, SysFont(8), NSFontAttributeName, nil];
            _tipText  = @"诺";
            
        }
            break;
            
        case DSLCalendarDayViewNotSelected:
        case DSLCalendarDayViewSelected:
        {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor], NSForegroundColorAttributeName, SysFont(17), NSFontAttributeName, nil];
            
            if (self.day.weekday == 7 || self.day.weekday == 1) {
                attributesOfTipText = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIColor redColor], NSForegroundColorAttributeName, SysFont(8), NSFontAttributeName, nil];
                _tipText  = @"班";
            }
        }
            break;
            
        default:
            break;
    }
    
    if (_isToday) {
        attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                      kDayBgColor, NSForegroundColorAttributeName, SysFont(17), NSFontAttributeName, nil];
    }
    
    CGSize  textSize =  [_labelText sizeWithAttributes:attributes];
    
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds) - (textSize.height / 2.0)), textSize.width, textSize.height);
    [_labelText drawInRect:textRect withAttributes:attributes];
    
    if (attributesOfTipText) {
        CGRect textRect = CGRectMake(self.bounds.origin.x+self.bounds.size.width-15, self.bounds.origin.y +4, 8, 8);
        [_tipText drawInRect:textRect withAttributes:attributesOfTipText];
    }
}

@end
