//
//  NROrderCommentCell.m
//  Nourish
//
//  Created by gtc on 15/3/17.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderCommentCell.h"
//#import "TQStarRatingView.h"
#import "UIImageView+WebCache.h"
#import "AMRatingControl.h"

NSString * const kPlaceHolder = @"您的意见非常重要，来点评一下吧...";

@interface NROrderCommentCell ()<UITextFieldDelegate, UITextViewDelegate>
{
//    TQStarRatingView *_starRatingView;
    AMRatingControl *_simpleRatingControl;
    UILabel *_onewordLabel;
}

@property (nonatomic, strong) UIImageView *setmealImageView;
@property (nonatomic, assign) DinnerType dinnerType;
@property (nonatomic, strong) UIImageView *timeIconImageView;
@property (nonatomic, strong) UILabel *dinnerTypeLabel;
@property (nonatomic, strong) UILabel *setmealNamesLabel;
@property (nonatomic, strong) UITextView *commentText;
@property (nonatomic, strong) UILabel *placeHolerLabel;

@end

static const CGFloat padding = 15;

@implementation NROrderCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
        [self.contentView addGestureRecognizer:tapGR];
        
        [self.contentView addSubview:self.setmealImageView];
        [self.setmealImageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(padding);
            make.top.equalTo(padding);
            make.height.equalTo(75);
            make.width.equalTo(70);
        }];
        self.setmealImageView.layer.cornerRadius = CornerRadius;
        self.setmealImageView.layer.masksToBounds = YES;
        
        UIView *setmealContainerView = [[UIView alloc] init];
        [self.contentView addSubview:setmealContainerView];
        setmealContainerView.backgroundColor = [UIColor clearColor];
        [setmealContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.setmealImageView);
            make.left.equalTo(self.setmealImageView.mas_right).offset(5);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.height.equalTo(34);
        }];
        
        [setmealContainerView addSubview:self.timeIconImageView];
        [self.timeIconImageView makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(20);
            make.centerY.equalTo(setmealContainerView.centerY);
            make.left.equalTo(5);
            make.width.equalTo(20);
        }];
        
        _dinnerTypeLabel = [[UILabel alloc] init];
        [setmealContainerView addSubview:_dinnerTypeLabel];
        self.dinnerTypeLabel.backgroundColor = [UIColor clearColor];
        self.dinnerTypeLabel.font = NRFont(FontLabelSize);
        self.dinnerTypeLabel.textColor = [UIColor blackColor];
        [self.dinnerTypeLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.timeIconImageView.centerY);
            make.leading.equalTo(self.timeIconImageView.mas_trailing).offset(10);
            make.height.equalTo(@20);
        }];
        
        _setmealNamesLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_setmealNamesLabel];
        _setmealNamesLabel.numberOfLines = 0;
        _setmealNamesLabel.font = SysFont(13);
        _setmealNamesLabel.textColor = ColorBaseFont;
        [_setmealNamesLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.dinnerTypeLabel.mas_bottom).offset(10);
            make.left.equalTo(self.dinnerTypeLabel.mas_left).offset(0);
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-15);
        }];
        
        _onewordLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_onewordLabel];
        [_onewordLabel setText:@"整体评价"];
        _onewordLabel.font = SysFont(14);
        _onewordLabel.textColor = ColorBaseFont;
        _onewordLabel.textAlignment = NSTextAlignmentLeft;
        [_onewordLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_setmealImageView.mas_bottom).offset(padding-5);
            make.left.equalTo(_setmealImageView.mas_left);
            make.height.equalTo(20);
            make.right.equalTo(_setmealImageView.mas_right);
        }];
    
        __weak typeof(self) weakSelf = self;
        CGFloat centerX = _onewordLabel.frame.origin.x + _onewordLabel.frame.size.width + 50;
        _simpleRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(centerX, _onewordLabel.center.y) emptyImage:[UIImage imageNamed:@"comment-star-normal"] solidImage:[UIImage imageNamed:@"comment-star-selected"] andMaxRating:5];
        _simpleRatingControl.starWidthAndHeight = 25.0f;
        [_simpleRatingControl setStarSpacing:5];
        
        // Define block to handle events
        _simpleRatingControl.editingChangedBlock = ^(NSUInteger rating)
        {
            
        };
        _simpleRatingControl.editingDidEndBlock = ^(NSUInteger rating)
        {
            weakSelf.commentInfo.starValue = rating;
        };
        
        [self.contentView addSubview:_simpleRatingControl];
        [_simpleRatingControl makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_onewordLabel.mas_top);
            make.left.equalTo(_setmealNamesLabel.mas_left);
            make.height.equalTo(25);
        }];
        
        [self.contentView addSubview:self.commentText];
        [self.commentText makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_onewordLabel.mas_bottom).offset(padding-5);
            make.left.equalTo(padding);
            make.right.equalTo(-padding);
            make.bottom.equalTo(0);
        }];
        
        [self.commentText addSubview:self.placeHolerLabel];
        [self.placeHolerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(5);
            make.top.equalTo(7);
        }];
    }
    
    return self;
}

