//
//  NRSwitchLocationViewController.m
//  Nourish
//
//  Created by gtc on 15/2/28.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSwitchLocationViewController.h"
#import "BMButton.h"
#import "NRUIHandLocationCell.h"
#import "NRUIHistoryLocationCell.h"
#import "NRDistributionAddrModel.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "NRLoginManager.h"

@interface NRSwitchLocationViewController ()<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, AMapSearchDelegate>
{
    AMapSearchAPI *_search;
    AMapPlaceSearchRequest *_poiRequest;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, strong) NSMutableArray *marrAddress;

@property (nonatomic, weak) NSURLSessionDataTask *addressListTask;

@end


@implementation NRSwitchLocationViewController

@synthesize searchDisplayController;

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"切换位置";
    self.view.backgroundColor = [UIColor whiteColor];
    self.marrAddress = [NSMutableArray array];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 44)];
    _searchBar.delegate = self;
    [_searchBar setTranslucent:NO];
    _searchBar.placeholder = @"输入地址搜索附近周计划";
    
    _search = [[AMapSearchAPI alloc] initWithSearchKey:kAMapKey Delegate:self];
    _search.language = AMapSearchLanguage_zh_CN;
    
    _poiRequest = [[AMapPlaceSearchRequest alloc] init];
    _poiRequest.searchType = AMapSearchType_PlaceKeyword;
    
    _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    _myTableView.backgroundColor = ColorViewBg;
    _myTableView.tableHeaderView = _searchBar;
    
//    self.myTableView.frame = CGRectMake(0, 100, 320, 100);
    [self.view addSubview:self.myTableView];
    
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.dataSource = self;
    self.searchDisplayController.searchResultsTableView.delegate = self;
    
    if ([NRLoginManager sharedInstance].isLogined) {
         [self queryAddress];
    }
}

#pragma mark - Action
/**
 * 定位到当前位置
 */
- (void)handCurrentLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //---弹出请打开定位的提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务未开启" message:@"请在系统设置中开启定位服务\n设置->隐私->定位服务->诺食" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    
    self.weakPlanSelectVC.currentLocationType = NRLocationTypeCurrerentLocation;
    [self.weakPlanSelectVC handCurrentLocation];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)queryAddress {
    [MBProgressHUD showActivityWithText:self.view text:Tips_Loading animated:YES];
    NSDictionary *paramDict = @{@"check": [NSNumber numberWithInteger:0],
                                @"all": [NSNumber numberWithInteger:1],
                                @"smwIds": [NSArray array]};
    
    __weak typeof(self) weakself = self;
    if (self.addressListTask) {
        [self.addressListTask cancel];
    }
    self.addressListTask = [[NRNetworkClient sharedClient] sendPost:@"user/address/list" parameters:paramDict success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        if (errorCode == 0) {
            
            [weakself.marrAddress removeAllObjects];//先移除所有对象
            NSArray *arrAddrs = [res valueForKey:@"addresses"];
            
            for (id obj in arrAddrs) {
                NSInteger addrID = [[obj valueForKey:@"id"] integerValue];
                NSString *name = [obj valueForKey:@"name"];
                NSString *phone = [obj valueForKey:@"phone"];
                NSString *poiName = [obj valueForKey:@"poiName"];
                NSString *poiAddress = [obj valueForKey:@"poiAddress"];
                NSNumber *distance = [obj valueForKey:@"distance"];
                BOOL reachable = [[obj valueForKey:@"reachable"] boolValue];//是否可配送
                NSString *detail = [obj valueForKey:@"detail"];
                
                NRDistributionAddrModel *model = [[NRDistributionAddrModel alloc] init];
                model.addressID = addrID;
                model.name = name;
                model.phone = phone;
                model.poiName = poiName;
                model.poiAddress = poiAddress;
                model.detailAddress = detail;
                model.reachable = reachable;
                model.distance = [distance floatValue];
                model.longitude = [[obj valueForKey:@"x"] doubleValue];
                model.latitude = [[obj valueForKey:@"y"] doubleValue];
                
                [weakself.marrAddress addObject:model];
            }
            
            [_myTableView reloadData];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}


#pragma mark - UISearchBarDelegate
//搜索框中的内容发生改变时 回调（即要搜索的内容改变）
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"changed");
    if (_searchBar.text.length != 0) {
        _poiRequest.keywords = _searchBar.text;
        _poiRequest.city = @[self.cityCode];
        _poiRequest.requireExtension = NO;
        //发起POI搜索
        [_search AMapPlaceSearch:_poiRequest];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    NSLog(@"shuould begin");
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.text = @"";
//    NSLog(@"did begin");
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    NSLog(@"did end");
    searchBar.showsCancelButton = NO;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    NSLog(@"search clicked");
}

//点击搜索框上的 取消按钮时 调用
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"cancle clicked");
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_myTableView]) {
        if (section == 0) {
            return 1;
        }
        
        return self.marrAddress.count;
    }
    else if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return self.pois.count;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellHandLocationID = @"cellHandLocationID";
    static NSString *cellHistoryLocationID = @"cellHistoryLocationID";
    static NSString *cellResultID = @"HISTORYRESULT";
    
    UITableViewCell *cell = nil;
    if ([tableView isEqual:_myTableView]) {
        
        if (indexPath.section == 0) {
            cell = [[NRUIHandLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellHandLocationID];
            
            return cell;
        }
        if (indexPath.section == 1) {
            NRUIHistoryLocationCell *addrcell = [tableView dequeueReusableCellWithIdentifier:cellHistoryLocationID];
            if (!addrcell) {
                addrcell = [[NRUIHistoryLocationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellHistoryLocationID];
            }
            if (self.marrAddress.count > 0) {
                NRDistributionAddrModel *model = [self.marrAddress objectAtIndex:indexPath.row];
                addrcell.nameLabel.text = model.name;
                addrcell.phoneLabel.text = model.phone;
                addrcell.addrLabel.text = model.wholeAddress;
            }
          
            return addrcell;
        }
    }
    else if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellResultID];;
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellResultID];
            cell.detailTextLabel.textColor = RgbHex2UIColor(0x88, 0x88, 0X88);
            cell.textLabel.textColor = RgbHex2UIColor(0X33, 0X33, 0X33);
        }
        
        AMapPOI *amapPOI = (AMapPOI *)[self.pois objectAtIndex:indexPath.row];
        cell.textLabel.text = amapPOI.name;
        cell.detailTextLabel.text = amapPOI.address;
        
        return cell;
    }
    
    return cell;
}

