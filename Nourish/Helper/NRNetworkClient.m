//
//  NRAFNetworkClient.m
//  Nourish
//
//  Created by gtc on 15/1/2.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRNetworkClient.h"
#import "JSONKit.h"
#import "NSData+AES.h"
#import "BMBase64Helper.h"
#import "Config.h"
#import "Reachability.h"
#import "AFNetworkReachabilityManager.h"
#import "AFURLRequestSerialization.h"
#import "NRLoginManager.h"
#import "AFNetworking.h"
@implementation NRNetworkClient

static NRNetworkClient *client = nil;

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLCache *cache = [NSURLCache sharedURLCache]; // 默认
        [config setURLCache:cache];
        [config setTimeoutIntervalForRequest:15.0f];
        
        client =[[NRNetworkClient alloc] initWithBaseURL:[NSURL URLWithString:NourishBaseURLString] sessionConfiguration:config];
        client.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        client.responseSerializer = [AFJSONResponseSerializer serializer];
        client.requestSerializer  = [AFHTTPRequestSerializer serializer];
        [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [client.requestSerializer setValue:@"Nourish" forHTTPHeaderField:@"User-Agent"];
        [client.requestSerializer setValue:@"json" forHTTPHeaderField:@"dataType"];
    });
    
    return  client;
}

- (NSURLSessionDataTask *)sendPost: (NSString *)URLString
                       parameters:(id)parameters
                          success:(void (^)(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    NetworkStatus networkStatus = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    if (networkStatus == NotReachable) {
        
        NSDictionary *userInfoDict = @{ @"errorMsg":  @"似乎已断开与互联网的连接" };
        NSError *notReachableError = [NSError errorWithDomain:NourishDomain code:NRRequestErrorNetworkDisAvailablity userInfo:userInfoDict];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(nil, notReachableError);
            }
        });
        
        return nil;
    }
    
    NSString *sessionid = [NRLoginManager sharedInstance].sessionId;
    NSString *token = [NRLoginManager sharedInstance].token;
    NSDictionary *commDic = @{ @"version": NourishVersion,
                               @"ua": DeviceName,
                               @"os": OS,
                               @"connecttype": [NSString stringWithFormat:@"%li", (long)networkStatus],
                               @"sessionid": sessionid == nil ? @"":sessionid,
                               @"token": token == nil ? @"":token,
                               @"udid": UUID };
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:commDic];
    if (DICTIONARYHASVALUE(parameters)) {
        [mdic addEntriesFromDictionary:parameters];
    }
    
#ifdef DEBUG
    NSLog(@"req = %@", mdic);
#endif
    
    NSData *postdata = [[mdic JSONData] AES256EncryptWithKey: AESKEY];
    NSDictionary *postdic = @{ @"data":[postdata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]};
    
    NSURLSessionDataTask *task = [self POST:URLString parameters:postdic success:^(NSURLSessionDataTask *task, id responseObject) {
            NSInteger errorcode = [[responseObject valueForKeyPath:@"errorcode"] integerValue];
            NSString *errormsg  = [responseObject valueForKeyPath:@"errormsg"];
            NSString *retRes    = [responseObject valueForKeyPath:@"res"];
        
            NSError *error = nil;
            NSString *resJson = nil;
            id resObj = nil;
        
            if (errorcode != 0) {
                //接口错误
                NSDictionary *errorInfo = @{ @"errorMsg":errormsg };
                error = [NSError errorWithDomain:NourishDomain code:errorcode userInfo:errorInfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(task, error);
                    }
                });
                return;
            }
        
            @try {
                if (STRINGHASVALUE(retRes)) {
                    NSData *dedata = [BMBase64Helper decodeBase64DataWithString:retRes];
                    NSData *strdata = [dedata AES256DecryptWithKey:AESKEY];
                    resJson = [[strdata objectFromJSONDataWithParseOptions:JKParseOptionValidFlags] JSONString];
                    resObj = [resJson objectFromJSONStringWithParseOptions:JKParseOptionStrict];
                }
            }
            @catch (NSException *exception) {
                NSDictionary *userInfo = @{ @"errorMsg":  @"Json数据解析失败" };
                error = [NSError errorWithDomain:NourishDomain code:NRRequestErrorParseJsonError userInfo:userInfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(task, error);
                    }
                });
                return;
            }
        
            if (resObj) {
                // 更新sessionid
                NSString *sessionid =  [resObj valueForKey:@"sessionid"];
                if (sessionid && sessionid.length != 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:sessionid forKey:kUserDefault_SessionID];
                }
            }
            
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(task, errorcode, errormsg, resObj);
                });
            }
        
