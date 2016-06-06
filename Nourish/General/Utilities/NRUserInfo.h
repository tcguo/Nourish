//
//  NRUserInfo.h
//  Nourish

//   用户信息类，用于归档

//  Created by gtc on 15/8/4.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NRUserInfo : NSObject<NSCoding>

//@property (copy, nonatomic) NSString *realname; //用户真名 --预留字段还没用到
@property (copy, nonatomic) NSString *sessionId;
@property (copy, nonatomic) NSString *token;

@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *cellPhone;
@property (copy, nonatomic) NSString *avatarUrl;
@property (copy, nonatomic) NSString *point; // 积分

@property (strong, nonatomic) NSNumber *age;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSNumber *weight;
@property (strong, nonatomic) NSNumber *gender;

+ (instancetype)instance;
- (BOOL)archivedUserInfoData; // 个人信息归档
- (instancetype)unarchivedUserInfo;

- (NSUInteger)getUserAge;
- (NSUInteger)getUserHeight;
- (NSUInteger)getUserWeight;
- (GenderType)getUserGender;

@end
