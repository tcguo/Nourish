//
//  NRWeekPlanDetailViewController.m
//  Nourish
//
//  Created by gtc on 15/1/20.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanSelectViewController.h"
#import "UIButton+Additions.h"
#import "BMButton.h"
#import "NRWeekPlanListViewController.h"
#import "BMDeviceInfo.h"
#import "NRNavigationController.h"
#import "NRSwitchLocationViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

//---gaode sdk
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapSearchKit/AMapCommonObj.h>
#import <AMapSearchKit/AMapSearchObj.h>

//
#import "NRUINavigationBar.h"
#import "MozTopAlertView.h"

@interface NRWeekPlanSelectViewController ()<AMapSearchDelegate, CLLocationManagerDelegate>
{
    UILabel *_lblMyoffice;
    UIImageView *_imgViewOffice;
//    UIButton *_btnSetLocation;
    UIImageView *_imgViewLocation;
    
    UIImageView *_imgViewDinner;
    UILabel *_lblDinner;
    UIButton *_btnZao;
    UIButton *_btnWu;
    UIButton *_btnCha;
    
    UIImageView *_imgViewPrice;
    UILabel *_lblPrice;
    UILabel *_locationLabel;
    
    BMButton *_btnOk;
    BOOL _needUpdate;
    UITapGestureRecognizer *_tapGR;
}

@property (strong, nonatomic) NSMutableSet *msetMealtypes;
@property (strong, nonatomic) NSMutableSet *msetPricesDefault;

@property (strong, nonatomic) AMapSearchAPI *amapSearch;
@property (strong, nonatomic) AMapReGeocodeSearchRequest *regeoRequest;
@property (strong, nonatomic) AMapGeoPoint *amapGeoPoint;

@property (copy, nonatomic) NSString *cityCode;//当前所在城市的编码

// Controls
@property (strong, nonatomic) UILabel *displayPriceLabel;
@property (strong, nonatomic) UIView  *locationView;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIImageView *locationImageView;

@property (strong, nonatomic) NSString *mealPrice;

@property (strong, nonatomic) NRWeekPlanListViewController *listVC;

@property (weak, nonatomic) NSURLSessionDataTask *priceTask;
@property (assign, nonatomic) NSUInteger zaoPrice;
@property (assign, nonatomic) NSUInteger wuPrice;
@property (assign, nonatomic) NSUInteger chaPirce;
@property (assign, nonatomic) NSUInteger pricePerDay;

@end

@implementation NRWeekPlanSelectViewController

- (id)init {
    if (self = [super init]) {
        // 初始化检索对象
        _amapSearch = [[AMapSearchAPI alloc] initWithSearchKey:kAMapKey Delegate:self];
        _pricePerDay = DinnerPriceWu;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"选择套餐";
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-bg"]];
    bgImg.frame = self.view.bounds;
    [self.view addSubview:bgImg];
    
    _needUpdate = YES;
    self.msetMealtypes = [NSMutableSet setWithObjects:[NSNumber numberWithInteger:2], nil];
    
    [self setupControls];
    [self loadPrice];
}

- (void)setupControls {
    // 当前位置
    _lblMyoffice = [[UILabel alloc] init];
    [self.view addSubview:_lblMyoffice];
    _lblMyoffice.text = @"当前位置";
    _lblMyoffice.textColor = [UIColor whiteColor];
    _lblMyoffice.font = NRFont(FontLabelSize);
    [_lblMyoffice makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.centerX.equalTo(self.view.centerX);
    }];
    
    // wp-myoffice
    _imgViewOffice = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-location"]];
    [self.view addSubview:_imgViewOffice];
    [_imgViewOffice makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblMyoffice).offset(-5);
        make.right.equalTo(_lblMyoffice.mas_left).offset(-5);
    }];
    
    WeakSelf(self);
    // 位置
    self.locationView = [[UIView alloc] init];
    [self.view addSubview:self.locationView];
    self.locationView.backgroundColor = [UIColor clearColor];
    [self.locationView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblMyoffice.mas_bottom).offset(15);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.height.equalTo(15);
        make.width.equalTo(280);
        make.width.lessThanOrEqualTo(300);
    }];
    
    self.locationLabel = [[UILabel alloc] init];
    _locationLabel.font = SysFont(14);
    _locationLabel.textColor = RgbHex2UIColor(0X2F, 0X3F, 0X4E);
    _locationLabel.textAlignment = NSTextAlignmentLeft;
    _locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.locationView addSubview:self.locationLabel];
    
    self.locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wps-location-jitou"]];
    self.locationImageView.hidden = YES;
    [self.locationView addSubview:self.locationImageView];
    
