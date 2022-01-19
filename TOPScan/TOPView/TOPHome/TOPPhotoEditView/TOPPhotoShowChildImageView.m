#define kPanHeight 250
#define kMaxZoom 3.0
#define TopView_H 44
#define Bottom_H 60
#define NoteView_H 300

#import "TOPPhotoShowChildImageView.h"
#import "TOPShowPicCollectionViewCell.h"
#import "TOPShowPicTextCollectionViewCell.h"
#import "TOPShowPicOCRCell.h"
#import "TOPPhotoEditView.h"
#import "TOPOcrModel.h"
#import "TOPLocalFlowLayout.h"
@interface TOPPhotoShowChildImageView()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
{
    BOOL isShowEditView;
    BOOL isZoom;//缩放图片时作为不走scrollView滑动结束的代理方法的判定属性
}
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIView *topWhiteView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) TOPPhotoEditView *upView;
@property (nonatomic, strong) TOPPhotoEditView *downView;
@property (nonatomic, strong) NSMutableDictionary *allOCRDic;//获取所有裁剪和没裁剪的图片数据
@property (nonatomic, strong) NSMutableDictionary * cellDic;
@property (nonatomic, copy)NSString * backIconName;
@property (nonatomic, assign) CGFloat pagH;
@end
@implementation TOPPhotoShowChildImageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        if (isRTL()) {
            self.backIconName = @"top_RTLbackItem";
        }else{
            self.backIconName = @"top_backItem";
        }
        isShowEditView = YES;
        isZoom = YES;
        self.pagH = 23;
        [self top_setupUI];
        [self top_setUpEditView];
    }
    return self;
}

#pragma mark -- collectionView and delegate
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        //滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
         
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//防止UICollectionView的contentView发生20像素的偏移
//        _collectionView.alwaysBounceHorizontal = YES;
        [_collectionView registerClass:[TOPShowPicCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPShowPicCollectionViewCell class])];
        [_collectionView registerClass:[TOPShowPicTextCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPShowPicTextCollectionViewCell class])];
        [_collectionView registerClass:[TOPShowPicOCRCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPShowPicOCRCell class])];
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    if (self.showType == TOPPhotoShowViewImageType) {
        TOPShowPicCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPShowPicCollectionViewCell class]) forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.item];
        cell.top_clickItem = ^{
            [weakSelf top_dismissImageBrowser];
        };
        
        cell.top_clickZoom = ^{
            [weakSelf top_dismissImageAction];
        };
        cell.top_sendZoomScale = ^(CGFloat zoomScale) {
            [weakSelf top_setCollectionScrollState:zoomScale];
        };
        return cell;
    }else if (self.showType == TOPPhotoShowViewTextType){
        TOPShowPicTextCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPShowPicTextCollectionViewCell class]) forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.item];
        cell.top_clickToOcr = ^{
            [weakSelf top_photoShow_OcrAgain];
        };
        cell.top_scrollBeginHide = ^{
            if ([weakSelf.delegate respondsToSelector:@selector(top_photoShowChildImageViewScrollBeginHide)]) {
                [weakSelf.delegate top_photoShowChildImageViewScrollBeginHide];
            }
        };
        cell.top_scrollEndShow = ^{
            if ([weakSelf.delegate respondsToSelector:@selector(top_photoShowChildImageViewScrollEndShow)]) {
                [weakSelf.delegate top_photoShowChildImageViewScrollEndShow];
            }
        };
        return cell;
    }else if (self.showType == TOPPhotoShowViewTextAgain){
        TOPShowPicCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPShowPicCollectionViewCell class]) forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.item];
        cell.top_scrollBeginShow = ^{
            if ([weakSelf.delegate respondsToSelector:@selector(top_photoShowChildImageViewTextAgainScrollBeginShow)]) {
                [weakSelf.delegate top_photoShowChildImageViewTextAgainScrollBeginShow];
            }
        };
        cell.top_scrollEndHide = ^{
            if ([weakSelf.delegate respondsToSelector:@selector(top_photoShowChildImageViewTextAgainScrollEndHide)]) {
                [weakSelf.delegate top_photoShowChildImageViewTextAgainScrollEndHide];
            }
        };
        cell.top_clickItem = ^{
        };
        
        cell.top_clickZoom = ^{
        };
        return cell;
    }else if(self.showType == TOPPhotoShowViewTextOCR){
        // 每次先从字典中根据IndexPath取出唯一标识符
        NSString *identifier = [self.cellDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
        if (identifier == nil) {
            // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
            identifier = [NSString stringWithFormat:@"myCell%@", [NSString stringWithFormat:@"%@", indexPath]];
            [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
            // 注册Cell
            [self.collectionView registerClass:[TOPShowPicOCRCell class]  forCellWithReuseIdentifier:identifier];
        }
        TOPShowPicOCRCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.item];
        return cell;
    }else{
        return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showType == TOPPhotoShowViewImageType) {
        return CGSizeMake(TOPScreenWidth, TOPScreenHeight);
    }else if (self.showType == TOPPhotoShowViewTextType){
        return CGSizeMake(TOPScreenWidth, TOPScreenHeight);
    }else if (self.showType == TOPPhotoShowViewTextAgain){
        return CGSizeMake(TOPScreenWidth, _textAgainCellH);
    }else if (self.showType == TOPPhotoShowViewTextOCR){
        return CGSizeMake(TOPScreenWidth, TOPScreenHeight-TOPStatusBarHeight-TOPBottomSafeHeight-Bottom_H-TopView_H);
    }else{
        return CGSizeMake(0.1, 0.1);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark -- 当图片在放缩状态时不让collectionView滑动
- (void)top_setCollectionScrollState:(CGFloat)zoomScale{
    if (zoomScale == 1.0) {
        self.collectionView.scrollEnabled = YES;
    }else{
        self.collectionView.scrollEnabled = NO;
    }
}

- (NSArray *)imageTopTempArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageTopViewActionBack),@(TOPPhotoShowViewImageTopViewActionTailoring),@(TOPPhotoShowViewImageTopViewActionRotating),@(TOPPhotoShowViewImageTopViewActionSelect),@(TOPPhotoShowViewImageTopViewActionSignature)];
    return tempArray;
}

