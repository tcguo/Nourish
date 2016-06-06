//
//  NRWeekPlanListViewController.m
//  Nourish
//
//  Created by gtc on 15/1/22.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanListViewController.h"
#import "NRWeekPlanListItemView.h"
#import "UIButton+Additions.h"
#import "NRWeekPlanListItemModel.h"
#import "FTAnimation.h"
#import "NRPlaceOrderViewController.h"
#import "UIImageView+LBBlurredImage.h"
#import "NRLoginViewController.h"
#import "NRNavigationController.h"
#import "EGORefreshTableHeaderView.h"
#import "NRLoginManager.h"
#import "NRWeekPlanListViewModel.h"
#import "UIView+ActivityIndicator.h"

@interface NRWeekPlanListViewController () <WeekPlanListDelegate, LoginDelegate, UIAlertViewDelegate, EGORefreshTableHeaderDelegate>
{
    BOOL _needupdate;
    UIButton *_changeButton;
    UIButton *_collectButton;
    
    UILabel *_lblWeekday;
    UILabel *_lblFeastday;
    BOOL _reloading;
    BOOL _isSwitching;
}

@property (nonatomic, strong) NSURLSessionDataTask *changeTask;
@property (nonatomic, strong) NSURLSessionDataTask *collectTask;
@property (nonatomic, strong) NRWeekPlanListViewModel *viewModel;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *barView;

@property (nonatomic, assign) BOOL isFromCollectVC;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NRWeekPlanListItemModel *currentMod;

@property (nonatomic, strong) NSMutableArray *marrItemViews;
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, strong) NSNumber *collectID;

@property (nonatomic, assign) NSInteger changeIndex;

@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;

@end

@implementation NRWeekPlanListViewController

#pragma mark - super method

- (id)initWithFromCollect:(BOOL)isFromCollect {
    self = [super init];
    if (self) {
        _isFromCollectVC = isFromCollect;
        _changeIndex = 0;
        _isSwitching = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    
    _bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _bgImgView.image = [UIImage imageNamed:@"wp-bg"];
    _bgImgView.contentMode = UIViewContentModeScaleToFill;
    [self.view.layer addSublayer:self.bgImgView.layer];
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_maskView];
    [self.view addSubview:self.scrollView];
    if (self.isFromCollectVC) {
        [self setupOrderButtonWithChangeBarButton:NO];
    }
}

- (void)setupOrderButtonWithChangeBarButton:(BOOL)hasChangeButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"下单" style:UIBarButtonItemStylePlain target:self action:@selector(placeOrder:)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    
    _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_collectButton setImage:[UIImage imageNamed:@"wp-collect"] forState:UIControlStateNormal];
    [_collectButton setImage:[UIImage imageNamed:@"wp-collected"] forState:UIControlStateSelected];
    
    _collectButton.exclusiveTouch = YES;
    [_collectButton addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    _collectButton.frame = CGRectMake(0, 0, 28, 28);
    UIBarButtonItem *collBarButton = [[UIBarButtonItem alloc] initWithCustomView:_collectButton];
    
    if (hasChangeButton) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton setImage:[UIImage imageNamed:@"wp-change"] forState:UIControlStateNormal];
        _changeButton.exclusiveTouch = YES;
        [_changeButton addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
        _changeButton.frame = CGRectMake(0, 0, 28, 28);
        UIBarButtonItem *changeBarButton = [[UIBarButtonItem alloc] initWithCustomView:_changeButton];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem, collBarButton, changeBarButton, nil];
    }
    else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem, collBarButton, nil];
    }
}

#pragma mark - ScrollView
- (void)initScrollViewWithRefreshable:(BOOL)refreshable {
    CGFloat height = self.view.frame.size.height-20-10;
    _scrollView.frame = CGRectMake(15, 20, self.view.bounds.size.width-30, height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*self.numberOfPages, self.scrollView.frame.size.height);
    
    if (refreshable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_refreshHeaderView == nil) {
                CGRect rect = CGRectMake(SCREEN_WIDTH-75, 20, 65, height);
                EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:rect];
                view.delegate = self;
                [self.view insertSubview:view belowSubview:self.scrollView];
                _refreshHeaderView = view;
                _refreshHeaderView.hidden = YES;
            }
        });
    }
  
    [self createAllEmptyPagesForScrollView:self.numberOfPages];
    self.currentPage = 0;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // 预加载三个
    [self loadScrollViewWithPage:self.currentPage-1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage+1];
}

