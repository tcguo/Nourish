//
//  UIScrollView+BDSBottomPullToRefresh.m
//  BDStockClient
//
//  Created by chengfei05 on 14/12/30.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "UITableView+BDSBottomPullToRefresh.h"
#import <objc/runtime.h>


@interface BDSBottomPullToRefreshView ()

@property (nonatomic, readwrite) CGFloat originalBottomInset;

- (void)resetScrollViewContentInset;

@end

static char keyBDSBottomPullToRefreshDelegate;
static char keyBDSBottomPullToRefreshView;

@implementation UITableView (BDSBottomPullToRefresh)

- (void)setBottomRefreshDelegate:(id <BDSBottomPullToRefreshDelegate>)refreshDelegate {
    if (refreshDelegate) {
        __weak typeof (self)                       weakSelf     = self;
        __weak id <BDSBottomPullToRefreshDelegate> weakDelegate = refreshDelegate;

        BDSBottomPullToRefreshView *view = [BDSBottomPullToRefreshView createRefreshView];
        view.originalBottomInset      = self.contentInset.bottom;
        self.bottomPullToRefreshView  = view;
        self.showsBottomPullToRefresh = YES;

        view.bottomPullToRefreshActionHandler = ^{
            [weakDelegate onStartBottomPullToRefresh:weakSelf];
        };
        view.tableView                        = self;
        [self addSubview:view];

        [self willChangeValueForKey:@"bottomRefreshDelegate"];
        objc_setAssociatedObject(self, &keyBDSBottomPullToRefreshDelegate, refreshDelegate, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"bottomRefreshDelegate"];
    }
}

- (id)bottomRefreshDelegate {
    return objc_getAssociatedObject(self, &keyBDSBottomPullToRefreshDelegate);
}

- (void)stopBottomRefresh {
    [self.bottomPullToRefreshView stopAnimating];

    if ([self.bottomRefreshDelegate respondsToSelector:@selector(onEndBottomPullToRefresh:)]) {
        [self.bottomRefreshDelegate onEndBottomPullToRefresh:self];
    }
}

- (void)stopBottomRefreshWithMsg:(NSString *)msg {
    self.bottomPullToRefreshView.state             = BDSBottomPullToRefreshState_Stopped;
    self.bottomPullToRefreshView.loadingLabel.text = msg;
}

- (void)finishBottomRefreshWithMsg:(NSString *)msg {
    self.bottomPullToRefreshView.state             = BDSBottomPullToRefreshState_Finished;
    [self.bottomPullToRefreshView.loadingLabel setText:msg];
}

- (void)finishBottomRefresh {
    [self finishBottomRefreshWithMsg:Tips_LOAD_NO_MORE];
}

- (void)finishBottomRefreshWithNetworkError {
    self.bottomPullToRefreshView.state             = BDSBottomPullToRefreshState_Click;
    self.bottomPullToRefreshView.loadingLabel.text = Tips_LOAD_WAITING;
}

- (void)resetBottomRefresh {
    self.bottomPullToRefreshView.state = BDSBottomPullToRefreshState_Stopped;
}

//- (void)reloadTableView {
//    [self reloadData];
//    CGFloat                    contentHeight   = self.contentSize.height;
//    CGFloat                    tableViewHeight = self.bounds.size.height;
//    BDSBottomPullToRefreshView *refreshView    = [self bottomPullToRefreshView];
//    CGFloat                    footerHeight    = refreshView.bounds.size.height;
//    BOOL                       visible         = tableViewHeight <= (contentHeight - footerHeight);
//    [refreshView makeVisible:visible];
//}


#pragma mark - Private
- (void)setBottomPullToRefreshView:(BDSBottomPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"BDSBottomPullToRefreshView"];
    objc_setAssociatedObject(self, &keyBDSBottomPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"BDSBottomPullToRefreshView"];
}

- (BDSBottomPullToRefreshView *)bottomPullToRefreshView {
    return objc_getAssociatedObject(self, &keyBDSBottomPullToRefreshView);
}

