//
//  NRWriteAddressViewController.m
//  Nourish
//  填写收获地址，从高德地图中选择
//  Created by tcguo on 15/9/12.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWriteAddressViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapSearchKit/AMapSearchObj.h>

#import "NRAddrAutoLocationCell.h"

@interface NRWriteAddressViewController ()<MAMapViewDelegate, AMapSearchDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
{
    MAMapView *_mapView;
    AMapSearchAPI *_search;
    AMapSearchAPI *_searchManual;
    CLLocationCoordinate2D _currentCoordinate;
    UIActivityIndicatorView *_activityView;
}

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIImageView *locationImgView;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *poisList;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) AMapPlaceSearchRequest *poiRequest;
@property (nonatomic, strong) AMapPlaceSearchRequest *poiRequestKeyword;
@property (nonatomic, strong) NSArray *searchResultList;
@property (nonatomic, strong) NSMutableArray *cityCodes;

@end


@implementation NRWriteAddressViewController

@synthesize searchDisplayController;

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.title = @"填写收货地址";
    _searchResultList = [NSArray array];
    _cityCodes = [NSMutableArray array];
    
    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, 550/2+NAV_BAR_HEIGHT);
    _mapView = [[MAMapView alloc] initWithFrame:rect];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    _mapView.showsScale = NO;
    _mapView.showsCompass = YES;
    [_mapView setZoomLevel:16.1 animated:YES];
    
    int padding = 5;
    CGFloat x = _mapView.bounds.size.width - padding -_mapView.logoSize.width+ _mapView.logoSize.width/2;
    CGFloat y = _mapView.bounds.size.height - padding - _mapView.logoSize.height + _mapView.logoSize.height/2;
    _mapView.logoCenter = CGPointMake(x, y);
   [self.view addSubview:_mapView];
    
    CGPoint point = [_mapView convertCoordinate:_mapView.centerCoordinate toPointToView:self.view];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-poi"]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    imageView.bounds = CGRectMake(0, 0, 24, 30);
    imageView.layer.position = CGPointMake(point.x, point.y-NAV_BAR_HEIGHT+33/2);
    self.locationImgView = imageView;
    
    // 定位到当前
    UIButton *currentLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [currentLocationBtn setImage:[UIImage imageNamed:@"takeout_ic_map_location_normal"] forState:UIControlStateNormal];
    [currentLocationBtn setImage:[UIImage imageNamed:@"takeout_ic_map_location_press"] forState:UIControlStateSelected];
    [_mapView addSubview:currentLocationBtn];
    [currentLocationBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(padding);
        make.bottom.equalTo(_mapView.mas_bottom).offset(-padding);
        make.width.equalTo(34);
        make.height.equalTo(34);
    }];
    [currentLocationBtn addTarget:self action:@selector(locationCurrent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 44)];
    [_searchBar setTranslucent:YES];
    _searchBar.placeholder = @"收货地址: 输入写字楼、小区、街道";
    _searchBar.delegate = self;
    [self.view addSubview:self.searchBar];

    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.dataSource = self;
    self.searchDisplayController.searchResultsTableView.delegate = self;
    
    // 初始化检索对象
    _search = [[AMapSearchAPI alloc] initWithSearchKey:kAMapKey Delegate:self];
    _search.language = AMapSearchLanguage_zh_CN;
    _search.delegate = self;
    
    _searchManual = [[AMapSearchAPI alloc] initWithSearchKey:kAMapKey Delegate:self];
    _searchManual.language = AMapSearchLanguage_zh_CN;
    _searchManual.delegate = self;
    
    // 构造AMapPlaceSearchRequest对象，配置关键字搜索参数
//    self.poiRequest.location = [AMapGeoPoint locationWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
//    [_search AMapPlaceSearch:self.poiRequest];

    [self.view addSubview:self.tableView];
    
    // 添加指示器
    CGFloat rectY = self.tableView.frame.origin.y + (self.tableView.frame.size.height - 60)/2;
    CGRect avtivityRect = CGRectMake((self.tableView.bounds.size.width-60)/2, rectY, 60, 60);
    _activityView = [[UIActivityIndicatorView  alloc] initWithFrame:avtivityRect];
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray; // 设置活动指示器的颜色
    _activityView.hidesWhenStopped = YES; // hidesWhenStopped默认为YES，会隐藏活动指示器。要改为NO
    [_activityView startAnimating];
    [self.view addSubview:_activityView];
    self.tableView.userInteractionEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
    
}

