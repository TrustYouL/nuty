#import "TOPPageNumCell.h"
#import "TOPPageTypeItemCell.h"
#import "TOPPageNumModel.h"
#import "TOPPageDirectionModel.h"


@interface TOPPageNumCell ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *cellTitleLab;
@property (nonatomic ,strong) UIImageView *vipLogoView;
@end

@implementation TOPPageNumCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self top_sd_layoutSubViews];
}
- (void)top_sd_layoutSubViews {
    [self.cellTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16);
        make.height.mas_equalTo(20);
        make.top.equalTo(self.contentView).offset(12);
    }];
    [self.vipLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.cellTitleLab.mas_trailing).offset(20);
        make.centerY.equalTo(self.cellTitleLab);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(40);
    }];
}
- (void)top_configCellWithData:(NSArray *)data title:(NSString *)title {
    _cellTitle = title;
    self.cellTitleLab.text = _cellTitle;
    if (data.count) {
        _typeDatas = [data mutableCopy];
        [self.collectionView reloadData];
    }
}

- (void)setShowVip:(BOOL)showVip {
    _showVip = showVip;
    self.vipLogoView.hidden = !showVip;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.typeDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TOPPageTypeItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPPageTypeItemCell class]) forIndexPath:indexPath];

    if (indexPath.item < self.typeDatas.count) {
        NSObject *obj = self.typeDatas[indexPath.item];
        if ([obj isKindOfClass:[TOPPageNumModel class]]) {
            TOPPageNumModel *model = (TOPPageNumModel *)obj;
            [cell top_configCellWithData:model];
        } else if ([obj isKindOfClass:[TOPPageDirectionModel class]]) {
            TOPPageDirectionModel *model = (TOPPageDirectionModel *)obj;
            [cell top_configDirectionCellWithData:model];
        }
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.typeDatas.count) {
        TOPPageNumModel *model = self.typeDatas[indexPath.item];
        if ([model isKindOfClass:[TOPPageNumModel class]]) {
            if (model.pageNumLayout != TOPPDFPageNumLayoutTypeNull ) {
                if (![TOPPermissionManager top_enableByPDFPageNO]) {
                    if (self.top_permissionPDFPageNOBlock) {
                        self.top_permissionPDFPageNOBlock();
                    }
                    return;
                }
            }
            for (TOPPageNumModel *model1 in self.typeDatas) {
                if (model1.isHigh) {
                    model1.isHigh = NO;
                    break;
                }
            }
            model.isHigh = YES;
        } else if ([model isKindOfClass:[TOPPageDirectionModel class]]) {
            for (TOPPageDirectionModel *model1 in self.typeDatas) {
                if (model1.isHigh) {
                    model1.isHigh = NO;
                    break;
                }
            }
            model.isHigh = YES;
        }
        if (self.top_didSelectedBlock) {
            self.top_didSelectedBlock(indexPath.item);
        }
        [self.collectionView reloadData];
    }
}

// 两列cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSObject *obj = self.typeDatas[0];
    if ([obj isKindOfClass:[TOPPageNumModel class]]) {
        return 10;
    } else if ([obj isKindOfClass:[TOPPageDirectionModel class]]) {
        CGFloat width = (TOPScreenWidth - 50*2 - 3*51)/2;
        return width;
    }
    return 10;
}

#pragma mark -- lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.itemSize = CGSizeMake(51, 82);
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 50, 0, 50);
        UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collection.dataSource = self;
        collection.delegate = self;
        [collection registerClass:[TOPPageTypeItemCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPPageTypeItemCell class])];
        collection.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        collection.scrollEnabled = NO;
        [self.contentView addSubview:collection];
        _collectionView = collection;
    }
    return _collectionView;
}

- (UILabel *)cellTitleLab {
    if (!_cellTitleLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentNatural;
        noClassLab.font = PingFang_R_FONT_(16);
        noClassLab.text = @"";
        [self.contentView addSubview:noClassLab];
        _cellTitleLab = noClassLab;
    }
    return _cellTitleLab;
}

- (UIImageView *)vipLogoView {
    if (!_vipLogoView) {
        UIImage *noClassImg = [UIImage imageNamed:@"top_vip_logo"];
        UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
        [self.contentView addSubview:noClass];
        noClass.hidden = YES;
        _vipLogoView = noClass;
    }
    return _vipLogoView;
}


@end
