//
//  NRWeekPlanCell.m
//  Nourish
//
//  Created by gtc on 15/1/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanCell.h"
#import "NRWeekPlanPost.h"
//#import "UIImageView+AFNetworking.h"
#import "BMButton.h"
#import "UIView+Effects.h"
#import "Constants.h"
#import "UIImageView+LBBlurredImage.h"
#import "UILabel+Additions.h"
#import "UIImageView+WebCache.h"

#define FontshadowColor RgbHex2UIColor(0x5d, 0x5d, 0x5d)

@interface NRWeekPlanCell ()
{
    UIView *_maskBg;
    CGFloat _heightForMask;
    CGFloat _yForMask;
    CGFloat _heightForCell;
}

@property (nonatomic, readwrite, strong) UIImageView *weekPlanImageView;
@property (nonatomic, readwrite, strong) UIImageView *weekPlanImageView2;
@property (nonatomic, readwrite, strong) UIView *maskBg;
@property (nonatomic, readwrite, strong) UILabel *lblName;
@property (nonatomic, readwrite, strong) UILabel *lblPrice;
@property (nonatomic, readwrite, strong) UILabel *lblDescZH;
@property (nonatomic, readwrite, strong) UILabel *lblDescEN;
@property (nonatomic, readwrite, copy) NSMutableAttributedString *str;

@end

@implementation NRWeekPlanCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = RgbHex2UIColor(0xdb, 0xdb, 0xdb);
    
    UIImage *weekImg = [UIImage imageNamed:@"wpt-default"];
    self.weekPlanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.weekPlanImageView.image = weekImg;
    [self.contentView addSubview:_weekPlanImageView];
    
    _heightForMask = 133/2*kAppUIScaleY;
    _heightForCell = 433/2*kAppUIScaleY;
    _yForMask = _heightForCell - _heightForMask;
    
    // 背景遮罩
    self.maskBg = [[UIView alloc] initWithFrame:CGRectMake(0, _yForMask, SCREEN_WIDTH, _heightForMask)];
    _maskBg.backgroundColor = RgbHex2UIColorWithAlpha(0xa0, 0x9d, 0x99, 0.4);
    
//    UIView *leftContainer = [[UIView alloc] init];
//    [_maskBg addSubview:leftContainer];
//    [leftContainer makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(15);
//        make.top.equalTo
//    }];
    
    CGFloat y = 5 *self.appdelegate.autoSizeScaleY;
    // 这个frame是初设的，没关系，后面还会重新设置其size。
    self.lblDescEN = [[UILabel alloc] initWithFrame:CGRectMake(40*self.appdelegate.autoSizeScaleX, y, 30, 18)];
    self.lblDescEN.font = [UIFont fontWithName:@"American Typewriter" size:16];
    self.lblDescEN.textColor = [UIColor whiteColor];
    self.lblDescEN.backgroundColor = [UIColor clearColor];
    self.lblDescEN.shadowColor = FontshadowColor;
    self.lblDescEN.shadowOffset = CGSizeMake(1.0, 1.0);
    self.lblDescEN.numberOfLines = 1;
   
    
    self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(20*self.appdelegate.autoSizeScaleX, 25*self.appdelegate.autoSizeScaleY, 200, 17)];
    self.lblName.shadowOffset = CGSizeMake(1.0, 1.0);
    self.lblName.shadowColor = FontshadowColor;
    self.lblName.backgroundColor = [UIColor clearColor];
    self.lblName.font = NRFont(15);
    self.lblName.textColor = [UIColor whiteColor];
    
    self.lblDescZH = [[UILabel alloc] initWithFrame:CGRectMake(40*self.appdelegate.autoSizeScaleX, 48*self.appdelegate.autoSizeScaleY, 100, 12)];
    self.lblDescZH.shadowColor = FontshadowColor;
    self.lblDescZH.shadowOffset = CGSizeMake(1.0, 1.0);
    self.lblDescZH.font = NRFont(10);
    self.lblDescZH.textColor = [UIColor whiteColor];
    self.lblDescZH.backgroundColor = [UIColor clearColor];
    
    //TODO:价格如果三位，显示的不对
    self.lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(220, 32*self.appdelegate.autoSizeScaleY, 90, 20)];
    self.lblPrice.backgroundColor = [UIColor clearColor];
    
    NSString *price = [NSString stringWithFormat:@"低至 %lu 元/天", (unsigned long)DinnerPriceWu];
    _str = [[NSMutableAttributedString alloc] initWithString:price];
    [_str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,2)];
    [_str addAttribute:NSFontAttributeName value:NRFont(12) range:NSMakeRange(0,2)];
    [_str addAttribute:NSShadowAttributeName value:FontshadowColor range:NSMakeRange(0,2)];
    
    [_str addAttribute:NSForegroundColorAttributeName value:RgbHex2UIColor(0xeb, 0x06, 0x06) range:NSMakeRange(3,2)];
    [_str addAttribute:NSFontAttributeName value:NRFont(19) range:NSMakeRange(3,2)];
    
    [_str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(6,3)];
    [_str addAttribute:NSFontAttributeName value:NRFont(12) range:NSMakeRange(6,3)];
    [_str addAttribute:NSShadowAttributeName value:FontshadowColor range:NSMakeRange(6,3)];
    
    self.lblPrice.attributedText = _str;
    
    [_maskBg addSubview:self.lblDescEN];
    [_maskBg addSubview:self.lblName];
    [_maskBg addSubview:self.lblDescZH];
    [_maskBg addSubview:self.lblPrice];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.weekPlanImageView.frame =CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
