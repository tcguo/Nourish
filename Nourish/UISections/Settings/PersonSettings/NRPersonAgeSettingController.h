//
//  NRPersonAgeSettingController.h
//  Nourish
//
//  Created by gtc on 15/3/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NRPersonSettingViewController.h"
#import "NRUserInfoModel.h"
#import "NRPersonHeightSettingController.h"

@interface NRPersonAgeSettingController : NRBaseViewController

- (id)initWithUserInfo:(NRUserInfoModel *)userInfo isFromSexVC:(BOOL)fromSexVC;

@end
