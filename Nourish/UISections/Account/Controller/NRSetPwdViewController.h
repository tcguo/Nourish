//
//  NRSetPwdViewController.h
//  Nourish
//
//  Created by gtc on 15/1/7.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"

@interface NRSetPwdViewController : NRBaseViewController

@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *verfiyCode;

- (id)initWithPhoneNum:(NSString *)phoneNum verfiyCode:(NSString *)code;

@end