- (NSArray *)imageBottomArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageBottomViewActionShare),@(TOPPhotoShowViewImageBottomViewActionEmail),@(TOPPhotoShowViewImageBottomViewActionSaveGallery),@(TOPPhotoShowViewImageBottomViewActionDelecte),@(TOPPhotoShowViewImageBottomViewActionMore)];
    return tempArray;
}

- (NSArray *)textTopRocgnTempArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageTopViewActionBack),@(TOPPhotoShowViewImageTopViewActionRecogn)];
    return tempArray;
}

- (NSArray *)textBottomArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageBottomViewActionEdit),@(TOPPhotoShowViewImageBottomViewActionCopy),@(TOPPhotoShowViewImageBottomViewActionTranslation),@(TOPPhotoShowViewImageBottomViewActionExport)];
    return tempArray;
}

- (NSArray *)textTopTempArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageTopViewActionBack)];
    return tempArray;
}

- (NSArray *)textAgainTopTempArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageTopViewActionBack),@(TOPPhotoShowViewImageTopViewActionSaveText),@(TOPPhotoShowViewImageTopViewActionShareText)];
    return tempArray;
}

- (NSArray *)textAgainBottomTempArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageTopViewActionRecogn),@(TOPPhotoShowViewImageBottomViewActionCopy),@(TOPPhotoShowViewImageBottomViewActionTranslation),@(TOPPhotoShowViewImageBottomViewActionExport)];
    return tempArray;
}


- (NSArray *)ocrTempSubArray{
    NSArray * teampArray = @[@(TOPPhotoShowViewImageTopViewActionBack),@(TOPPhotoShowViewImageBottomViewActionOcrNum),@(TOPPhotoShowViewImageTopViewActionOCRLanguage),@(TOPPhotoShowViewImageTopViewActionOCRStart)];
    return teampArray;
}

- (NSArray *)ocrTempArray{
    NSArray * teampArray = @[@(TOPPhotoShowViewImageTopViewActionBack),@(TOPPhotoShowViewImageTopViewActionOCRLanguage),@(TOPPhotoShowViewImageTopViewActionOCRStart)];
    return teampArray;
}
#pragma mark -- 懒加载

- (UILabel *)pageLabel{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, TOPScreenHeight- Bottom_H - TOPBottomSafeHeight-30-30, 100, 30)];
        _pageLabel.backgroundColor = RGBA(36, 196, 164, 0.7);
        _pageLabel.font = [self fontsWithSize:13];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.clipsToBounds = YES;//layer.masksToBounds = YES;
        _pageLabel.layer.cornerRadius = self.pagH/2;
    }
    return _pageLabel;
}