//    
//    if (self.maskBg) {
//        self.maskBg.frame = CGRectMake(0, self.bounds.size.height-_heightForMask, self.bounds.size.width,_heightForMask);
//    }
    
//    if (self.weekPlanImageView2) {
//        self.weekPlanImageView2.frame = CGRectMake(0, self.bounds.size.height-_heightForMask, self.bounds.size.width, _heightForMask);
//    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor =  FontshadowColor;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    
    NSDictionary *attrDic = @{ NSFontAttributeName:[UIFont fontWithName:@"American Typewriter" size:16*self.appdelegate.autoSizeScaleY],
                               NSForegroundColorAttributeName: [UIColor whiteColor],
                               NSShadowAttributeName: shadow};
    
    CGRect labelsize = [self.lblDescEN getLabelSizeWithAttr:attrDic];
    [self.lblDescEN setFrame:CGRectMake(self.lblDescEN.frame.origin.x, self.lblDescEN.frame.origin.y, labelsize.size.width, labelsize.size.height)];

    CGFloat fontSizeName = 15*self.appdelegate.autoSizeScaleY;
    NSDictionary *attrName = @{ NSFontAttributeName:NRFont(fontSizeName),
                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSShadowAttributeName: shadow};
    
    CGRect namelabelsize = [self.lblName getLabelSizeWithAttr:attrName];
    [self.lblName setFrame:CGRectMake(self.lblName.frame.origin.x, self.lblName.frame.origin.y, namelabelsize.size.width, namelabelsize.size.height)];
    
    
    CGFloat fontSizeDescZH = 10*self.appdelegate.autoSizeScaleY;
    NSDictionary *attrDescZH =@{ NSFontAttributeName:NRFont(fontSizeDescZH),
                               NSForegroundColorAttributeName: [UIColor whiteColor],
                               NSShadowAttributeName: shadow};
    
    CGRect descZHLabelsize = [self.lblDescZH getLabelSizeWithAttr:attrDescZH];
    [self.lblDescZH setFrame:CGRectMake(self.lblDescZH.frame.origin.x, self.lblDescZH.frame.origin.y, descZHLabelsize.size.width, descZHLabelsize.size.height+2)];
    
    
    if (self.lblDescEN.bounds.size.width > self.lblName.bounds.size.width) {
        CGFloat offetx = (self.lblDescEN.bounds.size.width - self.lblName.bounds.size.width)/2;
        [self.lblDescEN setFrame:CGRectMake(self.lblName.frame.origin.x-offetx, self.lblDescEN.frame.origin.y, self.lblDescEN.bounds.size.width, self.lblDescEN.bounds.size.height)];
    }
    else {
        CGFloat offetx = (self.lblName.bounds.size.width - self.lblDescEN.bounds.size.width)/2;
        [self.lblDescEN setFrame:CGRectMake(self.lblName.frame.origin.x+offetx, self.lblDescEN.frame.origin.y, self.lblDescEN.bounds.size.width, self.lblDescEN.bounds.size.height)];
    }
    
    CGFloat offetx = (self.lblName.bounds.size.width - self.lblDescZH.bounds.size.width)/2;
    [self.lblDescZH setFrame:CGRectMake(self.lblName.frame.origin.x+offetx, self.lblDescZH.frame.origin.y, self.lblDescZH.bounds.size.width, self.lblDescZH.bounds.size.height)];
    
    CGFloat fontForPrice = 19*self.appdelegate.autoSizeScaleY;
    NSDictionary *attrPrice = @{ NSFontAttributeName:NRFont(fontForPrice),
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSShadowAttributeName: shadow };
    
    CGRect pricelabelsize = [self.lblPrice getLabelSizeWithAttr:attrPrice];
    CGFloat xPrice = SCREEN_WIDTH - pricelabelsize.size.width;
    [self.lblPrice setFrame:CGRectMake(xPrice, self.lblPrice.frame.origin.y, pricelabelsize.size.width, pricelabelsize.size.height+2)];
    
}

