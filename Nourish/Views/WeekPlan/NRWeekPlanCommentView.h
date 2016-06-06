//
//  NRWeekPlanCommentView.h
//  Nourish
//
//  Created by gtc on 15/1/26.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseView.h"
#import "AMBlurView.h"

@interface NRWeekPlanCommentView : AMBlurView

@property (assign, nonatomic) NSUInteger setmealID;

- (void)updateData;

@end
