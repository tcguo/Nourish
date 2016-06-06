//
//  NRWeekPlanCommentViewController.m
//  Nourish
//
//  Created by tcguo on 15/11/3.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanCommentViewController.h"
#import "NRHistoryOrderCell.h"
#import "NROrderCommentProvider.h"
#import "UIView+ActivityIndicator.h"

static NSString * const kPlaceHolder = @"周计划吃的怎么样？ 快告诉我们您的感受吧~";

@interface NRWeekPlanCommentViewController ()<UITextViewDelegate> {
    NSString *_commentContent;
    UIView  *_contentView;
}

@property (nonatomic, strong) UILabel    *placeholderLabel;
@property (nonatomic, strong) UITextView *commentText;
@property (nonatomic, strong) NROrderInfoModel *orderInfo;
@property (nonatomic, strong) NROrderCommentProvider *provider;

@end

@implementation NRWeekPlanCommentViewController

- (id)initWithOrderInfo:(NROrderInfoModel *)orderInfo {
    self = [super init];
    if (self) {
        _orderInfo = orderInfo;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.title = @"周计划评价";
    self.view.backgroundColor = [UIColor whiteColor];
    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignComment)];
    [_contentView addGestureRecognizer:tapGR];
    
    [self setupRightNavButtonWithTitle:@"提交" action:@selector(submitComment:)];
    
    UIView *topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 161)];
    topContainerView.backgroundColor = ColorViewBg;
    [_contentView addSubview:topContainerView];
    
    NRHistoryOrderCell *cell = [[NRHistoryOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [topContainerView addSubview:cell];
    cell.frame = CGRectMake(0, 15, SCREEN_WIDTH, 131);
    cell.orderModel = self.orderInfo;
    
    CGFloat y = cell.frame.origin.y+cell.bounds.size.height+30;
    self.commentText.frame = CGRectMake(15, y, SCREEN_WIDTH-30, 115);
    [_contentView addSubview:self.commentText];
    self.placeholderLabel.frame = CGRectMake(7, 9, SCREEN_WIDTH-30, 13);
    [self.commentText addSubview:self.placeholderLabel];
}

#pragma mark - Action
- (void)resignComment {
    [self.commentText resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)submitComment:(id)sender {
    // 1.校验
    WeakSelf(self);
    _commentContent = self.commentText.text;
    if (!STRINGHASVALUE(_commentContent) || [_commentContent isEqualToString:kPlaceHolder]) {
        [MBProgressHUD showTips:KeyWindow text:@"还是写点东西吧"];
        return;
    }
    
    if (_contentView.frame.origin.y < 0) {
        [self.commentText resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height);
        } completion:^(BOOL finished) {
        }];
    }
    
    NSDictionary *userInfo = @{ @"orderId": self.orderInfo.orderID,
                                @"smwIds": self.orderInfo.smwIds,
                                @"content": _commentContent,
                                @"wptId": [NSNumber numberWithInteger:self.orderInfo.wptId]};

    [self.provider submitWeekplanCommentWithUserInfo:userInfo completeBlock:^(id reslut, NSError *error) {
        if (!error) {
            [MBProgressHUD showDoneWithText:weakSelf.view text:@"评价成功" completionBlock:^{
                if (weakSelf.refreshCmd) {
                    [weakSelf.refreshCmd execute:nil];
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
           
        } else {
            [weakSelf processRequestError:error];
        }
    }];
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGFloat newY = -100.f;
    
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.frame = CGRectMake(0, newY, SCREEN_WIDTH, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    if ([textView.text isEqualToString:kPlaceHolder]) {
        self.commentText.text = @"";
        self.commentText.textColor = ColorBaseFont;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    if (textView.text.length == 0) {
        self.placeholderLabel.text = kPlaceHolder;
    } else {
        self.placeholderLabel.text = @"";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView isFirstResponder]) {
        // 屏蔽键盘表情
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
            ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeholderLabel.text = kPlaceHolder;
    }
    else{
        self.placeholderLabel.text = @"";
    }
}

#pragma mark - Property

- (UITextView *)commentText {
    if (_commentText) {
        return _commentText;
    }
    
    _commentText = [[UITextView alloc] init];
    _commentText.backgroundColor = [UIColor whiteColor]; // 设置背景色
    _commentText.alpha = 1.0; // 设置透明度
    _commentText.textAlignment = NSTextAlignmentLeft; // 设置字体对其方式
    _commentText.font = SysFont(14); // 设置字体大小
    _commentText.textColor = ColorBaseFont; // 设置文字颜色
    _commentText.editable = YES; // 设置时候可以编辑
    _commentText.dataDetectorTypes = UIDataDetectorTypeAll; // 显示数据类型的连接模式（如电话号码、网址、地址等）
    _commentText.keyboardType = UIKeyboardTypeDefault;
    _commentText.returnKeyType = UIReturnKeyDefault;
    _commentText.scrollEnabled = YES; // 当文字宽度超过UITextView的宽度时，是否允许滑动
    _commentText.layer.borderWidth = 1.0;
    _commentText.layer.borderColor = ColorGragBorder.CGColor;
    _commentText.layer.cornerRadius = CornerRadius;
    _commentText.layer.masksToBounds = YES;
    _commentText.delegate = self;
    
    return _commentText;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];;
        _placeholderLabel.textColor = ColorPlaceholderFont;
        _placeholderLabel.text = kPlaceHolder;
        _placeholderLabel.font = SysFont(13);
        _placeholderLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _placeholderLabel;
}

- (NROrderCommentProvider *)provider {
    if (!_provider) {
        _provider  = [[NROrderCommentProvider alloc] init];
    }
    return _provider;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
