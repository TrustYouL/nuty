#import "TOPChildMoreView.h"
#import "TOPChildMoreCollectionCell.h"
#import "TOPHeadMenuModel.h"
#import "TOPHeadMenuCell.h"
#define Space 10
#define MaxItemCount 4 //collectionView 一行最多4个item
#define Row_H 50
@interface TOPChildMoreView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *headMenuView;
@property (nonatomic ,strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *iconArray;
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^selectBlock)(NSInteger);
@property (nonatomic, strong) UICollectionView *bottomCollectionView;
@property (nonatomic, assign) CGPoint containerOrigin;
@property (nonatomic, strong) UIView * myView;
@property (nonatomic, strong) UIButton * cancelBtn;
@end
@implementation TOPChildMoreView

- (instancetype)initWithTitleView:(UIView *)titleView optionsArr:(NSArray *)optionsArr iconArr:(NSArray *)iconArr cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^)(void))cancelBlock selectBlock:(void (^)(NSInteger))selectBlock
{
    if (self = [super init]) {
        self.dataSource = [NSArray array];
        self.iconArray = [NSArray array];
        self.headView = titleView;
        self.dataSource = optionsArr;
        self.iconArray = iconArr;
        self.cancelTitle = cancelTitle;
        self.cancelBlock = cancelBlock;
        self.selectBlock = selectBlock;
        [self top_createUI];
    }
    return self;
    
}

- (UIView *)myView{
    if (!_myView) {
        _myView = [UIView new];
        _myView.backgroundColor = [UIColor clearColor];
    }
    return _myView;
}

- (void)top_createUI
{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
    
    [self addSubview:self.maskView];
    [self addSubview:self.bottomCollectionView];
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    cancelBtn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:[UIColor whiteColor]];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_dismissView) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.layer.cornerRadius = 10;
    [self addSubview:cancelBtn];
    self.cancelBtn = cancelBtn;
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    
    if (IS_IPAD) {
        [self.bottomCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(Row_H*(self.dataSource.count));
            make.width.mas_equalTo(IPAD_CELLW);
        }];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(Row_H*(self.dataSource.count+1)+10);
            make.height.mas_equalTo(Row_H);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.bottomCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(Space);
            make.trailing.equalTo(self).offset(-Space);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(Row_H*(self.dataSource.count));
        }];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(Space);
            make.trailing.equalTo(self).offset(-Space);
            make.bottom.equalTo(self).offset(Row_H*(self.dataSource.count+1)+10);
            make.height.mas_equalTo(Row_H);
        }];
    }
    
    [self layoutIfNeeded];
    [self top_showView];
}

- (void)top_updateWithNewData {
    if (self.menuItems.count) {
        [self.bottomCollectionView reloadData];
    }
}

- (void)setShowHeadMenu:(BOOL)showHeadMenu {
    _showHeadMenu = showHeadMenu;
    if (_showHeadMenu) {
        [self.bottomCollectionView removeFromSuperview];
        self.cancelBtn.hidden = YES;
        self.bottomCollectionView = nil;
        [self addSubview:self.headMenuView];
        [self.headMenuView addSubview:self.collectionView];
        [self.headMenuView addSubview:self.bottomCollectionView];
        [self top_addUIPanGestureRecognizer];
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ovalBtn.frame = CGRectMake(TOPScreenWidth - 30 - 15, 15, 30, 30);
        [ovalBtn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
        [self.headMenuView addSubview:ovalBtn];
        [ovalBtn addTarget:self action:@selector(top_clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        
        if (IS_IPAD) {
            [self.headMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self.mas_bottom);
                make.height.mas_equalTo((Row_H*(self.dataSource.count)+Space+156)+TOPBottomSafeHeight);
                make.width.mas_equalTo(IPAD_CELLW);
            }];
        }else{
            [self.headMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self);
                make.top.equalTo(self.mas_bottom);
                make.height.mas_equalTo((Row_H*(self.dataSource.count)+Space+156)+TOPBottomSafeHeight);
            }];
        }
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.headMenuView);
            make.top.equalTo(self.headMenuView).offset(15+15+30);
            make.height.mas_equalTo(88);
        }];
        [self.bottomCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.headMenuView).offset(Space);
            make.trailing.equalTo(self.headMenuView).offset(-Space);
            make.top.equalTo(self.collectionView.mas_bottom).offset(Space);
            make.height.mas_equalTo(Row_H*(self.dataSource.count));
        }];
        [ovalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headMenuView).offset(15);
            make.trailing.equalTo(self.headMenuView).offset(-15);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        [self layoutIfNeeded];
    }else{
        self.cancelBtn.hidden = NO;
    }
    
    [self top_showView];
}

