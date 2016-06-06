//
//  NRLoginManager.h
//  Nourish
//
//  Created by tcguo on 15/12/3.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRLoginManager : NSObject
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *token;

@property (copy, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSNumber *age;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSNumber *weight;
@property (assign, nonatomic) GenderType genderType;
@property (copy, nonatomic) NSString *cellPhone;
@property (copy, nonatomic) NSString *avatarUrl;
@property (copy, nonatomic) NSString *point; // 积分

@property (copy, nonatomic) NSString *channelId; //BPush
@property (copy, nonatomic) NSString *deviceToken;

@property (nonatomic, assign) BOOL isLogined;
+ (instancetype)sharedInstance;
- (void)logoutUserInfo;
- (void)archivedData;
- (void)unarchivedData;

@end
