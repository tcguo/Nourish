//
//  NROrderCommentCell.h
//  Nourish
//
//  Created by gtc on 15/3/17.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMTextField.h"
#import "NROrderCommentController.h"

extern NSString * const kPlaceHolder;

@class NROrderCommentInfo;

@interface NROrderCommentCell : UITableViewCell

@property (nonatomic, strong) NROrderCommentInfo *commentInfo;
@property (nonatomic, weak) NROrderCommentController *weakCommentVC;

@property (nonatomic, assign) NSUInteger row;

@end


@interface NROrderCommentInfo : NSObject

@property (nonatomic, assign) BOOL hasCommented;
@property (nonatomic, assign) NSInteger setmealId;
@property (nonatomic, copy) NSString *setmealImage;
@property (nonatomic, assign) DinnerType dinnerType;
@property (nonatomic, copy) NSString *foods;
@property (nonatomic, assign) NSInteger starValue;
@property (nonatomic, copy) NSString *comment;

@end
