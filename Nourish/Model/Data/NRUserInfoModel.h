//
//  NRUserInfoModel.h
//  Nourish

//  用户信息类
//  用于编码中传参

//  Created by gtc on 15/2/11.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NRUserInfoModel : NSObject

@property (copy, nonatomic) NSString *nickName;
@property (assign, nonatomic) NSUInteger age;
@property (assign, nonatomic) NSUInteger birYear;
@property (assign, nonatomic) NSUInteger  height;
@property (assign, nonatomic) NSUInteger weight;
@property (assign, nonatomic) GenderType gender;
@property (copy, nonatomic) NSString *cellPhone;
@property (copy, nonatomic) NSString *avatarurl;

@end
