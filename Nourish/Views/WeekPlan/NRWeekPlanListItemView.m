//
//  NRWeekPlanListItemView.m
//  Nourish
//
//  Created by gtc on 15/1/22.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanListItemView.h"
#import "UIImageView+AFNetworking.h"

#import "NRWeekPlanCommentView.h"
#import "UIImageView+LBBlurredImage.h"
#import "NRSetmealFoodOriginCell.h"

#import "UIImageView+WebCache.h"
#import "NRWeekPlanCommentListViewController.h"
#import "UIView+BDSExtension.h"

@interface NRWeekPlanListItemView () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
{
    UIImageView *_imageview;
    UILabel *_lblDinnerType;
    UILabel *_themeLabel;
    UILabel *_lblTotalComment;
    UIView *_bgView;
    
    UIView *_bgDetailView;
    UIImageView *_detailImgView;
    UITableView *_tbDetail;
    UIView *_topViewOftbComme;
    UIActivityIndicatorView *_activityView;
}

@property (assign, nonatomic) BOOL hasLoadedImage;

// 所有元素
@property (strong, nonatomic) NSMutableArray *marrElementNames;
@property (strong, nonatomic) NSMutableArray *marrElementTexts;
@property (strong, nonatomic) NSMutableArray *marrMaterialNames;
@property (strong, nonatomic) NSMutableArray *marrMaterialTexts;

@property (copy, nonatomic) NSString *strDescHtml;

@property (strong, nonatomic) UIImageView *imageview;
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *bgDetailView;

// 功能食材
@property (weak, nonatomic) UILabel *funcTitleLabel;
@property (weak, nonatomic) UILabel *funcContentLabel;
@property (strong, nonatomic) UIImageView *detailImgView;
@property (strong, nonatomic, nonnull) NSMutableParagraphStyle *paragraphStyle;

@property (strong, nonatomic) NSMutableDictionary *mdic_SetmealDetail;
@property (strong, nonatomic) NRWeekPlanCommentView *commentview;

// session
@property (nonatomic, weak) NSURLSessionDataTask *setmealDetailTask;
@end

@implementation NRWeekPlanListItemView

- (id)initWithFrame:(CGRect)frame type:(ListItemType)itemtype mod:(NRWeekPlanListItemModel *)mod {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.model = mod;
        self.hasLoadedImage = NO;
        
        self.marrElementNames = [NSMutableArray array];
        self.marrElementTexts = [NSMutableArray array];
        self.marrMaterialNames = [NSMutableArray array];
        self.marrMaterialTexts = [NSMutableArray array];
        self.listItemType = itemtype;
        
        if (itemtype == ListItemTypeIntrodution) {
            //周计划介绍页
            [self addIntroControl];
        }
        else if (itemtype == ListItemTypeImage) {
            //套餐主图页
            [self addImageControl];
        }
        else if (itemtype == ListItemTypeDetail) {
            //翻转详情页
            [self addDetailControl];
        }
    }
    
    return self;
}

#pragma mark - Property
- (NSMutableParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        _paragraphStyle.lineSpacing = 5.0f;
        _paragraphStyle.minimumLineHeight = 12.0f;
        _paragraphStyle.maximumLineHeight = 0;
        _paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        _paragraphStyle.alignment = NSTextAlignmentLeft;
        _paragraphStyle.lineHeightMultiple = 1.0f;
        //        _paragraphStyle.headIndent = 4.0f;
        _paragraphStyle.firstLineHeadIndent = 24.0f;
    }
    return _paragraphStyle;
}

