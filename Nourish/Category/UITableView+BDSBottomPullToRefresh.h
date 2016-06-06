//
//  UIScrollView+BDSBottomPullToRefresh.h
//  BDStockClient
//
//  Created by chengfei05 on 14/12/30.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BDSBottomPullToRefreshDelegate <NSObject>

- (void)onStartBottomPullToRefresh:(UITableView *)tableView;

@optional
- (void)onEndBottomPullToRefresh:(UITableView *)tableView;

@end

@class BDSBottomPullToRefreshView;

@interface UITableView (BDSBottomPullToRefresh)

@property (nonatomic, weak) id <BDSBottomPullToRefreshDelegate> bottomRefreshDelegate;

@property (nonatomic, strong, readonly) BDSBottomPullToRefreshView *bottomPullToRefreshView;
@property (nonatomic, assign) BOOL                                 showsBottomPullToRefresh;

- (void)stopBottomRefresh;

- (void)finishBottomRefreshWithMsg:(NSString *)msg;

- (void)finishBottomRefresh;

- (void)finishBottomRefreshWithNetworkError;

- (void)resetBottomRefresh;

@end


#pragma mark -

typedef NS_ENUM(NSUInteger, BDSBottomPullToRefreshState) {
    BDSBottomPullToRefreshState_Stopped = 0,
    BDSBottomPullToRefreshState_Loading,
    BDSBottomPullToRefreshState_Finished,
    BDSBottomPullToRefreshState_Click
};

@interface BDSBottomPullToRefreshView : UIView

@property (nonatomic, strong)          NSString                *loadingText;
@property (nonatomic, strong) IBOutlet UIView                  *content;
@property (nonatomic, strong) IBOutlet UILabel                 *loadingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicatorView;

@property (nonatomic, weak) UITableView                   *tableView;
@property (nonatomic, assign) BDSBottomPullToRefreshState state;
@property (nonatomic, assign) BOOL                        showsPullToRefresh;
@property (nonatomic, assign) BOOL                        isObserving;
@property (nonatomic, assign) CGFloat                     bottomInset;

@property (nonatomic, copy) void (^bottomPullToRefreshActionHandler)(void);

+ (BDSBottomPullToRefreshView *)createRefreshView;

- (void)startLoading;

- (void)stopLoading;

- (void)finishLoading;

- (void)makeVisible:(BOOL)visible;


- (void)startAnimating;

- (void)stopAnimating;

- (void)resetLoaingText;

- (IBAction)onClicked:(id)sender;

@end

