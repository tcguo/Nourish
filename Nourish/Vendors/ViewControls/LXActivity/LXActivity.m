//
//  LXActivity.m
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import "LXActivity.h"
#import "DSLCalendarDayView.h"
#import "DSLCalendarView.h"

#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]
#define ACTIONSHEET_BACKGROUNDCOLOR             [UIColor colorWithRed:106/255.00f green:106/255.00f blue:106/255.00f alpha:0.8]
#define ANIMATE_DURATION                        0.25f

#define CORNER_RADIUS                           5
#define SHAREBUTTON_BORDER_WIDTH                0.5f
#define SHAREBUTTON_BORDER_COLOR                [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor
#define SHAREBUTTONTITLE_FONT                   [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]

#define CANCEL_BUTTON_COLOR                     [UIColor colorWithRed:53/255.00f green:53/255.00f blue:53/255.00f alpha:1]

#define SHAREBUTTON_WIDTH                       50
#define SHAREBUTTON_HEIGHT                      50
//#define SHAREBUTTON_INTERVAL_WIDTH              42.5
//#define SHAREBUTTON_INTERVAL_HEIGHT             35

#define SHAREBUTTON_INTERVAL_WIDTH              24
#define SHAREBUTTON_INTERVAL_HEIGHT             22

#define SHARETITLE_WIDTH                        50
#define SHARETITLE_HEIGHT                       22

#define SHARETITLE_INTERVAL_WIDTH               24
#define SHARETITLE_INTERVAL_HEIGHT              SHAREBUTTON_WIDTH+SHAREBUTTON_INTERVAL_HEIGHT

#define SHARETITLE_FONT                         [UIFont fontWithName:@"Helvetica-Bold" size:14]

#define TITLE_INTERVAL_HEIGHT                   15
#define TITLE_HEIGHT                            30
#define TITLE_INTERVAL_WIDTH                    30
#define TITLE_WIDTH                             260
#define TITLE_FONT                              [UIFont fontWithName:@"Helvetica-Bold" size:10]
#define SHADOW_OFFSET                           CGSizeMake(0, 0.8f)
#define TITLE_NUMBER_LINES                      2

#define BUTTON_INTERVAL_HEIGHT                  20
#define BUTTON_HEIGHT                           40
#define BUTTON_INTERVAL_WIDTH                   40
#define BUTTON_WIDTH                            240
#define BUTTONTITLE_FONT                        [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
#define BUTTON_BORDER_WIDTH                     0.5f
#define BUTTON_BORDER_COLOR                     [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor



@interface UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end


@implementation UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@interface LXActivity ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSString *actionTitle;
@property (nonatomic,assign) NSInteger postionIndexNumber;
@property (nonatomic,assign) BOOL isHadTitle;
@property (nonatomic,assign) BOOL isHadShareButton;
@property (nonatomic,assign) BOOL isHadCancelButton;


@end

@implementation LXActivity

#pragma mark - Public method

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.appDelegate  =  AppDelegateInstance;
    }
    return self;
}

