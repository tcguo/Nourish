//
//  NRRecordUserView.h
//  Nourish
//
//  Created by gtc on 8/24/15.
//  Copyright (c) 2015 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseView.h"
#import "NRUserInfoModel.h"
#import "NRRecordDayInfo.h"
#import "MZDayPicker.h"
#import "KACircleProgressView.h"

@interface NRRecordHeaderView : UIView

@property (strong, nonatomic) NRUserInfoModel *userMod;
@property (strong, nonatomic) NRRecordDayInfo *dayMod;
@property (strong, nonatomic) MZDayPicker *dayPicker;
@property (strong, nonatomic) KACircleProgressView *progressView;

- (void)setupViews;

@end