- (TOPPhotoEditView*)upView{
    if (!_upView) {
        _upView = [[TOPPhotoEditView alloc] initWithFrame:CGRectMake(0, TOPStatusBarHeight, TOPScreenWidth, TopView_H) withType:0];
        _upView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
    return _upView;
}

- (TOPPhotoEditView*)downView{
    if (!_downView) {
        _downView = [[TOPPhotoEditView alloc] initWithFrame:CGRectMake(0, TOPScreenHeight -TOPBottomSafeHeight - Bottom_H, TOPScreenWidth, Bottom_H) withType:1];
        _downView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
    return _downView;
}

- (void)top_setupUI{
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
}

- (void)top_setUpEditView{
    UIView * topWhiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPStatusBarHeight)];
    topWhiteView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.topWhiteView = topWhiteView;
    
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight -TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.bottomView = bottomView;
    
    [self addSubview:self.upView];
    [self addSubview:self.downView];
    [self addSubview:topWhiteView];
    [self addSubview:bottomView];
    [self addSubview:self.pageLabel];
    
    [self.upView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self).offset(TOPStatusBarHeight);
        make.height.mas_equalTo(TopView_H);
    }];
    
    [self.downView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H);
    }];
    
    [topWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(TOPStatusBarHeight);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    
    [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-(Bottom_H+TOPBottomSafeHeight+self.pagH));
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(self.pagH);
    }];
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
}

- (void)setTextAgainCellH:(CGFloat)textAgainCellH{
    _textAgainCellH = textAgainCellH;
}

- (void)setConstantType:(TOPCollectionConstantType)ConstantType{
    if (ConstantType == TOPCollectionConstantTypeAuto) {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self).offset(TOPNavBarAndStatusBarHeight);
            make.bottom.equalTo(self.mas_centerY).offset(-(44));
        }];
    }else{
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self).offset(TOPNavBarAndStatusBarHeight);
            make.height.mas_equalTo(_textAgainCellH);
        }];
    }
}
- (NSMutableDictionary *)allOCRDic{
    if (!_allOCRDic) {
        _allOCRDic = [NSMutableDictionary new];
    }
    return _allOCRDic;
}

- (NSMutableDictionary *)cellDic{
    if (!_cellDic) {
        _cellDic = [NSMutableDictionary new];
    }
    return _cellDic;
}

- (void)setShowType:(TOPPhotoShowViewShowType)showType{
    _showType = showType;
    NSArray * upArray = [NSArray new];
    NSArray * downImgArray = [NSArray new];
    NSArray * downTitleArray = [NSArray new];
    if (_showType == TOPPhotoShowViewImageType) {
        upArray = @[self.backIconName,@"top_cutImg",@"top_revolveImg",@"top_jumpPage",@"top_signature"];
        downImgArray = @[@"top_downview_share",@"top_sendToEmail",@"top_saveToFolder",@"top_downview_selectdelete",@"top_morefunction"];
        downTitleArray = @[NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_savetogallery", @""),NSLocalizedString(@"topscan_delete", @""),NSLocalizedString(@"topscan_more", @"")];
    }else if (_showType == TOPPhotoShowViewTextType){
        //此种情况下需要先判断当前选中的图片有没有ocr文档
        DocumentModel * currentModel = self.dataArray[self.currentIndex];
        downImgArray = @[@"top_txtedit",@"top_ocr_textcopy",@"top_ocr_texttranslation",@"top_ocr_txtexport"];
        downTitleArray = @[NSLocalizedString(@"topscan_ocrtexttdit", @""),NSLocalizedString(@"topscan_ocrtextcopy", @""),NSLocalizedString(@"topscan_ocrtexttranslation", @""),NSLocalizedString(@"topscan_ocrtextexport", @"")];
        if ([TOPWHCFileManager top_isExistsAtPath:currentModel.ocrPath]) {
            upArray = @[self.backIconName,@"top_ocrAgain"];
        }else{
            upArray = @[self.backIconName];
        }
    }else if(_showType == TOPPhotoShowViewTextAgain){
        upArray = @[self.backIconName,@"top_ocr_savetext",@"top_saveshare"];
        downImgArray = @[@"top_ocr_again",@"top_ocr_textcopy",@"top_ocr_texttranslation",@"top_ocr_txtexport"];
        downTitleArray = @[NSLocalizedString(@"topscan_ocrtextagain", @""),NSLocalizedString(@"topscan_ocrtextcopy", @""),NSLocalizedString(@"topscan_ocrtexttranslation", @""),NSLocalizedString(@"topscan_ocrtextexport", @"")];
    }else if (_showType == TOPPhotoShowViewTextOCR){
        if ([self top_isShowOcrNumberButStates]) {
            upArray = @[self.backIconName,@"top_credits_ocrNum",@"ocrLan",@"top_ocrstart"];
        }else{
            upArray = @[self.backIconName,@"ocrLan",@"top_ocrstart"];
        }
        [self.downView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(Bottom_H);
        }];
        [self top_defaultDownViewFream];
    }
    
    self.upView.upArray = upArray;
    self.downView.downImgArray = downImgArray;
    self.downView.downTitleArray = downTitleArray;
    self.upView.enterType = _showType;
    
    [self.upView top_creatView];
    [self.downView top_creatView];
    [self top_loadViewData];
}

