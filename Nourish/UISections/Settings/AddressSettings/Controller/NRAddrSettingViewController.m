//
//  NRAddressSettingViewController.m
//  Nourish
//
//  Created by gtc on 15/2/12.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddrSettingViewController.h"
#import "UIButton+Additions.h"

#import "NRAddAddressButtonCell.h"
#import "NRAddressListCell.h"
#import "NRDistributionAddrModel.h"
#import "NRAddressViewModel.h"

@interface NRAddrSettingViewController ()

@property (strong, nonatomic) NSMutableArray *marrAddress;
@property (strong, nonatomic) NRAddAddressController *addAddrVC;
@property (strong, nonatomic) NRAddAddressController *editAddrVC;
@property (weak, nonatomic) NSURLSessionDataTask *updateDataTask;
@property (weak, nonatomic) NSURLSessionDataTask *loadMoreTask;
@property (weak, nonatomic) NSURLSessionDataTask *deleteTask;
@property (strong, nonatomic) NRAddressViewModel *viewModel;
@property (assign, nonatomic) NSInteger pageIndex;

@end


@implementation NRAddrSettingViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = @"我的送餐地址";
    self.tableView.backgroundColor = ColorViewBg;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.marrAddress = [[NSMutableArray alloc] init];
    [self setupRefreshControls];
    [self.tableView.mj_header beginRefreshing];
}

- (void)setupRefreshControls {
    __weak typeof(self) weakself = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself loadData];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Action
- (void)loadData {
    WeakSelf(self);
    self.pageIndex = 0;
    NSDictionary *paramDict = @{@"check": [NSNumber numberWithInteger:0],
                                @"all": [NSNumber numberWithInteger:1],
                                @"smwIds": [NSArray array],
                                @"pageIndex": @(self.pageIndex)};
    
    [[self.viewModel queryAddressListWithParameters:paramDict] subscribeNext:^(id x) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.marrAddress removeAllObjects];
        weakSelf.marrAddress = (NSMutableArray *)x;
        [weakSelf.tableView reloadData];
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

- (void)loadMoreData {
    if (self.viewModel.nextPageIndex < 0) {
        [self.tableView finishBottomRefresh];
        return;
    }
    
    WeakSelf(self);
    NSDictionary *paramDict = @{@"check": [NSNumber numberWithInteger:0],
                                @"all": [NSNumber numberWithInteger:1],
                                @"smwIds": [NSArray array],
                                @"pageIndex": @(self.viewModel.nextPageIndex)};
    [[self.viewModel queryAddressListWithParameters:paramDict] subscribeNext:^(id x) {
        NSMutableArray *dataArray = (NSMutableArray *)x;
        [weakSelf.marrAddress addObjectsFromArray:[dataArray copy]];
        [weakSelf.tableView reloadData];
        if (weakSelf.viewModel.nextPageIndex < 0) {
            [weakSelf.tableView finishBottomRefresh];
        }else {
            [weakSelf.tableView resetBottomRefresh];
        }
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

- (void)deleteAddressWithAddr:(NRDistributionAddrModel *)model indexPath:(NSIndexPath *)idxPath {
    if (self.deleteTask) {
        [self.deleteTask cancel];
    }
    __weak typeof(self) weakself = self;
    NSDictionary *params = @{ @"id": @(model.addressID) };
    self.deleteTask = [[NRNetworkClient sharedClient] sendPost:@"user/address/delete" parameters:params success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [weakself.marrAddress removeObject:model];
        [weakself.tableView beginUpdates];
        [weakself.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
        [weakself.tableView endUpdates];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}


#pragma mark - AddAddressDelegate
- (void)addAddressCompleted {
    [self.tableView.mj_header beginRefreshing];
}


//#pragma mark - BDSBottomPullToRefreshDelegate
//- (void)onStartBottomPullToRefresh:(UITableView *)tableView {
//    [self loadMoreData];
//}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return self.marrAddress.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AddressListCellIdentifier = @"AddressListCellIdentifier";
    static NSString *AddAddressCellIdentifier  = @"AddAddressCellIdentifier";
    
    NRAddAddressButtonCell *addCell = nil;
    NRAddressListCell *listCell = nil;
    
    if (indexPath.section == 0) {
        addCell = [tableView dequeueReusableCellWithIdentifier:AddAddressCellIdentifier];
        if (!addCell) {
            addCell = [[NRAddAddressButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddAddressCellIdentifier];
        }
        addCell.titleLabel.text = @"添加一个新地址";
        addCell.iconImageView.image = [UIImage imageNamed:@"settings-address-add"];
        
        return addCell;
    }
    else {
        listCell = [tableView dequeueReusableCellWithIdentifier:AddressListCellIdentifier];
        
        if (!listCell) {
            listCell=[[NRAddressListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AddressListCellIdentifier];
        }
        
        listCell.selectedBackgroundView = nil;
        listCell.selectionStyle = UITableViewCellSelectionStyleNone;
        listCell.accessoryButton.tag = indexPath.row;
        [listCell.accessoryButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        NRDistributionAddrModel *addrModel = [self.marrAddress objectAtIndex:indexPath.row];
        
        listCell.nameLabel.text = addrModel.name;
        listCell.phoneLabel.text = addrModel.phone;
        NSString *detailAddr = addrModel.wholeAddress;
        listCell.addressLabel.text = detailAddr;

        return listCell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NRDistributionAddrModel *addrModel = [self.marrAddress objectAtIndex:indexPath.row];
    [self deleteAddressWithAddr:addrModel indexPath:indexPath];
}

- (void)checkButtonTapped:(id)sender {
    self.editAddrVC = [[NRAddAddressController alloc] initWithStyle:UITableViewStyleGrouped operateType:AddrOperateTypeEdit];
    self.editAddrVC.delegate = self;
    self.editAddrVC.editModel = [self.marrAddress objectAtIndex:((UIButton *)sender).tag];
    [self.navigationController pushViewController:self.editAddrVC animated:YES];
}


#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 40;
    }
    
    return 83;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    
    return 7.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 7.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.marrAddress.count >= 20) {
            [MBProgressHUD showAlert:nil msg:@"收货地址不能超过20个" delegate:nil cancelBtnTitle:@"确定"];
            return;
        }
        
        self.addAddrVC = [[NRAddAddressController alloc] initWithStyle:UITableViewStyleGrouped];
        self.addAddrVC.delegate = self;
        [self.navigationController pushViewController:self.addAddrVC animated:YES];
    }
    else {
//        NRAddressListCell *currentCell = (NRAddressListCell *)[tableView cellForRowAtIndexPath:indexPath];
//        if (self.selectEnabled) {
//            self.selectedIndexPath = indexPath;
//            [currentCell setSelected:YES];
//            self.placeOrderVC.addressString = currentCell.addressLabel.text;
//            self.placeOrderVC.nameString = currentCell.nameLabel.text;
//            self.placeOrderVC.phoneString = currentCell.phoneLabel.text;
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else {
//            self.selectedIndexPath = nil;
//            [currentCell setSelected:NO];
//        }

    }
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section != 0) {
//        NRAddressListCell *currentCell = (NRAddressListCell *)[tableView cellForRowAtIndexPath:indexPath];
//        [currentCell setSelected:NO];
//    }
//}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"taped");
}


#pragma mark - Property
- (NRAddressViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NRAddressViewModel alloc] init];
    }
    
    return _viewModel;
}


#pragma mark - Override
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
