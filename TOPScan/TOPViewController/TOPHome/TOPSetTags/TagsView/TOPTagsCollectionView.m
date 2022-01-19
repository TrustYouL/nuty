#import "TOPTagsCollectionView.h"
#import "TOPTagsReusableHeader.h"
#import "TOPSetTagsCell.h"
@implementation TOPTagsCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.backgroundColor = RGB(245, 245, 245);
        self.dataSource = self;
        self.delegate = self;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;

        [self registerClass:[TOPSetTagsCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPSetTagsCell class])];
        [self registerClass:[TOPTagsReusableHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([TOPTagsReusableHeader class])];

    }
    return self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (self.headerTitle.length>0) {
        return CGSizeMake(TOPScreenWidth, 40);
    }
    return CGSizeMake(TOPScreenWidth, 0);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPSetTagsCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPSetTagsCell class]) forIndexPath:indexPath];
    TOPTagsModel * tagModel = self.dataArray[indexPath.item];
    cell.tagModel = tagModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPTagsModel * model = self.dataArray[indexPath.item];
    if (self.top_clickCellchangeState) {
        self.top_clickCellchangeState(model);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        TOPTagsReusableHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([TOPTagsReusableHeader class]) forIndexPath:indexPath];
        headerView.titleLab.text = self.headerTitle;
        reusableview = headerView;
    }
    return reusableview;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPTagsModel * model = self.dataArray[indexPath.item];
    CGFloat cellW = [TOPDocumentHelper top_getSizeWithStr:model.name Height:25 Font:15].width+30;

    return CGSizeMake(cellW, 25);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    [self reloadData];
}
- (void)dealloc{
    
}

@end
