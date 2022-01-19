#define TopView_H 25
#import "TOPNextCollectionView.h"
#import "TOPDocumentFooterReusableView.h"
#import "TOPGridTwoCollectionViewCell.h"
#import "TOPGridThreeCollectionViewCell.h"
#import "TOPGirdTwoFolderCollectionViewCell.h"
#import "TOPGirdThreeFolderCollectionViewCell.h"
#import "TOPGridDocDetailCollectionViewCell.h"
#import "TOPListTitleCollectionViewCell.h"
#import "TOPDocSectionOneHeader.h"
#import "TOPNextCollectionHeader.h"

#import "TOPNextCollectionCell.h"
#import "TOPNextAdCell.h"
#import "TOPNextCollFolderCell.h"
static NSString *const DocumentHeaderIdentifier = @"DocumentHeaderIdentifier";
static NSString *const DocumentOneHeaderIdentifier = @"DocumentOneHeaderIdentifier";
static NSString *const DocumentFooterIdentifier = @"DocumentFooterIdentifier";
@interface TOPNextCollectionView ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *folderArray;
@property (nonatomic, strong) NSMutableArray *docArray;
@property (nonatomic, strong) NSMutableArray *showFolderArray;
@property (nonatomic, assign) BOOL isStar;
@property (nonatomic, assign) CGFloat contentOffsetY;
@property (nonatomic, assign) CGFloat oldContentOffsetY;
@property (nonatomic, assign) CGFloat lastPosY;//记录上次滚动偏移量Y轴
@property (nonatomic, assign) CGFloat edgeMargin;//安全外距离
@property (nonatomic, assign) CGFloat cellPading;//内间距
@end
@implementation TOPNextCollectionView
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        _lastPosY = 0;
        _isMerge = NO;
        self.isMainVC = YES;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        self.dataSource = self;
        self.delegate = self;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
        self.alwaysBounceVertical = YES;
        [self registerClass:[TOPNextCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPNextCollectionCell class])];
        [self registerClass:[TOPNextAdCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPNextAdCell class])];
        [self registerClass:[TOPNextCollFolderCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPNextCollFolderCell class])];
        [self registerClass:[TOPListTitleCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPListTitleCollectionViewCell class])];

        [self registerClass:[TOPNextCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentHeaderIdentifier];
        [self registerClass:[TOPDocumentFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DocumentFooterIdentifier];
        [self registerClass:[TOPDocSectionOneHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier];

    }
    return self;
}

- (void)addGestureRecognizer{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    [self addGestureRecognizer:longPress];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.isFromSecondFolderVC) {
            return 1;
        }else{
            return 0;
        }
    }else if (section == 1){
        return self.showFolderArray.count;
    }else{
        return self.docArray.count;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(TOPScreenWidth, 0.1);
    }else if(section == 1){
        if ([TOPScanerShare shared].isEditing) {
            return CGSizeMake(TOPScreenWidth, 0.1);
        }else{
            if (self.folderArray.count>3) {
                return CGSizeMake(TOPScreenWidth, TopView_H);
            }else{
                return CGSizeMake(TOPScreenWidth, 0.1);
            }
        }
    }else{
        return CGSizeMake(TOPScreenWidth, 0.1);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(TOPScreenWidth, 0.1);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPListTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPListTitleCollectionViewCell class]) forIndexPath:indexPath];
        cell.titleLab.text = self.showName;
        return cell;
    }else if(indexPath.section == 1){
        DocumentModel *model = self.showFolderArray[indexPath.item];
        TOPNextCollFolderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPNextCollFolderCell class]) forIndexPath:indexPath];
        cell.isMerge = _isMerge;
        cell.model = model;
        if (![TOPScanerShare shared].isEditing) {
            if (self.isMainVC) {
                [cell top_showCircleView];
            }else{
                [cell top_hideCircleView];
            }
        }
        weakify(self);
        cell.top_ChoseBtnBlock = ^(BOOL selected){
            model.selectStatus = selected;
            if (weakSelf.top_longPressCheckItemHandler) {
                weakSelf.top_longPressCheckItemHandler(model, selected);
            }
            if (weakSelf.top_longPressCalculateSelectedHander) {
                weakSelf.top_longPressCalculateSelectedHander();
            }
        };
        cell.top_circleBtnBlock = ^{
            [weakSelf longPressAndEdit:indexPath];
        };
        return cell;
    }else{
        DocumentModel *model = self.docArray[indexPath.item];
        if (!model.isAd) {
            TOPNextCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPNextCollectionCell class]) forIndexPath:indexPath];
            cell.model = model;
            if (![TOPScanerShare shared].isEditing) {
                if (self.isMainVC) {
                    [cell top_showCircleView];
                }else{
                    [cell top_hideCircleView];
                }
            }
            weakify(self);
            cell.top_ChoseBtnBlock = ^(BOOL selected) {
                model.selectStatus = selected;
                if (weakSelf.top_longPressCheckItemHandler) {
                    weakSelf.top_longPressCheckItemHandler(model, selected);
                }
                if (weakSelf.top_longPressCalculateSelectedHander) {
                    weakSelf.top_longPressCalculateSelectedHander();
                }
            };
            cell.top_circleBtnBlock = ^{
                [weakSelf longPressAndEdit:indexPath];
            };
            return cell;
        }else{
            TOPNextAdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPNextAdCell class]) forIndexPath:indexPath];
            DocumentModel * nativeAd = model;
            cell.nativeAd = nativeAd;
            return cell;
        }
    }
}