- (BOOL )top_isShowOcrNumberButStates{
    BOOL  upArrayStates;
    if ([TOPSubscriptTools getSubscriptStates] ) {
        if ([TOPSubscriptTools getCurrentSubscriptIdentifyNum] >0) {
            upArrayStates = NO;
        }else{
            upArrayStates = YES;
        }
    }else{
        if ([TOPSubscriptTools getCurrentFreeIdentifyNum]>0 || [TOPSubscriptTools getCurrentUserBalance] >0) {
            upArrayStates = YES;
        }else{
            upArrayStates = NO;
        }
    }
    NSLog(@"====是否要显示余额或免费识别点数===%d",upArrayStates);
    return upArrayStates;
}

- (void)top_loadViewData{
    WS(weakSelf);
    self.upView.photoEditUpClickHandler = ^(NSInteger index) {
        NSArray * tempArray = [NSArray new];
        if (weakSelf.showType == TOPPhotoShowViewImageType) {
            [FIRAnalytics logEventWithName:@"PhotoShowViewImageType" parameters:nil];
            tempArray = [weakSelf imageTopTempArray];
        }else if(weakSelf.showType == TOPPhotoShowViewTextType){
            [FIRAnalytics logEventWithName:@"PhotoShowViewTextType" parameters:nil];
            DocumentModel * model = weakSelf.dataArray[weakSelf.currentIndex];
            //有无ocr文档 对应不同的数据源
            if ([TOPWHCFileManager top_isExistsAtPath:model.ocrPath]) {
                tempArray = [weakSelf textTopRocgnTempArray];
            }else{
                tempArray = [weakSelf textTopTempArray];
            }
        }else if (weakSelf.showType == TOPPhotoShowViewTextAgain){
            [FIRAnalytics logEventWithName:@"PhotoShowViewTextAgain" parameters:nil];
            tempArray = [weakSelf textAgainTopTempArray];
        }else if(weakSelf.showType == TOPPhotoShowViewTextOCR){
            if ([weakSelf top_isShowOcrNumberButStates]) {
                [FIRAnalytics logEventWithName:@"isShowOcrNumberButStates" parameters:nil];
                tempArray = [weakSelf ocrTempSubArray];
            }else{
                [FIRAnalytics logEventWithName:@"notShowOcrNumberButStates" parameters:nil];
                tempArray = [weakSelf ocrTempArray];
            }
        }
        NSNumber * num = tempArray[index];
        switch ([num integerValue]) {
            case TOPPhotoShowViewImageTopViewActionBack:
                //返回
                [weakSelf top_backUpNextController];
                break;
            case TOPPhotoShowViewImageTopViewActionTailoring:
                //图片编辑 再次剪切
                [weakSelf top_photoShow_ToEdit];
                break;
            case TOPPhotoShowViewImageTopViewActionRotating:
                //旋转
                [weakSelf top_photoShow_Rotation];
                break;
            case TOPPhotoShowViewImageTopViewActionSelect:
                //选择图片
                [weakSelf top_photoShow_ScrollViewToSelect];
                break;
            case TOPPhotoShowViewImageTopViewActionSignature://涂鸦
                [weakSelf top_photoShow_signatureImage];
                break;
            case TOPPhotoShowViewImageTopViewActionRecogn:
                //重新识别
                [weakSelf top_photoShow_OcrAgain];
            case TOPPhotoShowViewImageTopViewActionSaveText:
                //保存文本
                [weakSelf top_photoShow_SaveText];
                break;
            case TOPPhotoShowViewImageTopViewActionShareText:
                //分享文本
                [weakSelf top_photoShow_ShareText];
                break;
            case TOPPhotoShowViewImageTopViewActionOCRText:
                NSLog(@"11111");
                break;
            case TOPPhotoShowViewImageTopViewActionOCRLanguage:
                [weakSelf top_photoShow_OCRLanguage];
                break;
            case TOPPhotoShowViewImageBottomViewActionOcrNum:
                [weakSelf top_photoShow_OCRBalance];
                break;
            case TOPPhotoShowViewImageTopViewActionOCRStart:
                [weakSelf top_photoShow_OCRStart];
                break;
            default:
                break;
        }
    };
    
    self.downView.photoEditDownClickHandler = ^(NSInteger index) {
        NSArray * tempArray = [NSArray new];
        if (weakSelf.showType == TOPPhotoShowViewImageType) {
            tempArray = [weakSelf imageBottomArray];
        }else if(weakSelf.showType == TOPPhotoShowViewTextType){
            tempArray = [weakSelf textBottomArray];
        }else if (weakSelf.showType == TOPPhotoShowViewTextAgain){
            tempArray = [weakSelf textAgainBottomTempArray];
        }
        NSNumber * num = tempArray[index];
        switch ([num integerValue]) {
            case TOPPhotoShowViewImageBottomViewActionShare:
                //分享
                [weakSelf top_photoShow_ShareTipShareType:index];
                break;
            case TOPPhotoShowViewImageBottomViewActionEmail:
                //发送email
                [weakSelf top_photoShow_ShareTipShareType:index];
                break;
            case TOPPhotoShowViewImageBottomViewActionSaveGallery:
                [weakSelf top_photoShow_SaveToGalleryTip];
                break;
            case TOPPhotoShowViewImageBottomViewActionPrint:
                //打印
                [weakSelf top_photoShow_PdfPrint];
                break;
            case TOPPhotoShowViewImageBottomViewActionDelecte:
                //删除
                [weakSelf top_photoShow_PhotoEditToDelete];
                break;
            case TOPPhotoShowViewImageBottomViewActionMore:
                //更多
                [weakSelf top_photoShow_More];
                break;
            case TOPPhotoShowViewImageBottomViewActionEdit:
                //编辑
                [weakSelf top_photoShow_EditAgain];
                break;
            case TOPPhotoShowViewImageBottomViewActionCopy:
                //拷贝
                [weakSelf top_photoShow_Copy];
                break;
            case TOPPhotoShowViewImageBottomViewActionExport:
                //导出
                [weakSelf top_photoShow_Export];
                break;
            case TOPPhotoShowViewImageBottomViewActionTranslation:
                //翻译
                [weakSelf top_photoShow_Translation];
                break;
            case TOPPhotoShowViewImageTopViewActionRecogn:
                //重新识别
                if (weakSelf.showType == TOPPhotoShowViewTextAgain) {
                    [weakSelf top_photoShow_OcrAgain];
                }else{
                    [weakSelf top_photoShow_OcrAgain];
                }
                break;
            default:
                break;
        }
    };
}

