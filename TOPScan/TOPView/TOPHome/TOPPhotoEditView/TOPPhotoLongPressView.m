#import "TOPPhotoLongPressView.h"
#import "TOPTabBarModel.h"

@interface TOPPhotoLongPressView()

@property(nonatomic,strong)UILabel  *chooseLabel;
@property(nonatomic,strong)UIButton *cancelBtn;
@property(nonatomic,strong)NSMutableArray *btnArray;
@property(nonatomic,strong) NSMutableArray *barItemsArray;
@property(nonatomic,strong) NSMutableArray *logoArray;

@end

@implementation TOPPhotoLongPressView

- (instancetype)initWithPressUpFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
       if (self) {
           [self top_setUpUpView];
           self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
       }
       return self;
}

- (instancetype)initWithPressBottomFrame:(CGRect)frame sendPicArray:(nonnull NSArray *)picArray sendNameArray:(nonnull NSArray *)nameArray{

    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectedImgs = picArray;
        self.isSingle = YES;
        [self top_setUpBootomViewAndsendPicArray:picArray sendNameArray:nameArray];
    }
    return self;
    
}

- (instancetype)initWithFrame:(CGRect)frame withBarItems:(NSArray *)itemArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.barItemsArray = [itemArray mutableCopy];
        self.isSingle = YES;
        [self top_setupTabbarViewWithItems];
    }
    return self;
}

- (void)top_setUpUpView{
    [self addSubview:self.allSelectBtn];
    [self addSubview:self.chooseLabel];
    [self addSubview:self.cancelBtn];
    
    [self.allSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(TOPStatusBarHeight+5);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.chooseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(100);
        make.trailing.equalTo(self).offset(-100);
        make.top.equalTo(self).offset(TOPStatusBarHeight + 8);
        make.height.mas_equalTo(18);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.top.equalTo(self).offset(TOPStatusBarHeight+5);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
}

- (void)top_changeUPViewState{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.cancelBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    self.chooseLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}

- (void)top_setUpBootomViewAndsendPicArray:(NSArray *)picArray sendNameArray:(NSArray *)nameArray{
     for (int i = 0; i < picArray.count; i ++) {
         TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
         UIImage *btnImg = [UIImage imageNamed:picArray[i]];
         [btn setImage:btnImg forState:UIControlStateNormal];
         [btn setTitle:nameArray[i] forState:UIControlStateNormal];
         btn.titleLabel.textAlignment = NSTextAlignmentCenter;
         btn.titleLabel.adjustsFontSizeToFitWidth = YES;
         [btn.titleLabel setFont:[self fontsWithSize:12]];
         [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
         btn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
         btn.tag = 1000 + i;
         [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
         [self addSubview:btn];
         [self.btnArray addObject:btn];

         if (IS_IPAD) {
             [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.top.bottom.equalTo(self);
                 make.width.mas_equalTo(120);
             }];
         }else{
             [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.top.bottom.equalTo(self);
                 make.width.mas_equalTo(70);
             }];
         }
         btn.margin = UIEdgeInsetsMake(8, 0, 8, 0);
     }
    [self top_distributeSpacingHorizontallyWith:self.btnArray];
}

- (void)top_setupTabbarViewWithItems {
    for (int i = 0; i < self.barItemsArray.count; i ++) {
        TOPTabBarModel *model = self.barItemsArray[i];
        TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
        UIImage *btnImg = [UIImage imageNamed:model.icon];
        [btn setImage:btnImg forState:UIControlStateNormal];
        [btn setTitle:model.title forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [btn.titleLabel setFont:[self fontsWithSize:12]];
        [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.btnArray addObject:btn];
        
        if (IS_IPAD) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self);
                make.width.mas_equalTo(120);
            }];
        }else{
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self);
                make.width.mas_equalTo(70);
            }];
        }
        btn.margin = UIEdgeInsetsMake(8, 0, 8, 0);
        
        if (model.showVip) {
            UIImage *noClassImg = [UIImage imageNamed:@"top_vip_logo"];
            UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
            [btn addSubview:noClass];
            [self.logoArray addObject:noClass];
            [noClass mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(btn).offset(7);
                make.trailing.equalTo(btn).offset(-8);
                make.height.width.mas_equalTo(16);
            }];
        }
    }
    [self top_distributeSpacingHorizontallyWith:self.btnArray];
}

- (void)top_refreshLogoShow:(BOOL)show {
    for (UIImageView *noClass in self.logoArray) {
        noClass.hidden = !show;
    }
}

- (void)top_setUpVipLogoUI {
    for (int i = 0; i < self.btnArray.count; i++) {
        if (i < self.barItemsArray.count) {
            TOPTabBarModel *model = self.barItemsArray[i];
            if (model.showVip) {
                TOPImageTitleButton *btn = self.btnArray[i];
                UIImage *noClassImg = [UIImage imageNamed:@"top_vip_logo"];
                UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
                [btn addSubview:noClass];
                [noClass mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.trailing.equalTo(btn);
                    make.height.width.mas_equalTo(16);
                }];
            }
        }
    }
}

