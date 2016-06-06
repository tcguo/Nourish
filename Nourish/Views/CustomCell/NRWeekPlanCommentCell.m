//
//  NRWeekPlanCommentCell.m
//  Nourish
//
//  Created by gtc on 15/1/23.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanCommentCell.h"
#import "UIImageView+AFNetworking.h"

@interface NRWeekPlanCommentCell ()
{
    UIImageView *_lineView;
}

@property (nonatomic, readwrite, strong) UIImageView *imgAvatar;
@property (nonatomic, readwrite, strong) UILabel *lblNickName;
@property (nonatomic, readwrite, strong) UILabel *lblComment;
@property (nonatomic, readwrite, strong) UILabel *lblDate;
@property (nonatomic, strong) UIView *padView;
@property (nonatomic, readwrite, strong) UIImageView *lineView;

@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

@end

@implementation NRWeekPlanCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    self.padView = [[UIView alloc] init];
    [self.contentView addSubview:_padView];
    
    self.padView.backgroundColor = [UIColor yellowColor];
    self.imgAvatar = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.padView addSubview:_imgAvatar];
    
    [self.padView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    
    self.lblDate = [[UILabel alloc] init];
    self.lblDate.font = NRFont(14);
    self.lblDate.textColor = RgbHex2UIColor(0xa9, 0xa9, 0xa9);
    [self.padView addSubview:self.lblDate];
    
    self.lblNickName = [[UILabel alloc] init];
    self.lblNickName.font = NRFont(15);
    self.lblNickName.textColor = RgbHex2UIColor(0x09, 0xaa, 0x5d);
    [self.padView addSubview:_lblNickName];
    
    self.lblComment = [[UILabel alloc] init];
    self.lblComment.font = NRFont(14);
    self.lblComment.textColor = RgbHex2UIColor(0x64, 0x64, 0x64);
    self.lblComment.numberOfLines = 0;
    self.lblComment.textAlignment = NSTextAlignmentLeft;
    [self.padView addSubview:_lblComment];
    
    [self.imgAvatar makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(30);
        make.height.equalTo(30);
        make.top.equalTo(self.padView.mas_top);
        make.left.equalTo(self.padView.mas_left);
    }];

    [self.lblDate updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.padView.mas_right);
        make.height.equalTo(14);
        make.top.equalTo(self.padView.mas_top).offset(8);
    }];
    
    [self.lblNickName updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgAvatar.mas_right).offset(5);
        make.height.equalTo(15);
        make.top.equalTo(self.padView.mas_top).offset(7);
    }];
    
    [self.lblComment updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgAvatar.mas_right);
        make.top.equalTo(self.imgAvatar.mas_bottom);
        make.right.equalTo(self.padView.mas_right);
    }];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.padView updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];

    self.imgAvatar.layer.masksToBounds = YES;
    self.imgAvatar.layer.cornerRadius = self.imgAvatar.bounds.size.width/2;
}

- (NSMutableParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        _paragraphStyle.lineSpacing = 5.0f;
        _paragraphStyle.minimumLineHeight = 14.0f;
        _paragraphStyle.maximumLineHeight = 14.0f;
        _paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        _paragraphStyle.alignment = NSTextAlignmentLeft;
        _paragraphStyle.lineHeightMultiple = 1.0f;
        //        _paragraphStyle.headIndent = 4.0f;
        _paragraphStyle.firstLineHeadIndent = 24.0f;
    }
    return _paragraphStyle;
}

- (void)setCommentMod:(NRComment *)commentMod {
    _commentMod = commentMod;
    self.lblNickName.text = _commentMod.nickname;
    self.lblDate.text = _commentMod.datetime;
    
//    self.lblNickName.text = @"晴天里的小猪猪";
//    self.lblDate.text = @"2015-11-28";
//    _commentMod.comment = @"今天吃的真不错今天吃的真不错今天吃的真不错今天吃的真不错今天吃的真不错，今天吃的真不错今天吃的真不错，今天吃的真不错，今天吃的真不错，今天吃的真不错，今天吃的真不错，今天吃的真不错，今天吃的真不错。";
    
    NSURL *url = [NSURL URLWithString:_commentMod.avatarsurl];
    [self.imgAvatar setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    NSDictionary *attr = @{ NSFontAttributeName: SysFont(14),
                            NSParagraphStyleAttributeName: self.paragraphStyle};
    
    CGSize size = [_commentMod.comment sizeWithAttributes:attr];
    CGFloat wid = self.contentView.bounds.size.width;
    long int rowNum = ceil(ceil(size.width)/(wid-20));
    
    CGFloat height = 40+rowNum*14 +(rowNum-1)*5.0 +20;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, wid, height);
    [self layoutIfNeeded];
   
    
    NSMutableAttributedString *attrComment = [[NSMutableAttributedString alloc] initWithString:_commentMod.comment attributes:attr];
    
    self.lblComment.attributedText  = attrComment;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
