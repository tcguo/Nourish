//
//  NRDrawCycleView.m
//  NRAnimationTest
//
//  Created by gtc on 15/5/25.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "KACircleProgressView.h"

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@interface KACircleProgressView ()

@property (nonatomic, assign) CGPoint newCenter;

@end

@implementation KACircleProgressView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _trackLayer = [CAShapeLayer new];
        [self.layer addSublayer:_trackLayer];
        _trackLayer.fillColor = nil;
         _trackLayer.lineCap = kCALineCapRound;
        _trackLayer.frame = self.bounds;
        
        _progressLayer = [CAShapeLayer new];
        [self.layer addSublayer:_progressLayer];
        _progressLayer.fillColor = nil;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.frame = self.bounds;
        _progressLayer.speed = 0.5;
        _progressLayer.strokeEnd = 0.0;
        
        //默认5
        self.progressWidth = 5;

        self.newCenter = CGPointMake(self.center.x, (self.center.y + self.bounds.size.height/2));
    }
    return self;
}

- (void)setTrack
{
    _trackPath = [UIBezierPath bezierPathWithArcCenter:self.newCenter radius:(self.bounds.size.width - _progressWidth)/ 2 startAngle:DEGREES_TO_RADIANS(-180) endAngle:DEGREES_TO_RADIANS(0)  clockwise:YES];;
    
//    _trackPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:(self.bounds.size.width - _progressWidth)/ 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    _trackLayer.path = _trackPath.CGPath;
}

- (void)setProgress {
     _progressPath = [UIBezierPath bezierPathWithArcCenter:self.newCenter radius:(self.bounds.size.width - _progressWidth)/ 2 startAngle:DEGREES_TO_RADIANS(-180) endAngle: DEGREES_TO_RADIANS(-(180-_progress)) clockwise:YES];
    
    _progressLayer.path = _progressPath.CGPath;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.25;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    [_progressLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    _progressLayer.strokeEnd = 1;
}


- (void)setProgressWidth:(float)progressWidth
{
    _progressWidth = progressWidth;
    _trackLayer.lineWidth = _progressWidth;
    _progressLayer.lineWidth = _progressWidth;
    
    [self setTrack];
    [self setProgress];
}

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackLayer.strokeColor = trackColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressLayer.strokeColor = progressColor.CGColor;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    
    [self setProgress];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    
}


@end