#pragma mark - Event
- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [self indexPathForItemAtPoint:[longPress locationInView:self]];
            if (indexPath == nil) {
                break;
            }
            if (indexPath.section>0) {
                [self longPressAndEdit:indexPath];
                [self beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            [self updateInteractiveMovementTargetPosition:[longPress locationInView:self]];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self endInteractiveMovement];
        }
            break;
        default:
            [self cancelInteractiveMovement];
            break;
    }
}
#pragma mark -- 长按或者点cell上的圆圈之后执行的事件
- (void)longPressAndEdit:(NSIndexPath *)indexPath{
    DocumentModel *model = [DocumentModel new];
    if (indexPath.section == 1) {
        model = self.showFolderArray[indexPath.item];
    }else{
        model = self.docArray[indexPath.item];
    }
    if (!model.isAd) {
        if (![TOPScanerShare shared].isEditing) {
            for (DocumentModel * model in self.showFolderArray) {
                model.selectStatus = NO;
            }
            for (DocumentModel * model in self.docArray) {
                if (!model.isAd) {
                    model.selectStatus = NO;
                }
            }
        }
        
        if (![TOPScanerShare shared].isManualSorting) {
            [TOPScanerShare shared].isEditing = YES;
            self.showFolderArray = self.folderArray;
            [self reloadData];
            NSArray *cells = [self visibleCells];
            NSLog(@"这个cell的数量 %ld",cells.count);
            
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
            if ([cell isKindOfClass:[TOPNextCollFolderCell class]]) {
                TOPNextCollFolderCell *cell11 = (TOPNextCollFolderCell*)cell;
                model.selectStatus = YES;
                cell11.choseBtn.selected = YES;
            }else if ([cell isKindOfClass:[TOPNextCollectionCell class]]){
                TOPNextCollectionCell *cell12 = (TOPNextCollectionCell*)cell;
                model.selectStatus = YES;
                cell12.choseBtn.selected = YES;
            }
            
            for (UICollectionViewCell *cell in cells) {
                if ([cell isKindOfClass:[TOPNextCollFolderCell class]]) {
                    [(TOPNextCollFolderCell*)cell top_showSelectBtn];
                    [(TOPNextCollFolderCell*)cell top_hideCircleView];
                }else if ([cell isKindOfClass:[TOPNextCollectionCell class]]){
                    [(TOPNextCollectionCell*)cell top_showSelectBtn];
                    [(TOPNextCollectionCell*)cell top_hideCircleView];
                }
            }
            
            if (self.top_longPressEditHandler) {
                self.top_longPressEditHandler(indexPath);
            }
            if (self.top_longPressCheckItemHandler) {
                self.top_longPressCheckItemHandler(model, YES);
            }
            if (self.top_longPressCalculateSelectedHander) {
                self.top_longPressCalculateSelectedHander();
            }
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([TOPScanerShare shared].isManualSorting) {
        return;
    }
    
    if (indexPath.section == 0) {
        if (self.top_clickToChangeName) {
            self.top_clickToChangeName();
        }
    }
    
    if (indexPath.section>0) {
        DocumentModel *model = [DocumentModel new];
        if (indexPath.section == 1) {
            model = self.showFolderArray[indexPath.item];
        }else{
            model = self.docArray[indexPath.item];
        }
        if (!model.isAd) {
            if ([TOPScanerShare shared].isEditing) {
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                if ([cell isKindOfClass:[TOPNextCollFolderCell class]]) {
                    TOPNextCollFolderCell *cell1 = (TOPNextCollFolderCell*)cell;
                    cell1.choseBtn.selected = ! cell1.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if ([cell isKindOfClass:[TOPNextCollectionCell class]]){
                    TOPNextCollectionCell *cell2 = (TOPNextCollectionCell*)cell;
                    cell2.choseBtn.selected = ! cell2.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }
                if (_isMerge) {
                    if ([model.type isEqualToString:@"0"]) {
                        //是folder文件夹就push到另外一个控制器
                        if (self.top_pushNextControllerHandler) {
                            self.top_pushNextControllerHandler(model);
                        }
                        return;
                    }
                }
                
                if (self.top_longPressCheckItemHandler) {
                    self.top_longPressCheckItemHandler(model,  model.selectStatus);
                }
                if (self.top_longPressCalculateSelectedHander) {
                    self.top_longPressCalculateSelectedHander();
                }
            }else{
                if (self.top_pushNextControllerHandler) {
                    self.top_pushNextControllerHandler(model);
                }
            }
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
            TOPDocSectionOneHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier forIndexPath:indexPath];
            reusableview = headerView;
        }else if(indexPath.section == 1){
            if ([TOPScanerShare shared].isEditing) {
                TOPDocSectionOneHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier forIndexPath:indexPath];
                reusableview = headerView;
            }else{
                if (self.folderArray.count>3) {
                    WS(weakSelf);
                    TOPNextCollectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentHeaderIdentifier forIndexPath:indexPath];
                    headerView.showBtn.selected = [TOPScanerShare top_saveFolderMergeState];
                    headerView.top_refreshFolder = ^(BOOL isSelect) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [TOPScanerShare top_writeSaveFolderMergeState:isSelect];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                weakSelf.showFolderArray = [[weakSelf getShowArray:[TOPScanerShare top_saveFolderMergeState]] mutableCopy];
                                [weakSelf reloadData];
                            });
                        });
                    };
                    reusableview = headerView;
                }else{
                    TOPDocSectionOneHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier forIndexPath:indexPath];
                    reusableview = headerView;
                }
            }
        }else{
            TOPDocSectionOneHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier forIndexPath:indexPath];
            reusableview = headerView;
        }
    }else{
        TOPDocumentFooterReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DocumentFooterIdentifier forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.isFromSecondFolderVC) {
            return CGSizeMake(TOPScreenWidth, 50);
        }else{
            return CGSizeMake(TOPScreenWidth, 0.1);
        }
    }else if(indexPath.section == 1){
        CGFloat tempW = (TOPScreenWidth - 15*2-10*2);
        NSInteger cellW = tempW/3;
        return CGSizeMake(cellW, cellW);
    }else{
        CGFloat tempW = (TOPScreenWidth - (15+15+10*3));
        NSInteger cellW = tempW/4;
        return CGSizeMake(TOPScreenWidth, cellW+65);
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return UIEdgeInsetsMake(0,0, 0, 0);
    }else if(section == 1){
        if (self.folderArray.count) {
            return UIEdgeInsetsMake(10,15, 10, 15);
        }else{
            return UIEdgeInsetsMake(0,0, 0, 0);
        }
    }else{
        return UIEdgeInsetsMake(0,0, 0, 0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
                 minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 1) {
        return 10;
    }else{
        return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 1) {
        return 10;
    }else{
        return 0;
    }
}