- (void)top_addUIPanGestureRecognizer{
    UIPanGestureRecognizer * ges = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(top_panGestureRecognized:)];
    ges.delegate = self;
    [self.headMenuView addGestureRecognizer:ges];
}

- (void)top_panGestureRecognized:(UIPanGestureRecognizer *)recognizer{
    CGPoint point = [recognizer translationInView:self];
    CGFloat headMenuViewH = 0;
    CGFloat headMenuViewChangeH = (Row_H*(self.dataSource.count)+Space+156)+TOPBottomSafeHeight;
    //弹框高度是否达到整个屏幕的一半
    if (headMenuViewChangeH<TOPScreenHeight/2) {
        headMenuViewH = Row_H*(self.dataSource.count)+Space+156;
    }else{
        headMenuViewH = Row_H*(self.dataSource.count-2)+Space+156;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.containerOrigin = recognizer.view.frame.origin;
        NSLog(@"containerOriginyyyy===%f",self.containerOrigin.y);
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGRect frame = recognizer.view.frame;
        frame.origin.y = self.containerOrigin.y + point.y;
        if (frame.origin.y<=TOPScreenHeight-headMenuViewChangeH) {
            if (IS_IPAD) {
                [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.width.mas_equalTo(IPAD_CELLW);
                    make.bottom.equalTo(self).offset(0);
                    make.height.mas_equalTo(headMenuViewChangeH);
                }];
            }else{
                [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(self);
                    make.bottom.equalTo(self).offset(0);
                    make.height.mas_equalTo(headMenuViewChangeH);
                }];
            }
            [recognizer.view.superview layoutIfNeeded];
        }else{
            if (IS_IPAD) {
                [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.width.mas_equalTo(IPAD_CELLW);
                    make.top.equalTo(self).offset(self.containerOrigin.y + point.y);
                    make.height.mas_equalTo(headMenuViewChangeH);
                }];
            }else{
                [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(self);
                    make.top.equalTo(self).offset(self.containerOrigin.y + point.y);
                    make.height.mas_equalTo(headMenuViewChangeH);
                }];
            }
            
            [recognizer.view.superview layoutIfNeeded];
        }
    }
    
    CGFloat bottomH = 0.0 ;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frame = recognizer.view.frame;
        if (frame.origin.y>=TOPScreenHeight-headMenuViewH) {
            if (frame.origin.y>=TOPScreenHeight-headMenuViewH+180) {
                [self top_dismissView];
            }else{
                if (headMenuViewChangeH<TOPScreenHeight/2) {
                    bottomH = 0 ;
                }else{
                    bottomH = 2*Row_H;
                }
                [UIView animateWithDuration:0.3 animations:^{
                    if (IS_IPAD) {
                        [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.centerX.equalTo(self);
                            make.width.mas_equalTo(IPAD_CELLW);
                            make.bottom.equalTo(self).offset(bottomH);
                            make.height.mas_equalTo(headMenuViewChangeH);
                        }];
                    }else{
                        [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.leading.trailing.equalTo(self);
                            make.bottom.equalTo(self).offset(bottomH);
                            make.height.mas_equalTo(headMenuViewChangeH);
                        }];
                    }
                    
                    [recognizer.view.superview layoutIfNeeded];
                }];
            }
        }
        
        if (frame.origin.y<TOPScreenHeight-headMenuViewH) {
            bottomH = 0 ;
            [UIView animateWithDuration:0.3 animations:^{
                if (IS_IPAD) {
                    [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.equalTo(self);
                        make.width.mas_equalTo(IPAD_CELLW);
                        make.bottom.equalTo(self.mas_bottom);
                        make.height.mas_equalTo(headMenuViewChangeH);
                    }];
                }else{
                    [recognizer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.equalTo(self);
                        make.bottom.equalTo(self.mas_bottom);
                        make.height.mas_equalTo(headMenuViewChangeH);
                    }];
                }
                [recognizer.view.superview layoutIfNeeded];
            }];
        }
    }
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTapAction:)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

