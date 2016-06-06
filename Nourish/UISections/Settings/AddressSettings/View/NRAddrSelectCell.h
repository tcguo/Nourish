//
//  NRAddrSelectCell.h
//  Nourish
//
//  Created by tcguo on 15/9/15.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRTableViewBaseCell.h"

@interface NRAddrSelectCell : NRTableViewBaseCell

@property (nonatomic, strong) UITextField *textField;
//@property (nonatomic, strong) UITextView *textview;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *iconImgView;

@end