//    [_locationLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(weakSelf.view.mas_centerX);
//        make.top.equalTo(_lblMyoffice.mas_bottom).offset(15);
//        make.width.equalTo(250);
//    }];
    
    
//    _btnSetLocation = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_btnSetLocation.titleLabel setFont:NRFont(14)];
//    _btnSetLocation.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    _btnSetLocation.titleLabel.numberOfLines = 0;
//    [_btnSetLocation setTitleColor:RgbHex2UIColor(0X2F, 0X3F, 0X4E) forState:UIControlStateNormal];
////    [_btnSetLocation setImage:[UIImage imageNamed:@"wp-location"] forState:UIControlStateNormal];
//    [_btnSetLocation addTarget:self action:@selector(switchLocation:) forControlEvents:UIControlEventTouchUpInside];
//    [_btnSetLocation setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
//    [_btnSetLocation setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//    
//    [self.view addSubview:_btnSetLocation];
//    [_btnSetLocation makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.top.equalTo(_lblMyoffice.mas_bottom).offset(15);
//        make.width.equalTo(200);
//    }];
    
    
//    _imgViewLocation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-direction-down"]];
//    [self.view addSubview:_imgViewLocation];
//    [_imgViewLocation makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(_btnSetLocation.centerY);
//        make.left.equalTo(_btnSetLocation.mas_right).offset(5);
//        make.width.equalTo(15);
//        make.height.equalTo(10);
//    }];
    
    // 套餐类型
    _imgViewDinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-dinnertype"]];
    [self.view addSubview:_imgViewDinner];
    
    _lblDinner = [[UILabel alloc] init];
    _lblDinner.text= @"套餐";
    _lblDinner.textColor = [UIColor whiteColor];
    _lblDinner.font = NRFont(FontLabelSize);
    [self.view addSubview:_lblDinner];
    
    [_lblDinner makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(5);
        make.top.equalTo(_locationLabel.mas_bottom).offset(73);
    }];
    [_imgViewDinner makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblDinner).offset(-5);
        make.right.equalTo(_lblDinner.mas_left).offset(-5);
    }];
    
    int padding = 10;
    _btnZao = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnZao setImage:[UIImage imageNamed:@"dinner-zao"] forState:UIControlStateNormal];
    [_btnZao setTitle:@"早" forState:UIControlStateNormal];
    _btnZao.contentMode = UIViewContentModeScaleAspectFit;
    [_btnZao setBackgroundColorForState:ColorRed_Normal forState:UIControlStateSelected];
    _btnZao.backgroundColor= RgbHex2UIColor(0xcc, 0xb1, 0xb6);
    _btnZao.tag = 1;
    _btnZao.exclusiveTouch = YES;
    [_btnZao setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [_btnZao setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.view addSubview:_btnZao];
   
    _btnWu = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnWu setImage:[UIImage imageNamed:@"dinner-wu"] forState:UIControlStateNormal];
    [_btnWu setTitle:@"午" forState:UIControlStateNormal];
    [_btnWu setBackgroundColorForState:ColorRed_Normal forState:UIControlStateSelected];
    _btnWu.selected = YES;
    _btnWu.tag = 2;
    _btnWu.userInteractionEnabled = YES;
    _btnWu.exclusiveTouch = YES;
    _btnWu.backgroundColor= RgbHex2UIColor(0xcc, 0xb1, 0xb6);
    [_btnWu setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [_btnWu setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.view addSubview:_btnWu];
    
    _btnCha = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCha setImage:[UIImage imageNamed:@"dinner-tea"] forState:UIControlStateNormal];
    [_btnCha setTitle:@"茶" forState:UIControlStateNormal];
    [_btnCha setBackgroundColorForState:ColorRed_Normal forState:UIControlStateSelected];
    _btnCha.backgroundColor= RgbHex2UIColor(0xcc, 0xb1, 0xb6);
    _btnCha.tag = 3;
    _btnCha.exclusiveTouch = YES;
    [_btnCha setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [_btnCha setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.view addSubview:_btnCha];
    
    [_btnZao addTarget:self action:@selector(switchDinner:) forControlEvents:UIControlEventTouchUpInside];
    [_btnWu addTarget:self action:@selector(switchDinner:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCha addTarget:self action:@selector(switchDinner:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnZao makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblDinner.mas_bottom).offset(20);
        make.left.equalTo(self.view.mas_left).offset(37);
        make.right.equalTo(_btnWu.left).offset(-padding);
        make.width.equalTo(_btnWu.width);
        make.height.equalTo(28*self.appdelegate.autoSizeScaleY);
    }];
    
    [_btnWu makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_btnZao.top);
        make.left.equalTo(_btnZao.mas_right).offset(padding);
        make.right.equalTo(_btnCha.mas_left).offset(-padding);
        make.width.equalTo(_btnZao.width);
        make.height.equalTo(_btnZao.height);
    }];
    
    [_btnCha makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_btnZao.mas_top);
        make.left.equalTo(_btnWu.mas_right).offset(padding);
        make.right.equalTo(self.view.mas_right).offset(-37);
        make.width.equalTo(_btnZao.width);
        make.height.equalTo(@[_btnZao.height,_btnWu.height]);
    }];
    
    //价格
    _imgViewPrice = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-price"]];
    [self.view addSubview:_imgViewPrice];
    
    _lblPrice = [[UILabel alloc] init];
    _lblPrice.text= @"价格";

    _lblPrice.textColor = [UIColor whiteColor];
    _lblPrice.font = NRFont(FontLabelSize);
    [self.view addSubview:_lblPrice];
    
    
    [_lblPrice makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(5);
        make.top.equalTo(_btnWu.mas_bottom).offset(35);
    }];
    [_imgViewPrice makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblPrice).offset(-5);
        make.right.equalTo(_lblPrice.mas_left).offset(-5);
    }];
    
    self.displayPriceLabel = [[UILabel alloc] init];
    self.displayPriceLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.displayPriceLabel];
  
    [self.displayPriceLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_imgViewPrice.mas_bottom).with.offset(20);
        make.height.equalTo(@30);
    }];
    
    // 确定
    _btnOk = [BMButton buttonWithType:UIButtonTypeCustom];
    _btnOk.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnOk.layer.borderWidth = 0.5;
    _btnOk.layer.masksToBounds = YES;
    [_btnOk setTitle:@"确定" forState:UIControlStateNormal];
    _btnOk.titleLabel.font = NRFont(20);
    [_btnOk setBackgroundImage:nil forState:UIControlStateHighlighted];
    [_btnOk setBackgroundImage:nil forState:UIControlStateNormal];
    [self.view addSubview:_btnOk];
    [_btnOk makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_displayPriceLabel.mas_bottom).offset(50);
        make.height.greaterThanOrEqualTo(ButtonDefaultHeight);
        make.left.equalTo(self.view.mas_left).offset(100);
        make.right.equalTo(self.view.mas_right).offset(-100);
    }];
    
    [_btnOk addTarget:self action:@selector(gotoWeekPlanList:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews {
    if (!_needUpdate) {
        return;
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_btnWu.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                         cornerRadii:CGSizeMake(5, 5)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _btnZao.bounds;
    maskLayer.path = maskPath.CGPath;
    _btnZao.layer.mask = maskLayer;
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:_btnWu.bounds
                                                   byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(5, 5)];
    
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = _btnCha.bounds;
    maskLayer2.path = maskPath2.CGPath;
    _btnCha.layer.mask = maskLayer2;
    
    _needUpdate = NO;
}


#pragma mark - Action
- (void)loadPrice {
    if (self.priceTask) {
        [self.priceTask cancel];
    }
    
    [MBProgressHUD showActivityWithText:KeyWindow text:Tips_Loading animated:YES];
    WeakSelf(self);
    NSDictionary *params = @{ @"wptId": @(self.weekplanID) };
    self.priceTask = [[NRNetworkClient sharedClient] sendPost:@"wpt/lowest-price" parameters:params success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        NSString *zaoNum = [res valueForKey:@"morning"];
        NSString *wuNum = [res valueForKey:@"noon"];
        NSString *chaNum = [res valueForKey:@"afternoon"];
        weakSelf.zaoPrice = [zaoNum integerValue];
        weakSelf.wuPrice = [wuNum integerValue];
        weakSelf.chaPirce  = [chaNum integerValue];
        weakSelf.pricePerDay= weakSelf.wuPrice;
        weakSelf.mealPrice = [NSString stringWithFormat:@"%lu/天", weakSelf.wuPrice];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf processRequestError:error];
    }];
}