- (void)createAllEmptyPagesForScrollView:(NSUInteger) pages {
    if (pages == 0) {
        return;
    }
    
    for (int page = 0; page < pages; page++) {
        CGRect frame = self.scrollView.frame;
        CGRect rect = CGRectMake(frame.size.width * page +5, 0, self.scrollView.bounds.size.width-10, self.scrollView.bounds.size.height);
        
        NRWeekPlanListItemModel *mod = [self.marrWPList objectAtIndex:page];
        NRWeekPlanListItemView *view = nil;
        if (mod.itemType == ListItemTypeIntrodution) {
            view =  [[NRWeekPlanListItemView alloc] initWithFrame:rect type:ListItemTypeIntrodution mod:mod];
        }
        else {
            view =  [[NRWeekPlanListItemView alloc] initWithFrame:rect type:ListItemTypeImage mod:mod];
            view.weekplanlistDelegate = self;
        }
        
        view.tag = page;
        [self.marrItemViews addObject:view];
        [self.scrollView addSubview:view];
    }
}

- (void)loadScrollViewWithPage:(NSInteger)page {
    if (page < 0 || page >= self.numberOfPages) {
        return;
    }
    
    NRWeekPlanListItemView *view = [self.marrItemViews objectAtIndex:page];
    if (view.listItemType == ListItemTypeImage) {
        [view loadImage];
    }
}

#pragma mark - Action
- (void)changeAction:(id)sender {
    [MobClick event:NREvent_Click_WPList_Change];
    
    if (_isSwitching) {
        // 正在执行右边换口味的时候，上面菜单不可点
        return;
    }
    
    if (!self.viewModel.hasMore) {
        [MBProgressHUD showTips:KeyWindow text:@"没有更多了"];
        return;
    }
    
    //    [self getWeekplanlist];
    [self changeWeekplanlistWithFromBarButton:YES];
}

- (void)collectAction:(id)sender {
    [MobClick event:NREvent_Click_WPList_Collect];
    
    // 取消收藏 挽留一下
    if (self.currentMod && self.currentMod.hasCollected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否取消收藏?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alertView show];
        return;
    }
    
    NSDictionary *paramDic = @{ @"smwIds": self.currentMod.arrWPSID };
    __weak typeof(self) weakself = self;
    [[self.viewModel collectWeekplanWithParametres:paramDic] subscribeNext:^(id x) {
        NSNumber *collectId = (NSNumber *)x;
        weakself.currentMod.collectId = [collectId integerValue];
        weakself.currentMod.hasCollected = YES;
        [_collectButton setSelected:YES];
        [MBProgressHUD showDoneWithText:KeyWindow text:@"收藏成功"];
        
    } error:^(NSError *error) {
        if (error.code == 3003) {
            [MBProgressHUD showErrormsgWithoutIcon:KeyWindow title:@"已收藏" detail:nil];
            weakself.currentMod.hasCollected = YES;
            [_collectButton setSelected:YES];
        }
        else {
            [weakself processRequestError:error];
        }
    } completed:^{
    }];
}

- (void)cancelCollect {
    // 取消收藏
    NSDictionary *paramDic = @{ @"id": [NSNumber numberWithInteger:self.currentMod.collectId] };
    __weak typeof(self) weakself = self;
    
    [[self.viewModel cancelCollectWeekplanWithParametres:paramDic] subscribeNext:^(id x) {
        [_collectButton setSelected:NO];
        weakself.currentMod.hasCollected = NO;
        weakself.currentMod.collectId = 0;
    } error:^(NSError *error) {
        [weakself processRequestError:error];
    } completed:^{
        [MBProgressHUD showDoneWithText:weakself.view text:@"取消收藏"];
    }];
}

