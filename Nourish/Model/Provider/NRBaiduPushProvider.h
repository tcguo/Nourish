//
//  NRBaiduPushProvider.h
//  Nourish
//
//  Created by tcguo on 15/11/10.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRBaiduPushProvider : NSObject

- (void)uploadBPushWithChannelId:(NSString *)channelId deviceToken:(NSString *)deviceToken;

@end
