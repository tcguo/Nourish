//
//  NRWeekPlanCommentListViewController.h
//  Nourish
//
//  Created by tcguo on 15/11/3.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"

@interface NRWeekPlanCommentListViewController : NRBaseViewController

@property (nonatomic, assign) NSUInteger wptId;
@property (nonatomic, strong) NSArray *smwIds;

@property (nonatomic, copy) NSString *weekplanName;
@property (nonatomic, copy) NSString *weekplanCoverImageUrl;

@end
