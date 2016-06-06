//
//  NRRecordUserView.m
//  Nourish
//
//  Created by gtc on 8/24/15.
//  Copyright (c) 2015 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordHeaderView.h"
#import "UIImageView+WebCache.h"

static NSInteger tagForVaue = 200;
static NSInteger tagForTitle = 100;

@interface NRRecordHeaderView ()
{
    UIImageView *_avatarImgv;
    UILabel *_lblUserNickName;
    UILabel *_lblUserWarn;
    UILabel *_lblTheme;
    
    UIView *_yundongView;
    UIView *_tuijianView;
    UIView *_nuoshiProvieView;
    UIView *_needView;
    
    UIView *_tableHeaderView;
    UIView *pickerContainerView;
    UIView *energyContainerView;
    UIView *_lineThreeView;
}

@property (nonatomic, strong) UIView *nuoshiProvieView;
@property (nonatomic, strong) UIView *needView;

@end


@implementation NRRecordHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _tableHeaderView = [[UIView alloc] init];
    _tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height);
    [self addSubview:_tableHeaderView];
    
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 48)];
    [_tableHeaderView addSubview:userView];
    
    _avatarImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:DefaultImageName_Avatar]];
    _avatarImgv.contentMode = UIViewContentModeScaleAspectFit;
    [userView addSubview:_avatarImgv];
    _avatarImgv.frame = CGRectMake(20, 5, 38, 38);
    _avatarImgv.layer.cornerRadius = _avatarImgv.bounds.size.width/2;
    _avatarImgv.layer.masksToBounds = YES;
    
    _lblUserNickName = [[UILabel alloc] init];
    [userView addSubview:_lblUserNickName];
    _lblUserNickName.textColor = ColorBaseFont;
    _lblUserNickName.font = SysFont(15);
    [_lblUserNickName makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatarImgv.mas_right).offset(5);
        make.centerY.equalTo(userView.centerY);
    }];
    
    _lblUserWarn = [[UILabel alloc] init];
    [userView addSubview:_lblUserWarn];
    _lblUserWarn.textColor = ColorRed_Normal;
    _lblUserWarn.font = SysFont(15);
    [_lblUserWarn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(userView.mas_right).offset(-20);
        make.centerY.equalTo(userView.centerY);
    }];
    
    UIView *lineOneView = [self createLineView];
    lineOneView.frame = CGRectMake(0, userView.frame.origin.y+userView.frame.size.height, lineOneView.bounds.size.width, lineOneView.bounds.size.height);
    [_tableHeaderView addSubview:lineOneView];
    
    //订单日历
    CGFloat yDate = lineOneView.frame.origin.y + lineOneView.frame.size.height;
    pickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, yDate, self.bounds.size.width, 100)];
    pickerContainerView.backgroundColor = [UIColor clearColor];
    [_tableHeaderView addSubview:pickerContainerView];
    
    _lblTheme = [[UILabel alloc] init];
    [pickerContainerView addSubview:_lblTheme];
    _lblTheme.textColor = RgbHex2UIColor(0xff, 0x85, 0x00);
    _lblTheme.font = SysFont(15);
    [_lblTheme updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pickerContainerView.mas_bottom).offset(-23);
        make.centerX.equalTo(pickerContainerView.centerX);
        make.height.equalTo(15);
    }];
    
    UIView *lineTwoView = [self createLineView];
    lineTwoView.frame = CGRectMake(0, pickerContainerView.frame.size.height-0.5, lineTwoView.bounds.size.width, lineTwoView.bounds.size.height);
    [pickerContainerView addSubview:lineTwoView];
}

