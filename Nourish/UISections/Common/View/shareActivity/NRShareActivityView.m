//
//  NRShareActivityView.m
//  Nourish
//
//  Created by tcguo on 15/12/11.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRShareActivityView.h"
#import "NRShareActivityViewCell.h"

#define SHARECELL_WIDTH 70
#define SHARECELL_HEIGHT 70
#define SHARECELL_COCLUM_SPACING 5
#define SHARECELL_ROW_SAPCING 10
#define DISMISS_BUTTON_HEIGHT 50

static  NSString * const kshareCellIdentifier  = @"shareCellIdentifier";

@interface NRShareActivityView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation NRShareActivityView

- (void)setupUI {
    [super setupUI];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(SHARECELL_WIDTH, SHARECELL_HEIGHT)];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumInteritemSpacing:SHARECELL_COCLUM_SPACING];
    [layout setMinimumLineSpacing:SHARECELL_ROW_SAPCING];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collectionView registerClass:[NRShareActivityViewCell class] forCellWithReuseIdentifier:kshareCellIdentifier];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

    [self.contentView addSubview:self.collectionView];
    
    NSInteger numberPerRow = (SCREEN_WIDTH - 20) / (SHARECELL_WIDTH + SHARECELL_COCLUM_SPACING);
    CGFloat floatNumberOfRow = [_dataArray count] / (CGFloat)numberPerRow;
    NSInteger numberOfRow = floor(floatNumberOfRow) < floatNumberOfRow ? floor(floatNumberOfRow) + 1 : floor(floatNumberOfRow);
    CGFloat collectionViewHeight = numberOfRow * SHARECELL_HEIGHT + (numberOfRow - 1) * SHARECELL_ROW_SAPCING + 6;
    self.collectionView.frame = CGRectMake(10, 10, SCREEN_WIDTH-20, collectionViewHeight);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 10+collectionViewHeight, SCREEN_WIDTH, SCREEN_SCALE)];
    lineView.backgroundColor = ColorLine;
    [self.contentView addSubview:lineView];
    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmButton setTitle:@"取消" forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = SysFont(FontLabelSize);
    [_confirmButton setTitleColor:ColorBaseFont forState:UIControlStateNormal];
    _confirmButton.backgroundColor = [UIColor clearColor];
    _confirmButton.frame = CGRectMake(0, 10+collectionViewHeight+SCREEN_SCALE, SCREEN_WIDTH, DISMISS_BUTTON_HEIGHT);
    [_confirmButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_confirmButton];
     self.contentViewHeight = 10 + collectionViewHeight + DISMISS_BUTTON_HEIGHT+ SCREEN_SCALE;
}

#pragma mark - UICollectionViewDataSource <NSObject>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NRShareActivityViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kshareCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[NRShareActivityViewCell alloc] initWithFrame:CGRectMake(0, 0, SHARECELL_WIDTH, SHARECELL_HEIGHT)];
    }
    NSShareViewItem *item = [self.dataArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:item.imageName];
    cell.titleLabel.text = item.title;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     NSShareViewItem *item = [self.dataArray objectAtIndex:indexPath.row];
    if (item.shareBlock) {
        item.shareBlock();
    }
}

@end


@implementation  NSShareViewItem

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName shareBlock:(ShareBlock)block {
    self = [super init];
    if (self) {
        _title = title;
        _imageName = imageName;
        _shareBlock = block;
    }
    
    return self;
}

@end

