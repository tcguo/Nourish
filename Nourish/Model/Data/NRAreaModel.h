//
//  NRAreaModel.h
//  Nourish
//
//  Created by gtc on 15/4/21.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRAreaModel : NSObject

@property (nonatomic, assign) NSInteger ID;

//此地区的级别, 1省，2市，3区，4街道
@property (nonatomic, assign) NSUInteger level;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger parentID;

//是否可用
@property (nonatomic, assign) BOOL enable;

@end