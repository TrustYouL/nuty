#import "TOPSignatureMenuView.h"
#import "TOPPDFSignatureCell.h"

@interface TOPSignatureMenuView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isEditing;
@end

#define Space 10
#define MaxItemCount 4 
#define Row_H 50

@implementation TOPSignatureMenuView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isEditing = NO;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self addSubview:self.editBtn];
    [self addSubview:self.addBtn];
    [self addSubview:self.lineView];
    [self addSubview:self.collectionView];
    [self.editBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(1.0);
        make.size.mas_equalTo(CGSizeMake(40, 24));
    }];
    [self.addBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.top.equalTo(self).offset(28);
        make.size.mas_equalTo(CGSizeMake(65, 49));
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(99);
        make.top.equalTo(self).offset(36);
        make.size.mas_equalTo(CGSizeMake(0.5, 39));
    }];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(100);
        make.top.equalTo(self).offset(28);
        make.trailing.equalTo(self);
        make.height.mas_equalTo(49);
    }];
    [self top_configContentData];
}

- (void)top_configContentData {
    if (_dataArray) {
        [_dataArray removeAllObjects];
    }
    NSArray *pngFiles = [TOPDocumentHelper top_getPNGFile:TOPSignationImagePath];
    for (NSString *png in pngFiles) {
        SSPDFSignatureModel * model = [[SSPDFSignatureModel alloc] init];
        model.imagePath = [TOPSignationImagePath stringByAppendingPathComponent:png];
        model.isEditing = NO;
        [self.dataArray addObject:model];
    }
    if (!self.dataArray.count) {
        self.editBtn.hidden = YES;
    } else {
        self.editBtn.hidden = NO;
    }
    self.isEditing = NO;
    [self.editBtn setTitle:NSLocalizedString(@"topscan_ocrtexttdit", @"") forState:UIControlStateNormal];
    [self.collectionView reloadData];
}

- (void)top_downAction:(UIButton *)sender {
    if (self.top_clickAddBtnBlock) {
        self.top_clickAddBtnBlock();
    }
}

- (void)top_clickEditBtn {
    if (self.isEditing) {
        self.isEditing = NO;
        [self.editBtn setTitle:NSLocalizedString(@"topscan_ocrtexttdit", @"") forState:UIControlStateNormal];
    } else {
        self.isEditing = YES;
        [self.editBtn setTitle:NSLocalizedString(@"topscan_tagsdone", @"") forState:UIControlStateNormal];
    }
    [self top_updateEditStatus];
}

- (void)top_updateEditStatus {
    for (SSPDFSignatureModel * model in self.dataArray) {
        model.isEditing = self.isEditing;
    }
    [self.collectionView reloadData];
}

#pragma mark -UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TOPPDFSignatureCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPPDFSignatureCell class]) forIndexPath:indexPath];
    SSPDFSignatureModel * model = self.dataArray[indexPath.item];
    [cell top_congfigCellWithData:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView setUserInteractionEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView setUserInteractionEnabled:YES];
    });
    if (self.isEditing) {
        [self top_deleteSignatureImageAlert:indexPath.item];
    } else {
        SSPDFSignatureModel * model = self.dataArray[indexPath.item];
        if (self.top_selectSignatureBlock) {
            self.top_selectSignatureBlock(model.imagePath);
        }
    }
}

- (void)top_deleteSignatureImage:(NSInteger)item {
    SSPDFSignatureModel * model = self.dataArray[item];
    [TOPWHCFileManager top_removeItemAtPath:model.imagePath];
    [self.dataArray removeObjectAtIndex:item];
    if (!self.dataArray.count) {
        self.editBtn.hidden = YES;
        [self top_clickEditBtn];
    } else {
        [self.collectionView reloadData];
    }
}

#pragma mark -- 删除提示
- (void)top_deleteSignatureImageAlert:(NSInteger)item {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_deletesignatureimagealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_delete", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [self top_deleteSignatureImage:item];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self.superVC presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- lazy
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        CGFloat lineSpace = 10;
        CGFloat collection_W = TOPScreenWidth - 100;
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(54, 49);
        layout.minimumLineSpacing = lineSpace;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(100, 28,collection_W , 49) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPPDFSignatureCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPPDFSignatureCell class])];
    }
    return _collectionView;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
        btn.frame = CGRectMake(20, 28, 65, 49);
        btn.margin = UIEdgeInsetsMake(1, 0,0, 0);
        UIImage *btnImg = [UIImage imageNamed:@"top_pdf_addSignature"];
        [btn setImage:btnImg forState:UIControlStateNormal];
        [btn setTitle:NSLocalizedString(@"topscan_addsignature", @"") forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [btn.titleLabel setFont:PingFang_R_FONT_(10)];
        [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
        _addBtn = btn;
    }
    return _addBtn;
}

- (UIButton *)editBtn {
    if (!_editBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ovalBtn.frame = CGRectMake(TOPScreenWidth - 50, 2, 40, 24);
        [ovalBtn setTitle:NSLocalizedString(@"topscan_ocrtexttdit", @"") forState:UIControlStateNormal];
        ovalBtn.titleLabel.font = PingFang_R_FONT_(11);
        [ovalBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        ovalBtn.backgroundColor = [UIColor clearColor];
        [ovalBtn addTarget:self action:@selector(top_clickEditBtn) forControlEvents:UIControlEventTouchUpInside];
        _editBtn = ovalBtn;
    }
    return _editBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(99, 36, 0.5, 39)];
        line.backgroundColor = RGBA(153, 153, 153, 1.0);
        [self addSubview:line];
        _lineView = line;
    }
    return _lineView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end
