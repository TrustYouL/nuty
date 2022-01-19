#define TopView_H 55
#import "TOPDocumentFooterReusableView.h"
#import "TOPDocumentCollectionView.h"
#import "TOPGridTwoCollectionViewCell.h"
#import "TOPGridThreeCollectionViewCell.h"
#import "TOPListCollectionViewCell.h"
#import "TOPGirdTwoFolderCollectionViewCell.h"
#import "TOPGirdThreeFolderCollectionViewCell.h"
#import "TOPGridDocDetailCollectionViewCell.h"
#import "TOPGirdDocDetailTypeFirstCell.h"
#import "TOPGirdDocDetailTypeThirdCell.h"
#import "TOPListFolderCollectionViewCell.h"
#import "TOPListTitleCollectionViewCell.h"
#import "TOPGridTwoNativeAdCell.h"
#import "TOPGridThreeNativeAdCell.h"
#import "TOPDocSectionOneHeader.h"
static NSString *const DocumentHeaderIdentifier = @"DocumentHeaderIdentifier";
static NSString *const DocumentOneHeaderIdentifier = @"DocumentOneHeaderIdentifier";
static NSString *const DocumentFooterIdentifier = @"DocumentFooterIdentifier";
@interface TOPDocumentCollectionView()<UIScrollViewDelegate>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isStar;
@property (nonatomic, assign) NSInteger headerH;
@property (nonatomic, assign) CGFloat contentOffsetY;
@property (nonatomic, assign) CGFloat oldContentOffsetY;
@property (nonatomic, assign) CGFloat lastPosY;//记录上次滚动偏移量Y轴
@property (nonatomic, assign) CGFloat edgeMargin;//安全外距离
@property (nonatomic, assign) CGFloat cellPading;//内间距
@end

@implementation TOPDocumentCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        _lastPosY = 0;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.dataSource = self;
        self.delegate = self;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        _headerH = TopView_H;
        _isMerge = NO;
        self.bounces = YES;
        self.alwaysBounceVertical = YES;
        [self registerClass:[TOPGridTwoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGridTwoCollectionViewCell class])];
        [self registerClass:[TOPGridThreeCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGridThreeCollectionViewCell class])];
        [self registerClass:[TOPListCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPListCollectionViewCell class])];
        [self registerClass:[TOPGirdTwoFolderCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGirdTwoFolderCollectionViewCell class])];
        [self registerClass:[TOPGirdThreeFolderCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGirdThreeFolderCollectionViewCell class])];
        [self registerClass:[TOPListFolderCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPListFolderCollectionViewCell class])];
        [self registerClass:[TOPGridDocDetailCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGridDocDetailCollectionViewCell class])];
        [self registerClass:[TOPGirdDocDetailTypeFirstCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGirdDocDetailTypeFirstCell class])];
        [self registerClass:[TOPGirdDocDetailTypeThirdCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGirdDocDetailTypeThirdCell class])];
        [self registerClass:[TOPListTitleCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPListTitleCollectionViewCell class])];
        [self registerClass:[TOPGridTwoNativeAdCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGridTwoNativeAdCell class])];
        [self registerClass:[TOPGridThreeNativeAdCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPGridThreeNativeAdCell class])];

        [self registerClass:[TOPDocumentHeadReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentHeaderIdentifier]; 
        [self registerClass:[TOPDocumentFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DocumentFooterIdentifier];
        [self registerClass:[TOPDocSectionOneHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier];

    }
    return self;
}

- (void)addGestureRecognizer{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(top_handleLongPressGestureRecognizer:)];
    [self addGestureRecognizer:longPress];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.isFromSecondFolderVC) {
            return 1;
        }else{
            return 0;
        }
    }
    return self.listArray.count;
}