#ifdef DEBUG
            NSLog(@"errorcode = %ld", (long)errorcode);
            NSLog(@"errormsg  = %@",  errormsg);
            NSLog(@"resp= %@",        resJson);
#endif
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
#ifdef DEBUG
        NSLog(@"error= %@", error.localizedDescription);
        NSLog(@"error= %@", error.localizedFailureReason);
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(task, error);
            }
        });
        
    }];
    
    return task;
}

- (NSURLSessionDownloadTask *)downloadFromUrl {
    return nil;
}

- (NSURLSessionDataTask *)sendUpload:(NSString *)URLString
                          parameters:(id)parameters
           constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                            success:(void (^)(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res))success
                            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NetworkStatus networkStatus = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    if (networkStatus == NotReachable) {
        
        NSDictionary *userInfoDict = @{ @"errorMsg":  @"似乎已断开与互联网的连接" };
        NSError *notReachableError = [NSError errorWithDomain:NourishDomain code:NRRequestErrorNetworkDisAvailablity userInfo:userInfoDict];
        if (failure) {
            failure(nil, notReachableError);
        }
        return nil;
    }
    
    NSString *sessionid = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefault_SessionID];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefault_Token];
    
    NSDictionary *commDic = @{ @"version": NourishVersion,
                               @"ua": DeviceName,
                               @"os": OS,
                               @"connecttype": [NSString stringWithFormat:@"%li", (long)networkStatus],
                               @"sessionid": sessionid == nil? @"":sessionid,
                               @"token": token == nil? @"":token,
                               @"udid": UUID };
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:commDic];
    if (DICTIONARYHASVALUE(parameters)) {
        [mdic addEntriesFromDictionary:parameters];
    }
    
    NSLog(@"req = %@", mdic);
    
    NSData *postdata = [[mdic JSONData] AES256EncryptWithKey: AESKEY];
    NSDictionary *postdic = @{@"data":[postdata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]};
    
    NSURLSessionDataTask *task = nil;
    task = [self POST:URLString parameters:postdic constructingBodyWithBlock:block success:^(NSURLSessionDataTask *task, id responseObject) {
        NSInteger errorcode = [[responseObject valueForKeyPath:@"errorcode"] integerValue];
        NSString *errormsg  = [responseObject valueForKeyPath:@"errormsg"];
        NSString *retRes    = [responseObject valueForKeyPath:@"res"];
        
        NSError *error = nil;
        NSString *resJson = nil;
        id resObj = nil;
        
        if (errorcode != 0) {
            NSDictionary *errorInfo = @{ kErrorMsg:errormsg };
            error = [NSError errorWithDomain:NourishDomain code:errorcode userInfo:errorInfo];
            failure(task, error);
            return;
        }
            
        @try {
             if (retRes != nil && retRes.length != 0) {
                NSData *dedata = [BMBase64Helper decodeBase64DataWithString:retRes];
                NSData *strdata = [dedata AES256DecryptWithKey:AESKEY];
                resJson = [[strdata objectFromJSONDataWithParseOptions:JKParseOptionValidFlags] JSONString];
                resObj = [resJson objectFromJSONStringWithParseOptions:JKParseOptionStrict];
             }
        }
        @catch (NSException *exception) {
            NSDictionary *userInfo = @{ @"errorMsg":  @"Json数据解析失败" };
            error = [NSError errorWithDomain:NourishDomain code:NRRequestErrorParseJsonError userInfo:userInfo];
            failure(task, error);
            return;
        }
        
        NSLog(@"errorcode = %ld", errorcode);
        NSLog(@"errormsg  = %@",  errormsg);
        NSLog(@"resp= %@",        resJson);
        
        if (resObj) {
            //更新sessionid
            NSString *sessionid =  [resObj valueForKey:@"sessionid"];
            if (STRINGHASVALUE(sessionid)) {
                [[NSUserDefaults standardUserDefaults] setObject:sessionid forKey:kUserDefault_SessionID];
            }
        }
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(task, errorcode, errormsg, resObj);
            });
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error= %@", error.localizedDescription);
        NSLog(@"error= %@", error.localizedFailureReason);
        if (failure) {
            failure(task, error);
        }
    }];
    
    return task;
}

