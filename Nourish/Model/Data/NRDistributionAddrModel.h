//
//  NRDistributionAddrModel.h
//  Nourish
//
//  Created by gtc on 15/3/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRDistributionAddrModel : NSObject

//@property (assign, nonatomic) NSInteger userId;

@property (assign, nonatomic) NSInteger addressID;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *phone;

//@property (copy, nonatomic) NSString *province;
//@property (copy, nonatomic) NSString *provinceId;
//@property (copy, nonatomic) NSString *city;
//@property (copy, nonatomic) NSString *cityId;
//@property (copy, nonatomic) NSString *district;
//@property (copy, nonatomic) NSString *districtId;
//@property (copy, nonatomic) NSString *town;//街道
//@property (copy, nonatomic) NSString *townId;//街道Code

@property (copy, nonatomic) NSString *adcode;//区域
@property (copy, nonatomic) NSString *poiName;//写字楼、公司名字
@property (copy, nonatomic) NSString *poiAddress;//写字楼地址
@property (copy, nonatomic) NSString *poiType;//写字楼地址

@property (copy, nonatomic) NSString *detailAddress;//详细地址，门牌号
@property (copy, nonatomic) NSString *wholeAddress;//完整地址= poiAddress+detailAddress号

@property (assign, nonatomic) CGFloat longitude;//经度
@property (assign, nonatomic) CGFloat latitude;//纬度

//是否默认地址
@property (assign, nonatomic) BOOL isFirst;
@property (assign, nonatomic) BOOL reachable;//是否可配送
@property (assign, nonatomic) CGFloat distance; //地址和午餐周计划所在商家的距离

@end
