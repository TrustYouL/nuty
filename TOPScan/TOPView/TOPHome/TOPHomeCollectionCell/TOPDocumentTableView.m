#define TopView_H 55

#import "TOPDocumentTableView.h"
#import "TOPListFolderTableViewCell.h"
#import "TOPListTableViewCell.h"
#import "TOPListTableViewTagsCell.h"
#import "TOPListTitleTableViewCell.h"
#import "TOPListNativeAdCell.h"
@interface TOPDocumentTableView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) CGFloat oldContentOffsetY;
@property (nonatomic, assign) CGFloat contentOffsetY;
@property (nonatomic, assign) CGFloat lastPosY;//记录上次滚动偏移量Y轴

@property (nonatomic, assign) NSInteger headerH;
@end
@implementation TOPDocumentTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        _lastPosY = 0;
        _isMerge = NO;
        _isCan = YES;
        _headerH = TopView_H;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.dataSource = self;
        self.delegate = self;
        self.bounces = YES;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[TOPListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewCell class])];
        [self registerClass:[TOPListFolderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListFolderTableViewCell class])];
        [self registerClass:[TOPListTableViewTagsCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewTagsCell class])];
        [self registerClass:[TOPListTitleTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTitleTableViewCell class])];
        [self registerClass:[TOPListNativeAdCell class] forCellReuseIdentifier:NSStringFromClass([TOPListNativeAdCell class])];
    }
    return self;;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
}
- (NSMutableArray *)listArray{
    if (!_listArray) {
        _listArray = [NSMutableArray new];
    }
    return _listArray;
}