- (void)switchDinner:(id)sender {
    [MobClick event:NREvent_Click_SelWP_Zao];
    [MobClick event:NREvent_Click_SelWP_Cha];
    UIButton *theBtn = (UIButton*)sender;
    
    if (theBtn.tag == 2) {
        
        [MozTopAlertView showWithType:MozAlertTypeInfo text:@"午餐很重要，不能取消哦" doText:nil doBlock:^{
        } parentView:self.view];
        
        return;
    }
    
    if (theBtn.selected) {
        theBtn.selected = NO;
        [self.msetMealtypes removeObject: [NSNumber numberWithInteger:(long)theBtn.tag]];
    }
    else {
        theBtn.selected = YES;
        [self.msetMealtypes addObject: [NSNumber numberWithInteger:(long)theBtn.tag]];
    }

    NSUInteger dayPrice = self.wuPrice;
    if (self.msetMealtypes.count == 2 && [self.msetMealtypes containsObject:[NSNumber numberWithInteger:1]]) {
        // 午+早
        dayPrice = self.wuPrice + self.zaoPrice;
        self.mealPrice = [NSString stringWithFormat:@"%lu/天", dayPrice];
        self.pricePerDay = dayPrice;
    }
    else if (self.msetMealtypes.count == 2 && [self.msetMealtypes containsObject:[NSNumber numberWithInteger:3]]) {
        // 午+茶
        dayPrice = self.wuPrice + self.chaPirce;
        self.mealPrice = [NSString stringWithFormat:@"%lu/天", dayPrice];
        self.pricePerDay = dayPrice;
    }
    else if (self.msetMealtypes.count == 3) {
        // 早+午+茶
        dayPrice = self.wuPrice + self.zaoPrice + self.chaPirce;
        self.mealPrice = [NSString stringWithFormat:@"%lu/天", dayPrice];
        self.pricePerDay = dayPrice;
    }
    else {
        self.mealPrice = [NSString stringWithFormat:@"%lu/天", dayPrice];
        self.pricePerDay = dayPrice;
    }
}

