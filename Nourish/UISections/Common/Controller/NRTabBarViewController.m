//
//  FNMyCollectionViewController.m
//  TabBarController_LYS
//
//  Created by lys on 12-8-23.
//  Copyright (c) 2012年 lys. All rights reserved.
//

#import "NRTabBarViewController.h"

#define kHeightTabContainerView 40

@interface NRTabBarViewController ()
//
////界面基本参数
//- (void) setNavBar;
//- (void) backAction;
//- (void) addBasicView;
//
////左右滑动相关
//- (void)initScrollView;
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
//- (void)createAllEmptyPagesForScrollView;
//
////界面按钮事件
//- (void) btnActionShow;
//- (void) leftTabButtonAction;
//- (void) rightTabButtonAction;

@end

@implementation NRTabBarViewController

- (void)viewDidLoadWithBarStyle:(NRBarStyle)barStyle
{
    [super viewDidLoadWithBarStyle:barStyle];
    // Do any additional setup after loading the view from its nib.
    
    [self addBasicView];
    
    [self initScrollView];
}

#pragma mark-
#pragma mark navigationController Methods

- (void)addBasicView
{
    self.tabBarContainerView = [[UIView alloc]  initWithFrame:CGRectMake(-1, 0, self.view.bounds.size.width +2, kHeightTabContainerView)];
    self.tabBarContainerView.layer.borderColor = ColorGragBorder.CGColor;
    self.tabBarContainerView.layer.borderWidth = 1;
    self.tabBarContainerView.layer.masksToBounds = YES;
    self.tabBarContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabBarContainerView];
    
    self.leftTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.leftTabButton setTitleColor:ColorBaseFont forState:UIControlStateNormal];
    [self.leftTabButton setTitleColor:ColorRed_Normal forState:UIControlStateSelected];
    [self.leftTabButton addTarget:self action:@selector(leftTabButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.rightTabButton setTitleColor:ColorBaseFont forState:UIControlStateNormal];
    [self.rightTabButton setTitleColor:ColorRed_Normal forState:UIControlStateSelected];
    [self.rightTabButton addTarget:self action:@selector(rightTabButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.leftTabButton.frame = CGRectMake(0, 0, self.view.bounds.size.width/2, kHeightTabContainerView);
    self.rightTabButton.frame = CGRectMake(self.view.bounds.size.width/2, 0, self.view.bounds.size.width/2, kHeightTabContainerView);
    [self.tabBarContainerView addSubview:self.leftTabButton];
    [self.tabBarContainerView addSubview:self.rightTabButton];
    
    [self.leftTabButton setBackgroundColor:[UIColor whiteColor]];
    [self.rightTabButton setBackgroundColor:[UIColor whiteColor]];
    
    [self.leftTabButton setTitle:@"诺食快讯" forState:UIControlStateNormal];
    [self.rightTabButton setTitle:@"系统消息" forState:UIControlStateNormal];
    [self.leftTabButton.titleLabel setFont:SysFont(15)];
    [self.rightTabButton.titleLabel setFont:SysFont(15)];

    self.slidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kHeightTabContainerView-3, self.view.bounds.size.width/2, 3)];
    self.slidLabel.backgroundColor = ColorRed_Normal;
    [self.tabBarContainerView addSubview:self.slidLabel];
    
//    self.rightTabButton.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
//    [self.rightTabButton setTitleColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1] forState:UIControlStateNormal];//此时未被选中
    
}


#pragma mark-
#pragma mark 界面按钮事件

- (void)btnActionShow
{
    if (currentPage == 0) {
        [self leftTabButtonAction];
    }
    else{
        [self rightTabButtonAction];
    }
}

- (void)leftTabButtonAction
{
    self.rightTabButton.selected = NO;
    self.leftTabButton.selected = YES;
    
    [UIView beginAnimations:nil context:nil];//动画开始    
    [UIView setAnimationDuration:0.2];

    self.slidLabel.frame = CGRectMake(0, kHeightTabContainerView-3, self.view.bounds.size.width/2, 3);
    [self.nibScrollView setContentOffset:CGPointMake(self.view.bounds.size.width*0, 0)];//页面滑动
    
    [UIView commitAnimations];
}

- (void)rightTabButtonAction {
    self.rightTabButton.selected = YES;
    self.leftTabButton.selected = NO;
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.2];
    
    self.slidLabel.frame = CGRectMake(self.view.bounds.size.width/2, kHeightTabContainerView-3, self.view.bounds.size.width/2, 3);
    [self.nibScrollView setContentOffset:CGPointMake(self.view.bounds.size.width*1, 0)];
    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark 左右滑动相关函数

- (void)initScrollView {
    
    //设置 tableScrollView
    // a page is the width of the scroll view
    self.nibScrollView = [[UIScrollView alloc] init];
    self.nibScrollView.backgroundColor = ColorViewBg;
    self.nibScrollView.frame = CGRectMake(0, self.tabBarContainerView.frame.origin.y + self.tabBarContainerView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height);

    self.nibScrollView.tag = 100;
    self.nibScrollView.pagingEnabled = YES;
    self.nibScrollView.clipsToBounds = NO;
    self.nibScrollView.scrollEnabled = YES;
    
    self.nibScrollView.contentSize = CGSizeMake(self.nibScrollView.frame.size.width*2, self.nibScrollView.frame.size.height);
    self.nibScrollView.showsHorizontalScrollIndicator = NO;
    self.nibScrollView.showsVerticalScrollIndicator = NO;
    self.nibScrollView.scrollsToTop = NO;
    self.nibScrollView.delegate = self;
    
    [self.nibScrollView setContentOffset:CGPointMake(0, 0)];
        [self.view addSubview:self.nibScrollView];
    
    //公用
    currentPage = 0;
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    
    [self createAllEmptyPagesForScrollView];
}

- (void)createAllEmptyPagesForScrollView {
    
    CGFloat width = self.view.bounds.size.width;
    
    //设置 tableScrollView 内部数据
    self.leftTableView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStylePlain];
    self.leftTableView.frame = CGRectMake(width*0, 0, width, self.nibScrollView.frame.size.height);
    self.rightTableView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStylePlain];
    self.rightTableView.frame = CGRectMake(width*1, 0, width, self.nibScrollView.frame.size.height);

    //设置tableView委托并添加进视图
    self.leftTableView.backgroundColor = [UIColor clearColor];
    self.rightTableView.backgroundColor = [UIColor clearColor];
    
//    self.leftTableView.delegate = self;
//    self.leftTableView.dataSource = self;
    [self.nibScrollView addSubview: self.leftTableView];
//    self.rightTableView.delegate = self;
//    self.rightTableView.dataSource = self;
    [self.nibScrollView addSubview: self.rightTableView];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = self.nibScrollView.frame.size.width;
    int page = floor((self.nibScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    pageControl.currentPage = page;
    currentPage = page;
    pageControlUsed = NO;
    [self btnActionShow];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //暂不处理 - 其实左右滑动还有包含开始等等操作，这里不做介绍
    if (scrollView.tag == 100) {
        CGFloat offsetX = scrollView.contentOffset.x;
        self.slidLabel.frame = CGRectMake(offsetX/2, kHeightTabContainerView-3, self.view.bounds.size.width/2, 3);
    }
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}


@end
