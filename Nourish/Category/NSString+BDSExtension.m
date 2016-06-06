//
//  NSString+BDSExtension.m
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "NSString+BDSExtension.h"

#pragma mark -
@implementation NSString(BDSExtension)

- (NSString *)URLEncoding
{
	NSString * result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
																			(CFStringRef)self,
																			NULL,
                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																			kCFStringEncodingUTF8 ));
    return result;
}

- (NSString *)UTF8Encoding
{
    NSString * result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
																			(CFStringRef)self,
																			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                            NULL,
																			kCFStringEncodingUTF8 ));
    return result;
}

- (NSString *)URLDecoding
{
    NSString * result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
    return result;

}

- (NSString *)MD5
{
    unsigned char *CC_MD5();
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSData *)UTF8Data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}


-(NSString *)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trimLeftAndRightWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
