//
//  NRNoteViewController.m
//  Nourish
//
//  Created by gtc on 15/3/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//


#import "NRPlaceOrderNoteController.h"

#define kPlaceHolderString  @"给餐厅留言，可输入口味、时间等"

@interface NRPlaceOrderNoteController ()<UITextViewDelegate>
{
       UILabel *_placeholderLabel;
}

@property (strong, nonatomic) UITextView *noteTextView;
@property (strong, nonatomic) NSArray *arrNotes;
@property (strong, nonatomic) NSMutableArray *marrSelectedNotes;
@property (strong, nonatomic) NSMutableString *mstrSelectedNote;
@end

@implementation NRPlaceOrderNoteController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"添加备注";
    self.view.backgroundColor = ColorViewBg;
    
    self.marrSelectedNotes = [[NSMutableArray alloc] init];
    self.mstrSelectedNote = [[NSMutableString alloc] init];
    
    [self setupRightNavButtonWithTitle:@"确定" action:@selector(saveNotes:)];
    [self.view addSubview:self.noteTextView];
    [self.noteTextView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(10);
        make.left.and.right.equalTo(0);
        make.height.equalTo(80);
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
    
    if (STRINGHASVALUE(self.placeOrderVC.noteString)) {
        self.noteTextView.text = self.placeOrderVC.noteString;
        _placeholderLabel.text = @"";
    }
    
//    [self loadNoteFromPlist];
//    [self setupDefautNotes];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.noteTextView becomeFirstResponder];
}

//- (void)setupRightMenuButton {
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确定"
//                                                                 style:UIBarButtonItemStylePlain
//                                                                target:self
//                                                                action:@selector(saveNotes:)];
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIColor whiteColor],
//                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
//    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = rightItem;
//}

- (void)setupDefautNotes {
    UIView *notesContainerView = [[UIView alloc] init];
    [self.view addSubview:notesContainerView];
    [notesContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noteTextView.mas_bottom).offset(15);
        make.left.equalTo(10);
        make.right.equalTo(-10);
        make.height.equalTo(200);
    }];
    
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 30)/3;
    CGFloat height = 30;
    
    for (int i = 0; i < self.arrNotes.count; i++) {
        int row = (i)/3; //行
        int column = (i)%3; //列
        
        CGFloat top = 5*(row+1) + height*row;
        CGFloat left = (5+width)*column;
        
        UILabel *nameLabel = [self createNoteLabel];
        nameLabel.tag = i;
        nameLabel.text = [self.arrNotes objectAtIndex:i];
        [notesContainerView addSubview:nameLabel];
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(top);
            make.left.equalTo(left);
            make.width.equalTo(width);
            make.height.equalTo(height);
        }];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectNote:)];
        [nameLabel addGestureRecognizer:tapGR];
    }
    
}


#pragma mark - Private Methods
- (NSArray *)loadNoteFromPlist {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"NRConfig" ofType:@"plist"];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.arrNotes = [dataDic valueForKey:@"Notes"];
    return self.arrNotes;
}

- (UILabel *)createNoteLabel {
    UILabel *noteLabel = [[UILabel alloc] init];
    noteLabel.layer.cornerRadius = 15;
    noteLabel.layer.masksToBounds = YES;
    noteLabel.backgroundColor = [UIColor whiteColor];
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.textColor = [UIColor blackColor];
    noteLabel.font = NRFont(14);
    noteLabel.userInteractionEnabled = YES;
    return noteLabel;
}

- (void)saveNotes:(id)sender {
    self.placeOrderVC.noteString = self.noteTextView.text;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectNote:(UITapGestureRecognizer *)tap {
    UILabel *selectedLabel = (UILabel *)tap.view;
    NSString *note = (NSString *)[self.arrNotes objectAtIndex:selectedLabel.tag];
    if ([self.marrSelectedNotes containsObject:note]) {
        return;
    }
    
    _placeholderLabel.text = @"";
    [self.marrSelectedNotes addObject:note];
    [self.mstrSelectedNote appendFormat:@"%@ ", note];
    self.noteTextView.text = self.mstrSelectedNote;
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
    [self.noteTextView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self.noteTextView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}


#pragma mark - Property

- (UITextView *)noteTextView {
    if (_noteTextView) {
        return _noteTextView;
    }
    
    _noteTextView = [[UITextView alloc] init];
    _noteTextView.backgroundColor = [UIColor whiteColor]; // 设置背景色
    _noteTextView.alpha = 1.0; // 设置透明度
    _noteTextView.textAlignment = NSTextAlignmentLeft; // 设置字体对其方式
    _noteTextView.font = [UIFont systemFontOfSize:FontLabelSize]; // 设置字体大小
    _noteTextView.textColor = ColorBaseFont; // 设置文字颜色
    _noteTextView.editable = YES; // 设置时候可以编辑
    _noteTextView.dataDetectorTypes = UIDataDetectorTypeAll; // 显示数据类型的连接模式（如电话号码、网址、地址等）
    _noteTextView.keyboardType = UIKeyboardTypeDefault; // 设置弹出键盘的类型
    _noteTextView.returnKeyType = UIReturnKeyDone; // 设置键盘上returen键的类型
    _noteTextView.scrollEnabled = YES; // 当文字宽度超过UITextView的宽度时，是否允许滑动
    _noteTextView.delegate = self;
    
    return _noteTextView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
