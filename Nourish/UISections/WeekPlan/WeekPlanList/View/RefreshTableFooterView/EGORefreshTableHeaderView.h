//
//  EGORefreshTableHeaderView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CircleView.h"

#define  REFRESH_REGION_HEIGHT 65.0f

typedef NS_ENUM(NSUInteger, EGOPullRefreshState) {
    EGOOPullRefreshPulling = 0,
    EGOOPullRefreshNormal,
    EGOOPullRefreshLoading,
    EGOOPullRefreshNoMore,
};

@protocol EGORefreshTableHeaderDelegate;
@interface EGORefreshTableHeaderView : UIView
{
	EGOPullRefreshState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
    CircleView *_circleView;
	UIActivityIndicatorView *_activityView;
	
    UIImageView *_loadImageView;
}

@property (nonatomic, assign) id<EGORefreshTableHeaderDelegate> delegate;
@property (nonatomic, assign) EGOPullRefreshState state;
@property (nonatomic, assign) BOOL noMore;

//- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewWillBeginScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end


@protocol EGORefreshTableHeaderDelegate<NSObject>
@required
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view;

@optional
- (void)hideHeaderView;
- (void)showHeaderView;
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;

@end