- (void)addGestureRecognizer{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    [self addGestureRecognizer:longPress];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TOPListTitleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTitleTableViewCell class]) forIndexPath:indexPath];
        cell.titleLab.text = self.showName;
        return cell;
    }else{
        DocumentModel *model = self.listArray[indexPath.row-1];
        if (!model.adModel) {
            if ([model.type isEqualToString:@"0"]) {
                TOPListFolderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListFolderTableViewCell class]) forIndexPath:indexPath];
                cell.isMerge = _isMerge;
                cell.model = model;
                weakify(self);
                cell.top_ChoseBtnBlock = ^(BOOL selected){
                    model.selectStatus = selected;
                    if (weakSelf.top_longPressCheckItemHandler) {
                        weakSelf.top_longPressCheckItemHandler(indexPath.row-1, selected);
                    }
                    if (weakSelf.top_longPressCalculateSelectedHander) {
                        weakSelf.top_longPressCalculateSelectedHander();
                    }
                };
                return cell;
            }else{
                if (model.tagsArray.count>0||model.collectionstate) {
                    TOPListTableViewTagsCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewTagsCell class]) forIndexPath:indexPath];
                    cell.model = model;
                    weakify(self);
                    cell.top_ChoseBtnBlock = ^(BOOL selected){
                        model.selectStatus = selected;
                        if (weakSelf.top_longPressCheckItemHandler) {
                            weakSelf.top_longPressCheckItemHandler(indexPath.row-1, selected);
                        }
                        if (weakSelf.top_longPressCalculateSelectedHander) {
                            weakSelf.top_longPressCalculateSelectedHander();
                        }
                    };
                    return cell;
                }else{
                    TOPListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewCell class]) forIndexPath:indexPath];
                    cell.model = model;
                    weakify(self);
                    cell.top_ChoseBtnBlock = ^(BOOL selected){
                        model.selectStatus = selected;
                        if (weakSelf.top_longPressCheckItemHandler) {
                            weakSelf.top_longPressCheckItemHandler(indexPath.row-1, selected);
                        }
                        if (weakSelf.top_longPressCalculateSelectedHander) {
                            weakSelf.top_longPressCalculateSelectedHander();
                        }
                    };
                    return cell;
                }
            }
        }else{
            TOPListNativeAdCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListNativeAdCell class])];
            DocumentModel *nativeAd = self.listArray[indexPath.row-1];
            cell.nativeAd = nativeAd;
            return cell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    weakify(self);
    TOPDocumentHeadReusableView * headerView = [[TOPDocumentHeadReusableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 60)];
    headerView.isShowVip = _isShowVip;
    headerView.tagBtn.selected = self.isTagSelect;
    headerView.top_DocumentHeadClickHandler = ^(NSInteger index,BOOL selected) {
        if (weakSelf.top_DocumentHomeHandler) {
            weakSelf.top_DocumentHomeHandler(index,selected);
        }
    };
    headerView.top_tagBtnClick = ^(BOOL selected) {
        weakSelf.isTagSelect = selected;//记录最右边按钮的选中状态
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
    self.tipHeaderView = headerView;
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 0)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (self.isFromSecondFolderVC) {
            return 50;
        }else{
            return 0;
        }
    }else{
        DocumentModel *model = self.listArray[indexPath.row-1];
        if (!model.isAd) {
            if ([model.type isEqualToString:@"0"]) {
                return 50;
            }else{
                return 110;
            }
        }else{
            return 110;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isShowHeaderView) {
        return _headerH;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (self.top_clickToChangeName) {
            self.top_clickToChangeName();
        }
    }
    if (indexPath.row>0) {
        DocumentModel *model = self.listArray[indexPath.row-1];
        if (!model.isAd) {
            if ([[TOPScanerShare shared] isEditing]) {
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass:[TOPListFolderTableViewCell class]]) {
                    TOPListFolderTableViewCell * cell11 = (TOPListFolderTableViewCell *)cell;
                    cell11.choseBtn.selected = ! cell11.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else if([cell isKindOfClass:[TOPListTableViewCell class]]){
                    TOPListTableViewCell * cell22 = (TOPListTableViewCell *)cell;
                    cell22.choseBtn.selected = ! cell22.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }else{
                    TOPListTableViewTagsCell * cell33 = (TOPListTableViewTagsCell *)cell;
                    cell33.choseBtn.selected = ! cell33.choseBtn.selected;
                    model.selectStatus = !model.selectStatus;
                }
                
                //在pdf合成界面
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
                    self.top_longPressCheckItemHandler(indexPath.row-1, model.selectStatus);
                }
                if (self.top_longPressCalculateSelectedHander) {
                    self.top_longPressCalculateSelectedHander();
                }
                
            }else{
                //这里判断是否有子文件夹，有的话就push到另一个页面
                //如果是文件
                if ([TOPWHCFileManager top_isFileAtPath:model.path]) {
                        
                    //防止cell快速二次点击
                    if (self.isSelect == false) {
                        self.isSelect = true;
                        //在延时方法中将isSelect更改为false
                        [self performSelector:@selector(top_repeatDelay) withObject:nil afterDelay:0.5f];
                        // TODO:在下面实现点击cell需要实现的逻辑就可以了
                        //那就展示图片
                        NSMutableArray *pathArray = [NSMutableArray array];
                        for (DocumentModel *model1 in self.listArray) {
                            if (model.path) {
                                [pathArray addObject:model1.path];
                            }
                        }
                        if (pathArray.count) {
                            if (self.top_showPhotoHandler) {
                                self.top_showPhotoHandler(pathArray, indexPath);
                            }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([TOPScanerShare shared].isEditing) {
        return NO;
    }else{
        if (indexPath.row>0) {
            DocumentModel *model = self.listArray[indexPath.row-1];
            if (!model.isAd) {//不是广告
                return _isCan;
            }else{//若是广告不能侧滑
                return NO;
            }
        }else{
            return NO;
        }
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    DocumentModel * currentModel = self.listArray[indexPath.row-1];
    if (!currentModel.isAd) {
        NSMutableArray * tempArray = [NSMutableArray new];
        for (int i = 0; i<self.listArray.count; i++) {
            if ([self.listArray[i] isKindOfClass:[DocumentModel class]]) {
                [tempArray addObject:self.listArray[i]];
            }
        }
        for (DocumentModel * model in self.listArray) {
            if (!model.isAd) {
                if ([self.listArray indexOfObject:model] == indexPath.row-1) {
                    model.selectStatus = YES;
                }else{
                    model.selectStatus = NO;
                }
            }
        }
        if ([currentModel.type isEqualToString:@"0"]) {
            //重命名
            UIContextualAction *renameRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_siderename", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                if (self.top_clickSideToRename) {
                    self.top_clickSideToRename();
                }
                completionHandler(NO);//这个属性是点击按钮之后恢复到原来的状态 测试发现大于ios13的版本设置为YES和设置为NO效果是一样的，小于ios13版本的设置为YES反而有问题 所有为了兼容版本就设置为NO

            }];
            renameRowAction.image = [UIImage imageNamed:@"top_sideRename"];
            renameRowAction.backgroundColor = RGBA(39, 43, 47, 1.0);
            
            //删除
            UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_delete", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                if (self.top_clickSideToDelete) {
                    self.top_clickSideToDelete();
                }
                completionHandler(NO);
            }];
            deleteRowAction.image = [UIImage imageNamed:@"top_sideDelete"];
            deleteRowAction.backgroundColor = [UIColor redColor];
            
            UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction,renameRowAction]];
            return config;
        }else{
            //分享
            UIContextualAction *shareRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_share", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                if (self.top_clickSideToShare) {
                    self.top_clickSideToShare();
                }
                completionHandler(NO);

            }];
            shareRowAction.image = [UIImage imageNamed:@"top_tvcontentShare"];
            shareRowAction.backgroundColor = RGBA(176, 176, 176, 1.0);
            
            //发送email
            UIContextualAction *emailRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_email", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                if (self.top_clickSideToEmail) {
                    self.top_clickSideToEmail();
                }
                completionHandler(NO);

            }];
            emailRowAction.image = [UIImage imageNamed:@"top_sideEmail"];
            emailRowAction.backgroundColor = RGBA(104, 153, 228, 1.0);
        
            //重命名
            UIContextualAction *renameRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_siderename", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                if (self.top_clickSideToRename) {
                    self.top_clickSideToRename();
                }
                completionHandler(NO);
                
            }];
            renameRowAction.image = [UIImage imageNamed:@"top_sideRename"];
            renameRowAction.backgroundColor = RGBA(39, 43, 47, 1.0);
            
            //删除
            UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_delete", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                if (self.top_clickSideToDelete) {
                    self.top_clickSideToDelete();
                }
                completionHandler(NO);
            }];
            deleteRowAction.image = [UIImage imageNamed:@"top_sideDelete"];
            deleteRowAction.backgroundColor = [UIColor redColor];
            
            UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction,renameRowAction,emailRowAction,shareRowAction]];
            return config;
        }
    }else{
        return nil;
    }
}

