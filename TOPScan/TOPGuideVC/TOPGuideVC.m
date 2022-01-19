#import "TOPGuideVC.h"
#import "TOPGuideView.h"
#import "TOPGuideIpadCell.h"
#import "TOPGuideModel.h"
#import "TOPGuideIphoneCell.h"
#import "TOPSubscribeVC.h"
@interface TOPGuideVC ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic ,strong)UICollectionView * myCollectionView;
@property (nonatomic ,strong)UIButton * skipBtn;
@property (nonatomic ,strong)UIButton * enterBtn;
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)UIView * runView;
@property (nonatomic ,assign)NSInteger currentIndex;
@property (nonatomic ,strong)NSMutableArray * dataArray;

@end

@implementation TOPGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [TOPScanerShare top_writeOldUserShow:YES];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.currentIndex = 0;
    
    [self top_setupCollectionView];
    [self top_collectionViewReloadData];
    [self top_setupSkipBtn];
    [self top_setupPageControlView:4];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    };
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.myCollectionView reloadData];
        [self.myCollectionView setContentOffset:CGPointMake(self.currentIndex*size.width, 0) animated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (IS_IPAD) {
        [self.myCollectionView reloadData];
        [self.myCollectionView setContentOffset:CGPointMake(self.currentIndex*size.width, 0) animated:NO];
    }
}
#pragma mark -- 更换RootVC
- (void)top_clickSkipAction{
    if (![TOPUserInfoManager shareInstance].isVip) {
        TOPSubscribeVC * subscribeVC = [TOPSubscribeVC new];
        subscribeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:subscribeVC animated:YES];
    }else{
        [self top_enterRootVC];
    }
}

- (void)top_enterRootVC{
    [TOPScanerShare top_writeFirstOpenStatesSave:YES];
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark -- 获取本地数据 刷新列表
- (void)top_collectionViewReloadData{
    NSArray * titleArray = @[NSLocalizedString(@"topscan_guidetitleprofessional", @""),NSLocalizedString(@"topscan_guidetitlecollage", @""),NSLocalizedString(@"topscan_imagetotext", @""),NSLocalizedString(@"topscan_guidetitlebackup", @"")];
    NSArray * contentArray = @[NSLocalizedString(@"topscan_guideprofessionaldes", @""),NSLocalizedString(@"topscan_guidecollagedes", @""),NSLocalizedString(@"topscan_guideimagedes", @""),NSLocalizedString(@"topscan_guidebackupdes", @"")];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<titleArray.count; i++) {
        TOPGuideModel * model = [TOPGuideModel new];
        model.titleString = titleArray[i];
        model.contentString = contentArray[i];
        model.index = i;
        [tempArray addObject:model];
    }
    self.dataArray = tempArray;
    [self.myCollectionView reloadData];
}
#pragma mark - 自定义pageControl
- (void)top_setupPageControlView:(NSInteger)page {
    UIView * backView = [UIView new];
    backView.backgroundColor = RGBA(235, 235, 235, 1.0);
    backView.layer.masksToBounds = YES;
    backView.layer.cornerRadius = 4/2;
    [self.view addSubview:backView];
    self.backView = backView;
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+35));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 4));
    }];
    
    UIView * runView = [UIView new];
    runView.backgroundColor = TOPAPPGreenColor;
    runView.layer.masksToBounds = YES;
    runView.layer.cornerRadius = 4/2;
    [backView addSubview:runView];
    self.runView = runView;
    [runView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(backView);
        make.leading.equalTo(backView).offset(0);
        make.width.mas_equalTo(25);
    }];
}

#pragma mark -- scrollviewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat setOffX = (75*(scrollView.contentOffset.x))/(TOPScreenWidth*3);
    [self.runView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backView).offset(setOffX);
    }];
    
    if (scrollView.contentOffset.x>TOPScreenWidth*2+TOPScreenWidth*0.5) {
        [UIView animateWithDuration:0.2 animations:^{
            self.skipBtn.alpha = 0;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.skipBtn.alpha = 1;
        }];
    }
    if (scrollView.contentOffset.x>TOPScreenWidth*3) {
        self.backView.hidden = YES;
    }else{
        self.backView.hidden = NO;
    }
     
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/TOPScreenWidth;
    self.currentIndex = index;
}
#pragma mark -- collectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    if (IS_IPAD) {
        TOPGuideIpadCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGuideIpadCell class]) forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.item];
        cell.top_lastPageEnterAction = ^{
            [weakSelf top_clickSkipAction];
        };
        return cell;
    }else{
        TOPGuideIphoneCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGuideIphoneCell class]) forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.item];
        cell.top_lastPageEnterAction = ^{
            [weakSelf top_clickSkipAction];
        };
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(TOPScreenWidth, TOPScreenHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (UICollectionView *)myCollectionView{
    if (!_myCollectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) collectionViewLayout:layout];
        _myCollectionView.backgroundColor = [UIColor whiteColor];
        _myCollectionView.dataSource = self;
        _myCollectionView.delegate = self;
        _myCollectionView.pagingEnabled = YES;
        _myCollectionView.showsHorizontalScrollIndicator = NO;
        [_myCollectionView registerClass:[TOPGuideIpadCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGuideIpadCell class])];
        [_myCollectionView registerClass:[TOPGuideIphoneCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGuideIphoneCell class])];

    }
    return _myCollectionView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}
#pragma mark -- SetUI
- (void)top_setupCollectionView{
    [self.view addSubview:self.myCollectionView];
    [self.myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(-TOPStatusBarHeight, 0, 0, 0));
    }];
}

- (void)top_setupSkipBtn{
    UIButton * skipBtn = [UIButton new];
    skipBtn.hidden = NO;
    skipBtn.backgroundColor = RGBA(235, 235, 235, 1.0);
    skipBtn.titleLabel.font = PingFang_M_FONT_(12);
    [skipBtn setTitle:NSLocalizedString(@"topscan_skip", @"") forState:UIControlStateNormal];
    [skipBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(top_clickSkipAction) forControlEvents:UIControlEventTouchUpInside];
    skipBtn.layer.masksToBounds = YES;
    skipBtn.layer.cornerRadius = 43/2;
    self.skipBtn = skipBtn;
    [self.view addSubview:self.skipBtn];
    if (IS_IPAD) {
        [self.skipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(TOPStatusBarHeight+30);
            make.trailing.equalTo(self.view).offset(-35);
            make.size.mas_equalTo(CGSizeMake(43, 43));
        }];
    }else{
        [self.skipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+15));
            make.trailing.equalTo(self.view).offset(-15);
            make.size.mas_equalTo(CGSizeMake(43, 43));
        }];
    }
}

@end