- (void)placeOrder:(id)sender {
    [MobClick event:NREvent_Click_WPList_PlaceOrder];
    
    if (self.currentMod == nil) {
        return;
    }
    
    // 判断登录
    if (![NRLoginManager sharedInstance].isLogined) {
        NRLoginViewController *loginVC = [NRLoginViewController sharedInstance];
        loginVC.loginDelegate = self;
        NRNavigationController *nav = [[NRNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else {
        NRPlaceOrderViewController *placeOrderVC = [[NRPlaceOrderViewController alloc] init];
        placeOrderVC.wptID = self.weekplanID;
        placeOrderVC.currentMod = self.currentMod;
        placeOrderVC.unitPrice = self.pricePerDay;
        placeOrderVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:placeOrderVC animated:YES];
    }
}


#pragma mark - Private Methods
- (void)getWeekplanlistWithSmwIds:(NSArray *)smwIds {
    [MBProgressHUD showActivityWithText:KeyWindow text:@"正在加载..." animated:YES];
    NSDictionary *dic = @{ @"smwIds": smwIds };
    __weak typeof(self) weakself = self;
    
    [[self.viewModel getCollectWeekplanlistWithParametres:dic] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        if (!ARRAYHASVALUE(weakself.viewModel.dataArray)) {
            [MBProgressHUD showErrormsg:KeyWindow msg:@"抱歉，您的地址不在配送范围内"];
            return;
        }

        // 继续加载视图
        weakself.currentMod = weakself.viewModel.currentMod;
        weakself.numberOfPages = weakself.viewModel.dataArray.count;
        weakself.marrWPList = weakself.viewModel.dataArray;
        weakself.marrItemViews = [NSMutableArray arrayWithCapacity:weakself.numberOfPages];
        [weakself initScrollViewWithRefreshable:NO];
        
    } error:^(NSError *error) {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        if (error.code == 3004 || error.code == 3005 ||
            error.code == 3006 || error.code == 3008) {
            [weakself.view addFailIndicatorViewWithTitle:@"抱歉，您的地址不在配送范围内" titleColor:[UIColor whiteColor] font:nil];
        } else {
            [weakself processRequestError:error];
        }
    } completed:^{
    }];
    
}

- (void)getWeekplanlist {
    [MBProgressHUD showActivityWithText:KeyWindow text:@"正在加载..." animated:YES];
    NSDictionary *dic = @{ @"wptid": [NSString stringWithFormat:@"%lu", (unsigned long)self.weekplanID],
                           @"mealtypes": self.arrMealtypes,
                           @"locationx": self.locationx,
                           @"locationy": self.locationy,
                           @"address": self.address };
    
    __weak typeof(self) weakself = self;
    [[self.viewModel getWeekplanlistWithParametres:dic] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        [weakself.view removeFailIndicatorView];
        
        weakself.currentMod = weakself.viewModel.currentMod;
        weakself.numberOfPages = weakself.viewModel.dataArray.count;
        weakself.marrWPList = weakself.viewModel.dataArray;
        weakself.marrItemViews = [NSMutableArray arrayWithCapacity:weakself.numberOfPages];
        [weakself setupOrderButtonWithChangeBarButton:self.viewModel.hasMore];
        [weakself initScrollViewWithRefreshable:self.viewModel.hasMore];
        
    } error:^(NSError *error) {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        if (error.code == 3004 || error.code == 3005 ||
            error.code == 3006 || error.code == 3008) {
            [weakself.view addFailIndicatorViewWithTitle:@"抱歉，您的地址不在配送范围内" titleColor:[UIColor whiteColor] font:nil];
        } else {
            [weakself processRequestError:error];
        }
    } completed:^{
    }];
}