#pragma mark -- add视图会调用 视图fream改变时也会调用 逻辑处理时要注意
- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)top_clickTapAction:(UIGestureRecognizer *)tap{
    self.cancelBlock();
    [self top_dismissView];
}

- (void)top_showView
{
    if (self.showHeadMenu) {
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat bottomH ;
            //弹框高度是否达到整个屏幕的一半
            if ((Row_H*(self.dataSource.count)+Space+156)<TOPScreenHeight/2) {
                bottomH = 0;
            }else{
                bottomH = 2*Row_H + TOPStatusBarHeight;
            }
            if (IS_IPAD) {
                [self.headMenuView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.width.mas_equalTo(IPAD_CELLW);
                    make.bottom.equalTo(self).offset(bottomH);
                    make.height.mas_equalTo((Row_H*(self.dataSource.count)+Space+156)+TOPBottomSafeHeight);
                }];
            }else{
                [self.headMenuView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(self);
                    make.bottom.equalTo(self).offset(bottomH);
                    make.height.mas_equalTo((Row_H*(self.dataSource.count)+Space+156)+TOPBottomSafeHeight);
                }];
            }
            self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
            [self layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.bottomCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_bottom).offset(-(Row_H*(self.dataSource.count+1)+10+TOPBottomSafeHeight));
            }];
            
            [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(-TOPBottomSafeHeight);
            }];
            self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
            [self layoutIfNeeded];
        }];
    }
}

- (void)top_dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        if (self.showHeadMenu) {
            if (IS_IPAD) {
                [self.headMenuView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.width.mas_equalTo(IPAD_CELLW);
                    make.top.equalTo(self.mas_bottom);
                    make.height.mas_equalTo((Row_H*(self.dataSource.count)+Space+156)+TOPBottomSafeHeight);
                }];
            }else{
                [self.headMenuView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(self);
                    make.top.equalTo(self.mas_bottom);
                    make.height.mas_equalTo((Row_H*(self.dataSource.count)+Space+156)+TOPBottomSafeHeight);
                }];
            }
        }else{
            [self.bottomCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_bottom);
            }];
            
            [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(Row_H*(self.dataSource.count+1)+10);
            }];
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)top_clickCloseBtn {
    self.cancelBlock();
    [self top_dismissView];
}