#pragma mark - SetupViews
- (void)addIntroControl {
    //初始化套餐简介
    UIWebView *webView = [[UIWebView alloc] init];
    [self addSubview:webView];
    
    [webView makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.centerY);
        make.top.equalTo(0);
        make.bottom.equalTo(-16);
        make.left.equalTo(0);
        make.right.equalTo(-10);
    }];
    
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
//    NSString *strHtml = @"<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"zh-CN\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><style type=\"text/css\">html,body,div,h1,h2,h3,h4,h5,h6{margin:0; padding:0;font-size:100%; font-weight:normal;}body{width:100%;background-color:filter:alpha(opacity:0);font-family:NotoSansHans-Light;color:white;}h1{width:100%;font-size:28px;padding-top:20px;margin-left:-5px;font-weight:bold;line-height:35px;}h2{width:100%;margin-top: 4px;font-size:16px;line-height:25px;border-bottom: 0.5px solid #ffffff}h3{width:100%;margin-top:5.5%;font-size:16px;font-weight: bold;line-height: 18px}h4{width:100%;margin-top:1.5%;font-size:12px;color:#f0f0f0;line-height:20px}#count{width:100%;position:absolute;top:95%;left:0px;font-size:13px}#count span{font-size:11px}</style></head> <body><h1>日式素食周计划</h1><h2>清心 轻身 降火 排毒</h2><h3>@营养师</h3><h4>有10年医科经验的营养师华先生，在合理的营养原色搭配基础上融入了日料原始的烹饪方法，简约的加工方法，最大程度上保留了食物本真的味道，这个周计划会让你产生轻微的饥饿感，but please enjoy the feeling</h4><h3>@主厨</h3><h4>你应该尝尝我做的日式厚蛋烧，这种醇厚的感觉不需要任何食物添加剂，我们只用来自长春的柴鸡蛋为您烹制。顺便说一句，大酱汤是有机黄豆酱，口味适中。</h4><div id=\"count\">11000  <span>次浏览</span></div></body></html>";
    
//    [webView loadHTMLString:strHtml baseURL:nil];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", NourishBaseURLString, self.model.introdution]];
    
    NSURL *url = [NSURL URLWithString:self.model.introdution];
    [webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
    webView.delegate  = self;
    webView.scrollView.bounces = NO;
    webView.scrollView.scrollEnabled = NO;

}

