//
//  NRFindBackPwdSMSCodeViewController.h
//  Nourish
//
//  Created by gtc on 15/7/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"

@interface NRFindBackPwdSMSCodeViewController : NRBaseViewController

@property (nonatomic, copy, readonly) NSString *phoneNum;

@property (nonatomic, copy) NSString *smsVCode;

- (id)initWithPhoneNum:(NSString *)phoneNum;
- (void)startThreadShutDown;

@end