- (void)displayPriceWithValue:(NSString *)valString {
    NSMutableAttributedString *_str = [[NSMutableAttributedString alloc] initWithString:valString];
    [_str addAttribute:NSForegroundColorAttributeName value:RgbHex2UIColor(0XD6, 0X3F, 0X26) range:NSMakeRange(0, valString.length)];
    
    [_str addAttribute:NSFontAttributeName value:SysFont(30) range:NSMakeRange(0, valString.length-2)];
    [_str addAttribute:NSFontAttributeName value:SysFont(9) range:NSMakeRange(valString.length-2, 2)];
    
    self.displayPriceLabel.attributedText = _str;
    [self.displayPriceLabel updateConstraints];
}

- (void)displayLocationWithAddress:(NSString *)address {
    self.locationImageView.hidden = NO;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                SysFont(14), NSFontAttributeName, nil];
    
    WeakSelf(self);
    self.locationLabel.text = address;
    CGSize textSize =  [address sizeWithAttributes:attributes];
    [self.locationLabel updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.locationView.mas_centerY);
        make.centerX.equalTo(weakSelf.locationView.mas_centerX).offset(-5);
        make.width.equalTo(textSize.width);
        make.width.lessThanOrEqualTo(250);
    }];
    
    [self.locationImageView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.locationLabel.mas_right).offset(8);
        make.centerY.equalTo(weakSelf.locationView.mas_centerY);
        make.width.equalTo(@(7.5));
        make.height.equalTo(@6);
    }];
    
    _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLocation:)];
    [self.locationView addGestureRecognizer:_tapGR];
    
}

