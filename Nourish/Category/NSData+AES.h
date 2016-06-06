//
//  NSData+AES.h
//  BMGameSDK
//
//  Created by Gavin Van on 14-5-12.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSString *)hexString;
- (NSData *)AES256EncryptWithKey:(NSString *)key;   //加密
- (NSData *)AES256DecryptWithKey:(NSString *)key;   //解密

@end