#pragma mark - Property
- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat height = self.view.bounds.size.height - NAV_BAR_HEIGHT - 550/2;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 550/2, self.view.bounds.size.width, height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, -5, 0, 10);
    }
    
    return _tableView;
}

- (AMapPlaceSearchRequest *)poiRequest {
    if (!_poiRequest) {
        _poiRequest = [[AMapPlaceSearchRequest alloc] init];
        _poiRequest.searchType = AMapSearchType_PlaceAround;
        // types属性表示限定搜索POI的类别，默认为：餐饮服务、商务住宅、生活服务
        // POI的类型共分为20种大类别，分别为：
        // 汽车服务、汽车销售、汽车维修、摩托车服务、餐饮服务、购物服务、生活服务、体育休闲服务、
        // 医疗保健服务、住宿服务、风景名胜、商务住宅、政府机构及社会团体、科教文化服务、
        // 交通设施服务、金融保险服务、公司企业、道路附属设施、地名地址信息、公共设施
        
//        @"公司企业", @"公司",@"商务写字楼",
//        @"地名地址信息",  @"商务住宅", @"生活服务", @"政府机构及社会团体", @"交通设施服务", @"道路附属设施", @"楼宇", @"餐厅", @"餐饮服务"
        
        _poiRequest.types = @[ @"120100", @"120201", @"120200", @"120202", @"120203", @"120300", @"120301", @"120302",@"120303", @"120304",
                               @"170000", @"170100", @"170200", @"170300",
                               @"190000",
                               @"050000", @"060000", @"070000", @"080000", @"090000",@"100000", @"110000",
                               @"130000", @"140000", @"150000", @"160000", @"180000", @"010000", @"020000",@"030000", @"040000"];
        
//        _poiRequest.city = @[@"beijing"];
        _poiRequest.requireExtension = YES;
        _poiRequest.offset = 10;
        _poiRequest.radius = 500;
        _poiRequest.sortrule = 0;
    }
    
    return _poiRequest;
}

- (AMapPlaceSearchRequest *)poiRequestKeyword {
    if (!_poiRequestKeyword) {
        _poiRequestKeyword = [[AMapPlaceSearchRequest alloc] init];
        _poiRequestKeyword.searchType = AMapSearchType_PlaceKeyword;
//        _poiRequestKeyword.types = @[ @"商务住宅", @"公司企业", @"政府机构及社会团体",@"科教文化服务",
//                                      @"交通设施服务", @"餐饮服务", @"生活服务", @"道路附属设施",
//                                      @"购物服务", @"体育休闲服务",@"医疗保健服务", @"住宿服务", @"风景名胜", @"金融保险服务",
//                                      @"地名地址信息", @"公共设施", @"汽车服务", @"汽车销售", @"汽车维修", @"摩托车服务"];
        
//        _poiRequestKeyword.offset = 50;
        _poiRequestKeyword.requireExtension = YES;
    }
    
    return _poiRequestKeyword;
}

#pragma mark - Private Methods
- (void)locationCurrent:(id)sender {
    [_mapView setCenterCoordinate:_currentCoordinate animated:YES];
}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [_activityView startAnimating];
    _activityView.hidden = NO;
    self.tableView.userInteractionEnabled = NO;
    
    CGPoint point = CGPointMake(self.locationImgView.layer.position.x, self.locationImgView.layer.position.y +33/2);
    CLLocationCoordinate2D corrdinate = [mapView convertPoint:point toCoordinateFromView:self.view];
    _poiRequest.location = [AMapGeoPoint locationWithLatitude:corrdinate.latitude longitude:corrdinate.longitude];
    [_search AMapPlaceSearch:self.poiRequest]; // 发起POI搜索
}

- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView {
    NSLog(@"longitude = %f, latitude= %f",mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude);
    
}

- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView {
     NSLog(@"longitude = %f, latitude= %f",mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude);
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    _currentCoordinate = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (!ARRAYHASVALUE(self.poisList)) {
        self.poiRequest.location = [AMapGeoPoint locationWithLatitude:_currentCoordinate.latitude longitude:_currentCoordinate.longitude];
        [_search AMapPlaceSearch:self.poiRequest]; //发起POI搜索
        [_activityView startAnimating];
        _activityView.hidden = NO;
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MAAnnotationView *view = views[0];
    
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
//        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
//        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
        pre.image = [UIImage imageNamed:@"map-location"];
        pre.showsAccuracyRing  = NO;
//        pre.lineWidth = 0.5;
//        pre.lineDashPattern = @[@6, @3];
//        pre.lineDashPattern = nil;
        
        [_mapView updateUserLocationRepresentation:pre];
        
        view.calloutOffset = CGPointMake(0, 0);
    } 
}