#pragma mark -- 判断图片是否有原图 有原图才显示裁剪按钮
- (NSArray *)top_getOriginalPictureArray{
    NSMutableArray * tempArray = [NSMutableArray new];
    if (self.dataArray.count>0&&self.currentIndex<self.dataArray.count) {
        DocumentModel * model = self.dataArray[self.currentIndex];
        //获取原图片
        UIImage * mainImage = [UIImage imageWithContentsOfFile:model.originalImagePath];
        
        if (mainImage) {
            if (mainImage.size.width>0&&mainImage.size.height>0) {
                [tempArray addObject:model];
                [self.upView top_changeCutBtnState:NO];
            }else{
                [self.upView top_changeCutBtnState:YES];
            }
        }else{
            [self.upView top_changeCutBtnState:YES];
        }
    }
   
    return tempArray;
}

#pragma mark -- 返回
- (void)top_backUpNextController{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewBackHomeVC)]) {
        [self.delegate top_photoShowChildImageViewBackHomeVC];
    }
}

#pragma mark -- 再次剪切
- (void)top_photoShow_ToEdit{
    NSArray * tempArray = [self top_getOriginalPictureArray];
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewTailoringAgain:)]) {
        [self.delegate top_photoShowChildImageViewTailoringAgain:tempArray];
    }
}

