//
//  NRAddInvoiceController.m
//  Nourish
//
//  Created by gtc on 15/3/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddInvoiceController.h"
#import "BMButton.h"

#define kPlaceHolderString  @"请在这里填写发票抬头"

@interface NRAddInvoiceController ()<UITextViewDelegate>
{
    UILabel *_placeholderLabel;
}

@property (strong, nonatomic) UITextView *invoiceTextView;
@property (strong, nonatomic) BMButton *saveButton;

@end

@implementation NRAddInvoiceController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"添加发票抬头";
    self.view.backgroundColor = ColorViewBg;
    [self setupRightMenuButton];
    [self.view addSubview:self.invoiceTextView];
    [self.invoiceTextView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(10);
        make.left.and.right.equalTo(0);
        make.height.equalTo(60);
    }];
    _placeholderLabel = [[UILabel alloc] init];
    [self.view addSubview:_placeholderLabel];
    [_placeholderLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(17);
        make.left.equalTo(7);
        make.right.equalTo(-5);
        make.height.equalTo(20);
    }];
    _placeholderLabel.font = SysFont(FontTextFieldSize);
    _placeholderLabel.text = kPlaceHolderString;
    _placeholderLabel.enabled = NO;//lable必须设置为不可用
    _placeholderLabel.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.invoiceTextView becomeFirstResponder];
}

- (void)setupRightMenuButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确定"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(save:)];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (UITextView *)invoiceTextView {
    if (_invoiceTextView) {
        return _invoiceTextView;
    }
    
    _invoiceTextView = [[UITextView alloc] init];
    _invoiceTextView.backgroundColor = [UIColor whiteColor]; // 设置背景色
    _invoiceTextView.alpha = 1.0; // 设置透明度
    _invoiceTextView.textAlignment = NSTextAlignmentLeft; // 设置字体对其方式
    _invoiceTextView.font = SysFont(FontTextFieldSize); // 设置字体大小
    _invoiceTextView.textColor = ColorBaseFont ; // 设置文字颜色
    [_invoiceTextView setEditable:YES]; // 设置时候可以编辑
    _invoiceTextView.dataDetectorTypes = UIDataDetectorTypeAll; // 显示数据类型的连接模式（如电话号码、网址、地址等）
    _invoiceTextView.keyboardType = UIKeyboardTypeDefault; // 设置弹出键盘的类型
    _invoiceTextView.returnKeyType = UIReturnKeyDone; // 设置键盘上returen键的类型
    _invoiceTextView.scrollEnabled = YES; // 当文字宽度超过UITextView的宽度时，是否允许滑动
    self.invoiceTextView.delegate = self;
    
    return _invoiceTextView;
}

- (void)save:(id)sender {
    [self.invoiceTextView resignFirstResponder];
    self.placeOrderVC.invoiceString = self.invoiceTextView.text;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        _placeholderLabel.text = kPlaceHolderString;
    }
    else{
        _placeholderLabel.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self.invoiceTextView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self.invoiceTextView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