- (void)top_changePressViewBtnStatue:(NSArray *)picArray enabled:(BOOL)enable{
    for (int i = 0; i<self.btnArray.count; i++) {
        TOPImageTitleButton *btn = self.btnArray[i];
        btn.enabled = enable;
        [btn setImage:[UIImage imageNamed:picArray[i]] forState:UIControlStateNormal];
        
        if (enable) {
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
        }
    }
}

- (void)top_changePressViewBtnState:(TOPItemsSelectedState)selectedState {
    switch (selectedState) {
        case TOPItemsSelectedNone:
            [self top_changePressViewBtnStatue:self.disableImgs enabled:NO];
            break;
        case TOPItemsSelectedOneDoc:
        {
            NSArray *disableFuncs = @[@(TOPMenuItemsFunctionMerge)];
            [self top_disableFunctionBtnState:disableFuncs];
        }
            break;
        case TOPItemsSelectedSomeDoc:
            [self top_changePressViewBtnStatue:self.selectedImgs enabled:YES];
            break;
        case TOPItemsSelectedOneFolder:
            [self top_disableCopyMerge];
            break;
        case TOPItemsSelectedSomeFolder:
            [self top_disableCopyMerge];
            break;
        case TOPItemsSelectedOnePic:
            [self top_changePressViewBtnStatue:self.selectedImgs enabled:YES];
            break;
        case TOPItemsSelectedSomePic:
            [self top_changePressViewBtnStatue:self.selectedImgs enabled:YES];
            break;
            
        default:
            break;
    }
    if (selectedState == (TOPItemsSelectedOneDoc | TOPItemsSelectedOneFolder)) {//不弄合并、拷贝
        [self top_disableCopyMerge];
    }
    if (selectedState == (TOPItemsSelectedOneDoc | TOPItemsSelectedSomeFolder)) {//不能合并、拷贝
        [self top_disableCopyMerge];
    }
    if (selectedState == (TOPItemsSelectedSomeDoc | TOPItemsSelectedOneFolder)) {//不弄合并、拷贝
        [self top_disableCopyMerge];
    }
    if (selectedState == (TOPItemsSelectedSomeDoc | TOPItemsSelectedSomeFolder)) {//不能合并、拷贝
        [self top_disableCopyMerge];
    }
}

#pragma mark -- 不能合并拷贝
- (void)top_disableCopyMerge {
    NSArray *disableFuncs = @[@(TOPMenuItemsFunctionMerge),@(TOPMenuItemsFunctionCopyMove)];
    [self top_disableFunctionBtnState:disableFuncs];
}

