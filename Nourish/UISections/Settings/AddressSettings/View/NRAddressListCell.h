//
//  NRAddressListCell.h
//  Nourish
//
//  Created by gtc on 15/3/6.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRAddressListCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *phoneLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *accessoryButton;
@property (assign, nonatomic) BOOL available;

@end