/**
 *  通用初始化
 *
 *  @param height   高度
 *  @param delegate <#delegate description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithHeight:(CGFloat)height delegate:(id<LXActivityDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.appDelegate  =  AppDelegateInstance;//适配用的
        
        // 初始化背景视图
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        self.LXActivityHeight = height;
//        self.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
//        [self addGestureRecognizer:tapGesture];

        if (delegate) {
            self.delegate = delegate;
        }
        
        //生成LXActionSheetView
        self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.backGroundView.backgroundColor = ColorGrayBg;
        [self addSubview:self.backGroundView];
        
        //给LXActionSheetView添加响应事件
//        UITapGestureRecognizer *tapGestureBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackGroundView)];
//        [self.backGroundView addGestureRecognizer:tapGestureBack];
        
        
        
        [UIView animateWithDuration:ANIMATE_DURATION animations:^{
            [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-self.LXActivityHeight, [UIScreen mainScreen].bounds.size.width, self.LXActivityHeight)];
        } completion:^(BOOL finished) {
        }];
    }
    
    return self;
}

/**
 *  下单日历初始化
 *
 *  @param title             <#title description#>
 *  @param height            <#height description#>
 *  @param delegate          <#delegate description#>
 *  @param cancelButtonTitle <#cancelButtonTitle description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithTitle:(NSString *)title height:(CGFloat)height delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle
{
    self = [super init];
    if (self) {
        self.appDelegate  =  AppDelegateInstance;
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        self.LXActivityHeight = height;
        [self creatButtonsWithTitle:title cancelButtonTitle:cancelButtonTitle];
    }
    return self;
}

/**
 *  分享初始化
 *
 *  @param title                      <#title description#>
 *  @param delegate                   <#delegate description#>
 *  @param cancelButtonTitle          <#cancelButtonTitle description#>
 *  @param shareButtonTitlesArray     <#shareButtonTitlesArray description#>
 *  @param shareButtonImagesNameArray <#shareButtonImagesNameArray description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithTitle:(NSString *)title delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray;
{
    
    self = [super init];
    if (self) {
        self.appDelegate  =  AppDelegateInstance;
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = WINDOW_COLOR;
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        tapGesture.delegate = nil;
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        [self creatButtonsWithTitle:title cancelButtonTitle:cancelButtonTitle shareButtonTitles:shareButtonTitlesArray withShareButtonImagesName:shareButtonImagesNameArray];
        
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    //目前没有用参数view ，直接放在rootVC的view中
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

#pragma mark - Praviate method

/**
 *  日历选择
 *
 *  @param title             <#title description#>
 *  @param cancelButtonTitle <#cancelButtonTitle description#>
 */
- (void)creatButtonsWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle
{
    //初始化
    self.isHadTitle = NO;
    self.isHadShareButton = NO;
    self.isHadCancelButton = NO;
    
    //初始化LXACtionView的高度为0
//    self.LXActivityHeight = 100;
    
    //初始化IndexNumber为0;
    self.postionIndexNumber = 0;
    
    //生成LXActionSheetView
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
    self.backGroundView.backgroundColor = ColorViewBg;
    [self addSubview:self.backGroundView];
    
    if (title) {
        self.isHadTitle = YES;
        self.titleLabel = [self creatTitleLabelWith:title];
        [self.backGroundView addSubview:_titleLabel];
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(0);
            make.top.equalTo(self.backGroundView.mas_top).offset(TITLE_INTERVAL_HEIGHT);
            make.height.equalTo(TITLE_HEIGHT);
        }];
    }
    
    if (cancelButtonTitle) {
        self.isHadCancelButton = YES;
        self.cancelButton = [self creatCancelButtonWith:cancelButtonTitle];
        self.cancelButton.tag = self.postionIndexNumber;
        [self.cancelButton addTarget:self action:@selector(didClickOnImageIndex:) forControlEvents:UIControlEventTouchUpInside];
        [self.backGroundView addSubview:self.cancelButton];
        [self.cancelButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(0);
            make.height.equalTo(BUTTON_HEIGHT);
        }];
    }
    
    //给LXActionSheetView添加响应事件
    
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-self.LXActivityHeight, [UIScreen mainScreen].bounds.size.width, self.LXActivityHeight)];
    } completion:^(BOOL finished) {
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackGroundView)];
//        tapGesture.delegate = self;
//        [self.backGroundView addGestureRecognizer:tapGesture];
    }];
}

/**
 *  分享视图
 *
 *  @param title                      <#title description#>
 *  @param cancelButtonTitle          <#cancelButtonTitle description#>
 *  @param shareButtonTitlesArray     <#shareButtonTitlesArray description#>
 *  @param shareButtonImagesNameArray <#shareButtonImagesNameArray description#>
 */
