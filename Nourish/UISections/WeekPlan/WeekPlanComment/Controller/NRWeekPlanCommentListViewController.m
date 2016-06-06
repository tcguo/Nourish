//
//  NRWeekPlanCommentListViewController.m
//  Nourish
//  周计划评价列表
//  Created by tcguo on 15/11/3.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanCommentListViewController.h"
#import "NRWeekPlanCommentListCell.h"
#import "AMRatingControl.h"
//#import "UITableView+BDSBottomPullToRefresh.h"
#import "NROrderCommentProvider.h"
#import "UIView+ActivityIndicator.h"
#import "UIImageView+WebCache.h"

@interface NRWeekPlanCommentListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIImageView *_weekplanImageView;
    UILabel *_weekplanNameLabel;
    AMRatingControl *_simpleRatingControl;
    UILabel *_levelLabel;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NROrderCommentProvider *provider;

@end

@implementation NRWeekPlanCommentListViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.title = @"周计划评价";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    _dataArray = [NSMutableArray array];
    [self setupRefreshControls];
    [self loadData];
}

- (void)setupRefreshControls {
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
}

- (void)setupHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    view.backgroundColor = RgbHex2UIColor(0xf8, 0xf8, 0xf8);
    self.tableView.tableHeaderView = view;
    self.headerView = view;
    _weekplanImageView = [[UIImageView alloc] init];
    _weekplanImageView.layer.cornerRadius = CornerRadius;
    _weekplanImageView.layer.masksToBounds = YES;
    
    [self.headerView addSubview:_weekplanImageView];
    [_weekplanImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(20);
        make.left.equalTo(15);
        make.width.equalTo(137);
        make.height.equalTo(90);
    }];
    [_weekplanImageView sd_setImageWithURL:[NSURL URLWithString:self.weekplanCoverImageUrl] placeholderImage:[UIImage imageNamed:DefaultImageName] completed:nil];
    
    _weekplanNameLabel = [UILabel new];
    _weekplanNameLabel.textColor = RgbHex2UIColor(0x43, 0x43, 0x34);
    _weekplanNameLabel.font = SysBoldFont(16);
    _weekplanNameLabel.text = self.weekplanName;
    [self.headerView addSubview:_weekplanNameLabel];
    [_weekplanNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weekplanImageView.mas_top).offset(14);
        make.left.equalTo(_weekplanImageView.mas_right).offset(17);
        make.height.equalTo(17);
    }];
    
    _simpleRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(self.headerView.center.x, self.headerView.center.y) emptyImage:[UIImage imageNamed:@"comment-star-normal"] solidImage:[UIImage imageNamed:@"comment-star-selected"] andMaxRating:5];
    _simpleRatingControl.starWidthAndHeight = 20.0f;
    [_simpleRatingControl setRating:5];  // Customize the current rating if needed
    [_simpleRatingControl setStarSpacing:5];
    _simpleRatingControl.userInteractionEnabled = NO;
    
    // Define block to handle events
    _simpleRatingControl.editingChangedBlock = ^(NSUInteger rating) {
        //            [label setText:[NSString stringWithFormat:@"%d", rating]];
    };
    _simpleRatingControl.editingDidEndBlock = ^(NSUInteger rating) {
        //            [endLabel setText:[NSString stringWithFormat:@"%d", rating]];
    };
    
    [self.headerView addSubview:_simpleRatingControl];
    [_simpleRatingControl makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weekplanNameLabel.mas_bottom).offset(10);
        make.left.equalTo(_weekplanNameLabel.mas_left);
        make.height.equalTo(20);
    }];
    
    _levelLabel = [UILabel new];
    _levelLabel.textColor = RgbHex2UIColor(0x9e, 0x9e, 0x9e);
    _levelLabel.font = SysFont(12);
    [self.headerView addSubview:_levelLabel];
    [_levelLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_simpleRatingControl.mas_bottom).offset(8);
        make.left.equalTo(_weekplanImageView.mas_left);
    }];
}

#pragma mark - Action
- (void)loadData {
    //TODO:测试数据
//    self.smwIds = @[@7, @8, @9];
    self.provider.wpCommentPageIndex = 0;
    NSDictionary *userInfo = @{ @"wptId": [NSNumber numberWithUnsignedInteger:self.wptId],
                                @"smwIds": self.smwIds,
                                @"pageIndex": [NSNumber numberWithInteger:self.provider.wpCommentPageIndex]};
    
    __weak typeof(self) weakSelf = self;
    [self.provider requestWeekplanCommentLisWithUserInfo:userInfo completeBlock:^(id reslut, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        if (!error) {
            [weakSelf.tableView removeFailIndicatorView];
            [weakSelf.dataArray removeAllObjects];
            
            if (ARRAYHASVALUE(reslut)) {
                [weakSelf setupHeaderView];
                [weakSelf.dataArray addObjectsFromArray:reslut];
                [weakSelf.tableView reloadData];
                
                if (self.provider.wpCommentPageIndex < 0) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.tableView.mj_footer endRefreshing];
                }
                
            } else {
                weakSelf.tableView.tableHeaderView = nil;
                [weakSelf.tableView addFailIndicatorViewWithTitle:Tips_LOAD_NO_DATA];
            }
        }
        else {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf processRequestError:error];
        }
    }];
}

- (void)loadMoreData {
    WeakSelf(self);
    NSDictionary *userInfo = @{ @"wptId": [NSNumber numberWithUnsignedInteger:self.wptId],
                                @"smwIds": self.smwIds,
                                @"pageIndex": @(self.provider.wpCommentPageIndex) };
    
    [self.provider requestWeekplanCommentLisWithUserInfo:userInfo completeBlock:^(id reslut, NSError *error) {
        if (!error) {
            if (ARRAYHASVALUE(reslut)) {
                [weakSelf.dataArray addObjectsFromArray:reslut];
                [weakSelf.tableView reloadData];
            }
            
            if (weakSelf.provider.wpCommentPageIndex < 0) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        }
        else {
            [weakSelf.tableView.mj_footer endRefreshing];
            [weakSelf processRequestError:error];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NRWeekPlanCommentListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *weekplanCommentListIdentifier = @"weekplanCommentListIdentifier";
    NRWeekPlanCommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:weekplanCommentListIdentifier];
    if (!cell) {
        cell = [[NRWeekPlanCommentListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:weekplanCommentListIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NRWeekPlanCommentListModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.bounds.size.height;
}

#pragma mark - Property
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- NAV_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.scrollsToTop = YES;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    
    return _tableView;
}

- (NROrderCommentProvider *)provider {
    if (!_provider) {
        _provider = [[NROrderCommentProvider alloc] init];
    }
    return _provider;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