#pragma mark -- 图片旋转
- (void)top_photoShow_Rotation{
    [FIRAnalytics logEventWithName:@"rotation" parameters:nil];
    UIImageOrientation  imgOrientation;
    imgOrientation = UIImageOrientationRight;
    DocumentModel * model = self.dataArray[self.currentIndex];
    UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //旋转后的图片
        UIImage * rotationImg = [TOPDocumentHelper top_image:img rotation:imgOrientation];
        //写入旋转的图片
        [TOPWHCFileManager top_removeItemAtPath:model.coverImagePath];
        BOOL result = [TOPDocumentHelper top_saveImage:rotationImg atPath:model.imagePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (result) {
                [self.collectionView reloadData];
            }
        });
    });
}
#pragma mark -- note
- (void)top_photoShow_signatureImage{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewShowSignatureImage:)]) {
        [self.delegate top_photoShowChildImageViewShowSignatureImage:self.currentIndex];
    }
}
#pragma mark -- ocr
- (void)top_photoShow_OcrAgain{
    
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewOcrAgain:)]) {
        [self.delegate top_photoShowChildImageViewOcrAgain:self.currentIndex];
    }
}
#pragma mark -- 保存文本
- (void)top_photoShow_SaveText{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewSaveText:)]) {
        [self.delegate top_photoShowChildImageViewSaveText:self.currentIndex];
    }
}
#pragma mark -- 分享文本
- (void)top_photoShow_ShareText{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewShareText:)]) {
        [self.delegate top_photoShowChildImageViewShareText:self.currentIndex];
    }
}
#pragma mark -- 所有数据的位置视图
- (void)top_photoShow_ScrollViewToSelect{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewScrollViewToSelect:)]) {
        [self.delegate top_photoShowChildImageViewScrollViewToSelect:self.currentIndex];
    }
}
#pragma mark -- 分享
- (void)top_photoShow_ShareTipShareType:(NSInteger)type{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewShowShareView:currentIndex:)]) {
        [self.delegate top_photoShowChildImageViewShowShareView:type currentIndex:self.currentIndex];
    }
}

#pragma mark -- 保存图片
- (void)top_photoShow_SaveToGalleryTip{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewSaveToGallery:)]) {
        [self.delegate top_photoShowChildImageViewSaveToGallery:self.currentIndex];
    }
}

#pragma mark --pdf
- (void)top_photoShow_PdfPrint{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewPrint:)]) {
        [self.delegate top_photoShowChildImageViewPrint:self.currentIndex];
    }
}
#pragma mark --more
- (void)top_photoShow_More{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewMore:)]) {
        [self.delegate top_photoShowChildImageViewMore:self.currentIndex];
    }
}
#pragma mark -- 删除
- (void)top_photoShow_PhotoEditToDelete{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewDelete:)]) {
        [self.delegate top_photoShowChildImageViewDelete:self.currentIndex];
    }
}
#pragma mark --Edit
- (void)top_photoShow_EditAgain{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewEditAgain:)]) {
        [self.delegate top_photoShowChildImageViewEditAgain:self.currentIndex];
    }
}
#pragma mark --copy
- (void)top_photoShow_Copy{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewCopy:)]) {
        [self.delegate top_photoShowChildImageViewCopy:self.currentIndex];
    }
}
#pragma mark --Export
- (void)top_photoShow_Export{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewExport:)]) {
        [self.delegate top_photoShowChildImageViewExport:self.currentIndex];
    }
}
#pragma mark --Translation
- (void)top_photoShow_Translation{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewTranlation:)]) {
        [self.delegate top_photoShowChildImageViewTranlation:self.currentIndex];
    }
}
#pragma mark --语言选择
- (void)top_photoShow_OCRLanguage{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewOCRLanguage)]) {
        [self.delegate top_photoShowChildImageViewOCRLanguage];
    }
}

#pragma mark --点击余额
- (void)top_photoShow_OCRBalance{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewOCRBalanceClick)]) {
        [self.delegate top_photoShowChildImageViewOCRBalanceClick];
    }
}
#pragma mark --返回OCR识别的图片
- (void)top_photoShow_OCRStart{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<self.dataArray.count; i++) {
        DocumentModel * docModel = self.dataArray[i];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        TOPShowPicOCRCell * ocrCell = (TOPShowPicOCRCell*)cell;
        TOPOcrModel * model = [TOPOcrModel new];
        model.isChange = ocrCell.tkImageView.isChange;
        model.ocrRect = [ocrCell.tkImageView top_currentCroppedImageRect];
        model.imgPath = docModel.imagePath;
        model.index = i;
        model.photoName = docModel.photoName;
        model.movePath = docModel.movePath;
        model.photoIndex = docModel.photoIndex;
        model.ocr = docModel.ocr;
        model.ocrPath = docModel.ocrPath;
        [tempArray addObject:model];
    }
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewOCRStarImage:currentIndex:)]) {
        [self.delegate top_photoShowChildImageViewOCRStarImage:tempArray currentIndex:self.currentIndex];
    }
}