#pragma mark - Methods
- (void)setCommentInfo:(NROrderCommentInfo *)commentInfo {
    _commentInfo = commentInfo;
    switch (_commentInfo.dinnerType) {
        case DinnerTypeZao:
            self.timeIconImageView.image = [UIImage imageNamed:@"dinner-zao"];
            self.dinnerTypeLabel.text = @"早餐";
            break;
        case DinnerTypeWu:
            self.timeIconImageView.image = [UIImage imageNamed:@"comment-icon-wuTime"];
            self.dinnerTypeLabel.text = @"午餐";
            break;
        case DinnerTypeCha:
            self.timeIconImageView.image = [UIImage imageNamed:@"dinner-tea"];
            self.dinnerTypeLabel.text = @"下午茶";
        default:
            break;
    }
    
    [self.setmealImageView sd_setImageWithURL:[NSURL URLWithString:_commentInfo.setmealImage] placeholderImage:[UIImage imageNamed:DefaultImageName] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    self.setmealNamesLabel.text = _commentInfo.foods;
    if (_commentInfo.hasCommented) {
        self.commentText.text = _commentInfo.comment;
        [_simpleRatingControl setRating:_commentInfo.starValue];
    } else {
        [_simpleRatingControl setRating:0];
    }
}


- (void)hideKeyBoard:(UIGestureRecognizer *)gesture {
    
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGFloat newY = 0.0f;

    if (self.row == 0) {
        newY = 0.f;
    } else if (self.row  == 1) {
        newY = 190.f;
    } else if (self.row == 2) {
        newY = 190*2;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.weakCommentVC.tableview setContentOffset:CGPointMake(0, newY) animated:YES];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeHolerLabel.text = kPlaceHolder;
    } else {
        self.placeHolerLabel.text = @"";
    }
    
    self.commentInfo.comment = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.25 animations:^{
        [self.weakCommentVC.tableview setContentOffset:CGPointMake(0, 0) animated:YES];
    } completion:^(BOOL finished) {
        
    }];
    
    if (textView.text.length == 0) {
        self.placeHolerLabel.text = kPlaceHolder;
    } else {
        self.placeHolerLabel.text = @"";
    }
    self.commentInfo.comment = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView isFirstResponder]) {
        // 屏蔽键盘表情
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
            ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    
    if ([text isEqualToString:@"\n"]){
        //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self.commentText resignFirstResponder];
        return NO; // 这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSString *content = textView.text;
    NSUInteger wordkLength = content.length;
    UIView *superView = textView.superview;
    UILabel *placeLabel = (UILabel *)[superView viewWithTag:999];
    if (wordkLength > 0) {
        placeLabel.text = @"";
    }
}

#pragma  mark -  Property
- (UILabel *)placeHolerLabel {
    if (!_placeHolerLabel) {
        _placeHolerLabel = [[UILabel alloc] init];
        _placeHolerLabel.textColor = ColorPlaceholderFont;
        _placeHolerLabel.font = SysFont(13);
        _placeHolerLabel.textAlignment = NSTextAlignmentLeft;
        _placeHolerLabel.text = kPlaceHolder;
        _placeHolerLabel.tag = 999;

    }
    
    return _placeHolerLabel;
}


- (UITextView *)commentText {
    if (_commentText) {
        return _commentText;
    }
    
    _commentText = [[UITextView alloc] init];
    _commentText.backgroundColor = [UIColor whiteColor]; // 设置背景色
    _commentText.alpha = 1.0; // 设置透明度
    _commentText.textAlignment = NSTextAlignmentLeft; // 设置字体对其方式
    _commentText.font = [UIFont systemFontOfSize:13]; // 设置字体大小
    _commentText.textColor = ColorBaseFont;
    _commentText.editable = YES; // 设置时候可以编辑
    
    _commentText.dataDetectorTypes = UIDataDetectorTypeAll; // 显示数据类型的连接模式（如电话号码、网址、地址等）
    _commentText.keyboardType = UIKeyboardTypeDefault; // 设置弹出键盘的类型
    _commentText.returnKeyType = UIReturnKeyDone; // 设置键盘上returen键的类型
    _commentText.scrollEnabled = YES; // 当文字宽度超过UITextView的宽度时，是否允许滑动
    _commentText.layer.borderWidth = 1.0;
    _commentText.layer.borderColor = ColorGragBorder.CGColor;
    _commentText.layer.cornerRadius = CornerRadius;
    _commentText.layer.masksToBounds = YES;
    _commentText.delegate = self;
    
    return _commentText;
}

- (UIImageView *)setmealImageView {
    if (_setmealImageView) {
        return _setmealImageView;
    }
    
    _setmealImageView = [[UIImageView alloc] init];
    _setmealImageView.image = [UIImage imageNamed:@"weekplan"];
    return _setmealImageView;
}

- (UIImageView *)timeIconImageView {
    if (_timeIconImageView) {
        return _timeIconImageView;
    }
    
    _timeIconImageView = [[UIImageView alloc] init];
    _timeIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return _timeIconImageView;
}

@end


@implementation NROrderCommentInfo


@end