- (void)addImageControl {
    //1.图片 2.评论 3.餐类型
    _bgView = [[UIView alloc] init];
    _bgView.layer.cornerRadius = CornerRadius;
    _bgView.clipsToBounds = YES;
    [self addSubview:_bgView];
    WeakSelf(self);
    [_bgView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.top.equalTo(weakSelf.mas_top);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-40);
        make.left.equalTo(weakSelf.mas_left);
        make.right.equalTo(weakSelf.mas_right);
    }];
    
    _imageview = [[UIImageView alloc] init];
    _imageview.backgroundColor = RgbHex2UIColor(0xdb, 0xdb, 0xdb);
    _imageview.userInteractionEnabled = YES;
    [_bgView addSubview:_imageview];
    [_imageview makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bgView.mas_top);
        make.bottom.equalTo(_bgView.mas_bottom).offset(-83*kAppUIScaleY);
        make.left.equalTo(_bgView.mas_left);
        make.right.equalTo(_bgView.mas_right);
    }];
    
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = ColorGrayBg;
    [_bgView addSubview:footerView];
    [footerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bgView.mas_left);
        make.right.equalTo(_bgView.mas_right);
        make.top.equalTo(_imageview.mas_bottom);
        make.bottom.equalTo(_bgView.mas_bottom);
    }];
    
    // 套餐单品
    UILabel *setmealNameLabel =  [[UILabel alloc] init];
    [footerView addSubview:setmealNameLabel];
    setmealNameLabel.textColor = RgbHex2UIColor(0X33, 0X33, 0X33);
    setmealNameLabel.font = SysFont(14);
    [setmealNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView.mas_top).offset(12);
        make.left.equalTo(15);
        make.height.equalTo(14);
    }];
    setmealNameLabel.text = self.model.setmealName;
    
    UILabel *foodsLabel = [[UILabel alloc] init];
    [footerView addSubview:foodsLabel];
    foodsLabel.textColor = RgbHex2UIColor(0X66, 0X66, 0X66);
    foodsLabel.font = SysFont(12);
    [foodsLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(setmealNameLabel.mas_bottom).offset(7);
        make.left.equalTo(15);
        make.height.equalTo(12);
    }];
    
    if (ARRAYHASVALUE(self.model.singleFoods)) {
        foodsLabel.text = [self.model.singleFoods componentsJoinedByString:@" + "];
    }
    
    UIImageView *lineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-line"]];
    [footerView addSubview:lineImgView];
    [lineImgView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView.left).offset(5);
        make.right.equalTo(footerView.right).offset(-5);
        make.top.equalTo(footerView.mas_bottom).offset(-30);
        make.height.equalTo(1);
    }];
    
    // 套餐评论
    UIView *moreView = [[UIView alloc] init];
    [footerView addSubview:moreView];
    [moreView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView.mas_left);
        make.right.equalTo(footerView.mas_right).offset(-15);
        make.top.equalTo(lineImgView.mas_bottom).offset(2);
        make.bottom.equalTo(footerView.mas_bottom).offset(-2);
    }];
    
    UIImageView *imgComment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-comment"]];
    [moreView addSubview:imgComment];
    [imgComment makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(moreView);
        make.left.equalTo(moreView.mas_left).offset(15);
        make.width.equalTo(14);
        make.height.equalTo(12);
    }];
    
    _lblTotalComment = [[UILabel alloc] init];
    [moreView addSubview:_lblTotalComment];
    _lblTotalComment.text = [NSString stringWithFormat:@"评论（%li）", (unsigned long)self.model.commentCount];
    _lblTotalComment.font = NRFont(12);
    _lblTotalComment.textColor = RgbHex2UIColor(0xaf, 0xaf, 0xaf);
    [_lblTotalComment makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(moreView.mas_top).offset(2);
        make.bottom.equalTo(moreView.mas_bottom).offset(-2);
        make.left.equalTo(imgComment.mas_right).offset(5);
    }];
    
    UIImageView *moreJiantouView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-commentmore"]];
    [moreView addSubview:moreJiantouView];
    [moreJiantouView makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(moreView.mas_right).offset(5);
        make.width.equalTo(8);
        make.centerY.equalTo(moreView);
        make.height.equalTo(12);
    }];
    
    UILabel *lblMore = [[UILabel alloc] init];
    [moreView addSubview:lblMore];
    lblMore.text = @"更多";
    lblMore.font = NRFont(12);
    lblMore.textColor = RgbHex2UIColor(0xaf, 0xaf, 0xaf);
    [lblMore makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(moreView.mas_top).offset(2);
        make.bottom.equalTo(moreView.mas_bottom).offset(-2);
        make.right.equalTo(moreJiantouView.mas_left).offset(-5);
    }];
    
    _lblDinnerType = [[UILabel alloc] init];
    [self addSubview:_lblDinnerType];
    NSString *weekdayZH = [NSString new];
    switch (self.model.weekday) {
        case WeekDayMonday:
            weekdayZH = @"星期一";
            break;
        case WeekDayTuesday:
            weekdayZH = @"星期二";
            break;
        case WeekDayWedensday:
            weekdayZH = @"星期三";
            break;
        case WeekDayThursday:
            weekdayZH = @"星期四";
            break;
        case WeekDayFirday:
            weekdayZH = @"星期五";
            break;
        case WeekDaySaturday:
            weekdayZH = @"星期六";
            break;
        case WeekDaySunday:
            weekdayZH = @"星期日";
            break;
            
        default:
            break;
    }
    switch (self.model.mealtype) {
        case MealTypeZao:
            _lblDinnerType.text = [NSString stringWithFormat:@"%@ 早餐", weekdayZH];
            break;
         case MealTypeWu:
            _lblDinnerType.text = [NSString stringWithFormat:@"%@ 午餐", weekdayZH];
            break;
        case MealTypeCha:
            _lblDinnerType.text = [NSString stringWithFormat:@"%@ 下午茶", weekdayZH];
            break;
        default:
            break;
    }
    
    _lblDinnerType.font = NRFont(FontLabelSize);
    _lblDinnerType.textColor = [UIColor whiteColor];
    [_lblDinnerType makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        make.top.greaterThanOrEqualTo(_bgView.mas_bottom).offset(5);
    }];
    
    _themeLabel = [[UILabel alloc] init];
    [self addSubview:_themeLabel];
    _themeLabel.font = NRFont(14);
    _themeLabel.textColor = [UIColor whiteColor];
    [_themeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        make.top.greaterThanOrEqualTo(_lblDinnerType.mas_bottom).offset(5);
        make.bottom.equalTo(self.bottom);
    }];
    _themeLabel.text = self.model.theme;
    
    self.commentview = [[NRWeekPlanCommentView alloc] init];
    self.commentview.setmealID = self.model.setmeal_id;
    UITapGestureRecognizer *tapGR_Comment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCommentView:)];
    [self.commentview addGestureRecognizer:tapGR_Comment];
    [_bgView addSubview:self.commentview];
    
    [self.commentview makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bgView.mas_left);
        make.right.equalTo(_bgView.mas_right);
        make.height.equalTo(0);
        make.bottom.equalTo(_bgView.mas_bottom);
    }];
    
    UITapGestureRecognizer *tapMoreGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCommentList:)];
    [moreView addGestureRecognizer:tapMoreGR];
}

