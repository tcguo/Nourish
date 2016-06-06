//
//  NRWeekPlanCommentListCell.m
//  Nourish
//
//  Created by tcguo on 15/11/4.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanCommentListCell.h"
#import <CoreText/CoreText.h>
#import "UIImageView+WebCache.h"

@interface NRWeekPlanCommentListCell ()
{
    UIImageView *_avatarImageView;
    UILabel *_nickNameLabel;
    UILabel *_commentLabel;
    UILabel *_dateLabel;
    UIView *_separatorLineView;
}

@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

@end

@implementation NRWeekPlanCommentListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUserControls];
    }
    return self;
}

- (void)setupUserControls {
    UIView *userView = [[UIView alloc] init];
    [self.contentView addSubview:userView];
    [userView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(10);
        make.left.equalTo(15);
        make.right.equalTo(-15);
        make.height.equalTo(28);
    }];
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [userView addSubview:_avatarImageView];
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.layer.cornerRadius = _avatarImageView.bounds.size.width/2;
    
    _nickNameLabel = [[UILabel alloc] init];
    _nickNameLabel.textColor = RgbHex2UIColor(0X34, 0X34, 0X34);
    _nickNameLabel.font = SysBoldFont(15);
    [userView addSubview:_nickNameLabel];
    [_nickNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_avatarImageView.centerY);
        make.left.equalTo(_avatarImageView.mas_right).offset(10);
        make.height.equalTo(16);
    }];
    
    _dateLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_dateLabel];
    _dateLabel.font = SysFont(12);
    _dateLabel.textColor = RgbHex2UIColor(0xb6, 0xb6, 0xb6);
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nickNameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-12);
        make.height.equalTo(12);
    }];
    
    _commentLabel = [[UILabel alloc] init];
    _commentLabel.numberOfLines = 0;
    [self.contentView addSubview:_commentLabel];
    _commentLabel.textColor = RgbHex2UIColor(0x55, 0x55, 0x55);
    _commentLabel.font = SysFont(14);
    [_commentLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nickNameLabel.mas_left);
        make.top.equalTo(_nickNameLabel.mas_bottom).offset(17);
        make.width.equalTo(SCREEN_WIDTH - 135/2);
    }];
    
    _separatorLineView = [[UIView alloc] init];
    _separatorLineView.backgroundColor = ColorGrayBg;
    [self.contentView addSubview:_separatorLineView];
    [_separatorLineView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(15);
        make.right.equalTo(-15);
        make.top.equalTo(_dateLabel.mas_bottom).offset(12);
        make.height.equalTo(1);
    }];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [_commentLabel updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nickNameLabel.mas_bottom).offset(17);
        make.left.equalTo(_nickNameLabel.mas_left);
        make.width.equalTo(SCREEN_WIDTH - 135/2);
    }];
}

- (NSMutableParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        _paragraphStyle.lineSpacing = 7.0f;
        _paragraphStyle.minimumLineHeight = 14.0f;
        _paragraphStyle.maximumLineHeight = 0;
        _paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        _paragraphStyle.alignment = NSTextAlignmentLeft;
        _paragraphStyle.lineHeightMultiple = 1.0f;
        _paragraphStyle.firstLineHeadIndent = 30.0f;
    }
    return _paragraphStyle;
}

- (void)setModel:(NRWeekPlanCommentListModel *)model {
    _model = model;
    
    NSURL *url = [NSURL URLWithString:_model.avatarUrl];
    [_avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:DefaultImageName_Avatar] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    _nickNameLabel.text = _model.nickName;
    _dateLabel.text = [NSString stringWithFormat:@"%@ 执行第%@周 套餐：%@/天", _model.dateTime, _model.weekth, _model.price];
    
    NSString *tmpcomment = _model.comment;
//    tmpcomment = @"今天吃的真心不错的今天吃的真心不错的今天吃的真心不错的今天吃的真心不错的今天吃的真心不错的今天吃的真心不错的";
    long number = 0.8f;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    NSDictionary *attr = @{ NSFontAttributeName: SysFont(14),
                            NSParagraphStyleAttributeName: self.paragraphStyle,
                            (id)kCTKernAttributeName: (__bridge id)num};
    
    CGSize size = [tmpcomment sizeWithAttributes:attr];
    long int rowNum = ceil(ceil(size.width)/(SCREEN_WIDTH - 135/2));
    CGFloat height = (20+54+30+30+24+26)/2+rowNum*14 +rowNum*7.0;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
    NSMutableAttributedString *attrComment = [[NSMutableAttributedString alloc] initWithString:tmpcomment attributes:attr];

    CFRelease(num);
    _commentLabel.attributedText = attrComment;
    
}


@end

@implementation NRWeekPlanCommentListModel


@end