- (void)creatButtonsWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
            shareButtonTitles:(NSArray *)shareButtonTitlesArray
    withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray
{
    //初始化
    self.isHadTitle = NO;
    self.isHadShareButton = NO;
    self.isHadCancelButton = NO;
    
    //初始化LXACtionView的高度为0
    self.LXActivityHeight = 0;
    
    //初始化IndexNumber为0;
    self.postionIndexNumber = 0;
    
    //生成LXActionSheetView
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
    self.backGroundView.backgroundColor = ACTIONSHEET_BACKGROUNDCOLOR;
    self.backGroundView.backgroundColor = [UIColor whiteColor];
    
    // 给LXActionSheetView添加响应事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackGroundView)];
    [self.backGroundView addGestureRecognizer:tapGesture];
    
    [self addSubview:self.backGroundView];
    
    CGFloat sharebutton_interval_width = self.appDelegate.autoSizeScaleX * SHAREBUTTON_INTERVAL_WIDTH;
    CGFloat sharebutton_width = self.appDelegate.autoSizeScaleX * SHAREBUTTON_WIDTH;
    CGFloat sharebutton_interval_height = self.appDelegate.autoSizeScaleY * SHAREBUTTON_INTERVAL_HEIGHT;
    CGFloat sharebutton_height = self.appDelegate.autoSizeScaleY * SHAREBUTTON_HEIGHT;
    

    CGFloat sharetitle_interval_width = self.appDelegate.autoSizeScaleX * SHARETITLE_INTERVAL_WIDTH;
    CGFloat sharetitle_width = self.appDelegate.autoSizeScaleX * SHARETITLE_WIDTH;
    
    CGFloat sharetitle_interval_height = sharebutton_interval_height + sharebutton_width;
    CGFloat sharetitle_height = self.appDelegate.autoSizeScaleY * SHARETITLE_HEIGHT;
    
    if (title) {
        self.isHadTitle = YES;
        UILabel *titleLabel = [self creatShareTitleLabelWith:title];
        self.LXActivityHeight = self.LXActivityHeight + 2*TITLE_INTERVAL_HEIGHT+TITLE_HEIGHT;
        [self.backGroundView addSubview:titleLabel];
    }
    CGFloat paddingTop = 10;
    
    if (shareButtonImagesNameArray) {
        if (shareButtonImagesNameArray.count > 0) {
            self.isHadShareButton = YES;
            for (int i = 1; i < shareButtonImagesNameArray.count+1; i++) {
                //计算出行数，与列数
                int column = (int)ceil((float)(i)/4); //行
                int line = (i)%4; //列
                if (line == 0) {
                    line = 4;
                }
                UIButton *shareButton = [self creatShareButtonWithColumn:column andLine:line];
                shareButton.tag = self.postionIndexNumber+1;
                [shareButton addTarget:self action:@selector(didClickOnImageIndex:) forControlEvents:UIControlEventTouchUpInside];
                
                [shareButton setBackgroundImage:[UIImage imageNamed:[shareButtonImagesNameArray objectAtIndex:i-1]] forState:UIControlStateNormal];
                
                
                // 有Title的时候
                if (self.isHadTitle == YES) {
                    [shareButton setFrame:CGRectMake(sharebutton_interval_width+((line-1)*(sharebutton_interval_width+sharebutton_width)), self.LXActivityHeight+((column-1)*(sharebutton_interval_height+sharebutton_height)), sharebutton_width, sharebutton_height)];
                }
                else{
                    [shareButton setFrame:CGRectMake(sharebutton_interval_width+((line-1)*(sharebutton_interval_width+sharebutton_width)), paddingTop +((column-1)*(sharebutton_interval_height+sharebutton_height)), sharebutton_width, sharebutton_height)];
                }
                
                [self.backGroundView addSubview:shareButton];
                
                self.postionIndexNumber++;
            }
        }
    }
    
    
    if (shareButtonTitlesArray) {
        if (shareButtonTitlesArray.count > 0 && shareButtonImagesNameArray.count > 0) {
            for (int j = 1; j < shareButtonTitlesArray.count+1; j++) {
                //计算出行数，与列数
                int column = (int)ceil((float)(j)/4); //行
                int line = (j)%4; //列
                if (line == 0) {
                    line = 4;
                }
                UILabel *shareLabel = [self creatShareLabelWithColumn:column andLine:line];
                shareLabel.text = [shareButtonTitlesArray objectAtIndex:j-1];
                //有Title的时候
                if (self.isHadTitle == YES) {
                    [shareLabel setFrame:CGRectMake(sharetitle_interval_width+((line-1)*(sharetitle_interval_width+sharetitle_width)), self.LXActivityHeight+sharebutton_height+((column-1)*(sharetitle_interval_height)), sharetitle_width, sharetitle_height)];
                }
                else {
                    [shareLabel setFrame:CGRectMake(sharetitle_interval_width+((line-1)*(sharetitle_interval_width+sharetitle_width)), paddingTop +sharebutton_height +((column-1)*(sharetitle_interval_height)), sharetitle_width, sharetitle_height)];
                }
                [self.backGroundView addSubview:shareLabel];
            }
        }
    }
    
    //再次计算加入shareButtons后LXActivity的高度
    if (shareButtonImagesNameArray && shareButtonImagesNameArray.count > 0) {
        int totalColumns = (int)ceil((float)(shareButtonImagesNameArray.count)/4);
        if (self.isHadTitle  == YES) {
            self.LXActivityHeight = self.LXActivityHeight + totalColumns*(sharebutton_interval_height+sharebutton_height);
        }
        else{
            self.LXActivityHeight =  sharebutton_interval_height + totalColumns*(sharebutton_interval_height+sharebutton_height);
        }
    }
    
    if (cancelButtonTitle) {
        self.isHadCancelButton = YES;
        UIButton *cancelButton = [self creatShareCancelButtonWith:cancelButtonTitle];
        cancelButton.tag = 0;
        [cancelButton addTarget:self action:@selector(didClickOnImageIndex:) forControlEvents:UIControlEventTouchUpInside];
        
        //当没title destructionButton otherbuttons时
        if (self.isHadTitle == NO && self.isHadShareButton == NO) {
            self.LXActivityHeight = self.LXActivityHeight + cancelButton.frame.size.height+(2*BUTTON_INTERVAL_HEIGHT*self.appDelegate.autoSizeScaleY);
        }
        //当有title或destructionButton或otherbuttons时
        if (self.isHadTitle == YES || self.isHadShareButton == YES) {
            [cancelButton setFrame:CGRectMake(cancelButton.frame.origin.x, self.LXActivityHeight +5, cancelButton.frame.size.width, cancelButton.frame.size.height)];
            self.LXActivityHeight = self.LXActivityHeight + cancelButton.frame.size.height+BUTTON_INTERVAL_HEIGHT*self.appDelegate.autoSizeScaleY;
        }
        [self.backGroundView addSubview:cancelButton];
    }
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-self.LXActivityHeight, [UIScreen mainScreen].bounds.size.width, self.LXActivityHeight)];
    } completion:^(BOOL finished) {
    }];
}

