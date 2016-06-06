//
//  NRRecordDinnerCell.m
//  Nourish
//
//  Created by gtc on 15/2/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordDinnerCell.h"
#import "NREnergyElementModel.h"
#import "NRFoodEnergyCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+RandomColor.h"

const CGFloat kCellFontSize = 11;

#define YellowColor RgbHex2UIColor(0xfe, 0xff, 0x03)

@interface NRRecordDinnerCell ()
{
    UIView *_maskView;
    UIView *_leftContainerView;
    UILabel *_foodNamesLabel;
    UIImageView *iconImg;
    UILabel *timeLabel;
    UILabel *nameLabel;
    UILabel *tipsLabel;
    UIImageView *pointImgv;
    CGFloat _height;
}

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *downMaskView;
@property (nonatomic, strong) NRFoodEnergyCell *fieldViewCell;

@end

@implementation NRRecordDinnerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier subTableTag:(NSInteger)tag
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _height = 150;
        
        self.imgv = [[UIImageView alloc] init];
        self.imgv.contentMode = UIViewContentModeScaleAspectFill;
        self.imgv.clipsToBounds = YES;
        [self.contentView addSubview:_imgv];
        
        self.maskView =  [[UIView alloc] init];
        self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.maskView.frame = self.contentView.bounds;
        
        self.downMaskView = [[UIView alloc] init];
        self.downMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.downMaskView.frame = CGRectMake(0, 150, self.contentView.bounds.size.width, _height);
        
        [self.contentView addSubview:self.maskView];
        [self.contentView addSubview:self.downMaskView];
        
        self.fieldViewCell = [[NRFoodEnergyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        self.fieldViewCell.frame = CGRectMake(15, 0, 85, _height);
        self.fieldViewCell.reliangLabel.text = @"热量(kcal)";
        self.fieldViewCell.reliangLabel.textColor = [UIColor whiteColor];
        self.fieldViewCell.reliangLabel.shadowColor = [UIColor blackColor];
        self.fieldViewCell.reliangLabel.shadowOffset = CGSizeMake(0,1);
        
        self.fieldViewCell.zhifangLabel.text = @"脂肪(g)";
        self.fieldViewCell.zhifangLabel.textColor = [UIColor whiteColor];
        self.fieldViewCell.zhifangLabel.shadowColor = [UIColor blackColor];
        self.fieldViewCell.zhifangLabel.shadowOffset = CGSizeMake(0,1);
        
        self.fieldViewCell.danbaizhiLabel.text = @"蛋白质(g)";
        self.fieldViewCell.danbaizhiLabel.textColor = [UIColor whiteColor];
        self.fieldViewCell.danbaizhiLabel.shadowColor = [UIColor blackColor];
        self.fieldViewCell.danbaizhiLabel.shadowOffset = CGSizeMake(0,1);
        
        self.fieldViewCell.huahewuLabel.text = @"碳水化合物(g)";
        self.fieldViewCell.huahewuLabel.textColor = [UIColor whiteColor];
        self.fieldViewCell.huahewuLabel.shadowColor = [UIColor blackColor];
        self.fieldViewCell.huahewuLabel.shadowOffset = CGSizeMake(0,1);
        
        self.fieldViewCell.xianweisuLabel.text = @"纤维素(g)";
        self.fieldViewCell.xianweisuLabel.textColor = [UIColor whiteColor];
        self.fieldViewCell.xianweisuLabel.shadowColor = [UIColor blackColor];
        self.fieldViewCell.xianweisuLabel.shadowOffset = CGSizeMake(0,1);
        
        [self.downMaskView addSubview:self.fieldViewCell];
        
        // 能量表table
        self.scrollView.frame = CGRectMake(100, 0, SCREEN_WIDTH-115, _height);
        [self.downMaskView addSubview:self.scrollView];
        self.scrollView.tag = tag;
        [self.downMaskView setHidden:YES];
        
        // mask subviews
        _foodNamesLabel = [[UILabel alloc] init];
        iconImg = [[UIImageView alloc] init];
        timeLabel = [UILabel new];
        nameLabel = [UILabel new];
        tipsLabel = [UILabel new];
        pointImgv = [[UIImageView alloc] init];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imgv.frame = self.contentView.bounds;
    self.maskView.frame = self.contentView.bounds;
    self.downMaskView.frame = CGRectMake(0, 150, self.contentView.bounds.size.width, 150);
}

- (void)addViews;
{
    //---展开
    self.imgv.image =  self.model.bigImage;
    self.downMaskView.frame =  CGRectMake(0, 150, self.contentView.bounds.size.width, 150);
    [self.maskView setHidden:YES];
    [self.downMaskView setHidden:NO];
    
    [self layoutIfNeeded];
}

- (void)removeViews
{
    //---折叠
    self.imgv.image =  self.model.smallImage;
    self.maskView.frame = self.contentView.bounds;
    [self.downMaskView setHidden:YES];
    [self.maskView setHidden:NO];
    
    [self layoutIfNeeded];
}

- (void)setModel:(NRRecordDetailModel *)model {
    _model = model;
    __weak typeof(self) weakSelf = self;
    
    if (!_model.isLoad) {
        NSURL *imageUrl = [NSURL URLWithString:_model.setmealImageUrl];
        self.imgv.image = [UIImage imageNamed:DefaultImageName];
        [self.imgv sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:DefaultImageName] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            _model.isLoad = YES;
            _model.bigImage = image;
            
            NSLog(@"height = %f, %f", image.size.height, SCREEN_WIDTH);
            int scale = 2;
            if (SCREEN_WIDTH >400) {
                scale  = 3;
                _height = 100;
            }
            
            CGFloat rate = _height/image.size.height;
            CGFloat y = (image.size.height - _height)/2;
            CGImageRef cgimage = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, y*scale, image.size.width*scale, image.size.height*scale*rate));
            
            _model.smallImage = [UIImage imageWithCGImage:cgimage];
            weakSelf.imgv.image = _model.isExpanded ? _model.bigImage : _model.smallImage;
        }];
    }
    else {
        weakSelf.imgv.image = _model.isExpanded ? _model.bigImage : _model.smallImage;
    }
    
    [self setupContent];
    [self setupScrollViewContent];
}


