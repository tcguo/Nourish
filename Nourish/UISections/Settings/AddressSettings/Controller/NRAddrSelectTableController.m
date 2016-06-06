//
//  NRAddrSelectTableController.m
//  Nourish
//
//  Created by gtc on 15/3/25.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddrSelectTableController.h"
#import "NRAddrSettingViewController.h"
#import "UIButton+Additions.h"
#import "NRAddAddressController.h"
#import "NRAddAddressButtonCell.h"
#import "NRAddressListCell.h"
#import "NRAddressViewModel.h"

@interface NRAddrSelectTableController ()<AddAddressDelegate>

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NRAddAddressController *addAddrVC;
@property (nonatomic, strong) NRAddAddressController *editAddrVC;
@property (nonatomic, strong, readwrite) NSMutableArray *marrAddrList;//地址列表
@property (nonatomic, strong) NRAddressViewModel *viewModel;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation NRAddrSelectTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = @"选择送餐地址";
    
    self.tableView.backgroundColor = ColorViewBg;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
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

- (void)loadData {
    __weak typeof(self) weakself = self;
    self.pageIndex = 0;
    NSDictionary *paramDict = @{@"check": [NSNumber numberWithInteger:1],
                                @"all": [NSNumber numberWithInteger:1],
                                @"smwIds":self.placeOrderVC.currentMod.arrWPSID,
                                @"pageIndex": @(self.pageIndex)};
    
    [[self.viewModel queryAddressListWithParameters:paramDict] subscribeNext:^(id x) {
        [weakself.marrAddrList removeAllObjects];
        weakself.marrAddrList = (NSMutableArray *)x;
        [weakself.tableView reloadData];
    } error:^(NSError *error) {
        [weakself processRequestError:error];
    } completed:^{
        [weakself.tableView.mj_header endRefreshing];
    }];
}

- (void)loadMoreAddress {
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
        [weakSelf.marrAddrList addObjectsFromArray:[dataArray copy]];
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

#pragma mark - AddAddressDelegate
- (void)addAddressCompleted {
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return self.marrAddrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AddressListCellIdentifier = @"AddressListCellIdentifier";
    static  NSString *AddAddressCellIdentifier = @"AddAddressCellIdentifier";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        NRAddAddressButtonCell *addBtnCell = [tableView dequeueReusableCellWithIdentifier:AddAddressCellIdentifier];
       
        if (!addBtnCell) {
            addBtnCell = [[NRAddAddressButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddAddressCellIdentifier];
        }
        addBtnCell.titleLabel.text = @"添加一个新地址";
        addBtnCell.iconImageView.image = [UIImage imageNamed:@"settings-address-add"];
        cell = addBtnCell;
    }
    else {
        NRAddressListCell *addrCell = [tableView dequeueReusableCellWithIdentifier:AddressListCellIdentifier];
        if (!addrCell) {
            addrCell = [[NRAddressListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AddressListCellIdentifier];
            addrCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        addrCell.accessoryButton.tag = indexPath.row;
        [addrCell.accessoryButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        NRDistributionAddrModel *addrModel = [self.marrAddrList objectAtIndex:indexPath.row];
        addrCell.nameLabel.text = addrModel.name;
        addrCell.phoneLabel.text = addrModel.phone;
        addrCell.addressLabel.text = addrModel.wholeAddress;
        addrCell.available = addrModel.reachable;
        
        cell = addrCell;
    }
    
    return cell;
}

- (void)checkButtonTapped:(id)sender {
    self.editAddrVC = [[NRAddAddressController alloc] initWithStyle:UITableViewStyleGrouped operateType:AddrOperateTypeEdit];
    self.editAddrVC.delegate = self;
    self.editAddrVC.editModel = [self.marrAddrList objectAtIndex:((UIButton *)sender).tag];
    [self.navigationController pushViewController:self.editAddrVC animated:YES];
}


#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.marrAddrList.count >= 20) {
            [MBProgressHUD showAlert:nil msg:@"收货地址不能超过20个" delegate:nil cancelBtnTitle:@"确定"];
            return;
        }
        
        self.addAddrVC = [[NRAddAddressController alloc] init];
        self.addAddrVC.delegate = self;
        [self.navigationController pushViewController:self.addAddrVC animated:YES];
    }
    else {
        NRAddressListCell *currentCell = (NRAddressListCell *)[tableView cellForRowAtIndexPath:indexPath];
        NRDistributionAddrModel *mod = [self.marrAddrList objectAtIndex:indexPath.row];
        if (!mod.reachable) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"该地址不在配送范围内"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles: nil, nil];
            [alertView show];
        }
        else {
            self.selectedModel = mod;
            [currentCell setSelected:YES];
            if (self.placeOrderVC) {
                self.placeOrderVC.viewModel.availableAddrModel = mod;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NRAddressListCell *currentCell = (NRAddressListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [currentCell setSelected:NO];
}

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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"taped");
}

//#pragma mark - BDSBottomPullToRefreshDelegate
//- (void)onStartBottomPullToRefresh:(UITableView *)tableView {
//    [self loadMoreAddress];
//}

#pragma mark - Property
- (NRAddressViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel  = [[NRAddressViewModel alloc] init];
    }
    return _viewModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
