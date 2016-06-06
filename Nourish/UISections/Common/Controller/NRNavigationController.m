//
//  NRNavigationController.m
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRNavigationController.h"

@implementation NRNavigationController


- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                    [UIFont fontWithName:NRFontName size:FontNavTitleSize], NSFontAttributeName, nil];
        
        [self.navigationBar setTitleTextAttributes:attributes];
        
        //        UIView *bgview =  [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 20)];
        //        bgview.backgroundColor = ColorRed_Normal;
        //        [self.navigationBar addSubview:bgview];
        //        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar-bg"] forBarMetrics:UIBarMetricsDefault];
        //        [self.navigationBar setBackgroundColor:ColorRed_Normal];
        
        if (ISIOS6) {
            self.navigationBar.tintColor = RgbHex2UIColor(0xff, 0x55, 0x00);
        }
        else {
            self.navigationBar.barTintColor = RgbHex2UIColor(0xff, 0x55, 0x00);
        }
        
        self.navigationBar.translucent = NO; //半透明
        
    }
    
    return self;
}


- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer {
    NSLog(@"OUT");
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
