//
//  NRShareActivityViewCell.m
//  Nourish
//
//  Created by tcguo on 15/12/14.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRShareActivityViewCell.h"

@implementation NRShareActivityViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width-20, 50)];
        [self.contentView addSubview:_imageView];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 55, 60, 15)];
        _titleLabel.font = SysFont(12);
        _titleLabel.textColor = ColorBaseFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    
    return self;
}

@end