- (void)addDetailControl {
    _bgDetailView = [[UIView alloc] init];
    _bgDetailView.backgroundColor = [UIColor whiteColor];
    _bgDetailView.layer.cornerRadius = CornerRadius;
    _bgDetailView.clipsToBounds = YES;
    [self addSubview:_bgDetailView];
    
    [_bgDetailView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_bgView);
        make.center.equalTo(_bgView);
    }];
    
    _tbDetail = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStylePlain];
    _tbDetail.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbDetail.tag = 2000;
    _tbDetail.dataSource = self;
    _tbDetail.delegate = self;
    [_bgDetailView addSubview:_tbDetail];
    UIEdgeInsets padding = UIEdgeInsetsMake(6, 5, 6, 5);
    [_tbDetail makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_bgDetailView).with.insets(padding);
    }];
    
    _topViewOftbComme  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tbDetail.bounds.size.width, 100)];
     [_topViewOftbComme addSubview:self.detailImgView];
    _tbDetail.tableHeaderView = _topViewOftbComme;
    [_detailImgView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_topViewOftbComme);
    }];

    // 功能食材
    UIImageView *tipImgView = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:@"wps-tips"]];
    [_topViewOftbComme addSubview:tipImgView];
    [tipImgView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topViewOftbComme.mas_top);
        make.right.equalTo(_topViewOftbComme.mas_right);
        make.height.equalTo(41*kAppUIScaleY);
        make.width.equalTo(41*kAppUIScaleX);
    }];
    
    
    // 食材小简介
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.detailImgView addSubview:maskView];
    [maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.detailImgView);
    }];
    
    UIView *funcViewContainer = [[UIView alloc] init];
    funcViewContainer.backgroundColor = [UIColor clearColor];
    
    [maskView addSubview:funcViewContainer];
    [funcViewContainer makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(maskView.mas_left).offset(5);
        make.right.equalTo(maskView.mas_right).offset(-5);
        make.top.equalTo(maskView.mas_top);
        make.bottom.equalTo(maskView.mas_bottom);
    }];
    
    UILabel *tmpfuncTitleLabel = [[UILabel alloc] init];
    [funcViewContainer addSubview:tmpfuncTitleLabel];
    self.funcTitleLabel = tmpfuncTitleLabel;
    self.funcTitleLabel.textColor = [UIColor whiteColor];
    self.funcTitleLabel.font = SysFont(14);
    [self.funcTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(funcViewContainer.mas_top).offset(5);
        make.left.equalTo(0);
        make.right.equalTo(funcViewContainer.mas_right);
        make.height.equalTo(14);
    }];
    
    WeakSelf(self);
    UILabel *tmpfuncContentLabel = [[UILabel alloc] init];
    [funcViewContainer addSubview:tmpfuncContentLabel];
    self.funcContentLabel = tmpfuncContentLabel;
    self.funcContentLabel.textColor = [UIColor whiteColor];
    self.funcContentLabel.font = NRFont(10);
    self.funcContentLabel.numberOfLines = 0;
    [self.funcContentLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(funcViewContainer.mas_left);
        make.top.equalTo(weakSelf.funcTitleLabel.mas_bottom).offset(5);
        make.right.equalTo(funcViewContainer.mas_right).offset(-8);
    }];

    CGRect avtivityRect = CGRectMake((_bgView.bounds.size.width-60)/2, (_bgView.bounds.size.height-60)/2, 60, 60);
    _activityView = [[UIActivityIndicatorView  alloc] initWithFrame:avtivityRect];
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray; // 设置活动指示器的颜色
    _activityView.hidesWhenStopped = YES; // hidesWhenStopped默认为YES，会隐藏活动指示器。要改为NO
    [_activityView startAnimating];
    [_tbDetail addSubview:_activityView];
    
    // 请求套餐详情
    [self getSetmealDetail];
    
    UITapGestureRecognizer *tapGR_hideDetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDetailView:)];
    [_tbDetail addGestureRecognizer:tapGR_hideDetail];
}

