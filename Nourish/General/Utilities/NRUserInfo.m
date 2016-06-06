//
//  NRUserInfo.m
//  Nourish
//
//  Created by gtc on 15/8/4.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRUserInfo.h"

static NRUserInfo *userInfo = nil;

@implementation NRUserInfo

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (userInfo == nil) {
            userInfo = [[NRUserInfo alloc] init];
        }
    });
    
    return userInfo;
}

- (instancetype)unarchivedUserInfo {
    NSData *userInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefault_UserInfo];
    if (userInfoData && userInfoData.length != 0) {
         userInfo = (NRUserInfo *)[NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
    }
   
    return userInfo;
}

- (BOOL)archivedUserInfoData
{
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefault_UserInfo];
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        
    }
   
    return YES;
}


- (NSUInteger)getUserAge {
    return [self.age unsignedIntegerValue];
}

- (NSUInteger)getUserHeight{
    return [self.height unsignedIntegerValue];
}

- (NSUInteger)getUserWeight {
    return [self.weight unsignedIntegerValue];
}

- (GenderType)getUserGender {
    if ([self.gender integerValue] == -1) {
        return GenderTypeFemale;
    }
    else if ([self.gender integerValue] == 1) {
        return GenderTypeMale;
    }
    else
        return GenderTypeUnknown;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.nickName forKey:@"nickname"];
    [aCoder encodeObject:self.age forKey:@"age"];
    [aCoder encodeObject:self.height forKey:@"height"];
    [aCoder encodeObject:self.weight forKey:@"weight"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.cellPhone forKey:@"cellPhone"];
    [aCoder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
    [aCoder encodeObject:self.point forKey:@"point"];
    [aCoder encodeObject:self.sessionId forKey:@"sessionId"];
    [aCoder encodeObject:self.token forKey:@"token"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self= [super init]) {
        self.nickName = [aDecoder decodeObjectForKey:@"nickname"];
        self.age = [aDecoder decodeObjectForKey:@"age"];
        self.height = [aDecoder decodeObjectForKey:@"height"];
        self.weight = [aDecoder decodeObjectForKey:@"weight"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.cellPhone = [aDecoder decodeObjectForKey:@"cellPhone"];
        self.avatarUrl = [aDecoder decodeObjectForKey:@"avatarUrl"];
        self.point = [aDecoder decodeObjectForKey:@"point"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.sessionId = [aDecoder decodeObjectForKey:@"sessionId"];
    }
    
    return self;
} //NS_DESIGNATED_INITIALIZER

@end