- (void)top_disableFunctionBtnState:(NSArray *)funcItems {
    [self top_changePressViewBtnStatue:self.selectedImgs enabled:YES];
    for (NSNumber *func in funcItems) {
        NSInteger btnIndex = [self.funcArray indexOfObject:func];
        TOPImageTitleButton *btn = self.btnArray[btnIndex];
        btn.enabled = NO;
        NSString *disableImg = self.disableImgs[btnIndex];
        [btn setImage:[UIImage imageNamed:disableImg] forState:UIControlStateNormal];
        [btn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
    }
}

- (void)setFuncTitles:(NSArray *)funcTitles {
    _funcTitles = funcTitles;
    for (int i = 0; i < _funcTitles.count; i++) {
        if (i < self.btnArray.count) {
            TOPImageTitleButton *btn = self.btnArray[i];
            [btn setTitle:_funcTitles[i] forState:UIControlStateNormal];
        }
    }
}

- (void)top_didSelectedFunction:(NSNumber *)item {
    if ([item integerValue] == TOPGraffitiToolTypeUndo || [item integerValue] ==  TOPGraffitiToolTypeRedo) {//没有选中效果
        return;
    }
    NSInteger btnIndex = [self.funcArray indexOfObject:item];
    for (int i = 0; i < self.funcArray.count; i ++) {
        TOPImageTitleButton *btn = self.btnArray[i];
        if (btnIndex == i) {//选中的
            UIImage *highImg = [UIImage imageNamed:self.highlightImgs[i]];
            if (highImg) {
                [btn setImage:[UIImage imageNamed:self.highlightImgs[i]] forState:UIControlStateNormal];
                [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
            }
        } else {
            [btn setImage:[UIImage imageNamed:self.selectedImgs[i]] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        }
    }
}

- (void)top_didSelectedFunctionChangeState:(NSNumber *)item{
    NSInteger btnIndex = [self.funcArray indexOfObject:item];
    for (int i = 0; i < self.funcArray.count; i ++) {
        TOPImageTitleButton *btn = self.btnArray[i];
        btn.selected = !btn.selected;
        if (btnIndex == i) {//选中的
            if (btn.selected) {
                [btn setImage:[UIImage imageNamed:self.highlightImgs[btnIndex]] forState:UIControlStateNormal];
                [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
            }else{
                [btn setImage:[UIImage imageNamed:self.selectedImgs[btnIndex]] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
            }
        }
    }
}
- (void)didSelectedFunctionNormal:(NSNumber *)item {
    NSInteger btnIndex = [self.funcArray indexOfObject:item];
    for (int i = 0; i < self.funcArray.count; i ++) {
        TOPImageTitleButton *btn = self.btnArray[i];
        if (btnIndex == i) {//选中的
            [btn setImage:[UIImage imageNamed:self.selectedImgs[i]] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        }
    }
}

- (void)top_changeShareBtnStatue:(BOOL)enable{
    TOPImageTitleButton *btn = self.btnArray[0];
    btn.enabled = enable;
    if (enable) {
        [btn setImage:[UIImage imageNamed:@"top_downview_share"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"top_downview_disableshare"] forState:UIControlStateNormal];
        [btn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
    }
}

- (void)top_changeDeleteBtnStatue:(BOOL)enable{
    TOPImageTitleButton *btn = self.btnArray.lastObject;
    btn.enabled = enable;
    if (enable) {
        [btn setImage:[UIImage imageNamed:@"top_downview_selectdelete"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"top_downview_disabledelete"] forState:UIControlStateNormal];
        [btn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
    }
}
- (void)top_allChoseAction{
    self.allSelectBtn.selected = !self.allSelectBtn.selected;
    if (self.top_selectAllHandler) {
        self.top_selectAllHandler(self.allSelectBtn.selected);
    }
}

- (void)top_cancleAction{
    if (self.top_cancleEditHandler) {
        self.top_cancleEditHandler();
    }
}

- (void)top_downAction:(UIButton*)btn{
    if (self.isSingle) {
        if (self.highlightImgs.count) {
            if (!self.highlightItems.count) {
                [self top_didSelectedFunction:[self.funcArray objectAtIndex:(btn.tag - 1000)]];
            } else {
                [self top_setHighlightItem:[self.funcArray objectAtIndex:(btn.tag - 1000)]];
            }
        }
    } else {
        btn.selected = !btn.selected;
        NSInteger btnIndex = [self.funcArray indexOfObject:[self.funcArray objectAtIndex:(btn.tag - 1000)]];
        if (btn.selected) {
            [btn setImage:[UIImage imageNamed:self.highlightImgs[btnIndex]] forState:UIControlStateNormal];
            [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        } else {
            [btn setImage:[UIImage imageNamed:self.selectedImgs[btnIndex]] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        }
    }
    
    if (self.top_longPressBootomItemHandler) {
        self.top_longPressBootomItemHandler(btn.tag - 1000);
    }
}

- (void)top_setHighlightItem:(NSNumber *)item {
    if ([self.highlightItems containsObject:item]) {
        NSInteger btnIndex = [self.funcArray indexOfObject:item];
        TOPImageTitleButton *btn = self.btnArray[btnIndex];
        if (btn.selected) {
            btn.selected = NO;
            [btn setImage:[UIImage imageNamed:self.selectedImgs[btnIndex]] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        } else {
            btn.selected = YES;
            [btn setImage:[UIImage imageNamed:self.highlightImgs[btnIndex]] forState:UIControlStateSelected];
            [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateSelected];
        }
    }
}

- (void)top_configureSelectedCount:(NSInteger)count{
    self.chooseLabel.text =  [NSString  stringWithFormat:@"%ld %@",count,NSLocalizedString(@"topscan_items", @"")];
}

#pragma mark -- lazy
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}

- (UIButton*)allSelectBtn{
    if (!_allSelectBtn) {
        _allSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allSelectBtn.frame = CGRectMake(TOPScreenWidth - (100), TOPStatusBarHeight + 5,  (80), (30));
        [_allSelectBtn setTitle:NSLocalizedString(@"topscan_allselect", @"") forState:UIControlStateNormal];
        [_allSelectBtn setTitle:NSLocalizedString(@"topscan_cancelallselect", @"") forState:UIControlStateSelected];
        _allSelectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _allSelectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_allSelectBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [_allSelectBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateHighlighted];
        [_allSelectBtn addTarget:self action:@selector(top_allChoseAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _allSelectBtn;
}

- (UIButton*)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, TOPStatusBarHeight + 5, (80), (30));
        [_cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(top_cancleAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelBtn;
}


- (UILabel*)chooseLabel{
    if (!_chooseLabel) {
        _chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake((100) , TOPStatusBarHeight + 8, TOPScreenWidth - (200), (18))];
        _chooseLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _chooseLabel.font = [self fontsWithSize:17];
        _chooseLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _chooseLabel;;
}

- (NSMutableArray *)logoArray {
    if (!_logoArray) {
        _logoArray = @[].mutableCopy;
    }
    return _logoArray;
}

@end
