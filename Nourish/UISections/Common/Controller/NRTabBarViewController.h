//  FNMyCollectionViewController.h
//  TabBarController_LYS
//
//  Created by lys on 12-8-23.
//  Copyright (c) 2012年 lys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseViewController.h"

@interface NRTabBarViewController : NRBaseViewController<UIScrollViewDelegate>
{
    //数据部分
    NSArray *couponArry;
    NSArray *groupbuyArry;
    
    //页面展示部分
    UIButton *_leftTabButton;
    UIButton *_rightTabButton;
    UITableView *_leftTableView;
    UITableView *_rightTableView;
    
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
}

@property (strong, nonatomic) UIView *tabBarContainerView;
@property (strong, nonatomic)  UIButton *leftTabButton;
@property (strong, nonatomic)  UIButton *rightTabButton;
@property (strong, nonatomic)  UILabel *slidLabel;//用于指示作用

@property (strong, nonatomic)  UIScrollView *nibScrollView;
@property (strong, nonatomic) UITableView *leftTableView;
@property (strong, nonatomic) UITableView *rightTableView;

- (void)createAllEmptyPagesForScrollView;

@end