//头部视图
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    /*
    if (section == 0) {
        return CGSizeMake(TOPScreenWidth, 0.1);
    }else{
        if (_isShowHeaderView) {
            return CGSizeMake(TOPScreenWidth, _headerH);
        }else{
            return CGSizeMake(TOPScreenWidth, 0.1);
        }
    }*/
    return CGSizeMake(TOPScreenWidth, 0.1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(TOPScreenWidth, 0.1);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPListTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPListTitleCollectionViewCell class]) forIndexPath:indexPath];
        cell.titleLab.text = self.showName;
        return cell;
    }else{
        DocumentModel *model = self.listArray[indexPath.item];
        if (self.showType == ShowTwoGoods) {
            if (!model.isAd) {
                if ([model.type isEqualToString:@"0"]) {
                    TOPGirdTwoFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGirdTwoFolderCollectionViewCell class]) forIndexPath:indexPath];
                    cell.isMerge = _isMerge;
                    cell.model = model;
                    weakify(self);
                    cell.top_ChoseBtnBlock = ^(BOOL selected) {
                        model.selectStatus = selected;
                        if (weakSelf.top_longPressCheckItemHandler) {
                            weakSelf.top_longPressCheckItemHandler(indexPath.item, selected);
                        }
                        if (weakSelf.top_longPressCalculateSelectedHander) {
                            weakSelf.top_longPressCalculateSelectedHander();
                        }
                    };
                    return cell;
                    
                }else{
                    DocumentModel *model = self.listArray[indexPath.item];
                    TOPGridTwoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGridTwoCollectionViewCell class]) forIndexPath:indexPath];
                    cell.model = model;
                    weakify(self);
                    cell.top_ChoseBtnBlock = ^(BOOL selected) {
                        model.selectStatus = selected;
                        if (weakSelf.top_longPressCheckItemHandler) {
                            weakSelf.top_longPressCheckItemHandler(indexPath.item, selected);
                        }
                        if (weakSelf.top_longPressCalculateSelectedHander) {
                            weakSelf.top_longPressCalculateSelectedHander();
                        }
                    };
                    return cell;
                }
            }else{//原生广告
                TOPGridTwoNativeAdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGridTwoNativeAdCell class]) forIndexPath:indexPath];
                DocumentModel * nativeAd = self.listArray[indexPath.row];
                cell.nativeAd = nativeAd;
                return cell;
            }
        }else if (self.showType == ShowThreeGoods){
            if (!model.isAd) {
                DocumentModel *model = self.listArray[indexPath.item];
                if ([model.type isEqualToString:@"0"]) {
                    TOPGirdThreeFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGirdThreeFolderCollectionViewCell class]) forIndexPath:indexPath];
                    cell.isMerge = _isMerge;
                    cell.model = model;
                    weakify(self);
                    cell.top_ChoseBtnBlock = ^(BOOL selected) {
                        model.selectStatus = selected;
                        if (weakSelf.top_longPressCheckItemHandler) {
                            weakSelf.top_longPressCheckItemHandler(indexPath.item, selected);
                        }
                        if (weakSelf.top_longPressCalculateSelectedHander) {
                            weakSelf.top_longPressCalculateSelectedHander();
                        }
                    };
                    return cell;
                }else{
                    DocumentModel *model = self.listArray[indexPath.item];
                    TOPGridThreeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGridThreeCollectionViewCell class]) forIndexPath:indexPath];
                    cell.model = model;
                    weakify(self);
                    cell.top_ChoseBtnBlock = ^(BOOL selected) {
                        model.selectStatus = selected;
                        if (weakSelf.top_longPressCheckItemHandler) {
                            weakSelf.top_longPressCheckItemHandler(indexPath.item, selected);
                        }
                        if (weakSelf.top_longPressCalculateSelectedHander) {
                            weakSelf.top_longPressCalculateSelectedHander();
                        }
                    };
                    return cell;
                }
            }else{//原生广告
                TOPGridThreeNativeAdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGridThreeNativeAdCell class]) forIndexPath:indexPath];
                DocumentModel * nativeAd = self.listArray[indexPath.row];
                cell.nativeAd = nativeAd;
                return cell;
            }
        }else if (self.showType == ShowListGoods || self.showType == ShowListNextGoods){
            if (!model.isAd) {
                DocumentModel *model = self.listArray[indexPath.item];
                if ([model.type isEqualToString:@"0"]) {
                    TOPListFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPListFolderCollectionViewCell class]) forIndexPath:indexPath];
                    cell.model = model;
                    return cell;
                    
                }else{
                    TOPListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPListCollectionViewCell class]) forIndexPath:indexPath];
                    cell.model = self.listArray[indexPath.item];
                    return cell;
                }
            }else{
                TOPListFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPListFolderCollectionViewCell class]) forIndexPath:indexPath];
                return cell;
            }
        }else if (self.showType == ShowListDetailGoods){
            DocumentModel *model = self.listArray[indexPath.item];
            NSInteger index = [TOPScanerShare top_childViewByType] == 1 ? indexPath.item + 1 : self.listArray.count - indexPath.item;//1:升序
            if (index < 10) {
                model.name = [NSString stringWithFormat:@"0%@",@(index)];
            }else{
                model.name = [NSString stringWithFormat:@"%@",@(index)];
            }
            return [self childVCDetailCell:indexPath collectionView:collectionView detailModel:model];
        }
        else{
            return nil;
        }
    }
}
- (UICollectionViewCell *)childVCDetailCell:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView  detailModel:(DocumentModel *)model{
    UICollectionViewCell * sendCell;
    if ([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeFirst) {
        TOPGirdDocDetailTypeFirstCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGirdDocDetailTypeFirstCell class]) forIndexPath:indexPath];
        cell.model = model;
        cell.markCellId = self.markCellId;
        weakify(self);
        cell.top_ChoseBtnBlock = ^(BOOL selected) {
            model.selectStatus = selected;
            if (weakSelf.top_longPressCheckItemHandler) {
                weakSelf.top_longPressCheckItemHandler(indexPath.item, selected);
            }
            if (weakSelf.top_longPressCalculateSelectedHander) {
                weakSelf.top_longPressCalculateSelectedHander();
            }
        };
        
        cell.top_clickToJump = ^{
            if (weakSelf.top_clickTxtNote) {
                weakSelf.top_clickTxtNote(weakSelf.listArray,indexPath);
            }
        };
        
        cell.top_clickOCRToJump = ^{
            if (weakSelf.top_clickTxtOCR) {
                weakSelf.top_clickTxtOCR(weakSelf.listArray,indexPath);
            }
        };
        sendCell = cell;
    }else if([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeSecond){
        TOPGridDocDetailCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGridDocDetailCollectionViewCell class]) forIndexPath:indexPath];
        cell.model = model;
        cell.markCellId = self.markCellId;
        weakify(self);
        cell.top_ChoseBtnBlock = ^(BOOL selected) {
            model.selectStatus = selected;
            if (weakSelf.top_longPressCheckItemHandler) {
                weakSelf.top_longPressCheckItemHandler(indexPath.item, selected);
            }
            if (weakSelf.top_longPressCalculateSelectedHander) {
                weakSelf.top_longPressCalculateSelectedHander();
            }
        };
        
        cell.top_clickToJump = ^{
            if (weakSelf.top_clickTxtNote) {
                weakSelf.top_clickTxtNote(weakSelf.listArray,indexPath);
            }
        };
        
        cell.top_clickOCRToJump = ^{
            if (weakSelf.top_clickTxtOCR) {
                weakSelf.top_clickTxtOCR(weakSelf.listArray,indexPath);
            }
        };
        sendCell = cell;
    }else{
        TOPGirdDocDetailTypeThirdCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPGirdDocDetailTypeThirdCell class]) forIndexPath:indexPath];
        cell.model = model;
        cell.markCellId = self.markCellId;
        weakify(self);
        cell.top_ChoseBtnBlock = ^(BOOL selected) {
            model.selectStatus = selected;
            if (weakSelf.top_longPressCheckItemHandler) {
                weakSelf.top_longPressCheckItemHandler(indexPath.item, selected);
            }
            if (weakSelf.top_longPressCalculateSelectedHander) {
                weakSelf.top_longPressCalculateSelectedHander();
            }
        };
        
        cell.top_clickToJump = ^{
            if (weakSelf.top_clickTxtNote) {
                weakSelf.top_clickTxtNote(weakSelf.listArray,indexPath);
            }
        };
        
        cell.top_clickOCRToJump = ^{
            if (weakSelf.top_clickTxtOCR) {
                weakSelf.top_clickTxtOCR(weakSelf.listArray,indexPath);
            }
        };
        sendCell = cell;
    }
    return sendCell;
}
#pragma mark - Event
- (void)top_handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [self indexPathForItemAtPoint:[longPress locationInView:self]];
            if (indexPath == nil) {
                break;
            }
            
            if (indexPath.section>0) {
                DocumentModel *model = self.listArray[indexPath.item];
                if (!model.isAd) {
                    if (self.selectBoxModel) {
                        if (self.selectBoxModel.functionType == TopFunctionTypePDFExtract) {
                            return;
                        }
                    }
                    
                    if (![TOPScanerShare shared].isEditing) {
                        for (DocumentModel * model in self.listArray) {
                            if (!model.isAd) {
                                model.selectStatus = NO;
                            }
                        }
                    }
                    
                    if (![TOPScanerShare shared].isManualSorting) {
                        [TOPScanerShare shared].isEditing = YES;
                        NSArray *cells = [self visibleCells];
                        NSLog(@"这个cell的数量 %ld",cells.count);
                        
                        UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
                        if ([cell isKindOfClass:[TOPGridTwoCollectionViewCell class]]) {
                            TOPGridTwoCollectionViewCell *cell11 = (TOPGridTwoCollectionViewCell*)cell;
                            model.selectStatus = YES;
                            cell11.choseBtn.selected = YES;
                        }else if ([cell isKindOfClass:[TOPGirdTwoFolderCollectionViewCell class]]){
                            TOPGirdTwoFolderCollectionViewCell *cell12 = (TOPGirdTwoFolderCollectionViewCell*)cell;
                            model.selectStatus = YES;
                            cell12.choseBtn.selected = YES;
                        }else if ([cell isKindOfClass:[TOPGridThreeCollectionViewCell class]]){
                            TOPGridThreeCollectionViewCell *cell21 = (TOPGridThreeCollectionViewCell*)cell;
                            model.selectStatus = YES;
                            cell21.choseBtn.selected = YES;
                        }else if ([cell isKindOfClass:[TOPGirdThreeFolderCollectionViewCell class]]){
                            TOPGirdThreeFolderCollectionViewCell *cell22 = (TOPGirdThreeFolderCollectionViewCell*)cell;
                            model.selectStatus = YES;
                            cell22.choseBtn.selected = YES;
                        }else if ([cell isKindOfClass:[TOPGridDocDetailCollectionViewCell class]]){
                            TOPGridDocDetailCollectionViewCell *cell22 = (TOPGridDocDetailCollectionViewCell*)cell;
                            model.selectStatus = YES;
                            cell22.choseBtn.selected = YES;
                        }else if ([cell isKindOfClass:[TOPGirdDocDetailTypeFirstCell class]]){
                            TOPGirdDocDetailTypeFirstCell *cell22 = (TOPGirdDocDetailTypeFirstCell*)cell;
                            model.selectStatus = YES;
                            cell22.choseBtn.selected = YES;
                        }else if ([cell isKindOfClass:[TOPGirdDocDetailTypeThirdCell class]]){
                            TOPGirdDocDetailTypeThirdCell *cell22 = (TOPGirdDocDetailTypeThirdCell*)cell;
                            model.selectStatus = YES;
                            cell22.choseBtn.selected = YES;
                        }
                        
                        for (UICollectionViewCell *cell in cells) {
                            if ([cell isKindOfClass:[TOPGridTwoCollectionViewCell class]]) {
                                [(TOPGridTwoCollectionViewCell*)cell top_showSelectBtn];
                            }else if ([cell isKindOfClass:[TOPGirdTwoFolderCollectionViewCell class]]){
                                [(TOPGirdTwoFolderCollectionViewCell*)cell top_showSelectBtn];
                            }else if ([cell isKindOfClass:[TOPGridThreeCollectionViewCell class]]){
                                [(TOPGridThreeCollectionViewCell*)cell top_showSelectBtn];
                            }else if ([cell isKindOfClass:[TOPGirdThreeFolderCollectionViewCell class]]){
                                [(TOPGirdThreeFolderCollectionViewCell*)cell top_showSelectBtn];
                            }else if ([cell isKindOfClass:[TOPGridDocDetailCollectionViewCell class]]){
                                [(TOPGridDocDetailCollectionViewCell*)cell top_showSelectBtn];
                            }else if ([cell isKindOfClass:[TOPGirdDocDetailTypeFirstCell class]]){
                                [(TOPGirdDocDetailTypeFirstCell*)cell top_showSelectBtn];
                            }else if ([cell isKindOfClass:[TOPGirdDocDetailTypeThirdCell class]]){
                                [(TOPGirdDocDetailTypeThirdCell*)cell top_showSelectBtn];
                            }
                        }
                        
                        if (self.top_longPressEditHandler) {
                            self.top_longPressEditHandler(indexPath);
                        }
                        if (self.top_longPressCheckItemHandler) {
                            self.top_longPressCheckItemHandler(indexPath.item, YES);
                        }
                        if (self.top_longPressCalculateSelectedHander) {
                            self.top_longPressCalculateSelectedHander();
                        }
                    }
                }
        
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
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isMoveState) {
        if (indexPath.section>0) {
            return YES;
        }else{
            return NO;
        }
    }else{
       return NO;
    }
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    DocumentModel *model1 = self.listArray[sourceIndexPath.item];
    if (!model1.isAd) {
        [self.listArray removeObject:model1];
        [self.listArray insertObject:model1 atIndex:destinationIndexPath.item];
         NSLog(@"From %ld  to   %ld",sourceIndexPath.item, destinationIndexPath.item);
        if (self.top_movePhotoIndexPathHandler) {
            self.top_movePhotoIndexPathHandler(sourceIndexPath.item, destinationIndexPath.item,self.listArray);
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
        DocumentModel *model = self.listArray[indexPath.item];
        if (!model.isAd) {
            if ([TOPScanerShare shared].isEditing) {
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                if ([cell isKindOfClass:[TOPGridTwoCollectionViewCell class]]) {
                    TOPGridTwoCollectionViewCell *cell1 = (TOPGridTwoCollectionViewCell*)cell;
                    cell1.choseBtn.selected = ! cell1.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if ([cell isKindOfClass:[TOPGirdTwoFolderCollectionViewCell class]]){
                    TOPGirdTwoFolderCollectionViewCell *cell2 = (TOPGirdTwoFolderCollectionViewCell*)cell;
                    cell2.choseBtn.selected = ! cell2.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if ([cell isKindOfClass:[TOPGridThreeCollectionViewCell class]]){
                    TOPGridThreeCollectionViewCell *cell21 = (TOPGridThreeCollectionViewCell*)cell;
                    cell21.choseBtn.selected = ! cell21.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if ([cell isKindOfClass:[TOPGirdThreeFolderCollectionViewCell class]]){
                    TOPGirdThreeFolderCollectionViewCell *cell22 = (TOPGirdThreeFolderCollectionViewCell*)cell;
                    cell22.choseBtn.selected = ! cell22.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if ([cell isKindOfClass:[TOPGridDocDetailCollectionViewCell class]]){
                    TOPGridDocDetailCollectionViewCell *cell22 = (TOPGridDocDetailCollectionViewCell*)cell;
                    cell22.choseBtn.selected = ! cell22.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if ([cell isKindOfClass:[TOPGirdDocDetailTypeFirstCell class]]){
                    TOPGirdDocDetailTypeFirstCell *cell22 = (TOPGirdDocDetailTypeFirstCell*)cell;
                    cell22.choseBtn.selected = ! cell22.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if ([cell isKindOfClass:[TOPGirdDocDetailTypeThirdCell class]]){
                    TOPGirdDocDetailTypeThirdCell *cell22 = (TOPGirdDocDetailTypeThirdCell*)cell;
                    cell22.choseBtn.selected = ! cell22.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }
                if (_isMerge) {
                    //在pdf合成界面 选中状态下的folder类文件夹 只有跳转的block 然后立马return 其他情况才有其他事件的block
                    if ([model.type isEqualToString:@"0"]) {
                        //是folder文件夹就push到另外一个控制器
                        if (self.top_pushNextControllerHandler) {
                            self.top_pushNextControllerHandler(model);
                        }
                        return;
                    }
                }
                
                if (self.top_longPressCheckItemHandler) {
                    self.top_longPressCheckItemHandler(indexPath.item,  model.selectStatus);
                }
                if (self.top_longPressCalculateSelectedHander) {
                    self.top_longPressCalculateSelectedHander();
                }
            }else{
                if ([TOPWHCFileManager top_isFileAtPath:model.path]) {
                    //防止cell快速二次点击
                    if (self.isSelect == false) {
                        self.isSelect = true;
                        //在延时方法中将isSelect更改为false
                        [self performSelector:@selector(top_repeatDelay) withObject:nil afterDelay:0.5f];
                        // TODO:在下面实现点击cell需要实现的逻辑就可以了
                        if (self.top_showPhotoHandler) {
                            self.top_showPhotoHandler(self.listArray, indexPath);
                        }
                    }
                }else{
                    //是文件夹就push到另外一个控制器
                    if (self.top_pushNextControllerHandler) {
                        self.top_pushNextControllerHandler(model);
                    }
                }
            }
        }
    }
}
- (void)top_repeatDelay{
      self.isSelect = false;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        /*
        if (indexPath.section == 0) {
            TOPDocSectionOneHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier forIndexPath:indexPath];
            reusableview = headerView;
        }else{
            TOPDocumentHeadReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentHeaderIdentifier forIndexPath:indexPath];
            headerView.isShowVip = _isShowVip;
            headerView.tagBtn.selected = self.isTagSelect;
            weakify(self);
            headerView.top_DocumentHeadClickHandler = ^(NSInteger index,BOOL selected) {
                if (weakSelf.top_DocumentHomeHandler) {
                    weakSelf.top_DocumentHomeHandler(index,selected);
                }
            };
            headerView.top_tagBtnClick = ^(BOOL selected) {
                weakSelf.isTagSelect = selected;
                if (weakSelf.top_tagShow) {
                    weakSelf.top_tagShow(selected);
                }
            };
            headerView.top_freeTrial = ^{
                if (weakSelf.top_upGradeVip) {
                    weakSelf.top_upGradeVip();
                }
            };
            if (_model) {
                headerView.model = _model;
            }
            self.headerView = headerView;
            if (_isShowHeaderView) {
                headerView.hidden = NO;
            }else{
                headerView.hidden = YES;
            }
            reusableview = headerView;
        }*/
        TOPDocSectionOneHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier forIndexPath:indexPath];
        reusableview = headerView;
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
//        return CGSizeMake(TOPScreenWidth, 0.1);
    }else{
        NSInteger currentNum = [self top_getDefaultParamete];
        NSInteger lineW = self.cellPading * (currentNum-1) + self.edgeMargin * 2;
        NSInteger cellW = (TOPScreenWidth-lineW)/currentNum;
        if (self.showType == ShowTwoGoods) {
            return CGSizeMake(cellW , (TOPScreenWidth-lineW)/currentNum+85);
        }else if (self.showType == ShowThreeGoods){
            return CGSizeMake(cellW, (TOPScreenWidth-lineW)/currentNum+65);
        }else if (self.showType == ShowListGoods){
            return CGSizeMake(TOPScreenWidth, 100);
        }else {//2
            if ([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeFirst) {
                return CGSizeMake(cellW , (TOPScreenWidth-lineW)/currentNum*(251/334.0));
            }else{
                return CGSizeMake(cellW , (TOPScreenWidth-lineW)/currentNum*1.4);
            }
        }
    }
}

#pragma mark -- 根据列表的排列方式 确定横竖屏对应的列数
- (NSInteger)top_getDefaultParamete{
    NSInteger kColumnCount = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (self.showType == ShowListDetailGoods||self.showType == ShowListChildBatch) {//childVC 界面
            if (IS_IPAD) {
                kColumnCount = 3;
            }else{
                NSInteger cellCount;
                if ([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeFirst) {
                    cellCount = 1;
                }else if([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeSecond){
                    return 2;
                }else{
                    return 3;
                }
                kColumnCount = self.columns ? : cellCount;
            }
        }else{
            if ([TOPScanerShare top_listType] == ShowTwoGoods) {
                kColumnCount = 2;
            }else{
                kColumnCount = 3;
            }
        }
    }else{
        if (self.showType == ShowListDetailGoods||self.showType == ShowListChildBatch) {
            kColumnCount = 5;
        }else{
            if ([TOPScanerShare top_listType] == ShowTwoGoods) {
                kColumnCount = 3;
            }else{
                kColumnCount = 5;
            }
        }
    }
    return kColumnCount;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return UIEdgeInsetsMake(0,0, 0, 0);
    }else{
        CGFloat top = 10;
        if (self.showType == ShowTwoGoods) {
           return UIEdgeInsetsMake(top, self.edgeMargin, 0, self.edgeMargin);
        }else if (self.showType == ShowThreeGoods){
            return UIEdgeInsetsMake(top, self.edgeMargin, 0, self.edgeMargin);
        }else if (self.showType == ShowListGoods){
            return UIEdgeInsetsMake(0,0, 0, 0);
        }else if (self.showType == ShowListDetailGoods){
            return UIEdgeInsetsMake(top, self.edgeMargin, 0,self.edgeMargin);
        }else{
            return UIEdgeInsetsZero;
        }
    }
}
#pragma mark -- 水平方向距离
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
                 minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else{
        if (self.showType == ShowListGoods) {
            return 0;
        }else if (self.showType == ShowThreeGoods){
            return 10;
        }else if (self.showType == ShowListDetailGoods){
           return self.cellPading;
       }else{
           return 10;
       }
    }
}
#pragma mark -- 垂直方向距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else{
        if (self.showType == ShowListGoods) {
            return 0;
        }else if (self.showType == ShowThreeGoods){
            return 10;
        }else if (self.showType == ShowListDetailGoods){
            if ([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeThird) {
                return self.cellPading+1;
            }
            return self.cellPading;
        }else{
            return 10;
        }
    }
}

- (void)setShowType:(TOPDocumentListShowType)showType{
    _showType = showType;
    self.cellPading = 10;
    if (_showType == ShowTwoGoods) {
       self.edgeMargin = 10;
    }else if (_showType == ShowThreeGoods){
        self.edgeMargin = 10;
    }else if (_showType == ShowListGoods){
        self.edgeMargin = 10;
    }else if (_showType == ShowListDetailGoods){
        if ([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeThird) {
            self.cellPading = 5;
        }
        self.edgeMargin = self.columns == 3 ? 10 : 15;
    }
    [self reloadData];
}

- (void)setModel:(TOPTagsListModel *)model{
    _model = model;
}

- (void)setIsShowHeaderView:(BOOL)isShowHeaderView{
    _isShowHeaderView = isShowHeaderView;
    [self reloadData];
}
- (void)setIsShowVip:(BOOL)isShowVip{
    if ([TOPUserInfoManager shareInstance].isVip) {//用户订阅之后不再显示
        _headerH = TopView_H;
        _isShowVip = NO;
    }else{
        if (_isShowVip) {//头部的vip提示试图出现了之后如果没有订阅 那么在整个app生命周期内都是显示的
            _headerH = TopView_H+70;
        }else{
            _isShowVip = isShowVip;
            if (isShowVip) {
                _headerH = TopView_H+70;
            }else{
                _headerH = TopView_H;
            }
        }
    }
    [self reloadData];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.bounces = YES;
    self.alwaysBounceVertical = YES;
    _contentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
    if (self.top_didScrollBlock) {
        self.top_didScrollBlock();
    }
    
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    BOOL isBottom = NO;
    if (bottomOffset <= height - 30) { //在最底部
        isBottom = YES;
    } else {
        isBottom = NO;
    }
    if (self.top_didScrolInBottom) {
        self.top_didScrolInBottom(isBottom);
    }
    //下拉时头偏移量达到50显示头部视图(如果头部还没有没有显示的话)  向上滚动开始就隐藏头部视图(如果头部视图已经显示的话)
    CGFloat thresholdY = -50;
    CGFloat newContentOffsetY = scrollView.contentOffset.y;
    if (self.top_scrollAndSendContentOffset) {
        self.top_scrollAndSendContentOffset(newContentOffsetY);
    }
    if (newContentOffsetY - self.lastPosY > 25) {//向上滚动
        self.lastPosY = newContentOffsetY;
        if (self.lastPosY > _contentOffsetY && _oldContentOffsetY > _contentOffsetY) {//排除scrollView自动回弹的情况
            if (self.top_deceleratingEndAndHide) {
                self.top_deceleratingEndAndHide();
            }
        }
    } else if (self.lastPosY - newContentOffsetY > 25) {//向下滚动
        self.lastPosY = newContentOffsetY;
        if (newContentOffsetY < thresholdY) {
            if (self.top_deceleratingAndShow) {
                self.top_deceleratingAndShow(newContentOffsetY);
            }
        }
    }
}

// 完成拖拽(手指离开屏幕前)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _oldContentOffsetY = scrollView.contentOffset.y;
    if (self.top_scrollDidEndDecelerating) {
        self.top_scrollDidEndDecelerating();
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
    if (self.top_endDraggingBlock) {
        self.top_endDraggingBlock();
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.top_scrollDidEndDecelerating) {
        self.top_scrollDidEndDecelerating();
    }
}
- (void)dealloc{
    
}
@end