#pragma mark -UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _collectionView) {
        return self.headMenuItems.count;
    }else{
        return self.dataSource.count ;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _collectionView) {
        TOPHeadMenuCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPHeadMenuCell class]) forIndexPath:indexPath];
        TOPHeadMenuModel * model = self.headMenuItems[indexPath.item];
        [cell top_congfigCellWithData:model];
        return cell;
    }else{
        TOPChildMoreCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPChildMoreCollectionCell class]) forIndexPath:indexPath];
        cell.showTime = [self top_setNoticeTime];
        cell.titlestring = self.dataSource[indexPath.row];
        cell.iconImg.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
        if (indexPath.row < self.menuItems.count) {
            TOPHomeMoreFunction func = [self.menuItems[indexPath.row] integerValue];
            if (func == TOPHomeMoreFunctionEmailMySelef) {
                cell.showVip = ![TOPPermissionManager top_enableByEmailMySelf];
            } else if (func == TOPHomeMoreFunctionPDFPassword) {
                cell.showVip = ![TOPPermissionManager top_enableByPDFPassword];
            } else if (func == TOPHomeMoreFunctionUpload || func ==  TOPPhotoShowViewImageBottomViewActionUpload) {
                cell.showVip = ![TOPPermissionManager top_enableByUploadFile];
            } else {
                cell.showVip = NO;
            }
        }
        if (indexPath.row == self.dataSource.count-1) {
            cell.lineView.hidden = YES;
        }else{
            cell.lineView.hidden = NO;
        }
        
        cell.titleLab.text = self.dataSource[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _collectionView) {
        if (self.top_selectedHeadMenuBlock) {
            self.top_selectedHeadMenuBlock(indexPath.item);
        }
        [self top_dismissView];
    }else{
        if (self.selectBlock) {
            self.selectBlock(indexPath.row);
        }
        self.cancelBlock();
        [self top_dismissView];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.bottomCollectionView) {
        if (IS_IPAD) {
            return CGSizeMake(IPAD_CELLW, Row_H);
        }else{
            return CGSizeMake(TOPScreenWidth-Space*2, Row_H);
        }
    }else{
        CGFloat lineSpace = 10;
        NSInteger itemCount = MIN(MaxItemCount, self.headMenuItems.count);//最多显示4个
        CGFloat itemWidth = 0;
        if (IS_IPAD) {
            itemWidth = 90;
        }else{
            itemWidth = (TOPScreenWidth - lineSpace*(itemCount +1) )/itemCount;
            if (self.headMenuItems.count > MaxItemCount) {
                itemWidth = ((TOPScreenWidth - lineSpace*4 - 10 )/4.5);
            }
        }
        return CGSizeMake(itemWidth, 78);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (collectionView == self.bottomCollectionView) {
        return UIEdgeInsetsMake(0, 10, 0, 10);
    }else{
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
}
#pragma mark -- doc提醒时间
- (NSString *)top_setNoticeTime{
    NSString * showTime = [NSString new];
    if (!self.docModel.docNoticeLock) {//文档提醒是关闭状态就不显示
        showTime = nil;
    }else{
        NSComparisonResult result = [self.docModel.remindTime compare:[NSDate date]];
        if (result == NSOrderedAscending || result == NSOrderedSame) {//文档提醒设置的时间失效就不显示
            showTime = nil;
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setDateFormat:@"MMM/dd/yyyy HH:mm"];
            showTime = [dateFormatter stringFromDate:self.docModel.remindTime];
        }
    }
    return showTime;
}

#pragma mark -- lazy
- (UIView *)headMenuView {
    if (!_headMenuView) {
        _headMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-10)];
        _headMenuView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kCommonGrayWhiteBgColor];
        _headMenuView.layer.cornerRadius = 10;
    }
    return _headMenuView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        CGFloat lineSpace = 10;
        NSInteger itemCount = MIN(MaxItemCount, self.headMenuItems.count);//最多显示4个
        CGFloat itemWidth = 0;
        if (IS_IPAD) {
            itemWidth = 90;
        }else{
            itemWidth = (TOPScreenWidth - lineSpace*(itemCount +1) )/itemCount;
            if (self.headMenuItems.count > MaxItemCount) {
                itemWidth = ((TOPScreenWidth - lineSpace*4 - 10 )/4.5);
            }
        }
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(itemWidth, 88);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 15+15+30,TOPScreenWidth , 88) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kCommonGrayWhiteBgColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPHeadMenuCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPHeadMenuCell class])];
    }
    return _collectionView;
}

- (UICollectionView *)bottomCollectionView{
    if (!_bottomCollectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        if (IS_IPAD) {
            layout.itemSize = CGSizeMake(IPAD_CELLW, Row_H);
        }
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _bottomCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(Space, -TOPScreenHeight, TOPScreenWidth-2*Space, Row_H*(self.dataSource.count)) collectionViewLayout:layout];
        _bottomCollectionView.dataSource = self;
        _bottomCollectionView.delegate = self;
        _bottomCollectionView.scrollEnabled = NO;
        _bottomCollectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:[UIColor whiteColor]];
        _bottomCollectionView.showsVerticalScrollIndicator = NO;
        _bottomCollectionView.showsHorizontalScrollIndicator = NO;
        [_bottomCollectionView registerClass:[TOPChildMoreCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPChildMoreCollectionCell class])];
        _bottomCollectionView.layer.cornerRadius = 10;
    }
    return _bottomCollectionView;
}
@end
