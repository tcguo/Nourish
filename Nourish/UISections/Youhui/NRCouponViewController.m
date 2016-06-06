//
//  NRCouponViewController.m
//  Nourish
//
//  Created by tcguo on 15/9/18.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRCouponViewController.h"
#import "NRCouponCell.h"
#import "UIView+ActivityIndicator.h"

@interface NRCouponViewController ()

@property (nonatomic, strong) NSMutableArray *couponModelsArray;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, weak) NSURLSessionDataTask *updateTask;
@property (nonatomic, weak) NSURLSessionDataTask *moreTask;

@end

@implementation NRCouponViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view from its nib.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = ColorViewBg;
    
    switch (self.fromWhere) {
        case CouponFromOrder:
            self.title = @"选择优惠券";
            break;
        case CouponFromMyExpired:
            self.title = @"过期券";
            break;
        case CouponFromMyAvailable:
        {
            [self setupRightNavButtonWithTitle:@"过期券" action:@selector(gotoExpiredCoupon)];
            self.title = @"优惠券";
        }
            break;
        default:
            break;
    }
    
    [self setupRefreshControls];
    self.couponModelsArray = [NSMutableArray array];
    [self requestCouponData];
}

- (void)setupRefreshControls {
    __weak typeof(self) weakself = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself requestCouponData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakself loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
}

#pragma mark - Private Methods
- (void)requestCouponData {
    self.state = 1; //可用优惠券
    switch (self.fromWhere) {
        case CouponFromMyAvailable:
            self.wptID = 0;
            self.state = 1;
            break;
        case CouponFromMyExpired:
            self.wptID = 0;
            self.state = 0;//已使用+已过期
            break;
        case CouponFromOrder:
            self.state = 1; 
            break;
        default:
            break;
    }
    
    self.pageIndex = 0;
    NSDictionary *userInfo = @{ @"wptId": @(self.wptID),
                                @"usable": @(self.state),
                                @"pageIndex": @(self.pageIndex) };
    
    __weak typeof(self) weakself = self;
    if (self.updateTask) {
        [self.updateTask cancel];
    }
    
    self.updateTask = [[NRNetworkClient sharedClient] sendPost:@"coupon/list" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [weakself.tableView.mj_header endRefreshing];
        NSNumber *numPageIndex = [res valueForKey:@"nextPageIndex"];
        weakself.pageIndex = [numPageIndex integerValue];
        NSArray *list = [res valueForKey:@"list"];
        [weakself.couponModelsArray removeAllObjects];
        [weakself.tableView reloadData];
        if (!ARRAYHASVALUE(list)) {
            [weakself.tableView addFailIndicatorViewWithTitle:Tips_LOAD_NO_DATA];
            return;
        }
        
        [weakself.tableView removeFailIndicatorView];
        for (NSDictionary *dic in list) {
            NRCouponInfoModel *mod = [[NRCouponInfoModel alloc] init];
            NSNumber *idNum = [dic valueForKey:@"id"];
            mod.couponID = [idNum integerValue];
            NSNumber *typeNum = [dic valueForKey:@"type"];
            mod.type = [typeNum integerValue];
            mod.name = [dic valueForKey:@"name"];
            mod.tips = [dic valueForKey:@"description"];
            mod.expiredDate = [dic valueForKey:@"endTime"];
            mod.amount = [dic valueForKey:@"amount"];
            mod.rate = [dic valueForKey:@"rate"];
            mod.wptName = [dic valueForKey:@"wptName"];
            NSNumber *wptID = [dic valueForKey:@"wptId"];
            mod.wptID = [wptID integerValue];
            NSNumber *usable = [dic valueForKey:@"usable"];
            mod.state = [usable integerValue];
            mod.minConsumption = [dic valueForKey:@"minConsumption"];
            
            [weakself.couponModelsArray addObject:mod];
        }
        
        [weakself.tableView reloadData];
        if (weakself.pageIndex < 0) {
            [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakself.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself.tableView.mj_header endRefreshing];
        [weakself processRequestError:error];
    }];
}

- (void)loadMoreData {
    NSDictionary *userInfo = @{ @"wptId": @(self.wptID),
                                @"usable": @(self.state),
                                @"createTime": @(self.pageIndex) };
    
    __weak typeof(self) weakself = self;
    if (self.moreTask) {
        [self.moreTask cancel];
    }
    self.moreTask = [[NRNetworkClient sharedClient] sendPost:@"coupon/list" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
    
        NSNumber *numPageIndex = [res valueForKey:@"nextPageIndex"];
        weakself.pageIndex = [numPageIndex integerValue];
        NSArray *list = [res valueForKey:@"list"];
        
        for (NSDictionary *dic in list) {
            NRCouponInfoModel *mod = [[NRCouponInfoModel alloc] init];
            NSNumber *idNum = [dic valueForKey:@"id"];
            mod.couponID = [idNum integerValue];
            NSNumber *typeNum = [dic valueForKey:@"type"];
            mod.type = [typeNum integerValue];
            mod.name = [dic valueForKey:@"name"];
            mod.tips = [dic valueForKey:@"description"];
            mod.expiredDate = [dic valueForKey:@"endTime"];
            mod.amount = [dic valueForKey:@"amount"];
            mod.rate = [dic valueForKey:@"rate"];
            mod.wptName = [dic valueForKey:@"wptName"];
            NSNumber *wptID = [dic valueForKey:@"wptId"];
            mod.wptID = [wptID integerValue];
            NSNumber *usable = [dic valueForKey:@"usable"];
            mod.state = [usable integerValue];
            mod.minConsumption = [dic valueForKey:@"minConsumption"];
            
            [weakself.couponModelsArray addObject:mod];
        }
        
        [weakself.tableView reloadData];
        if (weakself.pageIndex < 0) {
            [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakself.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself.tableView.mj_footer endRefreshing];
        [weakself processRequestError:error];
    }];
}

- (void)gotoExpiredCoupon {
    NRCouponViewController *couponVC = [[NRCouponViewController alloc] init];
    couponVC.fromWhere = CouponFromMyExpired;
    [self.navigationController pushViewController:couponVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.couponModelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CouponIdentifier = @"CouponIdentifier";
    NRCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:CouponIdentifier];
    
    if (!cell) {
        cell = [[NRCouponCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CouponIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.model = [self.couponModelsArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fromWhere == CouponFromMyAvailable || self.fromWhere == CouponFromMyExpired) {
        //我的优惠券页面进来不可选
        return;
    }
    
    if (self.selectCouponCmd) {
        NRCouponInfoModel *model = [self.couponModelsArray objectAtIndex:indexPath.row];
        [self.selectCouponCmd execute:model];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

#pragma mark -  BDSBottomPullToRefreshDelegate
- (void)onStartBottomPullToRefresh:(UITableView *)tableView {
    
}

#pragma mark - Override
- (void)back:(id)sender{
    if (self.selectCouponCmd) {
        [self.selectCouponCmd execute:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
