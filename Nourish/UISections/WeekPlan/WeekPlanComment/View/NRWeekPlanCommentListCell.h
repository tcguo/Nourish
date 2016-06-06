//
//  NRWeekPlanCommentListCell.h
//  Nourish
//
//  Created by tcguo on 15/11/4.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRTableViewBaseCell.h"
#include <UIKit/UIKit.h>

@class NRWeekPlanCommentListModel;
@interface NRWeekPlanCommentListCell : NRTableViewBaseCell

@property (nonatomic, strong) NRWeekPlanCommentListModel *model;

@end


@interface NRWeekPlanCommentListModel : NSObject

@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *dateTime;
@property (nonatomic, copy) NSString *weekth;
@property (nonatomic, strong) NSNumber *price;

@end

