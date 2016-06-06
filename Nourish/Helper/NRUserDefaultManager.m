//
//  NRUserDefaultManager.m
//  Nourish
//
//  Created by tcguo on 15/11/1.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRUserDefaultManager.h"

static NRUserDefaultManager *instance;

@implementation NRUserDefaultManager

+ (instancetype)shareInstance {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[NRUserDefaultManager alloc] init];
        }
    });
    
    return instance;
}

- (void)setToken:(NSString *)token {
    _token = token;
    if (_token == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefault_Token];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:_token forKey:kUserDefault_Token];
    }
}

- (NSString *)token {
    return _token;
}

- (NSString *)sessionID {
    return _sessionID;
}

- (void)setSessionID:(NSString *)sessionID {
    _sessionID = sessionID;
    if (_sessionID == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefault_SessionID];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:_sessionID forKey:kUserDefault_SessionID];
    }
}

- (void)removeAll {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefault_Token];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefault_SessionID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefault_UserInfo];
}

@end
