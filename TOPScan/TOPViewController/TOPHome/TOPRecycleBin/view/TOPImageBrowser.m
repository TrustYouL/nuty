#define Bottom_H 60

#import "TOPImageBrowser.h"
#import "TOPShowPicCollectionViewCell.h"
#import "TOPLocalFlowLayout.h"

@interface TOPImageBrowser ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate> {
    BOOL isShowEditView;
    BOOL isZoom;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, assign) CGFloat pagH;

@end

@implementation TOPImageBrowser

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        isShowEditView = YES;
        isZoom = YES;
        self.pagH = 23;
        [self top_configContentView];
    }
    return self;
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    if (_pageLabel) {
        [self top_defaultPageLabFream];
    }
}

- (void)top_updateCurrentItem {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//添加0.05s延迟 防止动画效果冲突
        [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth,0) animated:NO];
    });
}

- (void)top_configContentView {
    [self addSubview:self.collectionView];
    [self addSubview:self.pageLabel];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
}

#pragma mark -- collectionView delegate & dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    TOPShowPicCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPShowPicCollectionViewCell class]) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.item];
    cell.top_sendZoomScale = ^(CGFloat zoomScale) {
        [weakSelf top_setCollectionScrollState:zoomScale];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(TOPScreenWidth, TOPScreenHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -- 当图片在放缩状态时不让collectionView滑动
- (void)top_setCollectionScrollState:(CGFloat)zoomScale {
    if (zoomScale == 1.0) {
        self.collectionView.scrollEnabled = YES;
    }else{
        self.collectionView.scrollEnabled = NO;
    }
}

- (void)top_resetcollectionViewContent{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark -- 停止拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        [self top_setcurrentPage:pageIndex];
    }
}
#pragma mark -- 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.currentIndex = pageIndex;
        self->isZoom = YES;
    }
}
#pragma mark -- 滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        if (self->isZoom) {
            [self top_setcurrentPage:pageIndex];
        }
    }
}

- (void)top_setcurrentPage:(NSInteger)pageIndex{
    self.currentIndex = pageIndex;
    [self top_defaultPageLabFream];
    if (self.currentIndex < self.dataArray.count) {
        if (self.top_refreshCurrentIndex) {
            self.top_refreshCurrentIndex(self.currentIndex);
        }
    }
}

- (void)top_hiddenPageLab {
    self.pageLabel.hidden = YES;
}

- (void)top_defaultPageLabFream {
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)self.dataArray.count];
    CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.pageLabel.text Height:self.pagH Font:18].width+20;
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-(Bottom_H+TOPBottomSafeHeight));
        make.width.mas_equalTo(getWidth);
        make.height.mas_equalTo(self.pagH);
    }];
    self.pageLabel.hidden = NO;
}

#pragma mark -- lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        //滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
         
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = YES;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_collectionView registerClass:[TOPShowPicCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPShowPicCollectionViewCell class])];
    }
    return _collectionView;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, TOPScreenHeight- Bottom_H - TOPBottomSafeHeight-30-30, 100, 30)];
        _pageLabel.backgroundColor = RGBA(36, 196, 164, 0.7);
        _pageLabel.font = [self fontsWithSize:13];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.clipsToBounds = YES;//layer.masksToBounds = YES;
        _pageLabel.layer.cornerRadius = 12;
    }
    return _pageLabel;
}

@end
