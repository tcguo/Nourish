//
//  NRRecordArticelCell.m
//  Nourish
//
//  Created by tcguo on 15/11/19.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordArticleCell.h"
#import "UIImageView+WebCache.h"

@interface NRRecordArticleCell ()

@property (weak, nonatomic) UIImageView *articleImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) NSMutableParagraphStyle *paragraphStyle;


@end

@implementation NRRecordArticleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupSubView];
    }
    
    return self;
}

- (void)setupSubView {
    UIImageView *imgView = [[UIImageView alloc] init];
    [self.contentView addSubview:imgView];
    _articleImageView = imgView;
    [_articleImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.left.and.right.equalTo(0);
        make.height.equalTo(356/2*self.appdelegate.autoSizeScaleY);
    }];
    
    
    UILabel *tLabel = [[UILabel alloc] init];
    [self.contentView addSubview:tLabel];
    _titleLabel = tLabel;
    _titleLabel.textColor = RgbHex2UIColor(0x33, 0x33, 0x33);
    _titleLabel.font = SysBoldFont(16);
    [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_articleImageView.mas_bottom).offset(12.5);
        make.left.equalTo(13);
        make.right.equalTo(-13);
    }];
    
    UILabel *sLabel = [[UILabel alloc] init];
    [self.contentView addSubview:sLabel];
    _subTitleLabel = sLabel;
    [_subTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.left.equalTo(13);
        make.right.equalTo(-13);
    }];
    
    _subTitleLabel.numberOfLines = 3;
    _subTitleLabel.font = SysFont(12);
    _subTitleLabel.textColor = RgbHex2UIColor(0x99, 0x99, 0x99);
    
}

- (NSMutableParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        _paragraphStyle.lineSpacing = 2.0f;
        _paragraphStyle.minimumLineHeight = 12.0f;
        _paragraphStyle.maximumLineHeight = 0;
        _paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        _paragraphStyle.alignment = NSTextAlignmentLeft;
        _paragraphStyle.lineHeightMultiple = 1.0f;
        //        _paragraphStyle.headIndent = 4.0f;
        _paragraphStyle.firstLineHeadIndent = 30.0f;
    }
    return _paragraphStyle;
}

- (void)setArticleInfo:(NRRecordArticleInfo *)articleInfo {
    _articleInfo = articleInfo;
    NSURL *url = [NSURL URLWithString:_articleInfo.imageUrl];
    [self.articleImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:DefaultImageName] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];

    NSDictionary *attr = @{ NSFontAttributeName: SysFont(12),
                            NSParagraphStyleAttributeName: self.paragraphStyle };
    
    NSAttributedString *attrString  = [[NSAttributedString alloc] initWithString:_articleInfo.subTitle attributes:attr];
    self.titleLabel.text = _articleInfo.title;
    self.subTitleLabel.attributedText = attrString;
}

@end
