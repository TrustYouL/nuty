#import "TOPCollageTemplateView.h"
#import "TOPCollageTemplateCell.h"
#import "TOPCollageTemplateModel.h"

@interface TOPCollageTemplateView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic ,strong) UICollectionView * collectionView;
@end

@implementation TOPCollageTemplateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBA(39, 43, 48, 0.5);
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self).offset(14);
        make.height.mas_equalTo(85);
    }];
}

- (void)setTemplateItems:(NSArray *)templateItems {
    _templateItems = templateItems;
    if (IS_IPAD) {
        CGFloat collectionW = templateItems.count*61+(templateItems.count+1)*15;
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(14);
            make.size.mas_equalTo(CGSizeMake(collectionW, 85));
        }];
    }
    [self.collectionView reloadData];
    for (int i = 0; i < _templateItems.count; i ++) {
        TOPCollageTemplateModel *model = _templateItems[i];
        if (model.isSelected) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            break;
        }
    }
}

#pragma mark -UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.templateItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPCollageTemplateCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPCollageTemplateCell class]) forIndexPath:indexPath];
    TOPCollageTemplateModel * model = self.templateItems[indexPath.item];
    [cell top_congfigCellWithData:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPCollageTemplateModel *selectedModel = _templateItems[indexPath.item];
    if (selectedModel.isSelected) {
        return;
    }
    for (int i = 0; i < _templateItems.count; i ++) {
        TOPCollageTemplateModel *model = _templateItems[i];
        model.isSelected = i == indexPath.item ? YES : NO;
    }
    [self.collectionView reloadData];
    if (self.top_selectedHeadMenuBlock) {
        self.top_selectedHeadMenuBlock(indexPath.item);
    }
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        CGFloat lineSpace = 15;
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(61, 85);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = lineSpace;
        layout.sectionInset = UIEdgeInsetsMake(0, lineSpace, 0, lineSpace);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 14,TOPScreenWidth , 85) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPCollageTemplateCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPCollageTemplateCell class])];
    }
    return _collectionView;
}

@end