#pragma mark - RAC
- (RACSignal *)rac_sendPost:(NSString *)path parameters:(id)parameters {
    NetworkStatus networkStatus = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    if (networkStatus == NotReachable){
        NSDictionary *userInfoDict = @{ @"errorMsg":  @"似乎已断开与互联网的连接" };
        return [RACSignal error:[NSError errorWithDomain:NourishDomain code:NRRequestErrorNetworkDisAvailablity userInfo:userInfoDict]];
    }
    
    NSString *sessionid = [NRLoginManager sharedInstance].sessionId;
    NSString *token = [NRLoginManager sharedInstance].token;
    NSDictionary *commDic = @{ @"version": NourishVersion,
                               @"ua": DeviceName,
                               @"os": OS,
                               @"connecttype": [NSString stringWithFormat:@"%li", (long)networkStatus],
                               @"sessionid": sessionid == nil ? @"":sessionid,
                               @"token": token == nil ? @"":token,
                               @"udid": UUID };
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:commDic];
    if (DICTIONARYHASVALUE(parameters)) {
        [mdic addEntriesFromDictionary:parameters];
    }
    
    
#ifdef DEBUG
    NSLog(@"req = %@", mdic);
#endif
    
    NSData *postdata = [[mdic JSONData] AES256EncryptWithKey: AESKEY];
    NSDictionary *postdic = @{ @"data":[postdata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]};
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
         return [[super rac_POST:path parameters:postdic] subscribeNext:^(id x) {
             NSDictionary *responseObject = [x objectAtIndex:0];
             NSInteger errorcode = [[responseObject valueForKeyPath:@"errorcode"] integerValue];
             NSString *errormsg  = [responseObject valueForKeyPath:@"errormsg"];
             NSString *retRes    = [responseObject valueForKeyPath:@"res"];
             
             NSError *error = nil;
             if (errorcode != 0) {
                 NSDictionary *errorInfo = @{ kErrorMsg:errormsg };
                 error = [NSError errorWithDomain:NourishDomain code:errorcode userInfo:errorInfo];
                 [subscriber sendError:error];
             }
             
             id resObj = nil;
             NSString *resJson = nil;
             @try {
                  if (STRINGHASVALUE(retRes)) {
                     NSData *dedata = [BMBase64Helper decodeBase64DataWithString:retRes];
                     NSData *strdata = [dedata AES256DecryptWithKey:AESKEY];
                     resJson = [[strdata objectFromJSONDataWithParseOptions:JKParseOptionValidFlags] JSONString];
                     resObj = [resJson objectFromJSONStringWithParseOptions:JKParseOptionStrict];
                  }
             }
             @catch (NSException *exception) {
                 NSDictionary *userInfo = @{ @"errorMsg":  @"Json数据解析失败" };
                 error = [NSError errorWithDomain:NourishDomain code:NRRequestErrorParseJsonError userInfo:userInfo];
                 [subscriber sendError:error];
             }
             
             if (OBJHASVALUE(resObj)) {
                 // 更新sessionid
                 NSString *sessionid =  [resObj valueForKey:@"sessionid"];
                 if (STRINGHASVALUE(sessionid)) {
                     [NRLoginManager sharedInstance].sessionId = sessionid;
                 }
             }
             
             [subscriber sendNext:resObj];
#ifdef DEBUG
             NSLog(@"errorcode = %ld", (long)errorcode);
             NSLog(@"errormsg  = %@",  errormsg);
             NSLog(@"resp= %@",        resObj);
#endif
            
         } error:^(NSError *error) {
             [subscriber sendError:error];
         } completed:^{
             [subscriber sendCompleted];
         }];
    }];

}

@end
