//
//  NSData+AES.m
//  BMGameSDK
//
//  Created by Gavin Van on 14-5-12.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

static NSString *
toHexString(const unsigned char *data, int len)
{
    NSMutableString *buffer = [NSMutableString stringWithCapacity:2 * len];
    
    if (data && len > 0) {
        for (int i = 0; i < len; i++)
            [buffer appendFormat:@"%02x", (unsigned)data[i]];
    }
    
    return [buffer copy];
}


@implementation NSData (AES)


- (NSString *)hexString
{
    return toHexString(self.bytes, (int)self.length);
}

- (NSString *)md5String
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(self.bytes, (CC_LONG)self.length, digest);
    
    return toHexString(digest, CC_MD5_DIGEST_LENGTH);
}


- (NSData *)AES256EncryptWithKey:(NSString *)key {//加密
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}


- (NSData *)AES256DecryptWithKey:(NSString *)key {//解密
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end