- (void)setPost:(NRWeekPlanPost *)post {
    _post = post;
    
    self.lblName.text = _post.weekplanModel.weekplanName;
    self.lblDescEN.text = _post.weekplanModel.descEN;
    self.lblDescZH.text = _post.weekplanModel.descZH;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor =  FontshadowColor;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    
    NSString *price = [NSString stringWithFormat:@"%ld", _post.weekplanModel.price];
    _str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"低至 %@ 元/天", price]];
    [_str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,2)];
    [_str addAttribute:NSFontAttributeName value:NRFont(12*self.appdelegate.autoSizeScaleY) range:NSMakeRange(0,2)];
    [_str addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0,2)];
    
    [_str addAttribute:NSForegroundColorAttributeName value:RgbHex2UIColor(0xeb, 0x06, 0x06) range:NSMakeRange(3,price.length)];
    [_str addAttribute:NSFontAttributeName value:SysFont(25*self.appdelegate.autoSizeScaleY) range:NSMakeRange(3,price.length)];
    
    [_str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(3+price.length+1, 3)];
    [_str addAttribute:NSFontAttributeName value:NRFont(12*self.appdelegate.autoSizeScaleY) range:NSMakeRange(3+price.length+1,3)];
    [_str addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(3+price.length+1,3)];

    self.lblPrice.attributedText = _str;
    
    __weak NRWeekPlanCell *weakSelf = self;
    __weak UIView *weakMaskBg = _maskBg;
    [self.weekPlanImageView sd_setImageWithURL:_post.weekplanModel.imageUrl
                              placeholderImage:[UIImage imageNamed:@"wpt-default"]
                                       options:SDWebImageRefreshCached
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
     if (image) {
         int scale = 2;
         if (SCREEN_WIDTH >400) {
             scale  = 3;
         }
         
         CGFloat newY = _yForMask/_heightForCell*image.size.height;
         
//         CGImageRef cgimage = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, newY*scale, image.size.width*scale, _heightForMask*2));
         CGImageRef cgimage = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, newY*scale, image.size.width*scale, (image.size.height-newY)*scale));
         
         weakSelf.weekPlanImageView2 = [[UIImageView alloc] init];
         weakSelf.weekPlanImageView2.frame = CGRectMake(0, _yForMask, self.bounds.size.width, _heightForMask);
         
         [weakSelf.weekPlanImageView2 setImageToBlur:[UIImage imageWithCGImage:cgimage] blurRadius:5 completionBlock:nil];
         [weakSelf.weekPlanImageView addSubview:weakSelf.weekPlanImageView2];
         weakMaskBg.frame = CGRectMake(0, _yForMask, self.bounds.size.width, _heightForMask);
         [weakSelf.contentView addSubview:weakMaskBg];
     }
 }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
