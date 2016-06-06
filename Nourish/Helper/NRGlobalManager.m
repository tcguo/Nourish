//
//  NRGlobalManager.m
//  Nourish
//
//  Created by tcguo on 16/4/5.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRGlobalManager.h"
#import "NRNetworkClient.h"

static NRGlobalManager *instance = nil;

@interface NRGlobalManager ()
@property (nonatomic, copy, readwrite) NSString *customerPhone;
@property (nonatomic, weak) NSURLSessionDataTask *customerPhoneTask;
@end

@implementation NRGlobalManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[NRGlobalManager alloc] init];
        }
    });
    
    return instance;
}

- (void)getCustomerPhone {
    if (self.customerPhoneTask) {
        [self.customerPhoneTask cancel];
    }
    
    self.customerPhoneTask = [[NRNetworkClient sharedClient] sendPost:@"app-settings/customer-hotline" parameters:nil success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        NSString *customerHotline = [res valueForKey:@"customerHotline"];
        if (STRINGHASVALUE(customerHotline)) {
            [[NSUserDefaults standardUserDefaults] setValue:customerHotline forKey:kUserDefault_CustomerPhone];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (NSString *)customerPhone {
    _customerPhone = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:kUserDefault_CustomerPhone];
    if (!STRINGHASVALUE(_customerPhone)) {
        _customerPhone = kCustomerPhone;
    }
    return _customerPhone;
}

@end
