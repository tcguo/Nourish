//
//  NRAddrWriteCell.h
//  Nourish
//
//  Created by gtc on 15/4/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRAddrWriteCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *textview;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)resignFirstResponderByCell;
- (void)relayoutSubviews;
@end
