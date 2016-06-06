//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"

#define TEXT_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView ()

@property (nonatomic, assign) UIEdgeInsets scrollViewOriginalInset;

@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _noMore = NO;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor =  [UIColor clearColor];
//		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];

        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (height-30)/2 + 10, width, 15.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = SysFont(13);
		label.textColor = [UIColor whiteColor];
        
//		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
//		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
    
		CircleView *circleView = [[CircleView alloc] initWithFrame:CGRectMake(0, 80, 35, 35)];
        _circleView = circleView;
        [self addSubview:circleView];
        circleView.hidden = YES;
        
        _loadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-change-load"]];
        _loadImageView.contentMode = UIViewContentModeCenter;
        _loadImageView.frame = CGRectMake((width-30)/2, (height-30)/2 - 30, 30, 30);
        [self addSubview:_loadImageView];
		
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

/*
- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[formatter release];
		
	}
    else {
		_lastUpdatedLabel.text = nil;
	}
}
*/


- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			_statusLabel.text = @"松开即可新口味";
            [_loadImageView.layer removeAllAnimations];
			break;
		case EGOOPullRefreshNormal:
        {
			if (_state == EGOOPullRefreshPulling) {
                
			} else {
//                _circleView.transform = CGAffineTransformIdentity;
                _circleView.progress = 0;
                [_circleView setNeedsDisplay];
            }
			
            [_loadImageView.layer removeAllAnimations];
			_statusLabel.text = @"换口味";
        }
			break;
            
		case EGOOPullRefreshLoading:
        {
			_statusLabel.text = @"新口味...";
//			[_activityView startAnimating];
            
            CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
            rotate.removedOnCompletion = FALSE;
            rotate.fillMode = kCAFillModeForwards;
            
            //Do a series of 5 quarter turns for a total of a 1.25 turns
            //(2PI is a full turn, so pi/2 is a quarter turn)
            [rotate setToValue: [NSNumber numberWithFloat: M_PI / 2]];
            rotate.repeatCount = 11;
            
            rotate.duration = 0.25;
//            rotate.beginTime = start;
            rotate.cumulative = TRUE;
            rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            [_circleView.layer addAnimation:rotate forKey:@"rotateAnimation"];
			
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
            rotationAnimation.duration = 1.0;
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = 10;//HUGE_VALF;
            [_loadImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        }
			break;
        case EGOOPullRefreshNoMore:
        {
            _statusLabel.text = @"没有了~";
            [_loadImageView.layer removeAllAnimations];
        }
            break;
		default:
			break;
	}
	
	_state = aState;
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewWillBeginScroll:(UIScrollView *)scrollView
{
    BOOL _loading = NO;
    if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    if (!_loading) {
        [self setState:EGOOPullRefreshNormal];
    }
}

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"offset y = %f,H2=%f,b=%f", scrollView.contentOffset.y, H2,  scrollView.contentInset.bottom);
//    CGFloat offsetY = scrollView.contentOffset.y + scrollView.bounds.size.height;
    
    CGFloat offVal =  scrollView.contentOffset.x+(scrollView.frame.size.width) - scrollView.contentSize.width;
   
    if (offVal > 0.0) {
        if ([self.delegate respondsToSelector:@selector(showHeaderView)]) {
            [self.delegate showHeaderView];
        }
    }
    else {
        if (_state != EGOOPullRefreshLoading && _state != EGOOPullRefreshPulling) {
            if ([self.delegate respondsToSelector:@selector(hideHeaderView)]) {
                [self.delegate hideHeaderView];
            }
        }
    }
    
	if (_state == EGOOPullRefreshLoading) {
        CGFloat offset = MAX(scrollView.contentOffset.x * -1, 0);
        offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0, REFRESH_REGION_HEIGHT);
	}
    else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [self.delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
       
//        NSLog(@"offVal= %f", offVal);
        
        if (_state == EGOOPullRefreshPulling &&  offVal >0 && offVal <65 && !_loading) {
            if (self.noMore) {
                [self setState:EGOOPullRefreshNoMore];
            }
            else
                [self setState:EGOOPullRefreshNormal];
		}
        else if (_state == EGOOPullRefreshNormal && offVal >15.0 && !_loading) {
            
//            CGFloat tmp =  offVal;
//            float moveY = fabs(tmp);
//            if (moveY > 65)
//                moveY = 65;
//            _circleView.progress = (moveY-15) / (65-15);
//            [_circleView setNeedsDisplay];
            
            
            if (offVal > 65) {
                if (self.noMore) {
                    [self setState:EGOOPullRefreshNoMore];
                }
                else
                    [self setState:EGOOPullRefreshPulling];
            }
        }
        
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
        
        
//        if (_state == EGOOPullRefreshPulling &&  (scrollView.contentOffset.x+scrollView.frame.size.width) < scrollView.contentSize.width+REFRESH_REGION_HEIGHT && scrollView.contentOffset.x > 0.0f && !_loading) {
//            [self setState:EGOOPullRefreshNormal];
//        }
//        else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.x+(scrollView.frame.size.width) > scrollView.contentSize.width+REFRESH_REGION_HEIGHT && !_loading) {
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
    if (_state == EGOOPullRefreshNoMore) {
        return;
    }
    
    BOOL _loading = NO;
    if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [self.delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    if (scrollView.contentOffset.x+(scrollView.frame.size.width) > scrollView.contentSize.width+REFRESH_REGION_HEIGHT  && !_loading) {
        
        if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [self.delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        
        [self setState:EGOOPullRefreshLoading];
        scrollView.pagingEnabled = NO;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f , REFRESH_REGION_HEIGHT);
        [UIView commitAnimations];
        
    }
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
   
	[UIView commitAnimations];

    if (self.noMore) {
        [self setState:EGOOPullRefreshNoMore];
    }
    else
        [self setState:EGOOPullRefreshNormal];
    
    scrollView.pagingEnabled = YES;
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_circleView.layer removeAllAnimations];
        
        if ([self.delegate respondsToSelector:@selector(hideHeaderView)]) {
            [self.delegate hideHeaderView];
        }
    });
}


#pragma mark - Dealloc

- (void)dealloc {
	_delegate = nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
}


@end