- (void)setupContent {
    UIImage *image  = nil;
    NSString *dinnerName = nil;
    switch (self.model.dinnerType) {
        case DinnerTypeZao:
            image = [UIImage imageNamed:@"record-zaocan"];
            dinnerName = @"早  餐";
            break;
        case DinnerTypeWu:
            image = [UIImage imageNamed:@"record-wucan"];
            dinnerName = @"午  餐";
            break;
        case DinnerTypeCha:
            image = [UIImage imageNamed:@"record-xiawucha"];
            dinnerName = @"下午茶";
        default:
            break;
    }
    
    if (_leftContainerView) {
        _leftContainerView = nil;
        [_leftContainerView removeFromSuperview];
    }
    
    _leftContainerView = [[UIView alloc] init];
    [self.maskView addSubview:_leftContainerView];
    [_leftContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.width.equalTo(@80);
        make.height.equalTo(@35);
        make.centerY.equalTo(self.centerY);
    }];
    
    iconImg.image = image;
    [_leftContainerView addSubview:iconImg];
    [iconImg makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.width.and.height.equalTo(31);
        make.centerY.equalTo(_leftContainerView.centerY);
    }];
    
    timeLabel.textColor = YellowColor;
    timeLabel.font = SysFont(13);
    timeLabel.text = self.model.distributionTime;
    [_leftContainerView addSubview:timeLabel];
    [timeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(iconImg.mas_right).offset(5);
        make.height.equalTo(@14);
    }];
    
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = SysFont(15);
    nameLabel.text = dinnerName;
    [_leftContainerView addSubview:nameLabel];
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel.mas_bottom).offset(5);
        make.left.equalTo(iconImg.mas_right).offset(5);
        make.bottom.equalTo(0);
    }];
    
    _foodNamesLabel.font = SysFont(15);
    _foodNamesLabel.textColor = [UIColor whiteColor];
    _foodNamesLabel.adjustsFontSizeToFitWidth = YES;
    _foodNamesLabel.textAlignment = NSTextAlignmentCenter;
    _foodNamesLabel.text = [[self.model.marrSingleFoodNames valueForKey:@"description"] componentsJoinedByString:@"·"];
    [self.maskView addSubview:_foodNamesLabel];
    [_foodNamesLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftContainerView.mas_right).offset(8);
        make.centerY.equalTo(self.centerY);
        make.height.equalTo(@16);
    }];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.model.warmTips];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:LineSpacing];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.model.warmTips.length)];
    
    tipsLabel.font = SysFont(12);
    tipsLabel.textColor = YellowColor;
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.numberOfLines = 0;
    tipsLabel.attributedText = attributedString;
    tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.maskView addSubview:tipsLabel];
    
    [tipsLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_foodNamesLabel.mas_bottom).offset(10);
        make.left.equalTo(_foodNamesLabel.mas_left);
//        make.bottom.equalTo(_maskView.mas_bottom).offset(-5);
        make.right.equalTo(-10);
    }];
    
    pointImgv.image = [UIImage imageNamed:@"record-dot"];
    [_maskView addSubview:pointImgv];
    [pointImgv makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(tipsLabel.mas_left).offset(-5);
        make.centerY.equalTo(tipsLabel.centerY);
        make.width.equalTo(@7);
        make.height.equalTo(@7);
    }];
}


- (void)setupScrollViewContent {
    for (NRFoodEnergyCell *cell in self.scrollView.subviews) {
        [cell removeFromSuperview];
    }
    
    NSDictionary *attr = @{ NSFontAttributeName: SysFont(14)};
    CGFloat height = self.scrollView.bounds.size.height;
    CGFloat x = 0;
    for (int i = 0; i <self.model.marrEnergyList.count; i++) {
        NRFoodEnergyCell *cell = [[NRFoodEnergyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        NREnergyElementModel *elementMod = [self.model.marrEnergyList objectAtIndex:i];
        CGSize size = [elementMod.elementName sizeWithAttributes:attr];
        if (size.width < 50) {
            size.width = 55;
        }
        
        cell.frame = CGRectMake(x, 0, size.width, height);
        cell.backgroundColor = [UIColor clearColor];
        cell.nameLabel.text = elementMod.elementName;
        cell.reliangLabel.text = elementMod.reliangVal;
        cell.danbaizhiLabel.text = elementMod.danbaizhiVal;
        cell.zhifangLabel.text = elementMod.zhifangVal;
        cell.huahewuLabel.text = elementMod.huahewuVal;
        cell.xianweisuLabel.text = elementMod.qianweisuVal;
        
        x += size.width+10;
        
        [self.scrollView addSubview:cell];
    }
    
    self.scrollView.contentSize = CGSizeMake(x, height);
}

#pragma mark - Controls

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        CGFloat height = 150;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(100, 0, SCREEN_WIDTH-100, height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.scrollsToTop = NO;
    }
    
    return _scrollView;
}


#pragma mark - Override

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