#pragma mark - UISearchBarDelegate
//搜索框中的内容发生改变时 回调（即要搜索的内容改变）
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (_searchBar.text.length != 0) {
        [self startSearchAddressWithKeyword:searchText];
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

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //    NSLog(@"did end");
    searchBar.showsCancelButton = NO;
    [self startSearchAddressWithKeyword:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self startSearchAddressWithKeyword:searchBar.text];
}

//点击搜索框上的 取消按钮时 调用
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"cancle clicked");
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
}

- (void)startSearchAddressWithKeyword:(NSString *)words {
    self.poiRequestKeyword.keywords = _searchBar.text;
    if (!ARRAYHASVALUE(self.cityCodes)) {
        [self.cityCodes addObjectsFromArray:CoverCities];
    }
    self.poiRequestKeyword.city = self.cityCodes;
    [_searchManual AMapPlaceSearch:self.poiRequestKeyword];
}

#pragma mark - AMapSearchDelegate
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response {
    if ([request isEqual:self.poiRequest]) {
        [_activityView stopAnimating];
        self.tableView.userInteractionEnabled = YES;
        
        if(response.pois.count == 0)
            return;
        
        self.poisList = response.pois;
        [self.tableView reloadData];
    }
    else if ([request isEqual:self.poiRequestKeyword]){
        self.searchResultList = response.pois;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
   
    /* 
    //通过AMapPlaceSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %d",response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
    */
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        return self.poisList.count;
    }
    else if ([tableView isEqual:searchDisplayController.searchResultsTableView]) {
        return self.searchResultList.count;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const LocationIdentifier = @"LocationIdentifier";
    static NSString * const LocationManualIdentifier = @"LocationManualIdentifier";
    if ([tableView isEqual:self.tableView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LocationIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LocationIdentifier];
            cell.detailTextLabel.textColor = RgbHex2UIColor(0x88, 0x88, 0X88);
            cell.textLabel.textColor = RgbHex2UIColor(0X33, 0X33, 0X33);
            cell.textLabel.font = SysFont(14);
            cell.detailTextLabel.font = SysFont(12);
        }
        
        AMapPOI *ampPOI = [self.poisList objectAtIndex:indexPath.row];
        NSString *cityCode = ampPOI.citycode;
        if (STRINGHASVALUE(cityCode)) {
            if (![self.cityCodes containsObject:cityCode]) {
                 [self.cityCodes addObject:cityCode];
            }
        }
        
        cell.textLabel.text = ampPOI.name;
        cell.detailTextLabel.text = ampPOI.address;
        cell.imageView.image = [UIImage imageNamed:@"takeout_ic_auto_locate"];
        
        if (indexPath.row == 0) {
            UIImageView *calendarImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"takeout_ic_choose_suggest_address"]];
            calendarImgv.contentMode = UIViewContentModeScaleAspectFit;
            cell.accessoryView = calendarImgv;
        }
        else {
            cell.accessoryView = nil;
        }
        
        return cell;
    }
    
    else if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LocationManualIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LocationManualIdentifier];
            cell.detailTextLabel.textColor = RgbHex2UIColor(0x88, 0x88, 0X88);
            cell.textLabel.textColor = RgbHex2UIColor(0X33, 0X33, 0X33);
            cell.textLabel.font = SysFont(14);
            cell.detailTextLabel.font = SysFont(12);
        }
        
        AMapPOI *ampPOI = [self.searchResultList objectAtIndex:indexPath.row];
        cell.textLabel.text = ampPOI.name;
        cell.detailTextLabel.text = ampPOI.address;
        
        //第一个显示当前位置
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AMapPOI *ampPOI = nil;
    if ([tableView isEqual:self.tableView]) {
        ampPOI = [self.poisList objectAtIndex:indexPath.row];
    }
    
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        ampPOI = [self.searchResultList objectAtIndex:indexPath.row];
    }
    
    self.weakAddAddrVC.editModel.adcode = ampPOI.adcode;
    self.weakAddAddrVC.editModel.poiName = ampPOI.name;
    self.weakAddAddrVC.editModel.poiAddress = ampPOI.address;
    self.weakAddAddrVC.editModel.poiType = ampPOI.type;
    self.weakAddAddrVC.editModel.longitude = ampPOI.location.longitude;
    self.weakAddAddrVC.editModel.latitude = ampPOI.location.latitude;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