- (void)switchLocation:(id)sender {
    [MobClick event:NREvent_Click_SelWP_ChangeAddr];
    
    NRSwitchLocationViewController *locaVC = [[NRSwitchLocationViewController alloc] init];
    locaVC.cityCode = self.cityCode;
    locaVC.weakPlanSelectVC = self;
    [self.navigationController pushViewController:locaVC animated:YES];
}

- (void)gotoWeekPlanList:(id)sender {
    [MobClick event:NREvent_Click_SelWP_Comfirm];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //弹出请打开定位的提示
        
        NSString *msg = [NSString stringWithFormat:@"请在系统设置中开启定位服务\n设置->隐私->定位服务->%@", APPNAME];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务未开启"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    
    if ([_btnOk.titleLabel.text hasPrefix:@"无法定位"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位失败" message:@"请选择手动定位" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NoNetwork];
        return;
    }
    
    NRWeekPlanListViewController *listVC = [[NRWeekPlanListViewController alloc] initWithFromCollect:NO];
    listVC.weekplanID = self.weekplanID;
    listVC.arrMealtypes = [self.msetMealtypes allObjects];
    listVC.pricePerDay = self.pricePerDay;
    listVC.address = _locationLabel.text;
    listVC.locationx = [NSString stringWithFormat:@"%lf", self.coordinate2D.longitude];
    listVC.locationy = [NSString stringWithFormat:@"%lf", self.coordinate2D.latitude];
    
    [listVC getWeekplanlist];
    [self.navigationController pushViewController:listVC animated:YES];
    
    //打点
    [MobClick event:NREvent_Click_WeekPlanList];
}

/**
 *  手动定位到当前位置
 */
- (void)handCurrentLocation {
    NSNumber *numLongitude = [[NSUserDefaults standardUserDefaults] objectForKey:keyLongitude];
    NSNumber *numLatitude = [[NSUserDefaults standardUserDefaults] objectForKey:keyLatitude];
    CLLocationCoordinate2D corrdinate = CLLocationCoordinate2DMake([numLatitude doubleValue], [numLongitude doubleValue]);
    self.coordinate2D = corrdinate;
}

// 处理手动定位选中搜索地址的结果
- (void)handLocationWith:(AMapGeoPoint*)amapGeoPoint address:(NSString *)address {

    //-- 保存当前位置，为了以后获取收货地址的时候
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:amapGeoPoint.longitude] forKey:keyLongitude];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:amapGeoPoint.latitude] forKey:keyLatitude];
    
    
    //    self.amapGeoPoint = amapGeoPoint;
    _coordinate2D = CLLocationCoordinate2DMake(amapGeoPoint.latitude, amapGeoPoint.longitude);
