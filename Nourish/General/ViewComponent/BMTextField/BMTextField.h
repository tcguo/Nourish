//
//  BMTextField.h
//  BMGameSDK
//  自定义UITextField控件
//  Created by 任建文 on 14-5-6.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolBarDelegate <NSObject>

- (void)previousField;
- (void)nextField;

@optional
- (void)hideKeyBoard;

@end

@interface BMTextField : UITextField
{
    BOOL isEnablePadding;
    float paddingLeft;
    float paddingRight;
    float paddingTop;
    float paddingBottom;
}


/**
 *  是否重新绘制placeholder, 默认NO
 *  如果为YES, 将重写 placeholderRectForBounds 和 (void)drawPlaceholderInRect:(CGRect)rect
 */
@property (nonatomic, assign) BOOL redrawPlaceholder;

@property (nonatomic,retain)UIToolbar *toolbar;
@property (nonatomic,retain)UIBarButtonItem *barPrevious;
@property (nonatomic,retain)UIBarButtonItem *barNext;
@property (nonatomic,retain) UIBarButtonItem *barItemSpace;
@property (nonatomic,retain) UIBarButtonItem *barItemFinish;
@property (nonatomic,assign)id<ToolBarDelegate> toolBarDelegate;
@property (nonatomic, assign) UIInterfaceOrientation previousOrientation;

- (id)initWithFrame:(CGRect)frame hasControl:(BOOL)hasControl;

// 设置文本内边距 padding
- (void)setPadding:(BOOL)enable left:(float)left top:(float)top right:(float)right bottom:(float)bottom;

- (void)setTextFieldLeftImage: (UIImage *)image;

@end
