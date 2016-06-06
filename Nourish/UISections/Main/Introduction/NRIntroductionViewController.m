//
//  NRIntroductionViewController.m
//  Nourish
//
//  Created by tcguo on 15/9/25.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRIntroductionViewController.h"

@interface NRIntroductionViewController ()<UIScrollViewDelegate>
{
    UIButton *_doneButton;
    UIScrollView *_scrollView;
}

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *doneButton;

@property (strong, nonatomic) UIView *introdFirstView;
@property (strong, nonatomic) UIView *introdSecondView;
@property (strong, nonatomic) UIView *introdThirdView;
@property (strong, nonatomic) UIView *introdFourthView;

@end

@implementation NRIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.introdFourthView addSubview:self.doneButton];
    _doneButton.frame = CGRectMake((self.view.bounds.size.width-150)/2, self.view.frame.size.height*.80, 150, ButtonDefaultHeight);
    
    [self setupScrollView];
}

- (void)setupScrollView {
    [_scrollView addSubview:self.introdFirstView];
    [_scrollView addSubview:self.introdSecondView];
    [_scrollView addSubview:self.introdThirdView];
    [_scrollView addSubview:self.introdFourthView];
}

#pragma mark - Property
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_scrollView setDelegate:self];
        [_scrollView setPagingEnabled:YES];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width*4, self.view.frame.size.height)];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*.9, self.view.frame.size.width, 10)];
        [_pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000]];
        [_pageControl setPageIndicatorTintColor:ColorGrayBg];
        [_pageControl setNumberOfPages:4];
    }
    return _pageControl;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setTintColor:[UIColor whiteColor]];
        [_doneButton setTitle:@"进入诺食" forState:UIControlStateNormal];
        [_doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
        [_doneButton setBackgroundColor:RgbHex2UIColor(0X2B, 0XDE, 0X3E)];
        [_doneButton addTarget:self action:@selector(gotomain) forControlEvents:UIControlEventTouchUpInside];
        [_doneButton.layer setCornerRadius:CornerRadius];
        _doneButton.layer.masksToBounds = YES;
        [_doneButton setClipsToBounds:YES];
    }
    return _doneButton;
}


- (UIView *)introdFirstView {
    if (!_introdFirstView) {
        _introdFirstView = [[UIView alloc] initWithFrame:_scrollView.bounds];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Introduction-01"]];
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_introdFirstView addSubview:imageView];
        
    }
    
    return _introdFirstView;
}

- (UIView *)introdSecondView {
    if (!_introdSecondView) {
        CGRect rect = CGRectMake(_scrollView.bounds.size.width*1, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
        _introdSecondView = [[UIView alloc] initWithFrame:rect];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Introduction-02"]];
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_introdSecondView addSubview:imageView];
    }
    
    return _introdSecondView;
}

- (UIView *)introdThirdView {
    if (!_introdThirdView) {
        CGRect rect = CGRectMake(_scrollView.bounds.size.width*2, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
        _introdThirdView = [[UIView alloc] initWithFrame:rect];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Introduction-03"]];
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_introdThirdView addSubview:imageView];
        
    }
    
    return _introdThirdView;
}

- (UIView *)introdFourthView {
    if (!_introdFourthView) {
        CGRect rect = CGRectMake(_scrollView.bounds.size.width*3, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
        _introdFourthView = [[UIView alloc] initWithFrame:rect];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduction-04"]];
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_introdFourthView addSubview:imageView];
    }
    
    return _introdFourthView;
}


#pragma mark -
- (void)gotomain {
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate restoreRootViewController:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(self.view.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