- (void)changeWeekplanlistWithFromBarButton:(BOOL)fromBar {
    __weak typeof(self) weakSelf = self;
    if (self.changeTask) {
        [self.changeTask cancel];
    }
    
    _isSwitching = YES;
    self.changeIndex += 1; // 每次+1
    NSDictionary *dic = @{ @"key": self.viewModel.changeKey,
                           @"index": [NSNumber numberWithInteger:self.changeIndex] };
    
    if (fromBar) {
        [MBProgressHUD showActivityWithText:self.view text:@"正在换口味..." animated:YES];
    }
    
    [[self.viewModel changeWeekplanWithParametres:dic] subscribeNext:^(id x) {
        weakSelf.currentMod = weakSelf.viewModel.currentMod;
        weakSelf.numberOfPages = weakSelf.viewModel.dataArray.count;
        weakSelf.marrWPList = weakSelf.viewModel.dataArray;
        weakSelf.marrItemViews = [NSMutableArray arrayWithCapacity:weakSelf.numberOfPages];
        
        [weakSelf doneLoadingTableViewData];
        [weakSelf.scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        weakSelf.scrollView.pagingEnabled = YES;
        
        for (UIView *subview in weakSelf.scrollView.subviews) {
            [subview removeFromSuperview];
        }
        
        if (weakSelf.viewModel.hasMore == NO) {
            [weakSelf.refreshHeaderView setState:EGOOPullRefreshNoMore];
            weakSelf.refreshHeaderView.noMore = YES;
        }
        
        [weakSelf initScrollViewWithRefreshable:weakSelf.viewModel.hasMore];
        _isSwitching = NO;
    } error:^(NSError *error) {
        _isSwitching = NO;
        [weakSelf processRequestError:error];
    } completed:^{
        if (fromBar) {
            [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        }
    }];
    
}


#pragma mark - LoginDelegate
- (void)loginCompleted {
    NRPlaceOrderViewController *placeOrderVC = [[NRPlaceOrderViewController alloc] init];
    placeOrderVC.wptID = self.weekplanID;
    placeOrderVC.currentMod = self.currentMod;
    placeOrderVC.unitPrice = self.pricePerDay;
    placeOrderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:placeOrderVC animated:YES];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_refreshHeaderView) {
         [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
   
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page < 0 || page >= self.numberOfPages) {
        return;
    }
}

// 滑动减速时调用该方法。
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    // 该方法在scrollViewDidEndDragging方法之后。
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page != self.currentPage) {
        //预加载当前显示页的前后
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
    
    self.currentPage = page;
    
//    self.currentMod = [self.marrWPList objectAtIndex:page];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewWillBeginScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // cancel collect
        [self cancelCollect];
    }
}

#pragma mark  - WeekPlanListDelegate
- (void)showSetMealDetail {
    NRWeekPlanListItemView *theView = [self.marrItemViews objectAtIndex:self.currentPage];
    
    NRWeekPlanListItemView *detailView = [[NRWeekPlanListItemView alloc] initWithFrame:theView.frame type:ListItemTypeDetail mod:theView.model];
    detailView.weekplanlistDelegate = self;
    detailView.tag = self.currentPage;
    [self.scrollView addSubview:detailView];
}

- (void)hideSetMealDetail {
    NRWeekPlanListItemView *detailView = (NRWeekPlanListItemView *)[self.scrollView viewWithTag:self.currentPage];
    if (detailView) {
        [detailView removeFromSuperview];
    }
}

- (void)setBgImage:(UIImage *)image {
    self.maskView.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    @try {
        [self.bgImgView setImageToBlur:image blurRadius:10 completionBlock:nil];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource {
    // should be calling your tableviews data source model to reload
    // put here just for demo
    [MobClick event:NREvent_Click_WPList_Change];
    
    _reloading = YES;
    [self changeWeekplanlistWithFromBarButton:NO];
}

- (void)doneLoadingTableViewData  {
    //model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _reloading; //should return if data source model is reloading
}

- (void)hideHeaderView {
    self.refreshHeaderView.hidden = YES;
}

- (void)showHeaderView {
    self.refreshHeaderView.hidden = NO;
}


#pragma mark - Property
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        CGFloat height = self.view.frame.size.height-20-10;
        _scrollView.frame = CGRectMake(15, 20, self.view.bounds.size.width-30, height);
        _scrollView.pagingEnabled = YES;
        _scrollView.clipsToBounds = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = YES;
        _scrollView.delegate = self;
    }
    
    return _scrollView;
}

- (void)setCurrentMod:(NRWeekPlanListItemModel *)currentMod {
    _currentMod = currentMod;
    if (_currentMod.hasCollected) {
        [_collectButton setSelected:YES];
    }
    else {
        [_collectButton setSelected:NO];
    }
}

- (NRWeekPlanListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NRWeekPlanListViewModel alloc] initWithWptId:self.weekplanID];
    }
    
    return _viewModel;
}

#pragma mark - override
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
