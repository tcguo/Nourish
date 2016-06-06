//
//  HRTableViewCell.h
//  HRVTableView
//
//  Created by gtc on 15/6/2.
//  Copyright (c) 2015年 Hamidreza Vakilian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgv;
@property (nonatomic, strong) UIImage *bgImage;

- (void)addViews;
- (void)removeViews;

@end
