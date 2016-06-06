//
//  NRWriteAddressViewController.h
//  Nourish
//  高德地图定位增加地址
//  Created by tcguo on 15/9/12.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NRAddAddressController.h"

@interface NRWriteAddressViewController : NRBaseViewController

@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, weak) NRAddAddressController *weakAddAddrVC;

@end

@interface NRSearchPoi : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *pcode;
@property (nonatomic, copy) NSString *citycode;
@property (nonatomic, copy) NSString *adcode;

@end