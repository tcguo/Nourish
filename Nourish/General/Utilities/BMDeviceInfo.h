//
//  BMDeviceInfo.h
//  BMGameSDK
//  设备信息类
//  Created by 任建文 on 14-5-7.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BMDeviceInfo : NSObject

@property (nonatomic, copy, readonly) NSString *systemVersion;//系统版本
@property (nonatomic, copy, readonly) NSString *model;        //e.g. "iPHone" "iPod" "iPad"
@property (nonatomic, copy, readonly) NSString *name;         //.e.g."my phone"

+ (BMDeviceInfo *)instance;

@end
