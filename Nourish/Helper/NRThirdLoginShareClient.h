//
//  NRThirdLoginShareClient.h
//  Nourish
//
//  Created by gtc on 15/6/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ThirdLoginShareType) {
    ThirdLoginShareTypeQQ = 1,
    ThirdLoginShareTypeWeiXin = 2,
    ThirdLoginShareTypeSinaWB = 3,
};

typedef NS_ENUM(NSUInteger, NRShareType) {
    NRShareTypeWeiXin = 1,
    NRShareTypeFriendCycle,
    NRShareTypeQQ,
    NRShareTypeQQZone,
    NRShareTypeSinaWB,
};

@protocol ThirdLoginShareDelegate <NSObject>
@optional
- (void)loginDidSuccess;
- (void)loginDidFailure:(NSString *)errorMsg;
- (void)requestSaveThirdUserInfo:(NSDictionary *)data;

@end

@interface NRThirdLoginShareClient : NSObject

@property (nonatomic, weak) id<ThirdLoginShareDelegate> thirdLoginShareDelegate;
@property (nonatomic, weak) UIViewController *currentViewController;

@property (nonatomic, assign) BOOL qqEnabled;
@property (nonatomic, assign) BOOL sinaWBEnabled;
@property (nonatomic, assign) BOOL wxEnabled;

+ (instancetype)shareInstance;
- (void)registerApp;
- (BOOL)handleOpenURL:(NSURL *)url type:(ThirdLoginShareType)type;

- (void)loginByQQ;
- (void)loginByWechat;
- (void)loginBySinaWeibo;

- (BOOL)shareToQQWithUserInfo:(NSDictionary *)userInfo;
- (BOOL)shareToWeChatWithUserInfo:(NSDictionary *)userInfo;
- (BOOL)shareToFriendCycleWithUserInfo:(NSDictionary *)userInfo;
- (BOOL)shareToZoneWithUserInfo:(NSDictionary *)userInfo;
- (BOOL)shareToSinaWBWithUserInfo:(NSDictionary *)userInfo;

@end
