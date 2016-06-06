/*
 DSLCurrOrderCalendarMonthSelectorView.m
 
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


#import "DSLChangeOrderCalendarMonthSelectorView.h"


@interface DSLChangeOrderCalendarMonthSelectorView ()
{
}

@property (strong, nonatomic) NSMutableDictionary *dayNames;

@end


@implementation DSLChangeOrderCalendarMonthSelectorView


#pragma mark - Initialisation

// Designated initialiser
+ (id)view {
    static UINib *nib;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    });
    
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    for (id object in nibObjects) {
        if ([object isKindOfClass:[self class]]) {
            return object;
        }
    }
    
    return nil;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self.backButton makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(0);
            make.width.equalTo(45);
            make.height.equalTo(36);
        }];
        
        [self.forwardButton makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.equalTo(0);
            make.width.equalTo(45);
            make.height.equalTo(36);
        }];
        
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX);
            make.top.equalTo(10);
        }];
        
        UILabel *monLabel = [self createWeekLabel:0];
        [self addSubview:monLabel];
        UILabel *tuesLabel = [self createWeekLabel:1];
        [self addSubview:tuesLabel];
        UILabel *wedLabel = [self createWeekLabel:2];
        [self addSubview:wedLabel];
        UILabel *tursLabel = [self createWeekLabel:3];
        [self addSubview:tursLabel];
        UILabel *friLabel = [self createWeekLabel:4];
        [self addSubview:friLabel];
        UILabel *satLabel = [self createWeekLabel:5];
        [self addSubview:satLabel];
        UILabel *sunLabel = [self createWeekLabel:6];
        [self addSubview:sunLabel];
        
        CGFloat width = self.bounds.size.width/7;
        
        [monLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom);
            make.left.equalTo(0);
            make.width.equalTo(width);
            make.height.equalTo(35);
        }];
        
        [tuesLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom);
            make.left.equalTo(monLabel.mas_right);
            make.width.equalTo(width);
            make.height.equalTo(35);
        }];
        
        [wedLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom);
            make.left.equalTo(tuesLabel.mas_right);
            make.width.equalTo(width);
            make.height.equalTo(35);
        }];
        
        [tursLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom);
            make.left.equalTo(wedLabel.mas_right);
            make.width.equalTo(width);
            make.height.equalTo(35);
        }];
        [friLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom);
            make.left.equalTo(tursLabel.mas_right);
            make.width.equalTo(width);
            make.height.equalTo(35);
        }];
        [satLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom);
            make.left.equalTo(friLabel.mas_right);
            make.width.equalTo(width);
            make.height.equalTo(35);
        }];
        [sunLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom);
            make.right.equalTo(0);
            make.width.equalTo(width);
            make.height.equalTo(35);
        }];
    }
    
    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        // Initialise properties
    }
    
    return self;
}

- (UILabel *)createWeekLabel:(NSInteger)tag
{
    UILabel *weekLabel = [[UILabel alloc] init];
    weekLabel.textColor = RgbHex2UIColor(0x11, 0xaa, 0x76);
    weekLabel.backgroundColor = RgbHex2UIColor(0x6c, 0xef, 0xc4);
    weekLabel.text = [[self.dayNames objectForKey:@(tag)] uppercaseString];
    weekLabel.font = NRFont(10);
    weekLabel.textAlignment = NSTextAlignmentCenter;
    return weekLabel;
}

- (UILabel *)titleLabel
{
    if (_titleLabel) {
        return _titleLabel;
    }
    
    _titleLabel = [[UILabel alloc] init];
    [self addSubview:_titleLabel];
    _titleLabel.textColor = [UIColor whiteColor];
    [_titleLabel setFont:NRFont(17)];
    
    return _titleLabel;
}

- (UIButton *)backButton
{
    if (_backButton) {
        return _backButton;
    }
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_backButton];
    [_backButton setImage:[UIImage imageNamed:@"DSLCalendar-previousMonth"] forState:UIControlStateNormal];
    
    return _backButton;
}

- (UIButton *)forwardButton
{
    if (_forwardButton) {
        return _forwardButton;
    }
    
    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_forwardButton];
    [_forwardButton setImage:[UIImage imageNamed:@"DSLCalendar-nextMonth"] forState:UIControlStateNormal];
    
    return _forwardButton;
}

- (NSMutableDictionary *)dayNames
{
    if (_dayNames) {
        return _dayNames;
    }
    
    _dayNames = [[NSMutableDictionary alloc] init];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE";
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
   
    
    for (NSInteger index = 0; index < 7; index++) {
        NSInteger weekday = dateComponents.weekday - [dateComponents.calendar firstWeekday];
        if (weekday < 0) weekday += 7;
        //        NSLog(@"weekday = %@", [formatter stringFromDate:dateComponents.date]);
        [_dayNames setObject:[formatter stringFromDate:dateComponents.date] forKey:@(weekday)];
        
        dateComponents.day = dateComponents.day + 1;
        dateComponents = [dateComponents.calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:dateComponents.date];
    }
    
    return _dayNames;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}


#pragma mark - UIView methods

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ([self isMemberOfClass:[DSLChangeOrderCalendarMonthSelectorView class]]) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:205.0/255.0 alpha:1.0].CGColor);
        CGContextMoveToPoint(context, 0.0, self.bounds.size.height - 0.5);
        CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, self.bounds.size.height - 0.5);
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
    }
}

@end
