//
//  NRLoginManager.m
//  Nourish
//
//  Created by tcguo on 15/12/3.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRLoginManager.h"
#import "NRUserInfo.h"

static NRLoginManager *sharedInstance = nil;

@interface NRLoginManager ()

@property (nonatomic, strong) NRUserInfo *userInfo;

@end


@implementation NRLoginManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[NRLoginManager alloc] init];
        }
    });
    return sharedInstance;
}

- (BOOL)isLogined {
    if (STRINGHASVALUE(self.token)) {
        return YES;
    }
    
    return NO;
}

- (void)logoutUserInfo {
    self.token = nil;
    self.sessionId = nil;
    
    self.avatarUrl = nil;
    self.cellPhone = nil;
    self.nickName = nil;
    self.age = nil;
    self.height = nil;
    self.weight = nil;
    self.point = nil;
    self.channelId = nil;
    self.deviceToken = nil;
}

- (void)archivedData {
    // 归档数据
    self.userInfo = [NRUserInfo instance];
    self.userInfo.nickName = self.nickName;
    self.userInfo.cellPhone = self.cellPhone;
    self.userInfo.gender = [NSNumber numberWithInteger:self.genderType];
    self.userInfo.avatarUrl = self.avatarUrl;
    self.userInfo.age = self.age;
    self.userInfo.height = self.height;
    self.userInfo.weight = self.weight;
    self.userInfo.token = self.token;
    self.userInfo.sessionId = self.sessionId;
    [self.userInfo archivedUserInfoData];
}

- (void)unarchivedData {
    self.userInfo = [[NRUserInfo instance] unarchivedUserInfo];
    self.nickName = self.userInfo.nickName;
    self.cellPhone = self.userInfo.cellPhone;
    self.genderType = [self.userInfo.gender integerValue];
    self.avatarUrl = self.userInfo.avatarUrl;
    self.age = self.userInfo.age;
    self.height = self.userInfo.height;
    self.weight = self.userInfo.weight;
    self.token = self.userInfo.token;
    self.sessionId = self.userInfo.sessionId;
}

@end