//    self.locationLabel.text = address;
    [self displayLocationWithAddress:address];
}

- (void)handHistoryAddrLocationWith:(CLLocationCoordinate2D)coordinate2D address:(NSString *)address {
    _coordinate2D = coordinate2D;
//    self.locationLabel.text = address;
    [self displayLocationWithAddress:address];
}

#pragma mark - AMapSearchDelegate
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    NSMutableString *mstrAddress = [NSMutableString new];
    
    if(response.regeocode != nil) {
        // 通过AMapReGeocodeSearchResponse对象处理搜索结果
        self.cityCode = response.regeocode.addressComponent.citycode;
        
        /*
        if (response.regeocode.addressComponent.building.length > 0) {
            [mstrAddress appendString:response.regeocode.addressComponent.building];
            [mstrAddress appendString:@" >"];
        }
        else {
            [mstrAddress appendString:response.regeocode.addressComponent.province];
            [mstrAddress appendString:response.regeocode.addressComponent.city];
            [mstrAddress appendString:response.regeocode.addressComponent.district];
            [mstrAddress appendString:response.regeocode.addressComponent.streetNumber.street];
            [mstrAddress appendString:response.regeocode.addressComponent.streetNumber.number];
            NSRange range = [response.regeocode.addressComponent.streetNumber.number rangeOfString:@"号"];
            if (range.length == 0) {
                [mstrAddress appendString:@"号"];
            }
        }
        */
        
        [mstrAddress appendString:response.regeocode.formattedAddress];
//        [mstrAddress appendString:@" >"];
        
    }
    else {
//        [mstrAddress appendString:@"无法定位 >"];
        self.cityCode = nil;
    }
    
//    [_btnSetLocation setTitle:mstrAddress forState:UIControlStateNormal];
//    self.locationLabel.text = mstrAddress;
    [self displayLocationWithAddress:mstrAddress];
}

#pragma mark - Property
- (void)setMealPrice:(NSString *)mealPrice {
    _mealPrice = mealPrice;
    [self displayPriceWithValue:mealPrice];
}

- (void)setCoordinate2D:(CLLocationCoordinate2D)coordinate2D {
    _coordinate2D = coordinate2D;
    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
    self.regeoRequest.location = [AMapGeoPoint locationWithLatitude:_coordinate2D.latitude longitude:_coordinate2D.longitude];
    [self.amapSearch AMapReGoecodeSearch:self.regeoRequest];
}

- (AMapReGeocodeSearchRequest *)regeoRequest {
    if (!_regeoRequest) {
        _regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
        _regeoRequest.searchType = AMapSearchType_ReGeocode;
        _regeoRequest.radius = 50;
        _regeoRequest.requireExtension = YES; //是否输出扩展街道信息
    }
    
    return _regeoRequest;
}

#pragma mark - CLLocationManagerDelegate

/*
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorized:
            break;
        case kCLAuthorizationStatusDenied:
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
    
    // 定位到当前回来，重新发起高德地址逆编码
    self.amapGeoPoint = [AMapGeoPoint locationWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    self.regeoRequest.location = [AMapGeoPoint locationWithLatitude:self.amapGeoPoint.latitude longitude:self.amapGeoPoint.longitude];
    [self.amapSearch AMapReGoecodeSearch:self.regeoRequest];
    
    NSLog(@"定位到当前 经度：%f,纬度：%f",newCoordinate.longitude,newCoordinate.latitude);
    
    //--保存当前位置，为了以后获取收货地址的时候，自动出现街道等
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:newCoordinate.longitude] forKey:keyLongitude];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:newCoordinate.latitude] forKey:keyLatitude];
    
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败, error = %@", error);
}

*/

#pragma mark - override
- (void)back:(id)sender {
    [MobClick event:NREvent_Click_SelWP_Back];
    [super back:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
