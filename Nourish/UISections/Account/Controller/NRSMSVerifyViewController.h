//
//  NRSMSVerifyViewController.h
//  Nourish
//
//  Created by gtc on 15/1/7.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"

@interface NRSMSVerifyViewController : NRBaseViewController

@property (nonatomic, copy) NSString *phoneNum;

- (id)initWithPhoneNum:(NSString *)phoneNum;

@property (nonatomic, copy) NSString *smsVCode;

@end