- (void)setupEnergyView {
    [energyContainerView removeFromSuperview];
    
    // 能量
    CGFloat yEnergy = pickerContainerView.frame.origin.y + pickerContainerView.frame.size.height + 11;
    energyContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, yEnergy, self.bounds.size.width, 83)];
    [_tableHeaderView addSubview:energyContainerView];
    
    [energyContainerView addSubview:self.progressView];
    CGFloat x= (self.bounds.size.width - 158)/2;
    self.progressView.frame = CGRectMake(x, -5, 158, energyContainerView.frame.size.height+5);

    UIView *leftContainerView = [UIView new];
    [energyContainerView addSubview:leftContainerView];
    [leftContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.equalTo(0);
        make.right.equalTo(self.progressView.mas_left).offset(-5);
    }];
    
    _yundongView = [self createKCalViewWithTitle:@"运动量" imageName:@"record-shoes" tips:@"10000步/天" direction:UIInterfaceOrientationLandscapeRight];
    
    [leftContainerView addSubview:_yundongView];
    [_yundongView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@25);
        make.right.equalTo(leftContainerView.mas_right);
        make.left.equalTo(leftContainerView.mas_left);
        make.bottom.equalTo(leftContainerView.mas_bottom);
    }];
    
    // 减脂推荐
    UIView *rightContainerView = [UIView new];
    [energyContainerView addSubview:rightContainerView];
    [rightContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.and.bottom.equalTo(0);
        make.left.equalTo(self.progressView.mas_right).offset(5);
    }];
    
    CGFloat totalNeed = [self calculateRequireKCAL:self.userMod];
    NSString *tjTitle = [self getTuijianDesc:self.userMod];
    NSString *tjValue = [NSString stringWithFormat:@"%lukcal", (unsigned long)totalNeed];
    if (!_tuijianView) {
        _tuijianView = [self createKCalViewWithTitle:tjTitle imageName:@"record-zhifang" tips:tjValue direction:UIInterfaceOrientationLandscapeLeft];
    }
    UILabel *tjTitleLabel = [_tuijianView viewWithTag:tagForTitle];
    tjTitleLabel.text = tjTitle;
    UILabel *tjValueLabel = [_tuijianView viewWithTag:tagForVaue];
    tjValueLabel.text = tjValue;
   
    
    [rightContainerView addSubview:_tuijianView];
    [_tuijianView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@25);
        make.right.equalTo(rightContainerView.mas_right);
        make.left.equalTo(rightContainerView.mas_left);
        make.bottom.equalTo(rightContainerView.mas_bottom);
    }];
    
    UIView *vLine = [[UIView alloc] init];
    [energyContainerView addSubview:vLine];
    vLine.backgroundColor = RgbHex2UIColor(0xd2, 0xd2, 0xd2);
    [vLine makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@25);
        make.centerX.equalTo(energyContainerView.centerX);
        make.width.equalTo(@0.5);
        make.bottom.equalTo(energyContainerView.mas_bottom).offset(-5);
    }];
    
    NSString *pValue = [NSString stringWithFormat:@"%ldkcal", self.dayMod.nrProvide];
    if (!self.nuoshiProvieView) {
        _nuoshiProvieView = [self createKCalViewWithTitle:@"诺食提供" imageName:@"record-tianping" tips:pValue direction:UIInterfaceOrientationLandscapeRight];
    }
    UILabel *proLabel = [_nuoshiProvieView viewWithTag:tagForVaue];
    proLabel.text = pValue;
    
    [energyContainerView addSubview:_nuoshiProvieView];
    [_nuoshiProvieView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(energyContainerView.mas_top).offset(25);
        make.right.equalTo(vLine.mas_left).offset(-5);
//        make.left.equalTo(self.progressView.mas_left);
        make.bottom.equalTo(energyContainerView.mas_bottom).with.offset(-5);
    }];
    
    CGFloat need = totalNeed - self.dayMod.nrProvide;
    NSString *needVal = [NSString stringWithFormat:@"%lukcal", (unsigned long)need];
    
    if (!self.needView) {
        _needView = [self createKCalViewWithTitle:@"还可摄入" imageName:@"record-fire" tips:needVal direction:UIInterfaceOrientationLandscapeLeft];
    }
    UILabel *needLabel = [_needView viewWithTag:tagForVaue];
    needLabel.text = needVal;
    
    [energyContainerView addSubview:_needView];
    [_needView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@25);
        make.left.equalTo(vLine.mas_right).offset(5);
//        make.right.equalTo(energyContainerView.mas_right);
        make.bottom.equalTo(self.progressView.mas_bottom).with.offset(-5);
    }];
    
    if (need <= 0) {
        self.progressView.progress = 180;
    }
    else {
        self.progressView.progress = self.dayMod.nrProvide *180/totalNeed;
    }
}

- (KACircleProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[KACircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 158, 83)];
        _progressView.trackColor =  RgbHex2UIColor(0XE1, 0XE1, 0XE1);
        _progressView.progressColor = RgbHex2UIColor(0XFD, 0X6F, 0X57);
        _progressView.progressWidth = 12;
    }
    
    return _progressView;
}


#pragma mark - Public methods
- (void)setUserMod:(NRUserInfoModel *)userMod {
    _userMod = userMod;
    _lblUserNickName.text = _userMod.nickName;
    _lblUserWarn.text = [self getBMIDesc:_userMod];
    
    if (STRINGHASVALUE(_userMod.avatarurl)) {
        NSURL *avatarUrl = [NSURL URLWithString:_userMod.avatarurl];
        [_avatarImgv sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:DefaultImageName_Avatar] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }else {
        _avatarImgv.image = [UIImage imageNamed:DefaultImageName_Avatar];
    }
}

- (void)setDayMod:(NRRecordDayInfo *)dayMod {
    _dayMod = dayMod;
    
    if (!_dayMod) {
        _lblTheme.text = @"今天没预定，随便看看吧";
        [energyContainerView removeFromSuperview];
    }
    else {
        [self setupEnergyView];
        _lblTheme.text = [NSString stringWithFormat: @"%luth %@", (unsigned long)self.dayMod.dayth, self.dayMod.themeName];
    }
}

- (void)setDayPicker:(MZDayPicker *)dayPicker {
    _dayPicker = dayPicker;
    [pickerContainerView addSubview:_dayPicker];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_avatarImgv) {
        _avatarImgv.layer.masksToBounds = YES;
        _avatarImgv.layer.cornerRadius = _avatarImgv.bounds.size.width/2;
    }
}