#pragma mark - action
- (void)gotoWeekplanComment {
    [MobClick event:NREvent_Click_WPList_WPComment];
    
    NRWeekPlanCommentListViewController *commentVC = [[NRWeekPlanCommentListViewController alloc] init];
    commentVC.wptId = self.model.wptId;
    commentVC.smwIds = self.model.arrWPSID;
    commentVC.weekplanName = self.model.theWeekPlanName;
    commentVC.weekplanCoverImageUrl = self.model.theWeekPlanImageUrl;
    commentVC.hidesBottomBarWhenPushed = YES;
    [self.viewController.navigationController pushViewController:commentVC animated:YES];
}

- (void)showCommentList:(id)sender {
    [MobClick event:NREvent_Click_WPList_MoreComment];
    
    // 弹出更多评价
    [self.commentview updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bgView.mas_left);
        make.right.equalTo(_bgView.mas_right);
        make.height.equalTo(_bgView.bounds.size.height);
        make.bottom.equalTo(_bgView.mas_bottom);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [_bgView layoutIfNeeded];
    }];
    
    [self.commentview updateData];
}

- (void)hideCommentView:(id)sender {
    // 隐藏更多评价
    [self.commentview updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bgView.mas_left);
        make.right.equalTo(_bgView.mas_right);
        make.height.equalTo(0);
        make.bottom.equalTo(_bgView.mas_bottom);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [_bgView layoutIfNeeded];
    }];
}

- (void)loadImage {
    if (self.hasLoadedImage) {
        return;
    }
    
    // 1.加载大图
    NSURL *url = [NSURL URLWithString:self.model.imageurl];
    __weak UIImageView *weakImageView = self.imageview;
    __weak UIImageView *weakDetailImgView = self.detailImgView =  [[UIImageView alloc] init];
    __weak typeof(self) weakSelf = self;
    
    [self.imageview sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"wpl_default_load"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (weakSelf.tag == 1) {
            [weakSelf.weekplanlistDelegate setBgImage:image];
        }
        
        if (cacheType == SDImageCacheTypeNone || cacheType == SDImageCacheTypeMemory) {
            [[SDImageCache sharedImageCache]storeImage:image forKey:[url absoluteString] toDisk:YES];
        }
        
        if (image) {
            @try {
                CGImageRef cgimage = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, image.size.width, image.size.height*0.2));
                [weakDetailImgView setImageToBlur:[UIImage imageWithCGImage:cgimage] blurRadius:10 completionBlock:nil];
            }
            @catch (NSException *exception) {
            }
            @finally {

            }
        }
        
        // 图片下载完成加手势
        UITapGestureRecognizer *tapGR_Detail = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(showDetail:)];
        [weakImageView addGestureRecognizer:tapGR_Detail];
    }];
    
    //2.加载用户的头像
    self.hasLoadedImage = YES;
}

