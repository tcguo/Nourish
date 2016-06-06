//
//  HRTableViewCell.m
//  HRVTableView
//
//  Created by gtc on 15/6/2.
//  Copyright (c) 2015年 Hamidreza Vakilian. All rights reserved.
//

#import "HRTableViewCell.h"


@interface HRTableViewCell ()
{
    
}
@property (nonatomic, strong) UIImage *halfBgImage;

@end

@implementation HRTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgImage = [UIImage imageNamed:@"weekplan"];
        self.imgv = [[UIImageView alloc] init];
        self.imgv.contentMode = UIViewContentModeScaleToFill;
        self.imgv.frame  = CGRectMake(0, 10, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [self.contentView addSubview:self.imgv];
        
        CGFloat rate = CGRectGetHeight(self.imgv.frame)/self.bgImage.size.height*2;
        CGFloat y = ( self.bgImage.size.height - CGRectGetHeight(self.imgv.frame))/2;
        
        CGImageRef cgimage = CGImageCreateWithImageInRect([self.bgImage CGImage], CGRectMake(0, y,  self.bgImage.size.width*2,  self.bgImage.size.height*2 * rate));
        
        //        CGImageRef cgimage = CGImageCreateWithImageInRect([self.bgImage CGImage], CGRectMake(0, 30, self.bgImage.size.width*2 , self.bgImage.size.height *2 * 0.3));
        
        self.halfBgImage = [UIImage imageWithCGImage:cgimage];
        self.imgv.image = self.halfBgImage;
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imgv.frame = self.contentView.bounds;
}

- (void)addViews;
{
    self.imgv.image = self.bgImage;
}

- (void)removeViews
{
    self.imgv.image = self.halfBgImage;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