- (NRUIHandLocationCell *)handCellWithIndexPath:(NSIndexPath *)indexPath {
    NRUIHandLocationCell *cell = [[NRUIHandLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_myTableView]) {
        if ([NRLoginManager sharedInstance].isLogined) {
            return 2;
        }
        
        return 1;
    }
    
    return 1;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_myTableView]) {
        if (indexPath.section == 0) {
            return 44;
        }
        if (indexPath.section == 1) {
            return 76;
        }
    }
    else if([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return 60;
    }
    
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        AMapPOI *poi = (AMapPOI *)[self.pois objectAtIndex:indexPath.row];
        self.weakPlanSelectVC.currentLocationType = NRLocationTypeSearchLocation;
        [self.weakPlanSelectVC handLocationWith:poi.location address:poi.name];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([tableView isEqual:_myTableView]) {
        if (indexPath.section == 0) {
            //定位到当前位置
            [self handCurrentLocation];
        }
        else if (indexPath.section == 1) {
            NRDistributionAddrModel *model = [self.marrAddress objectAtIndex:indexPath.row];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(model.latitude, model.longitude);
            self.weakPlanSelectVC.currentLocationType = NRLocationTypeHistoryAddr;
            [self.weakPlanSelectVC handHistoryAddrLocationWith:coord address:model.poiName];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_myTableView]) {
        return 20;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_myTableView] && section == 1) {
            UIView *headerView = [UIView new];
            headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
            headerView.backgroundColor = [UIColor clearColor];
            
            UILabel *titleLabel = [UILabel new];
            titleLabel.font = SysFont(14);
            titleLabel.textColor = ColorBaseFont;
            titleLabel.text = @"历史收货地址";
            [headerView addSubview:titleLabel];
            [titleLabel makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(headerView.centerY);
                make.left.equalTo(10);
                make.height.equalTo(@14);
            }];
            
            return headerView;
    }
    
    return nil;
}

//实现POI搜索对应的回调函数
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response {
    if(response.pois.count == 0) {
        return;
    }
    
    //通过AMapPlaceSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %d", response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    self.pois = response.pois;
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