- (void)top_dismissImageBrowser{
    if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewSwitchShowType:)]) {
        [self.delegate top_photoShowChildImageViewSwitchShowType:self->isShowEditView];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self->isShowEditView) {
            [self top_hideTopAndBottomView];
            [self top_noOCRPageLabFream];
            [self layoutIfNeeded];
        }else{
            [self top_showTopAndBottomView];
            [self top_defaultPageLabFream];
            [self layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        self->isShowEditView = !self->isShowEditView;
        self->isZoom = YES;
    }];
}

- (void)top_dismissImageAction{
    //始终隐藏switch
    if (self->isShowEditView) {
        if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewSwitchShowType:)]) {
            [self.delegate top_photoShowChildImageViewSwitchShowType:self->isShowEditView];
        }
    }

    [UIView animateWithDuration:0.3 animations:^{
        [self top_hideTopAndBottomView];
        [self top_noOCRPageLabFream];
        [self layoutIfNeeded];
        self->isZoom = NO;
    }completion:^(BOOL finished) {
        self->isShowEditView = NO;
    }];
}
#pragma mark -- 头部底部视图的显示
- (void)top_showTopAndBottomView{
    [self.upView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self).offset(TOPStatusBarHeight);
        make.height.mas_equalTo(TopView_H);
    }];
    [self.topWhiteView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(TOPStatusBarHeight);
    }];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}
#pragma mark -- 头部底部视图的隐藏
- (void)top_hideTopAndBottomView{
    [self.upView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.mas_top);
        make.height.mas_equalTo(TopView_H);
    }];
    
    [self.downView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.mas_equalTo(Bottom_H);
    }];
    
    [self.topWhiteView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(-TopView_H);
        make.height.mas_equalTo(TOPStatusBarHeight);
    }];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_bottom).offset(Bottom_H);
    }];
}
#pragma mark - UIScrollViewDelegate
#pragma mark -- 停止拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        [self top_setcurrentPage:pageIndex];
    }
}
#pragma mark -- 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.currentIndex = pageIndex;
        self->isZoom = YES;
        if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewStartScrollow:)]) {
            [self.delegate top_photoShowChildImageViewStartScrollow:self.currentIndex];
        }
    }
}
#pragma mark -- 滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        if (self->isZoom) {//缩放图片时不能走下面的内容 点击图片 左右滑动图片都可以走
            [self top_setcurrentPage:pageIndex];
        }
    }
}
- (void)top_loadCurrentData{
    if (self.showType == TOPPhotoShowViewTextAgain) {
        self.pageLabel.hidden = YES;
    }else{
        self.pageLabel.hidden = NO;
    }
    
    [self.collectionView reloadData];
    self.collectionView.scrollEnabled = YES;
    if (self.showType == TOPPhotoShowViewTextType) {//txt文档
        NSArray * upArray = [NSArray new];
        //此种情况下需要先判断当前选中的图片有没有ocr文档
        DocumentModel * currentModel = self.dataArray[self.currentIndex];
        if ([TOPWHCFileManager top_isExistsAtPath:currentModel.ocrPath]) {
            upArray = @[self.backIconName,@"top_ocrAgain"];
            [self top_defaultPageLabFream];
            [self top_AdSizeHDownViewFream];
        }else{
            upArray = @[self.backIconName];
            [self top_noOCRPageLabFream];
            [self top_defaultDownViewFream];
        }
        
        self.upView.upArray = upArray;
        [self.upView top_creatView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//添加0.05s延迟 防止动画效果冲突
            [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth,0) animated:NO];
        });
    }
    
    if (self.showType == TOPPhotoShowViewImageType) {//图片展示
        [self top_defaultPageLabFream];
        [self top_getOriginalPictureArray];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//添加0.05s延迟 防止动画效果冲突
            [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth,0) animated:NO];
        });
    }
    
    if (self.showType == TOPPhotoShowViewTextOCR) {
        [self top_defaultOCRPageLabFream];
        NSArray * upArray = [NSArray new];
        if ([self top_isShowOcrNumberButStates]) {
            upArray = @[self.backIconName,@"top_credits_ocrNum",@"ocrLan",@"top_ocrstart"];
        }else{
            upArray = @[self.backIconName,@"ocrLan",@"top_ocrstart"];
        }
        self.upView.upArray = upArray;
        [self.upView top_creatView];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(TOPNavBarAndStatusBarHeight, 0, 0, 0));
        }];
    }
}

