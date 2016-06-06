//
//  NRLoginViewController.h
//  Nourish
//
//  Created by gtc on 14/12/25.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseViewController.h"


@protocol LoginDelegate <NSObject>

@optional
- (void)loginCompleted;


@end

@interface NRLoginViewController : NRBaseViewController

@property (assign, nonatomic) id<LoginDelegate> loginDelegate;

+ (instancetype)sharedInstance;

- (void)loginDidSuccess;
- (void)loginDidFailure:(NSString *)errorMsg;

//- (void)closeWithAnimated:(BOOL)Animated completion:(void(^)(void))completion;

@end
