//
//  NRMessageViewController.m
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRMessageViewController.h"
#import "NRSystemMessageModel.h"
#import "NRSystemMessageCell.h"
#import "NRMessageDetailViewController.h"
#import "UITableView+BDSBottomPullToRefresh.h"
#import "NRMessageViewModel.h"
#import "UIView+ActivityIndicator.h"

@interface NRMessageViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NRMessageViewModel *viewModel;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation NRMessageViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.title = @"诺食消息";
    self.view.backgroundColor = ColorViewBg;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self setupRefreshControls];
    
    _dataArray = [NSMutableArray  arrayWithCapacity:20];
    
    //TEST:
//    NRSystemMessageModel *model = [NRSystemMessageModel new];
//    model.strDateTime = @"2015-07-30";
//    model.title = @"你的周计划明天开始就要执行啦";
//    
//    NRSystemMessageModel *model1 = [NRSystemMessageModel new];
//    model1.strDateTime = @"2015-07-30";
//    model1.title = @"喜大普奔，多个商家入驻诺食计平台";
//    
//    NRSystemMessageModel *model2 = [NRSystemMessageModel new];
//    model2.strDateTime = @"2015-07-31";
//    model2.title = @"您的退款申请已处理";
}

- (void)setupRefreshControls {
    WeakSelf(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updateData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - Action
- (void)updateData {
    WeakSelf(self);
    NSDictionary *params = @{@"pageIndex": @(0)};
    [[self.viewModel loadMessageWithParametres:params] subscribeNext:^(id arr) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.tableView reloadData];
        if (!ARRAYHASVALUE(arr)) {
            [weakSelf.tableView addFailIndicatorViewWithTitle:Tips_LOAD_NO_DATA];
            return;
        }
        
        [weakSelf.tableView removeFailIndicatorView];
        [weakSelf.dataArray addObjectsFromArray:arr];
        [weakSelf.tableView reloadData];
        
        if (weakSelf.pageIndex < 0) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } error:^(NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf processRequestError:error];
    } completed:^{
        
    }];
}

- (void)loadMoreData {
    WeakSelf(self);
    NSDictionary *params = @{@"pageIndex": @(0)};
    [[self.viewModel loadMessageWithParametres:params] subscribeNext:^(id arr) {
        [weakSelf.dataArray addObjectsFromArray:arr];
        [weakSelf.tableView reloadData];
        
        if (weakSelf.viewModel.nextPageIndex < 0) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } error:^(NSError *error) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NRSystemMessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *systemMsgCellIdentifier = @"SystemMsgCellIdentifier";
    
    NRSystemMessageCell  *msgcell = [tableView dequeueReusableCellWithIdentifier:systemMsgCellIdentifier];
    if (msgcell == nil) {
        msgcell = [[NRSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:systemMsgCellIdentifier];
        msgcell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    msgcell.model = (NRSystemMessageModel *)[self.dataArray objectAtIndex:indexPath.row];
    
    return msgcell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NRSystemMessageModel *model = [self.dataArray objectAtIndex:indexPath.row];
    NRMessageDetailViewController *detailVC = [[NRMessageDetailViewController alloc] init];
    detailVC.linkUrl = model.linkUrl;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 131+40;
}

#pragma mark - BDSBottomPullToRefreshDelegate
//- (void)onStartBottomPullToRefresh:(UITableView *)tableView {
//    [self loadMoreData];
//}

#pragma mark - Property
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollsToTop = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (NRMessageViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NRMessageViewModel alloc] init];
    }
    return _viewModel;
}

@end
