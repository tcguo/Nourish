//
//  NRAFNetworkClient.h
//  Nourish
//
//  Created by gtc on 15/1/2.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "AFHTTPSessionManager+RACSupport.h"

@interface NRNetworkClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

/**
 *  发送post请求
 *
 *  @param URLString  请求url
 *  @param parameters post参数
 *  @param success    成功
 *  @param failure    失败
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)sendPost: (NSString *)URLString
                        parameters:(id)parameters
                        success:(void (^)(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDownloadTask *)downloadFromUrl;


- (NSURLSessionDataTask *)sendUpload:(NSString *)URLString
                          parameters:(id)parameters
           constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                             success:(void (^)(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (RACSignal *)rac_sendPost:(NSString *)path parameters:(id)parameters;

@end
