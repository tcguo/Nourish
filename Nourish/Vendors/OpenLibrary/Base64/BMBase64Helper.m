//
//  BMBase64Helper.m
//  BMGameSDK
//
//  Created by Gavin Van on 14-5-12.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BMBase64Helper.h"
#import "GTMBase64.h"

@implementation BMBase64Helper

+ (NSString*)encodeBase64StringWithString:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSString*)decodeBase64StringWithString:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSString*)encodeBase64StringWithData:(NSData *)data {
	data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSString*)decodeBase64StringWithData:(NSData *)data {
	data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSData*)encodeBase64DataWithString:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	return [GTMBase64 encodeData:data];
}

+ (NSData*)decodeBase64DataWithString:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	return [GTMBase64 decodeData:data];
}

+ (NSData*)encodeBase64DataWithData:(NSData *)data {
	return [GTMBase64 encodeData:data];
}

+ (NSData*)decodeBase64DataWithData:(NSData *)data {
	return [GTMBase64 decodeData:data];
}

@end