- (UIButton *)creatCancelButtonWith:(NSString *)cancelButtonTitle
{
    UIButton *cancelButton = [[UIButton alloc] init];
    UIImage *image = [UIImage imageWithColor:[UIColor whiteColor]];
    [cancelButton setBackgroundImage:image forState:UIControlStateNormal];
    [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    [cancelButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
    cancelButton.titleLabel.font = SysFont(18);
    
    return cancelButton;
}

- (void)changeCancelButtonTitle:(NSString *)title
{
    [self.cancelButton setTitle:[NSString stringWithFormat:@"确定%@", title] forState:UIControlStateNormal];
}

- (UIButton *)creatShareCancelButtonWith:(NSString *)cancelButtonTitle
{
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_INTERVAL_WIDTH, BUTTON_INTERVAL_HEIGHT, self.backGroundView.bounds.size.width - 2*BUTTON_INTERVAL_WIDTH, BUTTON_HEIGHT)];
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.cornerRadius = CORNER_RADIUS;
    
    cancelButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    cancelButton.layer.borderColor = BUTTON_BORDER_COLOR;
    
//    UIImage *image = [UIImage imageWithColor:CANCEL_BUTTON_COLOR];
//    [cancelButton setBackgroundImage:image forState:UIControlStateNormal];
    
    [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
//    cancelButton.titleLabel.font = BUTTONTITLE_FONT;
    cancelButton.titleLabel.font = NRFont(FontButtonTitleSize);
    [cancelButton setTitleColor: ColorBaseFont forState:UIControlStateNormal];
    
    return cancelButton;
}


- (UIButton *)creatShareButtonWithColumn:(int)column andLine:(int)line
{
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SHAREBUTTON_INTERVAL_WIDTH+((line-1)*(SHAREBUTTON_INTERVAL_WIDTH+SHAREBUTTON_WIDTH)), SHAREBUTTON_INTERVAL_HEIGHT+((column-1)*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT)), SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT)];
    return shareButton;
}

