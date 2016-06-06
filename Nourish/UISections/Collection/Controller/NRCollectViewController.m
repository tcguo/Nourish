//
//  NRCollectViewController.m
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRCollectViewController.h"
#import "NRMainTableViewController.h"
#import "MMDrawerController.h"
#import "NRMyCollectCell.h"
#import "UIView+ActivityIndicator.h"
#import "NRWeekPlanListViewController.h"

@interface NRCollectViewController ()

@property (nonatomic, assign) CGRect startingPanRect;
@property (nonatomic, assign) CGFloat maximumLeftDrawerWidth;
@property (nonatomic, assign) CGFloat maximumRightDrawerWidth;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, weak) NSURLSessionDataTask *updateDataTask;
@property (nonatomic, weak) NSURLSessionDataTask *loadMoreDataTask;

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation NRCollectViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = @"我的收藏";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = ColorViewBg;
    self.modelArray = [NSMutableArray array];
    [self setupRefreshControl];
    [self updateData];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)setupRefreshControl {
    WeakSelf(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updateData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
}


#pragma mark - Private Methods
- (void)updateData {
    if (self.updateDataTask) {
        [self.updateDataTask cancel];
    }
    
    __weak typeof(self) weakSelf = self;
    self.pageIndex = 0; // 第一页给0
    NSDictionary *paramDic = @{ @"pageIndex": @(self.pageIndex) };
   
    self.updateDataTask = [[NRNetworkClient sharedClient] sendPost:@"weekplan/collection/show" parameters:paramDic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.modelArray removeAllObjects];
        [weakSelf.tableView reloadData];
        
        NSNumber *numPageIndex = [res valueForKey:@"nextPageIndex"];
        weakSelf.pageIndex = [numPageIndex integerValue];
        NSArray *listArr = [res valueForKey:@"list"];
        if (!ARRAYHASVALUE(listArr)) {
            [weakSelf.tableView addFailIndicatorViewWithTitle:Tips_LOAD_NO_DATA];
            return;
        }
        
        [weakSelf.tableView removeFailIndicatorView];
        for (NSDictionary *dic in listArr) {
            NRCollectWeekPlanInfo *model = [[NRCollectWeekPlanInfo alloc] init];
            model.collectID = [[dic valueForKey:@"id"] integerValue];
            model.wpName = [dic valueForKey:@"wpName"];
            model.wptName = [dic valueForKey:@"wptName"];
            model.wpImage = [dic valueForKey:@"wpImage"];
            model.smwIds = [dic valueForKey:@"smwIds"];
            model.price = [dic valueForKey:@"price"];
            model.wptId = [[dic valueForKey:@"wptId"] integerValue];
            [weakSelf.modelArray addObject:model];
        }
        
        [weakSelf.tableView reloadData];
        if (weakSelf.pageIndex < 0) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf processRequestError:error];
    }];
}

- (void)loadMoreData {
    if (self.loadMoreDataTask) {
        [self.loadMoreDataTask cancel];
    }
    
    NSDictionary *paramDic = @{ @"pageIndex": @(self.pageIndex) };
    __weak typeof(self) weakSelf = self;
    self.loadMoreDataTask = [[NRNetworkClient sharedClient] sendPost:@"weekplan/collection/show" parameters:paramDic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        NSNumber *numPageIndex = [res valueForKey:@"nextPageIndex"];
        weakSelf.pageIndex = [numPageIndex integerValue];
        NSArray *listArr = [res valueForKey:@"list"];
        
        for (NSDictionary *dic in listArr) {
            NRCollectWeekPlanInfo *model = [[NRCollectWeekPlanInfo alloc] init];
            model.collectID = [[dic valueForKey:@"id"] integerValue];
            model.wpName = [dic valueForKey:@"wpName"];
            model.wptName = [dic valueForKey:@"wptName"];
            model.wpImage = [dic valueForKey:@"wpImage"];
            model.smwIds = [dic valueForKey:@"smwIds"];
            model.price = [dic valueForKey:@"price"];
            [weakSelf.modelArray addObject:model];
        }
        
        [weakSelf.tableView reloadData];
        
        if (weakSelf.pageIndex < 0) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf processRequestError:error];
    }];
}

- (void)handleSwipeGesture:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)leftDrawerButtonPress:(id)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - UITableViewDataSource
- (NRMyCollectCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CollectIdentifier = @"CollectIdentifier";
    NRMyCollectCell *cell = [tableView dequeueReusableCellWithIdentifier:CollectIdentifier];
    if (!cell) {
        cell = [[NRMyCollectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.model = [self.modelArray objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (440+126)/2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NRCollectWeekPlanInfo *model = [self.modelArray objectAtIndex:indexPath.row];
    NRWeekPlanListViewController *weekplanVC = [[NRWeekPlanListViewController alloc] initWithFromCollect:YES];
    weekplanVC.weekplanID = model.wptId;
    weekplanVC.pricePerDay = [model.price integerValue];
    [weekplanVC getWeekplanlistWithSmwIds:model.smwIds];
    
    [self.navigationController pushViewController:weekplanVC animated:YES];
}

#pragma mark - BDSBottomPullToRefreshDelegate
//- (void)onStartBottomPullToRefresh:(UITableView *)tableView {
//    [self loadMoreData];
//}

#pragma mark - Override

- (void)back:(id)sender {
    if (self.navigationController.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [self.updateDataTask cancel];
    [self.loadMoreDataTask cancel];
}

@end


@implementation NRCollectWeekPlanInfo


@end