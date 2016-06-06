//
//  BMBase64Helper.h
//  BMGameSDK
//
//  Created by Gavin Van on 14-5-12.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMBase64Helper : NSObject

+ (NSString*)encodeBase64StringWithString:(NSString *)input;
+ (NSString*)decodeBase64StringWithString:(NSString *)input;
+ (NSString*)encodeBase64StringWithData:(NSData *)data;
+ (NSString*)decodeBase64StringWithData:(NSData *)data;

+ (NSData*)encodeBase64DataWithString:(NSString *)input;
+ (NSData*)decodeBase64DataWithString:(NSString *)input;
+ (NSData*)encodeBase64DataWithData:(NSData *)data;
+ (NSData*)decodeBase64DataWithData:(NSData *)data;

@end
