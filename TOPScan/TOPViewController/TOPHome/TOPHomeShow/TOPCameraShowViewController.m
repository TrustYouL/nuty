#import "TOPCameraShowViewController.h"
#import "TOPShowPicCollectionViewCell.h"
#import "TOPCameraBatchModel.h"
#import "TOPReEditModel.h"

@interface TOPCameraShowViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) TOPBaseCollectionView *collectionView;

@end

@implementation TOPCameraShowViewController

#pragma mark -- collectionView and delegate
- (TOPBaseCollectionView *)collectionView{
    if (!_collectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[TOPBaseCollectionView alloc]initWithFrame:CGRectMake(0,TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor =  [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
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
    cell.top_sendZoomScale = ^(CGFloat zoomScale) {
        [weakSelf top_setCollectionScrollState:zoomScale];
    };
    cell.cameraImagePath = self.images[indexPath.item];
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
    if (zoomScale == 1.0) {
        self.collectionView.scrollEnabled = YES;
    }else{
        self.collectionView.scrollEnabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf5f5f5)];
    [self top_setupUI];
    [self top_loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_textColor:kWhiteColor defaultColor:RGBA(51, 51, 51, 1.0)],
    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)top_setupUI{
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPNavBarAndStatusBarHeight)];
    topView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    TOPImageTitleButton * backBtn = [[TOPImageTitleButton alloc]initWithFrame:CGRectMake(15, TOPStatusBarHeight, 44, 44)];
    backBtn.backgroundColor = [UIColor clearColor];
    if (isRTL()) {
        [backBtn setImage:[UIImage imageNamed:@"top_RTLbackItem"] forState:UIControlStateNormal];
        backBtn.style = EImageLeftTitleRightCenter;
    }else{
        [backBtn setImage:[UIImage imageNamed:@"top_backItem"] forState:UIControlStateNormal];
        backBtn.style = EImageLeftTitleRightLeft;
    }
    [backBtn addTarget:self action:@selector(top_backActionClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteImageBut = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteImageBut.frame = CGRectMake(TOPScreenWidth-64, TOPStatusBarHeight, 44, 44);
    deleteImageBut.backgroundColor = [UIColor clearColor];
    deleteImageBut.hidden = YES;
    [deleteImageBut setImage:[UIImage imageNamed:@"top_scamerbatch_deleteImage"] forState:UIControlStateNormal];
    [deleteImageBut addTarget:self action:@selector(top_deleteImageClick:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteBtn = deleteImageBut;

    [self.view addSubview:topView];
    [topView addSubview:backBtn];
    [topView addSubview:deleteImageBut];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TOPScreenWidth - 150)/2,  TOPScreenHeight-TOPBottomSafeHeight-30-40, 150, 30)];
    titleLabel.backgroundColor = RGBA(36, 196, 164, 0.7);
    titleLabel.font = [self fontsWithSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.layer.masksToBounds = YES;
    titleLabel.layer.cornerRadius = 15;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:titleLabel];
    self.pageLabel = titleLabel;
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(TOPNavBarAndStatusBarHeight);
    }];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(topView).offset(15);
        make.top.equalTo(topView).offset(TOPStatusBarHeight);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [deleteImageBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(topView).offset(-20);
        make.top.equalTo(topView).offset(TOPStatusBarHeight);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+40));
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(TOPNavBarAndStatusBarHeight, 0, 0, 0));
    }];
}

- (void)top_loadData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
        NSLog(@"picArray==%@",picArray);
        self.images = [picArray mutableCopy];
        if (self.images.count>0) {
            self.currentIndex = self.images.count-1;
        }else{
            self.currentIndex = 0;
        }
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
            self.deleteBtn.hidden = NO;
        });
    });
}

- (void)top_backActionClick
{
    [FIRAnalytics logEventWithName:@"preview_backClick" parameters:nil];
    if (self.top_showBackBlock) {
        self.top_showBackBlock(self.images);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)top_deleteImageClick:(UIButton *)sender
{
    if (self.images.count>0) {
        WS(weakSelf);
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                       message:NSLocalizedString(@"topscan_deletecurrentpage", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [FIRAnalytics logEventWithName:@"CameraShowVCDelete_Method" parameters:nil];
           
            if (self.currentIndex+1<=self.images.count) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *imageName = weakSelf.images[self.currentIndex];
                    [weakSelf top_removeCurrentFilePath:imageName];
                    if (weakSelf.images.count != 0) {
                        if (weakSelf.currentIndex == 0) {
                            weakSelf.currentIndex = 0;
                        }else{
                            weakSelf.currentIndex -=1 ;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.collectionView reloadData];
                            [weakSelf.collectionView setContentOffset:CGPointMake(weakSelf.currentIndex * weakSelf.view.frame.size.width, 0) animated:NO];
                            weakSelf.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)weakSelf.images.count];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (weakSelf.top_showBackBlock) {
                                weakSelf.top_showBackBlock(weakSelf.images);
                            }
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    }
                });
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
    [TOPWHCFileManager top_removeItemAtPath:[TOPCamerPic_Path stringByAppendingPathComponent:picName]];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:[TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:picName]];
    if (isExist) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:picName]];
        [TOPWHCFileManager top_removeItemAtPath:[TOPCameraBatchAdjustDraw_Path stringByAppendingPathComponent:picName]];
        [TOPWHCFileManager top_removeItemAtPath:[TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:picName]];
        [TOPWHCFileManager top_removeItemAtPath:[TOPCameraBatchCropDefaultDraw_Path stringByAppendingPathComponent:picName]];
    }

    NSMutableArray * tempArray = [NSMutableArray new];
    for (TOPCameraBatchModel * batchModel in [TOPScameraBatchSave save].images) {
        if (![batchModel.PicName isEqualToString:picName]) {
            [tempArray addObject:batchModel];
        }
    }
    [TOPScameraBatchSave save].images = tempArray;
    [self.images removeObject:picName];
    if (self.currentIndex<=[TOPScameraBatchSave save].currentIndex) {
        [TOPScameraBatchSave save].currentIndex--;
    }
   
    NSString *dicKey = picName;
    NSString *processTypeKey = [NSString stringWithFormat:@"processType%@",dicKey];
    NSMutableArray *selectArray = [TOPScameraBatchSave save].saveShowDic[dicKey];
    for (TOPReEditModel * model in selectArray) {
        NSString * iconPath = model.dic[@"image"];
        [TOPWHCFileManager top_removeItemAtPath:iconPath];
    }
    [[TOPScameraBatchSave save].saveShowDic removeObjectForKey:dicKey];
    [[TOPScameraBatchSave save].saveShowDic removeObjectForKey:processTypeKey];
    
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width ;
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%lu",pageIndex+1,(unsigned long)self.images.count] ;
    CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.pageLabel.text Height:30 Font:18].width+30;
    [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+40));
        make.size.mas_equalTo(CGSizeMake(getWidth, 30));
    }];
    self.currentIndex = pageIndex;
    [self dealGestureConflict:scrollView];
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