- (void)setShowsBottomPullToRefresh:(BOOL)showsPullToRefresh {
    self.bottomPullToRefreshView.hidden = !showsPullToRefresh;

    if (!showsPullToRefresh) {
        if (self.bottomPullToRefreshView.isObserving) {
            [self removeObserver:self.bottomPullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.bottomPullToRefreshView forKeyPath:@"contentSize"];
            [self.bottomPullToRefreshView resetScrollViewContentInset];
            self.bottomPullToRefreshView.isObserving = NO;
        }
    }
    else {
        if (!self.bottomPullToRefreshView.isObserving) {
            [self addObserver:self.bottomPullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.bottomPullToRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            self.bottomPullToRefreshView.isObserving = YES;

            BDSBottomPullToRefreshView *view = self.bottomPullToRefreshView;
            CGRect                     frame = view.frame;
            frame.origin.y   = self.bounds.size.height - frame.size.height;
            frame.size.width = self.bounds.size.width;
            view.frame       = frame;
        }
    }
}

- (BOOL)showsBottomPullToRefresh {
    return !self.bottomPullToRefreshView.hidden;
}

@end

#pragma mark -
@implementation BDSBottomPullToRefreshView

- (void)awakeFromNib {
    self.bottomInset = 0;
    self.loadingLabel.font      = SysFont(12);
    self.loadingLabel.textColor = RgbHex2UIColor(0X70, 0X7F, 0X8C);
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingText = Tips_LOAD_NO_MORE;
}

+ (BDSBottomPullToRefreshView *)createRefreshView {
    BDSBottomPullToRefreshView *view = [[[NSBundle mainBundle] loadNibNamed:@"BDSBottomPullToRefreshView" owner:nil options:nil] objectAtIndex:0];
    return view;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.loadingLabel.frame = CGRectMake(0, self.loadingLabel.frame.origin.y, self.frame.size.width, self.loadingLabel.frame.size.height);
}

- (void)startLoading {
    [self.loadingIndicatorView startAnimating];
    self.loadingIndicatorView.hidden = NO;
    self.loadingLabel.text           = @"正在加载更多...";
}

- (void)stopLoading {
    [self.loadingIndicatorView stopAnimating];
    self.loadingIndicatorView.hidden = YES;
    self.loadingLabel.text           = @"上拉加载更多";
}

- (void)finishLoading {
    [self.loadingIndicatorView stopAnimating];
    self.loadingIndicatorView.hidden = YES;
    self.loadingLabel.text           = self.loadingText;
}

- (void)makeVisible:(BOOL)visible {
    BOOL hidden = !visible;
    self.loadingLabel.hidden         = hidden;
    self.loadingIndicatorView.hidden = hidden;
}

- (void)startAnimating {
    self.state = BDSBottomPullToRefreshState_Loading;
}

- (void)stopAnimating {
    self.state = BDSBottomPullToRefreshState_Stopped;

//    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentSize.height - self.tableView.bounds.size.height + self.originalBottomInset) animated:YES];
}

- (void)resetLoaingText {
    self.loadingText = Tips_LOAD_NO_MORE;
}

- (void)setState:(BDSBottomPullToRefreshState)newState {
    if (_state == newState) {
        return;
    }

    BDSBottomPullToRefreshState previousState = _state;
    _state = newState;

    [self setNeedsLayout];
    [self layoutIfNeeded];

    switch (newState) {
        case BDSBottomPullToRefreshState_Stopped: {
            if (_tableView.contentSize.height >= _tableView.bounds.size.height) {
                [self stopLoading];
            }
        }
            break;

        case BDSBottomPullToRefreshState_Loading: {
            [self setScrollViewContentInsetForLoading];
            [self startLoading];
            if (previousState == BDSBottomPullToRefreshState_Stopped && _bottomPullToRefreshActionHandler)
                _bottomPullToRefreshActionHandler();
        }
            break;
        case BDSBottomPullToRefreshState_Finished: {
            [self setScrollViewContentInsetForLoading];
            [self finishLoading];
        }
            break;
        case BDSBottomPullToRefreshState_Click: {
            [self setScrollViewContentInsetForLoading];
            [self stopLoading];
        }
            break;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UITableView *tableView = (UITableView *) self.superview;
        if (tableView.showsBottomPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [tableView removeObserver:self forKeyPath:@"contentOffset"];
                [tableView removeObserver:self forKeyPath:@"contentSize"];
                self.isObserving = NO;
            }
        }
    }
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.tableView.contentInset;
    currentInsets.bottom = self.originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    //CGFloat offset = MAX(self.tableView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.tableView.contentInset;
    currentInsets.bottom = self.bounds.size.height;//MIN(offset, self.originalBottomInset + self.bounds.size.height);
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    self.tableView.contentInset = UIEdgeInsetsMake(contentInset.top, contentInset.left, contentInset.bottom + self.bottomInset, contentInset.right);
}

#pragma mark - Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat contentHeight   = self.tableView.contentSize.height;
        CGFloat tableViewHeight = self.tableView.bounds.size.height;
        if (contentHeight > 20) {
            self.content.hidden = NO;
            if (contentHeight < tableViewHeight) {
                [self finishLoading];
            }
        } else {
            self.content.hidden = YES;
        }   
//        BOOL visible = tableViewHeight <= (contentHeight - self.bounds.size.height);
//        self.content.hidden = !visible;
//        if (visible) {
        CGRect frame   = self.frame;
        frame.origin.y = self.tableView.contentSize.height;
        self.frame     = frame;
//        }
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    CGFloat contentHeight   = self.tableView.contentSize.height;
    CGFloat contentOffsetY  = contentOffset.y;
    CGFloat tableViewHeight = self.tableView.bounds.size.height;

    //BOOL visible = tableViewHeight <= (contentHeight - self.bounds.size.height);
    BOOL visible = tableViewHeight <= contentHeight;
    if (visible) {
        BOOL scrollToBottom = (contentOffsetY + tableViewHeight) >= contentHeight;
        if (scrollToBottom) {
            if (_state == BDSBottomPullToRefreshState_Stopped) {
                self.state = BDSBottomPullToRefreshState_Loading;
            }
        }
    }

}

- (IBAction)onClicked:(id)sender {
    if (_state == BDSBottomPullToRefreshState_Click && _bottomPullToRefreshActionHandler) {
        self.state = BDSBottomPullToRefreshState_Loading;
        _bottomPullToRefreshActionHandler();
    }
}


@end