- (void)setModel:(TOPTagsListModel *)model{
    _model = model;
}
- (void)setListArray:(NSMutableArray *)listArray{
    NSMutableArray * folderArray = [NSMutableArray new];
    NSMutableArray * docArray = [NSMutableArray new];
    for (DocumentModel * model in listArray) {
        if ([model.type isEqualToString:@"0"]) {
            [folderArray addObject:model];
        }else{
            [docArray addObject:model];
        }
    }
    self.folderArray = folderArray;
    self.docArray = docArray;
    if ([TOPScanerShare shared].isEditing) {
        self.showFolderArray = self.folderArray;
    }else{
        if (self.folderArray.count>3) {
            self.showFolderArray = [[self getShowArray:[TOPScanerShare top_saveFolderMergeState]] mutableCopy];;
        }else{
            self.showFolderArray = self.folderArray;
        }
    }
    [self reloadData];
}
- (NSArray *)getShowArray:(BOOL)select{
    NSArray * tempArray = [NSArray new];
    if (select) {
        tempArray = [self.folderArray subarrayWithRange:NSMakeRange(0, 3)];
    }else{
        tempArray = [self.folderArray copy];
    }
    return tempArray;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    BOOL isBottom = NO;
    if (bottomOffset <= height - 30) {
        isBottom = YES;
    } else {
        isBottom = NO;
    }
    if (self.top_didScrolInBottom) {
        self.top_didScrolInBottom(isBottom);
    }
    if (self.top_scrollAndSendContentOffset) {
        self.top_scrollAndSendContentOffset(contentOffsetY);
    }
}
// 完成拖拽(手指离开屏幕前)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _oldContentOffsetY = scrollView.contentOffset.y;
    if (self.top_scrollDidEndDecelerating) {
        self.top_scrollDidEndDecelerating();
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.top_scrollDidEndDecelerating) {
        self.top_scrollDidEndDecelerating();
    }
}
- (NSMutableArray *)folderArray{
    if (!_folderArray) {
        _folderArray = [NSMutableArray new];
    }
    return _folderArray;
}
- (NSMutableArray *)showFolderArray{
    if (!_showFolderArray) {
        _showFolderArray = [NSMutableArray new];
    }
    return _showFolderArray;
}
- (NSMutableArray *)docArray{
    if (!_docArray) {
        _docArray = [NSMutableArray new];
    }
    return _docArray;
}
- (void)dealloc{
    
}

@end
