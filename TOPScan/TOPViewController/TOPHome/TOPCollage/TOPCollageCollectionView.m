#import "TOPCollageCollectionView.h"
#import "TOPCollageModel.h"
#import "TOPCollageViewCell.h"
#import "StickerView.h"
#import "TOPUIThroughSuperView.h"

#define SSCelInterSpacing 10

@interface TOPCollageCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource, StickerViewDelegate>
@property (nonatomic, strong) TOPUIThroughSuperView *contrlView;
@property (nonatomic, assign) CGFloat cellHeight;//
@property (nonatomic, strong) NSMutableDictionary *cellDic;

@end

@implementation TOPCollageCollectionView
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        if ([layout isKindOfClass:[UICollectionViewFlowLayout class]]) {
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)layout;
            self.cellHeight = flowLayout.itemSize.height;
        }
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
    self.dataSource = self;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
}

- (void)setShowWaterMark:(BOOL)showWaterMark {
    _showWaterMark = showWaterMark;
    [self reloadData];
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    [self reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIde = @"cellIde";
    NSString *identifier = [self.cellDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    if(!identifier) {
        identifier = [NSString stringWithFormat:@"%@%@", cellIde, [NSString stringWithFormat:@"%@", indexPath]];
        [self.cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
        [self registerClass:[TOPCollageViewCell class] forCellWithReuseIdentifier:identifier];
    }
    TOPCollageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.idCardModel = self.idCardModel;
    if (indexPath.item < self.dataArray.count) {
        TOPCollageModel *collageModel = self.dataArray[indexPath.item];
        __weak typeof(self) weakSelf = self;
        cell.top_beginDragBlock = ^(StickerView * _Nonnull dragView) {
            [weakSelf top_bringToTopLayer:dragView atCellIndex:indexPath.item];
        };
        cell.collageModel = collageModel;
    }
    if (self.showWaterMark) {
        [cell top_showWaterMarkView];
    } else {
        [cell top_hiddenWaterMarkView];
    }
    return cell;
}

#pragma mark -- 把图片加载到最上层图层便于操作
- (void)top_bringToTopLayer:(StickerView *)sticker atCellIndex:(NSInteger)cellIndex {
    sticker.delegate = self;
    CGPoint centerAfter = CGPointMake(sticker.center.x, sticker.center.y + cellIndex * (self.cellHeight + SSCelInterSpacing));
    sticker.center = centerAfter;
    [self.contrlView addSubview:sticker];
    TOPCollageModel *collageModel = self.dataArray[cellIndex];
    for (SSCollagePic *pic in collageModel.picArr) {
        if (pic.imgIndex == sticker.tag) {
            pic.isEditing = YES;
        }
    }
}

#pragma mark -- sticker delegate
- (void)top_stickerViewBeMoving:(StickerView *)stickerView withPoint:(CGPoint)point {
    CGFloat modValue = fmodf(point.y, self.cellHeight);
    CGFloat modValue1 = fmodf(self.cellHeight, point.y);
    if (modValue <= 40) {
        CGRect rect = CGRectMake(0, point.y + 200, CGRectGetWidth(self.bounds), 200);
        [self scrollRectToVisible:rect animated:YES];
    }
    if (modValue1 <= 40) {
        CGRect rect = CGRectMake(0, point.y - 200, CGRectGetWidth(self.bounds), 200);
        [self scrollRectToVisible:rect animated:YES];
    }
}

- (void)stickerViewDidMoveEnd:(StickerView *)stickerView {
    
}

- (void)top_stickerViewDidTapRightTopControl:(StickerView *)stickerView {
    if (self.idCardModel) {
        if (self.top_selectPicEditBlock) {
            self.top_selectPicEditBlock(stickerView.tag);
        }
    } else {
        [stickerView removeFromSuperview];
        [self top_deleteCollagePic:stickerView];
    }
}

- (void)top_deleteCollagePic:(StickerView *)stickerView {
    CGPoint postion = stickerView.center;
    NSIndexPath *rowIndex = [self top_cellIndexForPostion:postion];
    TOPCollageModel *collageModel = self.dataArray[rowIndex.item];
    NSMutableArray *temp = [collageModel.picArr mutableCopy];
    for (int i = 0; i < temp.count; i ++) {
        SSCollagePic *pic = temp[i];
        if (pic.imgIndex == stickerView.tag) {
            [collageModel.picArr removeObjectAtIndex:i];
            break;
        }
    }
}

#pragma mark -- 把图片放回到cell中
- (void)top_insertToCellView:(StickerView *)stickerView {
    CGPoint postion = stickerView.center;
    NSIndexPath *rowIndex = [self top_cellIndexForPostion:postion];
    TOPCollageModel *collageModel = self.dataArray[rowIndex.item];
    for (SSCollagePic *pic in collageModel.picArr) {
        if (pic.imgIndex == stickerView.tag) {
            pic.isEditing = NO;
            if (self.top_changeEditingPicBlock) {
                self.top_changeEditingPicBlock(pic.imgIndex);
            }
        }
    }
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:rowIndex];
    if ([cell isKindOfClass:[TOPCollageViewCell class]]) {
        TOPCollageViewCell *collageCell = (TOPCollageViewCell *)cell;
        stickerView.center = CGPointMake(postion.x, postion.y - rowIndex.item * (self.cellHeight + SSCelInterSpacing));
        [collageCell top_addStickerView:stickerView];
    } else {
        collageModel.isReload = YES;
    }
}

- (NSIndexPath *)top_cellIndexForPostion:(CGPoint)postion {
    NSIndexPath *rowIndex = [self indexPathForItemAtPoint:postion];
    if (!rowIndex) {
        CGPoint tempPoint = CGPointMake(postion.x, postion.y + SSCelInterSpacing);
        rowIndex = [self indexPathForItemAtPoint:tempPoint];
    }
    return rowIndex;
}

- (void)top_hiddenCtrlTap {
    if (_contrlView) {
        for (UIView *subView in self.contrlView.subviews) {
            if ([subView isKindOfClass:[StickerView class]]) {
                StickerView *sticker = (StickerView *)subView;
                [sticker hiddenCtrl];
                sticker.enabledMove = NO;
                [sticker removeFromSuperview];
                [self top_insertToCellView:sticker];
                break;
            }
        }
        [self.contrlView removeFromSuperview];
        self.contrlView = nil;
    }
}

#pragma mark -- scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.y /
                          self.cellHeight;
    if (self.top_didScrollBlock) {
        self.top_didScrollBlock(page+1);
    }
}


#pragma mark -- lazy
- (TOPUIThroughSuperView *)contrlView {
    __weak typeof(self) weakSelf = self;
    if (!_contrlView) {
        _contrlView = [[TOPUIThroughSuperView alloc] initWithFrame:CGRectMake(10, 0, self.contentSize.width - 20, self.contentSize.height)];
        _contrlView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contrlView];
        _contrlView.tapViewBlock = ^{
            [weakSelf top_hiddenCtrlTap];
        };
    }
    return _contrlView;
}

- (NSMutableDictionary *)cellDic {
    if (!_cellDic) {
        _cellDic = [[NSMutableDictionary alloc] init];
    }
    return _cellDic;
}

@end
