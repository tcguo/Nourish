//
//  NRBaiduPushProvider.m
//  Nourish
//
//  Created by tcguo on 15/11/10.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaiduPushProvider.h"

@interface NRBaiduPushProvider ()

@property (weak, nonatomic) NSURLSessionDataTask *uploadDataTask;

@end

@implementation NRBaiduPushProvider

- (void)uploadBPushWithChannelId:(NSString *)channelId deviceToken:(NSString *)deviceToken {
    
    if (self.uploadDataTask) {
        [self.uploadDataTask cancel];
    }
    
    NSDictionary *data = @{ @"channelId": channelId,
                            @"deviceToken": deviceToken };
    
    self.uploadDataTask = [[NRNetworkClient sharedClient] sendPost:@"push/bind/baidu" parameters:data success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        if (errorCode == 0) {
            NSLog(@"devicetoken reigister success!");
        }
        else {
            NSLog(@"token register failure!!");
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

@end