- (void)top_resetcollectionViewContent{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}
#pragma mark -- 滑动时底部顶部视图的位置及状态
- (void)top_whenScrollowSetShowView:(DocumentModel *)currentModel{
    NSArray * upArray = [NSArray new];
    //此种情况下需要先判断当前选中的图片有没有ocr文档
    if ([TOPWHCFileManager top_isExistsAtPath:currentModel.ocrPath]) {
        upArray = @[self.backIconName,@"top_ocrAgain"];
        [self top_AdSizeHDownViewFream];
        [self top_defaultPageLabFream];
    }else{
        upArray = @[self.backIconName];
        [self top_defaultDownViewFream];
        [self top_noOCRPageLabFream];
    }
    self.upView.upArray = upArray;
    [self.upView top_creatView];
}

- (void)top_setcurrentPage:(NSInteger)pageIndex{
    self.currentIndex = pageIndex;
    if (self.showType == TOPPhotoShowViewImageType) {
        if (!self->isShowEditView) {
            [self top_noOCRPageLabFream];
        }else{
            [self top_defaultPageLabFream];
        }
        [self top_getOriginalPictureArray];
    }else if(self.showType == TOPPhotoShowViewTextType){
        //此种情况下需要先判断当前选中的图片有没有ocr文档
        DocumentModel * currentModel = [DocumentModel new];
        if (self.currentIndex<self.dataArray.count) {
            currentModel = self.dataArray[self.currentIndex];
        }
        [self top_whenScrollowSetShowView:currentModel];
    }else if (_showType == TOPPhotoShowViewTextOCR){
        [self top_defaultOCRPageLabFream];
        NSArray * upArray = [NSArray new];
        if ([self top_isShowOcrNumberButStates]) {
            upArray = @[self.backIconName,@"top_credits_ocrNum",@"ocrLan",@"top_ocrstart"];
        }else{
            upArray = @[self.backIconName,@"ocrLan",@"top_ocrstart"];
        }
        self.downView.hidden = YES;
//        [self top_defaultDownViewFream];
        self.upView.upArray = upArray;
        [self.upView top_creatView];
    }
    
    if (self.currentIndex<self.dataArray.count) {
        if ([self.delegate respondsToSelector:@selector(top_photoShowChildImageViewCurrentLocation:)]) {
            [self.delegate top_photoShowChildImageViewCurrentLocation:self.currentIndex];
        }
    }
}

- (void)setAdSizeH:(CGFloat)adSizeH{
    _adSizeH = adSizeH;
    if (self.showType == TOPPhotoShowViewTextType) {
        //此种情况下需要先判断当前选中的图片有没有ocr文档
        DocumentModel * currentModel = [DocumentModel new];
        if (self.currentIndex<self.dataArray.count) {
            currentModel = self.dataArray[self.currentIndex];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:currentModel.ocrPath]) {
            [self top_defaultPageLabFream];
            [self top_AdSizeHDownViewFream];
        }else{
            [self top_noOCRPageLabFream];
            [self top_defaultDownViewFream];
        }
    }
    
    if (self.showType == TOPPhotoShowViewImageType) {
        [self top_AdSizeHDownViewFream];
        [self top_defaultPageLabFream];
    }
     
}

- (void)top_AdSizeHDownViewFream{
    [UIView animateWithDuration:0.3 animations:^{
        [self.downView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.bottom.equalTo(self).offset(-TOPBottomSafeHeight-self->_adSizeH);
            make.height.mas_equalTo(Bottom_H);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)top_defaultDownViewFream{
    [UIView animateWithDuration:0.3 animations:^{
        [self.downView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(Bottom_H);
        }];
        [self.downView.superview layoutIfNeeded];
    }];
}
- (void)top_defaultOCRPageLabFream{
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)self.dataArray.count];
    CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.pageLabel.text Height:self.pagH Font:18].width+20;
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-(Bottom_H+TOPBottomSafeHeight-10));
        make.width.mas_equalTo(getWidth);
        make.height.mas_equalTo(self.pagH);
    }];
}
- (void)top_defaultPageLabFream{
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)self.dataArray.count];
    CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.pageLabel.text Height:self.pagH Font:18].width+20;
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-(Bottom_H+TOPBottomSafeHeight+10+self->_adSizeH));
        make.width.mas_equalTo(getWidth);
        make.height.mas_equalTo(self.pagH);
    }];
}
- (void)top_noOCRPageLabFream{
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)self.dataArray.count];
    CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.pageLabel.text Height:self.pagH Font:18].width+20;
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-(Bottom_H+TOPBottomSafeHeight-self.pagH-20+self->_adSizeH));
        make.width.mas_equalTo(getWidth);
        make.height.mas_equalTo(self.pagH);
    }];
}
@end

