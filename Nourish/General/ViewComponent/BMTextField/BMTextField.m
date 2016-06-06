//
//  BMTextField.m
//  BMGameSDK
//  自定义UITextField控件
//  Created by 任建文 on 14-5-6.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BMTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "BMDeviceInfo.h"
#import "Constants.h"

@implementation BMTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderStyle      = UITextBorderStyleNone;
        self.layer.borderColor = ColorGragBorder.CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
        self.font = SysFont(FontTextFieldSize);
        self.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self setPadding:YES left:10 top:0 right:0 bottom:0];
//        self.redrawPlaceholder = NO;
//        [self customControl];
//        [self addObservers];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame hasControl:(BOOL)hasControl
{
    self = [self initWithFrame:frame];
    if (hasControl) {
        self.redrawPlaceholder = NO;
        [self customControl];
        [self addObservers];
    }
    
    return self;
}


- (void)customControl {
    self.toolbar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 35)] ;
    
    self.barPrevious=[[UIBarButtonItem alloc] initWithTitle:@"上一项" style:UIBarButtonItemStyleDone target:self action:@selector(previousControl)];
    self.barPrevious.width=60;

    self.barNext=[[UIBarButtonItem alloc] initWithTitle:@"下一项" style:UIBarButtonItemStyleDone target:self action:@selector(nextControl)];
    self.barNext.width=60;
    float spaceWidth;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        spaceWidth=ISIOS8_OR_LATER?([UIScreen mainScreen].bounds.size.width-200):([UIScreen mainScreen].bounds.size.height-200);
        self.toolbar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 35);
    }
    else
    {
        spaceWidth=[UIScreen mainScreen].bounds.size.width-200;
        self.toolbar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 35);
    }
    self.barItemSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.barItemSpace.width=spaceWidth;
    self.barItemFinish=[[UIBarButtonItem alloc]initWithTitle:@"完成"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(hideKeyBoard)];
    self.toolbar.items=[NSArray arrayWithObjects:self.barPrevious,self.barNext,self.barItemSpace,self.barItemFinish, nil];
//    self.inputAccessoryView = self.toolbar;
}

- (void)previousControl
{
    [self.toolBarDelegate previousField];
}

- (void)nextControl
{
    [self.toolBarDelegate nextField];
}

- (void)hideKeyBoard
{
    if(self.toolBarDelegate != nil && [(NSObject *)self.toolBarDelegate respondsToSelector:@selector(hideKeyBoard)] == YES)
    {
        [self.toolBarDelegate hideKeyBoard];
    }
    else
        [self resignFirstResponder];
}

#pragma mark - View orientation

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == self.previousOrientation)
    {
        return NO;
    }
    else
    {
        return orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown
        || orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight;
    }
}

- (void)sizeToFitOrientation:(BOOL)transform
{
//    float spaceWidth;
//    self.previousOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsLandscape(self.previousOrientation))
//    {
//        spaceWidth=ISIOS8_OR_LATER?([UIScreen mainScreen].bounds.size.width-200):([UIScreen mainScreen].bounds.size.height-200);
//        self.toolbar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 35);
//    }
//    else
//    {
//        spaceWidth=[UIScreen mainScreen].bounds.size.width-200;
//        self.toolbar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 35);
//    }
//    self.barItemSpace=[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
//    self.barItemSpace.width=spaceWidth;
//    self.toolbar.items=[NSArray arrayWithObjects:self.barPrevious,self.barNext,self.barItemSpace,self.barItemFinish, nil];
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object
{
    
//    DBLog(@"当前屏幕宽度=====%f",self.bounds.size.width);
//    DBLog(@"方向==%d",[[UIDevice currentDevice] orientation]);
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if ([self shouldRotateToOrientation:orientation])
    {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
    
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)setPadding:(BOOL)enable left:(float)left top:(float)top right:(float)right bottom:(float)bottom {
    isEnablePadding = enable;
    paddingTop = top;
    paddingRight = right;
    paddingBottom = bottom;
    paddingLeft = left;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    if (isEnablePadding) {
        return CGRectMake(bounds.origin.x + paddingLeft,
                          bounds.origin.y + paddingTop,
                          bounds.size.width - paddingRight,
                          bounds.size.height - paddingBottom);
    } else {
        return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super leftViewRectForBounds:bounds];
    textRect.origin.x += 10;
    textRect.origin.y -= 2;
    
    return textRect;
}

// 重写控制placeHolder的位置，左右缩5
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGFloat systemVersion =  [[[BMDeviceInfo instance] systemVersion] floatValue];

    CGFloat selfWidth = self.bounds.size.height;
    CGFloat holderWidth = bounds.size.height;
    
    if (self.redrawPlaceholder)
    {
        if (systemVersion >= 7)
        {
            CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y+9, bounds.size.width, bounds.size.height);//更好理解些
            return inset;

        }
        else {
            CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y+0, bounds.size.width, bounds.size.height);//更好理解些
            return inset;
        }
    }
    
    return [super placeholderRectForBounds:bounds];
}

// 重写控制placeHolder的颜色、字体
- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (self.redrawPlaceholder == YES) {
        [[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] setFill];
        [[self placeholder] drawInRect:rect withFont:NRFont(12)];
    }
    else {
        [super drawPlaceholderInRect:rect];
    }
}

- (void)setTextFieldLeftImage:(UIImage *)image
{
    self.clipsToBounds = YES;
    [self setRightViewMode:UITextFieldViewModeUnlessEditing];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.leftView = imageView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