#pragma mark - Event
- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [self indexPathForRowAtPoint:[longPress locationInView:self]];
            if (indexPath == nil) {
                break;
            }
            if (indexPath.row>0) {
                DocumentModel *model = self.listArray[indexPath.row-1];
                if (!model.isAd) {
                    [TOPScanerShare shared].isEditing = YES;
                    NSArray *cells = [self visibleCells];
                    
                    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
                    if ([cell isKindOfClass:[TOPListFolderTableViewCell class]]) {
                        TOPListFolderTableViewCell * cell11 = (TOPListFolderTableViewCell *)cell;
                        model.selectStatus = YES;
                        cell11.choseBtn.selected = YES;
                    }else if([cell isKindOfClass:[TOPListTableViewCell class]]){
                        TOPListTableViewCell * cell22 = (TOPListTableViewCell *)cell;
                        model.selectStatus = YES;
                        cell22.choseBtn.selected = YES;
                    }else if([cell isKindOfClass:[TOPListTableViewTagsCell class]]){
                        TOPListTableViewTagsCell * cell33 = (TOPListTableViewTagsCell *)cell;
                        model.selectStatus = YES;
                        cell33.choseBtn.selected = YES;
                    }
         
                    for (UICollectionViewCell * cell in cells) {
                        if ([cell isKindOfClass:[TOPListFolderTableViewCell class]]) {
                            [(TOPListFolderTableViewCell *)cell top_showSelectBtn];
                        }else if([cell isKindOfClass:[TOPListTableViewCell class]]){
                            [(TOPListTableViewCell *)cell top_showSelectBtn];
                        }else if([cell isKindOfClass:[TOPListTableViewTagsCell class]]){
                            [(TOPListTableViewTagsCell *)cell top_showSelectBtn];
                        }
                    }
                    
                    if (self.top_longPressEditHandler) {
                        self.top_longPressEditHandler(indexPath);
                    }
                    if (self.top_longPressCheckItemHandler) {
                        self.top_longPressCheckItemHandler(indexPath.row-1, model.selectStatus);
                    }
                    if (self.top_longPressCalculateSelectedHander) {
                        self.top_longPressCalculateSelectedHander();
                    }
                    [self reloadData];
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            }
            break;
        case UIGestureRecognizerStateEnded: {
            }
            break;
        default:
            break;
    }
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

- (void)setModel:(TOPTagsListModel *)model{
    _model = model;
    [self reloadData];
}

- (void)setIsMerge:(BOOL)isMerge{
    _isMerge = isMerge;
    [self reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _contentOffsetY = scrollView.contentOffset.y;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
    NSLog(@"newContentOffsetY==%f",newContentOffsetY);
    
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
    } else if (self.lastPosY - newContentOffsetY > 25) {
        self.lastPosY = newContentOffsetY;
        if (newContentOffsetY < thresholdY) {
            if (self.top_deceleratingAndShow) {
                self.top_deceleratingAndShow(newContentOffsetY);
            }
        }
    }
    
}

// 完成拖拽(滚动停止时调用此方法，手指离开屏幕前)
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


@end
