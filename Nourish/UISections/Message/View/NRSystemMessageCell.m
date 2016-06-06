//
//  NRSystemMessageCell.m
//  Nourish

//  诺食消息 - 系统消息

//  Created by gtc on 15/7/30.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSystemMessageCell.h"
#import "UIImageView+WebCache.h"

@interface NRSystemMessageCell ()
{
    UILabel *_datetimeLabel;
    UIImageView *_coverImgageView;
    UILabel *_titleLabel;
}

@property (nonatomic, strong) NSMutableParagraphStyle *paragStyle;

@end

@implementation NRSystemMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //布局
        _datetimeLabel = [UILabel new];
        _datetimeLabel.font = SysFont(12);
        _datetimeLabel.textColor = ColorBaseFont;
        _datetimeLabel.text = self.model.date;
        [self.contentView addSubview:_datetimeLabel];
        [_datetimeLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.height.equalTo(15);
            make.top.equalTo(10);
        }];
        
        UIView *detailContainerView = [UIView new];
        detailContainerView.layer.cornerRadius = 0.5;
        detailContainerView.layer.masksToBounds = YES;
        detailContainerView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:detailContainerView];
        [detailContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_datetimeLabel.mas_bottom).offset(@(10));
            make.left.equalTo(self.contentView.mas_left).offset(@13);
            make.right.equalTo(self.contentView.mas_right).offset(-13);
            make.height.equalTo(131);
        }];
        
        UIView *upContainerView = [UIView new];
        [detailContainerView addSubview:upContainerView];
        [upContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(@0);
            make.height.equalTo(101);
        }];
        
        _coverImgageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weekplan"]];
        _coverImgageView.layer.cornerRadius = CornerRadius-1;
        _coverImgageView.layer.masksToBounds = YES;
        [upContainerView addSubview:_coverImgageView];
        [_coverImgageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(upContainerView.centerY);
            make.left.equalTo(12);
            make.height.equalTo(75);
            make.width.equalTo(135);
        }];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = SysFont(14);
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = ColorBaseFont;;
        _titleLabel.text = self.model.title;
        [upContainerView addSubview:_titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(upContainerView.mas_centerY);
            make.left.equalTo(_coverImgageView.mas_right).offset(12);
            make.right.equalTo(upContainerView.mas_right).offset(-10);
        }];
        
        UILabel *lineView = [UILabel new];
        lineView.backgroundColor = ColorGragBorder;
        [upContainerView addSubview:lineView];
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(0);
            make.height.equalTo(0.5);
            make.left.equalTo(@12);
            make.right.equalTo(-12);
        }];
        
        UIView *downContainerView = [UIView new];
        [detailContainerView addSubview:downContainerView];
        [downContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom).offset(2);
            make.bottom.and.left.and.right.equalTo(@0);
        }];
        
        UILabel *lookLabel = [UILabel new];
        lookLabel.font  = SysFont(13);
        lookLabel.textColor = ColorBaseFont;
        lookLabel.text = @"查看详情";
        [downContainerView addSubview:lookLabel];
        [lookLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.centerY.equalTo(downContainerView.centerY);
            make.height.equalTo(13);
        }];
        
        UIImageView *directionImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-commentmore"]];
        [downContainerView addSubview:directionImgv];
        [directionImgv makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(downContainerView.mas_centerY);
            make.right.equalTo(-12);
            make.width.equalTo(8);
            make.height.equalTo(13);
        }];
    }
    
    return self;
}

- (void)setModel:(NRSystemMessageModel *)model {
    _model = model;
    _datetimeLabel.text = _model.date;
   
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_model.title];;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:self.paragStyle range:NSMakeRange(0, _model.title.length)];
    _titleLabel.attributedText = attributedString;
    UIImage *defaultImge = [UIImage imageNamed:DefaultImageName];
    [_coverImgageView sd_setImageWithURL:[NSURL URLWithString:model.linkUrl] placeholderImage:defaultImge];
}

- (NSMutableParagraphStyle *)paragStyle {
    if (!_paragStyle) {
        _paragStyle = [[NSMutableParagraphStyle alloc] init];
        _paragStyle.lineSpacing = LineSpacing;
        _paragStyle.lineBreakMode = NSLineBreakByWordWrapping;
        _paragStyle.alignment = NSTextAlignmentLeft;
    }
    
    return _paragStyle;
}

@end
