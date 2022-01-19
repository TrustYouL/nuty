#import "TOPShowScreenshotVC.h"
#import "TOPShowPicCollectionViewCell.h"
@interface TOPShowScreenshotVC ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) TOPBaseCollectionView *collectionView;
@property (nonatomic, assign) BOOL isRotating;
@end

@implementation TOPShowScreenshotVC

#pragma mark -- collectionView and delegate
- (TOPBaseCollectionView *)collectionView{
    if (!_collectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;

        _collectionView = [[TOPBaseCollectionView alloc]initWithFrame:CGRectMake(0,0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPShowPicCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPShowPicCollectionViewCell class])];
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    TOPShowPicCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPShowPicCollectionViewCell class]) forIndexPath:indexPath];
    cell.cameraImagePath = self.images[indexPath.item];
    cell.top_sendZoomScale = ^(CGFloat zoomScale) {
        [weakSelf top_setCollectionScrollState:zoomScale];
    };
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark -- 当图片在放缩状态时不让collectionView滑动
- (void)top_setCollectionScrollState:(CGFloat)zoomScale{
    [FIRAnalytics logEventWithName:@"shotView_setCollectionScrollState" parameters:nil];
    if (zoomScale == 1.0) {
        self.collectionView.scrollEnabled = YES;
    }else{
        self.collectionView.scrollEnabled = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    self.isRotating = NO;
    [self top_setupUI];
    [self top_loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView reloadData];
        [self.collectionView setContentOffset:CGPointMake(self.currentIndex*size.width, 0) animated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (IS_IPAD) {
        NSLog(@"currentIndex==%ld",self.currentIndex);
        self.isRotating = YES;
        [self.collectionView reloadData];
        self.collectionView.scrollEnabled = YES;
        [self.collectionView setContentOffset:CGPointMake(self.currentIndex*size.width, 0) animated:NO];
    }
}
- (void)top_setupUI{
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backActionClick)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backActionClick)];
    }
    [self top_addRightButtonItem:@"" Image:[UIImage imageNamed:@"top_deleteShowImg"] WithSelector:@selector(top_deleteImageClick:)];
    [self.view addSubview:self.collectionView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TOPScreenWidth - 150)/2,  TOPScreenHeight-TOPBottomSafeHeight-30-40, 150, 30)];
    titleLabel.backgroundColor = RGBA(36, 196, 164, 0.7);
    titleLabel.font = [self fontsWithSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.layer.masksToBounds = YES;
    titleLabel.layer.cornerRadius = 15;
    [self.view addSubview:titleLabel];
    self.pageLabel = titleLabel;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)top_loadData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
        self.images = [picArray mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth, 0) animated:NO];
            self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)self.images.count];
            CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.pageLabel.text Height:30 Font:18].width+30;
            [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+40));
                make.size.mas_equalTo(CGSizeMake(getWidth, 30));
            }];
        });
    });
}

- (void)top_backActionClick{
    [FIRAnalytics logEventWithName:@"preview_backClick" parameters:nil];
    if (self.top_showBackBlock) {
        self.top_showBackBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)top_deleteImageClick:(UIButton *)sender
{
    if (self.images.count>0) {
        WS(weakSelf);
        //提示框添加文本输入框
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                       message:NSLocalizedString(@"topscan_deletecurrentpage", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [FIRAnalytics logEventWithName:@"TOPShowScreenshotVCDelete_Method" parameters:nil];
            
            if (self.currentIndex+1<=self.images.count) {
                NSString *imageName = weakSelf.images[self.currentIndex];
                [weakSelf.images removeObject:imageName];
                [weakSelf top_removeCurrentFilePath:imageName];
                if (weakSelf.images.count != 0) {
                    if (weakSelf.currentIndex == 0) {
                        weakSelf.currentIndex = 0;
                    }else{
                        weakSelf.currentIndex -=1 ;
                    }
                }else{
                    if (weakSelf.top_showBackBlock) {
                        weakSelf.top_showBackBlock();
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView setContentOffset:CGPointMake(weakSelf.currentIndex * weakSelf.view.frame.size.width, 0) animated:NO];
                weakSelf.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)weakSelf.images.count];
            }
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)top_removeCurrentFilePath:(NSString *)picName{
    NSString * imgPath = [TOPCamerPic_Path stringByAppendingPathComponent:picName];
    if ([TOPWHCFileManager top_isExistsAtPath:imgPath]) {
        [TOPWHCFileManager top_removeItemAtPath:imgPath];
    }
}
#pragma mark - UIScrollViewDelegate
#pragma mark -- 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self setCurrentIndex:pageIndex];
}
#pragma mark -- 停止拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self setCurrentIndex:pageIndex];
}
#pragma mark -- 滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self top_setcurrentPage:pageIndex];
}
#pragma mark -- 滑动时
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.isRotating) {//ipad切换横竖屏是不走这里
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        [self top_setcurrentPage:pageIndex];
    }
}
- (void)top_setcurrentPage:(int)pageIndex{
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%lu",pageIndex+1,(unsigned long)self.images.count] ;
    CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.pageLabel.text Height:30 Font:18].width+30;
    [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+40));
        make.size.mas_equalTo(CGSizeMake(getWidth, 30));
    }];
    self.currentIndex = pageIndex;
}
#pragma mark -- 处理侧滑和滚动的手势冲突
- (void)dealGestureConflict:(UIScrollView *)scrollView{
    NSArray * gestureArray = self.navigationController.view.gestureRecognizers;
    for (UIGestureRecognizer * gesture in gestureArray) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [scrollView.panGestureRecognizer requireGestureRecognizerToFail:gesture];
        }
    }
}
- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (NSMutableArray *)images
{
    if (_images == nil) {
        _images = [NSMutableArray new];
    }
    return _images;
}

@end
