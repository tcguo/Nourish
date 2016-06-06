//
//  NRUserDefaultManager.h
//  Nourish
//
//  Created by tcguo on 15/11/1.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRUserDefaultManager : NSObject
{
    NSString *_token;
    NSString *_sessionID;
}

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *sessionID;

+ (instancetype)shareInstance;
- (void)removeAll;

@end