#pragma mark - private methods

- (UIView *)createLineView
{
    UIView *lineView = [UIView new];
    lineView.frame = CGRectMake(0, 0, self.bounds.size.width, 0.5);
    lineView.backgroundColor = RgbHex2UIColor(0xd2, 0xd2, 0xd2);
    
    return lineView;
}

- (UIView *)createKCalViewWithTitle:(NSString *)title
                          imageName:(NSString *)name
                               tips:(NSString *)tips
                          direction:(UIInterfaceOrientation)dire
{
    UIView *containerView = [[UIView alloc] init];
    int titleFontSize = 14;
    int tipFontSize = 12;
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    [containerView addSubview:imgView];
    
    UILabel *titleLabel = [UILabel new];
    [containerView addSubview:titleLabel];
    titleLabel.text = title;
    titleLabel.font = SysFont(titleFontSize);
    titleLabel.textColor = ColorRed_Normal;
    titleLabel.tag = tagForTitle;
    
    UILabel *tipsLabel = [UILabel new];
    [containerView addSubview:tipsLabel];
    tipsLabel.text = tips;
    tipsLabel.font = SysFont(tipFontSize);
    tipsLabel.textColor = RgbHex2UIColor(0x96, 0x96, 0x96);
    tipsLabel.tag = tagForVaue;
    
    if (dire == UIInterfaceOrientationLandscapeLeft) {
        [imgView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.top.equalTo(0);
            make.height.equalTo(@18);
            make.width.equalTo(@17);
        }];
        
        [titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imgView.mas_bottom).offset(5);
            make.left.equalTo(0);
            make.height.equalTo(titleFontSize);
        }];
        
        [tipsLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.top.equalTo(titleLabel.mas_bottom).offset(5);
            make.height.equalTo(tipFontSize);
        }];
    }
    else if (dire == UIInterfaceOrientationLandscapeRight) {
        [imgView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(0);
            make.top.equalTo(0);
            make.height.equalTo(@18);
            make.width.equalTo(@17);
        }];
        
        [titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imgView.mas_bottom).offset(5);
            make.right.equalTo(0);
            make.height.equalTo(titleFontSize);
        }];
        
        [tipsLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(5);
            make.right.equalTo(0);
            make.height.equalTo(tipFontSize);
        }];
    }
    
    return containerView;
}

#pragma mark - helper

- (NSString *)getBMIDesc:(NRUserInfoModel *)userInfo {
    float bmi = [self calculateBMI:userInfo];
    if (bmi < 18.5) {
        return @"偏轻";
    }
    else if ( bmi >= 18.5 && bmi < 24) {
        return @"正常";
    }
    else if (bmi > 24) {
        return @"超重";
    }
    
    return @"";
}

- (NSString *)getTuijianDesc:(NRUserInfoModel *)userInfo {
    float bmi = [self calculateBMI:userInfo];
    if (bmi < 18.5) {
        return @"增重推荐";
    }
    else if ( bmi >= 18.5 && bmi < 24) {
        return @"平衡推荐";
    }
    else if (bmi > 24) {
        return @"减脂推荐";
    }
    
    return @"";
}

- (float)calculateBMI:(NRUserInfoModel *)userInfo {
    //BMI <18.5 偏瘦，  18.5 <= bmi <24 正常 ; bmi>24 超重
    CGFloat heightM = (float)userInfo.height/(float)100 ;
    CGFloat bmi = userInfo.weight/(heightM*heightM);
    return bmi;
}

- (float)calculateBMR:(NRUserInfoModel *)userInfo {
    //基础代谢量
    float retVal = 0;
    
    if(userInfo.gender == GenderTypeMale) {
        retVal = 13.7*userInfo.weight + 5.0*userInfo.height - 6.8*userInfo.age + 66;
    }
    
    if (userInfo.gender == GenderTypeFemale) {
        retVal =  9.6*userInfo.weight + 1.8*userInfo.height - 4.7*userInfo.age + 655;
    }
    
    return retVal;
}

- (CGFloat)calculateREE:(NRUserInfoModel *)userInfo {
    //平衡热量摄入
    return [self calculateBMR:userInfo] * 1.3;
}

- (CGFloat)calculateHKC:(NRUserInfoModel *)userInfo {
    //增重热量摄入
    return userInfo.weight * 24 * 1.3;
}

- (CGFloat)calculateLKC:(NRUserInfoModel *)userInfo {
    //减脂热量摄入
    return userInfo.weight * 22 * 1.3;
}

- (CGFloat)calculateRequireKCAL:(NRUserInfoModel *)userInfo {
    float bmiVal = [self calculateBMI:userInfo];
    if (bmiVal < 18.5) {
        return [self calculateHKC:userInfo] ;
    }
    else if ( bmiVal >= 18.5 && bmiVal < 24) {
        return [self calculateREE:userInfo];
    }
    else {
        return [self calculateLKC:userInfo];
    }
}

@end
