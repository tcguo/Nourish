//
//  NRWeekPlanCommentView.m
//  Nourish
//
//  Created by gtc on 15/1/26.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanCommentView.h"
#import "NRNetworkClient.h"
#import "NRWeekPlanCommentCell.h"
#import "NRWeekPlanListItemModel.h"
#import "UIView+ActivityIndicator.h"
#import "UITableView+BDSBottomPullToRefresh.h"

@interface NRWeekPlanCommentView ()<UITableViewDataSource, UITableViewDelegate, BDSBottomPullToRefreshDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSNumber *lastRefreshTime;
@property (strong, nonatomic) NSMutableArray *marrAllComments;
@property (weak, nonatomic) NSURLSessionDataTask *loadTask;
@property (weak, nonatomic) NSURLSessionDataTask *moreTask;
@end

@implementation NRWeekPlanCommentView

- (id)init {
    self = [super init];
    if (self) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.bottomRefreshDelegate = self;
        [self addSubview:_tableView];
        [_tableView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(0);
            make.bottom.equalTo(0);
            make.left.equalTo(0);
            make.right.equalTo(0);
        }];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        [self setupRefresh];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
  
        _lastRefreshTime = [NSNumber numberWithLong:0];
        _marrAllComments = [NSMutableArray arrayWithCapacity:20];
    }
    
    return self;
}

- (void)setupRefresh {
    //1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    WeakSelf(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updateComments];
    }];
//    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
//        [weakSelf getMoreComments];
//    }];
//    self.tableView.mj_footer.automaticallyHidden = YES;
}

- (void)updateData {
    [self.tableView.mj_header beginRefreshing];
}

- (void)updateComments {
    NSDictionary *dic = @{ @"lastTime": [NSNumber numberWithInteger:0],
                           @"setmealid": [NSNumber numberWithUnsignedInteger:self.setmealID] };
    
    __weak typeof(self) weakself = self;
    if (self.loadTask) {
        [self.loadTask cancel];
    }
    
    self.loadTask = [[NRNetworkClient sharedClient] sendPost:@"setmeal/comment/more" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [weakself.tableView.mj_header endRefreshing];
        [weakself removeNoDataLabel];
        
        NSNumber *numLastTime = [res valueForKey:@"lastTime"];
        weakself.lastRefreshTime = numLastTime;
        NSArray *arrComments = [res valueForKey:@"comments"];
        if (ARRAYHASVALUE(arrComments)) {
            [weakself.marrAllComments removeAllObjects];
            for (NSDictionary *dicComments in arrComments) {
                
                NRComment *model = [[NRComment alloc] init];
                NSNumber *userID = [dicComments valueForKey:@"userid"];
                model.userid = [userID integerValue];
                model.nickname = [dicComments valueForKey:@"nickname"];
                model.comment = [dicComments valueForKey:@"content"];
                model.avatarsurl = [dicComments valueForKey:@"avatarUrl"];
                model.datetime = [dicComments valueForKey:@"time"];
                
                [weakself.marrAllComments addObject:model];
            }
            
            [weakself.tableView reloadData];
            if ([weakself.lastRefreshTime integerValue] == 0) {
                [weakself.tableView finishBottomRefresh];
            } else {
                [weakself.tableView resetBottomRefresh];
            }
            
//            [weakself.tableView.mj_footer endRefreshing];
//            if ([weakself.lastRefreshTime integerValue] == 0) {
//                [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
//            } else {
//                [weakself.tableView.mj_footer endRefreshing];
//            }
        }
        else {
            [weakself.tableView addNoDataLabelWithTitle:Tips_LOAD_NO_DATA];
            [weakself.tableView.nodataLabel makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.tableView);
                make.height.equalTo(20);
                make.width.equalTo(80);
            }];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.tableView.mj_header endRefreshing];
        if (error.code == NRRequestErrorNetworkDisAvailablity) {
            [MBProgressHUD showErrormsgWithoutIcon:weakself title:Tips_NoNetwork detail:nil];
        } else if (error.code == NRRequestErrorParseJsonError) {
             [MBProgressHUD showErrormsgWithoutIcon:weakself title:Tips_ServiceException detail:nil];
        } else {
            NSString *errorMsg = [error.userInfo valueForKey:kErrorMsg];
            [MBProgressHUD showErrormsgWithoutIcon:weakself title:errorMsg detail:nil];
        }
    }];
}

- (void)getMoreComments {
    if ([self.lastRefreshTime integerValue] == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSDictionary *dic = @{ @"lastTime": self.lastRefreshTime,
                           @"setmealid": [NSNumber numberWithUnsignedInteger:self.setmealID] };
    if (self.moreTask) {
        [self.moreTask cancel];
    }
    
    self.moreTask =[[NRNetworkClient sharedClient] sendPost:@"setmeal/comment/more" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        NSNumber *numLastTime = [res valueForKey:@"lastTime"];
        weakSelf.lastRefreshTime = numLastTime;
        NSArray *arrComments = [res valueForKey:@"comments"];
        if (ARRAYHASVALUE(arrComments)) {
            for (NSDictionary *dicComments in arrComments) {
                NRComment *model = [[NRComment alloc] init];
                NSNumber *userID = [dicComments valueForKey:@"userid"];
                model.userid = [userID integerValue];
                model.nickname = [dicComments valueForKey:@"nickname"];
                model.comment = [dicComments valueForKey:@"content"];
                model.avatarsurl = [dicComments valueForKey:@"avatarUrl"];
                model.datetime = [dicComments valueForKey:@"time"];
                
                [weakSelf.marrAllComments addObject:model];
            }
            [weakSelf.tableView reloadData];
        }
        
        if ([weakSelf.lastRefreshTime integerValue] == 0) {
            [weakSelf.tableView finishBottomRefresh];
        } else {
            [weakSelf.tableView resetBottomRefresh];
        }
        
//        if ([weakSelf.lastRefreshTime integerValue] == 0) {
//            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
//        } else {
//            [weakSelf.tableView.mj_footer endRefreshing];
//        }
        
       
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView resetBottomRefresh];
        if (error.code == NRRequestErrorNetworkDisAvailablity) {
            [MBProgressHUD showTips:weakSelf text:Tips_NoNetwork];
        } else {
            NSString *errorMsg = [error.userInfo valueForKey:kErrorMsg];
            [MBProgressHUD showTips:weakSelf text:errorMsg];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_tableView) {
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        }
        
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
        }
    }
}

#pragma mark -  BDSBottomPullToRefreshDelegate
- (void)onStartBottomPullToRefresh:(UITableView *)tableView {
    [self getMoreComments];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
}

#pragma mark - UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.marrAllComments.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier = @"Cell";
    
    NRWeekPlanCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    
    if (cell == nil) {
        cell = [[NRWeekPlanCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellWithIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(10, 0, 0, 10);
    NRComment *model = [self.marrAllComments objectAtIndex:indexPath.row];
    
//    model.nickname = @"snowgirl";
//    model.comment = @"棒极了棒极了棒极了棒极了棒极了棒极了";
    
    cell.commentMod = model;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.bounds.size.height;
}

@end
