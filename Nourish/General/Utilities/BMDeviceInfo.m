//
//  BMDeviceInfo.m
//  BMGameSDK
//  设备信息类
//  Created by 任建文 on 14-5-7.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BMDeviceInfo.h"

@interface BMDeviceInfo ()

@property (nonatomic, copy, readwrite) NSString *systemVersion;//系统版本
@property (nonatomic, copy, readwrite) NSString *model;        //e.g. "iPHone" "iPod" "iPad"
@property (nonatomic, copy, readwrite) NSString *name;         //.e.g."my phone"

@end

@implementation BMDeviceInfo

+ (BMDeviceInfo *)instance
{
    static dispatch_once_t pred=0;
    static BMDeviceInfo *instance=nil;
    dispatch_once(&pred,^{
        instance=[[self alloc]init];
        [instance initData];
    });
    
    return instance;
}

- (void)initData
{
    UIDevice *device = [UIDevice currentDevice];
    self.systemVersion = device.systemVersion;
    self.model         = device.model;
    self.name          = device.name;
}

@end