- (UILabel *)creatShareLabelWithColumn:(int)column andLine:(int)line
{
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(SHARETITLE_INTERVAL_WIDTH+((line-1)*(SHARETITLE_INTERVAL_WIDTH+SHARETITLE_WIDTH)), SHARETITLE_INTERVAL_HEIGHT+((column-1)*(SHARETITLE_INTERVAL_HEIGHT)), SHARETITLE_WIDTH, SHARETITLE_HEIGHT)];
    
    shareLabel.backgroundColor = [UIColor clearColor];
    shareLabel.textAlignment = NSTextAlignmentCenter;
    shareLabel.font = TITLE_FONT;
    shareLabel.textColor = [UIColor whiteColor];
       shareLabel.textColor = ColorBaseFont;
    return shareLabel;
}

- (UILabel *)creatTitleLabelWith:(NSString *)title
{
    UILabel *titlelabel = [[UILabel alloc] init];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.text = title;
    titlelabel.textColor = [UIColor whiteColor];
    titlelabel.font = TITLE_FONT;
    titlelabel.numberOfLines = TITLE_NUMBER_LINES;
    return titlelabel;
}

- (UILabel *)creatShareTitleLabelWith:(NSString *)title
{
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_INTERVAL_WIDTH, TITLE_INTERVAL_HEIGHT, TITLE_WIDTH, TITLE_HEIGHT)];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.shadowColor = [UIColor blackColor];
    titlelabel.shadowOffset = SHADOW_OFFSET;
    titlelabel.font = SHARETITLE_FONT;
    titlelabel.text = title;
    titlelabel.textColor = [UIColor whiteColor];
    titlelabel.numberOfLines = TITLE_NUMBER_LINES;
    return titlelabel;
}


- (void)didClickOnImageIndex:(UIButton *)button
{
    if (self.delegate) {
        if (button.tag != 0) {
            if ([self.delegate respondsToSelector:@selector(didClickOnImageIndex:)] == YES) {
                [self.delegate didClickOnImageIndex:(NSInteger)button.tag];
            }
        }
        else{
            // 取消按钮
            if ([self.delegate respondsToSelector:@selector(didClickOnCancelButton:)] == YES){
                [self.delegate didClickOnCancelButton:nil];
            }
        }
    }
    
    [self tappedCancel];
}

- (void)tappedCancel {
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        self.alpha = 0;
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)tappedBackGroundView {
    //
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if([touch.view isKindOfClass:[DSLCalendarDayView class]] || [touch.view isKindOfClass:[DSLCalendarMonthView class]] ||
       [touch.view isKindOfClass:[DSLCalendarView class]]){
        return NO;
        
    }
       
    return YES;
}
       
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    CGPoint touchPoint = [self.backGroundView convertPoint:point fromView:self];
//    if ([self.backGroundView pointInside:touchPoint withEvent:event]) {
//        return NO;
//    }
//    
//    return YES;
//}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    CGPoint touchPoint = [self.backGroundView convertPoint:point fromView:self];
//    if ([self.backGroundView pointInside:touchPoint withEvent:event]) {
//        return nil;
//    }
//    
//    return self;
//}


@end