- (void)showDetail:(id)sender {
    if (self.bgDetailView == nil) {
         [self addDetailControl];
    } else {
        self.bgDetailView.hidden = NO;
    }
    
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    // 交换本视图控制器中2个view位置
    [self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
}

- (void)hideDetailView:(id)sender {
    self.bgDetailView.hidden = YES;
    
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    //  交换本视图控制器中2个view位置
    [self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
}

- (void)getSetmealDetail {
    [self.marrElementNames removeAllObjects];
    [self.marrElementTexts removeAllObjects];
    [self.marrMaterialNames removeAllObjects];
    [self.marrMaterialTexts removeAllObjects];
    
    NSDictionary *dic = @{ @"setmealid": [NSNumber numberWithUnsignedInteger:self.model.setmeal_id] };
    __weak typeof(self) weakself = self;
    if (self.setmealDetailTask) {
        [self.setmealDetailTask cancel];
    }
    
    self.setmealDetailTask = [[NRNetworkClient sharedClient] sendPost:@"setmeal/detail" parameters:dic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [_activityView stopAnimating];
        
        NSMutableDictionary *dicSetmealDetail = [res valueForKey:@"setmealDetail"];
        NSMutableArray *arrElements = [dicSetmealDetail valueForKey:@"elementContents"];
        
        if (arrElements && arrElements.count != 0) {
            for (NSDictionary *dic in arrElements) {
                NSString *name = [dic valueForKey:@"name"];
                NSString *text = [dic valueForKey:@"text"];
                [weakself.marrElementNames addObject:name];
                [weakself.marrElementTexts addObject:text];
            }
        }
        
        NSMutableArray *arrMaterialDescs = [dicSetmealDetail valueForKey:@"materialDescs"];
        if (arrMaterialDescs && arrMaterialDescs.count != 0) {
            for (NSDictionary *dic in arrMaterialDescs) {
                NSString *name = [dic valueForKey:@"name"];
                NSString *text = [dic valueForKey:@"text"];
                [weakself.marrMaterialNames addObject:name];
                [weakself.marrMaterialTexts addObject:text];
            }
        }
        
        weakself.strDescHtml = [dicSetmealDetail valueForKey:@"desc"];
        NSString *descTitle = [dicSetmealDetail valueForKey:@"descTitle"];
        NSString *descContent = [dicSetmealDetail valueForKey:@"descContent"];
        
        NSDictionary *attr = @{ NSFontAttributeName: NRFont(12),
                                NSParagraphStyleAttributeName: self.paragraphStyle};
        NSAttributedString *attrContent = [[NSAttributedString alloc] initWithString:descContent attributes:attr];
        weakself.funcTitleLabel.text = descTitle;
        weakself.funcContentLabel.attributedText = attrContent;
        
        [_tbDetail reloadData];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [_activityView stopAnimating];
        [MBProgressHUD hideActivityWithText:_tbDetail animated:YES];
        NSString  *msg = [error.userInfo valueForKey:@"errorMsg"];
        [MBProgressHUD showErrormsgWithoutIcon:weakself title:msg detail:nil];
    }];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIButton *entryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [entryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString *commentCount = [NSString stringWithFormat:@"%lu 条评论 >", (unsigned long)self.model.commentCount];
    [entryButton setTitle:commentCount forState: UIControlStateNormal];
    [entryButton.titleLabel setFont:NRFont(12)];
    entryButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [webView addSubview:entryButton];
    [entryButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(webView.mas_right);
        make.bottom.equalTo(webView.mas_bottom).offset(-12.5);
        make.height.equalTo(15);
        make.width.equalTo(150);
    }];
    
    [entryButton addTarget:self action:@selector(gotoWeekplanComment) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.marrElementNames.count;
    }

    return [self.marrMaterialNames count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DetailCellWithIdentifier = @"DetailCell";
    NRSetmealFoodOriginCell *detailCell = [tableView dequeueReusableCellWithIdentifier:DetailCellWithIdentifier];
    
    if (detailCell == nil) {
        detailCell = [[NRSetmealFoodOriginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DetailCellWithIdentifier];
    }
    
    NSInteger row = indexPath.row;
    
    if (indexPath.section == 0) {
        detailCell.backgroundColor = RgbHex2UIColor(0xfe, 0xe4, 0xe3);
        detailCell.lblName.text = [self.marrElementNames objectAtIndex:row];
        detailCell.lblText.text = [self.marrElementTexts objectAtIndex:row];
    }
    else if (indexPath.section == 1)
    {
        if (row >= self.marrMaterialNames.count) {
            detailCell.lblName.text = @"";
            detailCell.lblText.text = @"";
        }
        else {
            detailCell.lblName.text = [self.marrMaterialNames objectAtIndex:row];
            detailCell.lblText.text = [self.marrMaterialTexts objectAtIndex:row];
            detailCell.backgroundColor = RgbHex2UIColor(0xf8, 0xf0, 0xd6);
        }
    }
    
    return detailCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

@end
