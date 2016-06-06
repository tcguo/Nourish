//
//  NRTableViewBaseCell.m
//  Nourish
//
//  Created by gtc on 15/8/11.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRTableViewBaseCell.h"

@implementation NRTableViewBaseCell

- (id)init
{
    if (self = [super init]) {
        self.appdelegate = AppDelegateInstance;
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.appdelegate = AppDelegateInstance;
    }
    return self;
}

@end
