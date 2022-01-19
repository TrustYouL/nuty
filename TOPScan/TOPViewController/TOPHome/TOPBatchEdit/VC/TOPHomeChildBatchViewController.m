#define Bottom_H 60
#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)

#import "TOPHomeChildBatchViewController.h"
#import "TOPPhotoLongPressView.h"
#import "TOPBatchViewController.h"
#import "TOPChildBatchCell.h"
#import "TOPNextFolderViewController.h"
#import "TOPReEditCollectionViewCell.h"
#import "TOPBatchEditModel.h"
#import "TOPDataTool.h"
#import "TOPReEditModel.h"
#import "TOPCropEditModel.h"
#import "TOPOpenCVWrapper.h"
#import "TOPProcessBatchView.h"

@interface TOPHomeChildBatchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    CGFloat picH;
    UIInterfaceOrientation faceOr;
}
@property (nonatomic ,strong) UICollectionView * collectionView;
@property (nonatomic ,strong) UIView * filterBackView;
@property (nonatomic ,strong) UICollectionView * filterCollectionView;
@property (nonatomic ,strong) TOPPhotoLongPressView * pressBatchBootomView;
@property (nonatomic ,strong) NSMutableArray * allBatchArray;
@property (nonatomic ,strong) NSMutableArray * selectArray;
@property (nonatomic ,strong) NSMutableArray * selectBatchArray;
@property (nonatomic ,strong) NSMutableArray * deleteArray;
@property (nonatomic ,strong) NSMutableArray * tempDataArray;
@property (nonatomic ,strong) NSMutableArray * filterShowArray;
@property (nonatomic ,strong) UIView * coverView;
@property (nonatomic ,strong) UIView * bottomCoverView;
@property (nonatomic ,assign) BOOL isEdit;
@property (nonatomic ,assign) BOOL isSetPoints;
@property (nonatomic ,strong) TOPProcessBatchView * progressView;
@property (nonatomic ,assign) NSInteger selectCount;
@end

@implementation TOPHomeChildBatchViewController
- (instancetype)init{
    if (self = [super init]) {
        self.isCollectionBox = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backAction)];
    }
    self.isEdit = YES;
    self.isSetPoints = NO;
    self.title = NSLocalizedString(@"topscan_batchedit", @"");
    UIButton * saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [saveBtn setTitle:NSLocalizedString(@"topscan_tagsdone", @"") forState:UIControlStateNormal];
    [saveBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(top_ClickRightItems) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = barItem;
    
    picH = ((TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)*(TOPScreenWidth-30))/TOPScreenWidth;
    faceOr = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.coverView];
    [self.view addSubview:self.filterBackView];
    [self.view addSubview:self.filterCollectionView];
    [self.filterBackView addSubview:self.filterCollectionView];
    [self top_ShowBatchEditPressUpView];
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    [self.pressBatchBootomView addSubview:self.progressView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0,Bottom_H+TOPBottomSafeHeight, 0));
    }];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom).offset(-(Bottom_H+TOPBottomSafeHeight));
        make.height.equalTo(self.view.mas_height).offset(Bottom_H+TOPBottomSafeHeight);
    }];
    [self.filterBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom).offset(-(Bottom_H+TOPBottomSafeHeight));
        make.height.mas_equalTo(100);
    }];
    [self.filterCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.filterBackView);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.pressBatchBootomView);
        make.height.mas_equalTo(3);
    }];
    [self top_loadData];
    [self top_loadFilterDefaultPic];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isCollectionBox&&[self.addType isEqualToString:@"add"]) {
        if (self.top_dataChangeAndLoadData) {
            self.top_dataChangeAndLoadData();
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.allBatchArray.count) {
        [self.collectionView reloadData];
    }
}
- (void)top_loadData{
    self.tempDataArray = @[].mutableCopy;
    self.tempDataArray = [self.dataArray mutableCopy];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AutoRelease_for (DocumentModel * model in self.dataArray) {
            TOPBatchEditModel * batchModel = [TOPBatchEditModel new];
            batchModel.docId = model.docId;
            batchModel.originalPath = model.originalImagePath;
            batchModel.photoName = model.photoName;
            batchModel.movePath = model.movePath;
            NSString *coverName = [NSString stringWithFormat:@"%@_%@",[batchModel.movePath stringByReplacingOccurrencesOfString:@"/" withString:@""],batchModel.photoName];
            batchModel.imgPath = [TOPDocumentHelper top_batchImageFile:batchModel.photoName];
            batchModel.defaultPath = [TOPDocumentHelper top_defaultBatchImageFile:batchModel.photoName];
            batchModel.coverImgPath = [TOPDocumentHelper top_batchCoverImageFile:coverName];
            batchModel.selectStatus = YES;
            batchModel.isShow = NO;
            batchModel.isChange = NO;
            NSInteger item = [self.dataArray indexOfObject:model];
            NSString * titleString = [NSString new];
            if (item+1>=10) {
                titleString = [NSString stringWithFormat:@"%ld",item+1];
            }else{
                titleString = [NSString stringWithFormat:@"0%ld",item+1];
            }
            batchModel.index = item;
            batchModel.indexString = titleString;
            [TOPWHCFileManager top_copyItemAtPath:model.imagePath toPath:batchModel.imgPath];
            [self.allBatchArray addObject:batchModel];
            self.selectCount = self.allBatchArray.count;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_changeBottomViewState];
            [self.collectionView reloadData];
        });
    });
}

#pragma mark -- 设置裁剪点数据
- (void)top_setCropPointsDataCompletion:(void (^)(void))completion {
    if (!self.isSetPoints) {
        self.isSetPoints = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger count = self.allBatchArray.count;
            for (int i = 0; i < self.allBatchArray.count; i ++) {
                @autoreleasepool {
                    if (i < self.tempDataArray.count) {
                        DocumentModel * model = self.tempDataArray[i];
                        TOPBatchEditModel * batchModel = self.allBatchArray[i];
                        [self top_getCropViewPoints:model byBatchModel:batchModel];
                    }
                    CGFloat stateF = ((count+i+1)*10.0)/((self.allBatchArray.count*2+self.selectCount)*10.0);
                    [self.progressView top_showProgress:stateF];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (completion) {
                    completion();
                }
            });
        });
    } else {
        [SVProgressHUD dismiss];
        if (completion) {
            completion();
        }
    }
}

#pragma mark -- 获取数据库保存的裁剪坐标
- (void)top_getCropViewPoints:(DocumentModel *)docModel byBatchModel:(TOPBatchEditModel*)batchModel {
    if (![TOPWHCFileManager top_isExistsAtPath:docModel.originalImagePath]) {
        return;
    }
    NSData *imgData = [NSData dataWithContentsOfFile:docModel.originalImagePath];
    UIImage *showImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(TOPScreenWidth-30, picH)];
    CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:showImg fatherW:TOPScreenWidth-30 fatherH:picH];
    batchModel.cropImgViewRect = imgRect;
    TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:docModel.docId];
    if (imgFile.filterMode) {
        batchModel.processType = imgFile.filterMode;
    } else {
        batchModel.processType = [TOPScanerShare top_defaultProcessType];
    }
    NSData *data;
    NSData *autoData;
    if (faceOr == UIInterfaceOrientationLandscapeLeft || faceOr == UIInterfaceOrientationLandscapeRight) {
        data = imgFile.landscapePoints;
        autoData = imgFile.autoLandscapePoints;
    } else {
        data = imgFile.portraitPoints;
        autoData = imgFile.atuoPortraitPoints;
    }
    UIImage *originalImg = [UIImage imageWithData:imgData];
    CGFloat scaleW = originalImg.size.width / CGRectGetWidth(imgRect);
    CGFloat scaleH = originalImg.size.height / CGRectGetHeight(imgRect);
    if (data.length) {
        NSArray *points = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (points.count > 4) {
            NSMutableArray *temp = @[].mutableCopy;
            NSMutableArray *originalTemp = @[].mutableCopy;
            for (int i = 1; i < points.count; i ++) {
                NSString *pStr = points[i];
                CGPoint point = CGPointFromString(pStr);
                CGPoint cropPoint = CGPointMake(point.x / scaleW, point.y / scaleH);
                [temp addObject:[NSValue valueWithCGPoint:cropPoint]];
                [originalTemp addObject:[NSValue valueWithCGPoint:point]];
            }
            NSString *pStr = points.firstObject;
            CGPoint sizePot = CGPointFromString(pStr);
            
            batchModel.endPoinArray = temp;
            batchModel.cropImageSize = CGSizeMake(sizePot.x, sizePot.y);
            batchModel.cropImagePointArray = originalTemp;
        }
    }
    
    if (autoData.length) {
        NSArray *points = [NSJSONSerialization JSONObjectWithData:autoData options:NSJSONReadingMutableLeaves error:nil];
        if (points.count > 4) {
            NSMutableArray *temp = @[].mutableCopy;
            for (int i = 1; i < points.count; i ++) {
                NSString *pStr = points[i];
                CGPoint point = CGPointFromString(pStr);
                CGPoint cropPoint = CGPointMake(point.x / scaleW, point.y / scaleH);
                [temp addObject:[NSValue valueWithCGPoint:cropPoint]];
            }
            batchModel.autoEndPoinArray = temp;
        }
    }
}

- (NSMutableArray *)getFullPointsWithFrame:(CGRect)imgRect {
    NSMutableArray *cropFullPoints = @[].mutableCopy;
    [cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, 0)]];
    [cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, imgRect.size.height)]];
    [cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, imgRect.size.height)]];
    return cropFullPoints;
}

#pragma mark -- filter的数据处理
- (void)top_loadFilterDefaultPic{
    if (![TOPWHCFileManager top_isExistsAtPath:TOPBatchDefaultDraw_Path]) {
        [self top_writeFilterDefaultImg];
    }else{
        [self top_getFilterDefaultImg];
    }
}

#pragma mark -- 第一次写入filter本地并展示
- (void)top_writeFilterDefaultImg{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage * drawImg = [UIImage imageNamed:@"top_batchNormal"];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPBatchDefaultDraw_Path];
        GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:drawImg];
        NSArray *processArray = [TOPPictureProcessTool top_processTypeArray];
        for (int i = 0; i<processArray.count; i++) {
            @autoreleasepool {
                NSInteger processType = [processArray[i] integerValue];
                UIImage * drawImage = [TOPDataTool top_pictureProcessData:imageSource withImg:drawImg withItem:processType];
      
                [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
                NSData *drawData = UIImageJPEGRepresentation(drawImage, TOP_TRPicScale);
                if (!drawData) {
                    drawData = [[NSData alloc] init];
                }
                NSString * fileName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                NSString *fileEndPath =  [TOPBatchDefaultDraw_Path stringByAppendingPathComponent:fileName];
                [drawData writeToFile:fileEndPath atomically:YES];
                TOPReEditModel * model = [[TOPReEditModel alloc] init];
                if (drawImage) {
                    model.dic = [TOPDataTool top_pictureProcessDatawithImg:drawImage currentItem:processType];
                }
                model.isSelect = NO;
                [weakSelf.filterShowArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_resetFilterCollectionViewFream];
            [weakSelf.filterCollectionView reloadData];
        });
    });
}

#pragma mark -- 取出保存filter的本地图片 需要对图片进行排序 保存到本地的图片是无序的
- (void)top_getFilterDefaultImg{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * compareArray = [TOPDocumentHelper top_sortPicsAtPath:TOPBatchDefaultDraw_Path];
        NSArray *processArray = [TOPPictureProcessTool top_processTypeArray];
        for (int i = 0; i < [TOPPictureProcessTool top_processTypeArray].count; i++) {
            @autoreleasepool {
                NSInteger processType = [processArray[i] integerValue];
                TOPReEditModel * model = [[TOPReEditModel alloc] init];
                UIImage * getImg = nil;
                if (i < compareArray.count) {
                    getImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",TOPBatchDefaultDraw_Path,compareArray[i]]];
                }
                if (!getImg) {
                    UIImage * drawImg = [UIImage imageNamed:@"top_batchNormal"];
                    GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:drawImg];
                    getImg = [TOPDataTool top_pictureProcessData:imageSource withImg:drawImg withItem:processType];
                    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
                }
                if (getImg) {
                    model.dic = [TOPDataTool top_pictureProcessDatawithImg:getImg currentItem:processType];
                }
                model.isSelect = NO;
                [weakSelf.filterShowArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_resetFilterCollectionViewFream];
            [weakSelf.filterCollectionView reloadData];
        });
    });
}

- (void)top_resetFilterCollectionViewFream{
    if (IS_IPAD) {
        CGFloat collectionW = self.filterShowArray.count*80+(self.filterShowArray.count+1)*10;
        [self.filterCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.filterBackView);
            make.centerX.equalTo(self.filterBackView);
            make.size.mas_equalTo(CGSizeMake(collectionW, 100));
        }];
    }
}
#pragma mark--底部视图
- (void)top_ShowBatchEditPressUpView{
    weakify(self);
    SS(strongSelf);
    if (!strongSelf.pressBatchBootomView) {
        NSArray * sendPicArray = [strongSelf sendBatchPicArray];
        NSArray * sendNameArray = [strongSelf sendBatchNameArray];
        strongSelf.pressBatchBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight - (Bottom_H), TOPScreenWidth, (Bottom_H)) sendPicArray:sendPicArray sendNameArray:sendNameArray];
        strongSelf.pressBatchBootomView.isSingle = NO;
        strongSelf.pressBatchBootomView.disableImgs = [strongSelf batchPicArray];
        strongSelf.pressBatchBootomView.funcArray = [strongSelf batchfuncItems];
        strongSelf.pressBatchBootomView.highlightImgs = [strongSelf sendBatchSelectPicArray];
        strongSelf.pressBatchBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            [weakSelf top_Batch_InvokeMenuFunctionAtIndex:index];
        };
        [self.view addSubview:strongSelf.pressBatchBootomView];
        [strongSelf.pressBatchBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(Bottom_H);
        }];
    }
}

#pragma mark -- 更改底部视图按钮的状态
- (void)top_changeBottomViewState{
    if (self.selectCount == 0) {
        [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedNone];
    }else{
        [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedOnePic];
    }
}

#pragma mark -- 调用底部菜单事件
- (void)top_Batch_InvokeMenuFunctionAtIndex:(NSInteger)index{
    NSMutableArray * selectTempArray = [NSMutableArray new];
    for (TOPBatchEditModel * model in self.allBatchArray) {
        if (model.selectStatus) {
            [selectTempArray addObject:model];
        }
    }
    if (selectTempArray.count == 0) {
        return;
    }
    NSArray *funcIndexArray = [self funcItems];
    NSNumber *funcNum = funcIndexArray[index];
    switch ([funcNum integerValue]) {
        case TOPMenuItemsFunctionDelete:
            [self top_deleteSelectItem];
            break;
        case TOPMenuItemsFunctionLeft:
            [FIRAnalytics logEventWithName:@"homeChildBatch_ImageOrientationLeft" parameters:nil];
            [self top_topMenuItemsRotateImage:UIImageOrientationLeft];
            break;
        case TOPMenuItemsFunctionRight:
            [FIRAnalytics logEventWithName:@"homeChildBatch_ImageOrientationRight" parameters:nil];
            [self top_topMenuItemsRotateImage:UIImageOrientationRight];
            break;
        case TOPMenuItemsFunctionCrop:
        {
            [FIRAnalytics logEventWithName:@"homeChildBatch_FunctionPushCropVC" parameters:nil];
            [self top_topMenuItemsCrop];
            [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedOnePic];
        }
            break;
        case TOPMenuItemsFunctionFilter:
            [FIRAnalytics logEventWithName:@"homeChildBatch_FunctionFilter" parameters:nil];
            [self top_topMenuItemsFilterImage];
            break;
        default:
            break;
    }
}

#pragma mark --UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.collectionView) {
        return  self.allBatchArray.count;
    }
    return self.filterShowArray.count;
}

- (__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.collectionView) {
        TOPBatchEditModel * model = self.allBatchArray[indexPath.item];
        NSInteger item = indexPath.item;
        NSString *titleString = @"";
        if (item+1>=10) {
            titleString = [NSString stringWithFormat:@"%ld",item+1];
        }else{
            titleString = [NSString stringWithFormat:@"0%ld",item+1];
        }
        model.index = item;
        model.indexString = titleString;
        TOPChildBatchCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPChildBatchCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else{
        TOPReEditCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class]) forIndexPath:indexPath];
        TOPReEditModel * model = self.filterShowArray[indexPath.item];
        cell.model = model;
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.collectionView) {
        NSInteger lineNum = [self top_getDefaultParamete];
        NSInteger spaceW = (lineNum+1)*10;
        return CGSizeMake((TOPScreenWidth-spaceW)/lineNum , (TOPScreenWidth-spaceW)/lineNum+85);
    }else{
        return CGSizeMake(80, 80);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.collectionView) {
        if (self.isEdit) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            TOPBatchEditModel * model = self.allBatchArray[indexPath.item];
            model.selectStatus = !model.selectStatus;
            TOPChildBatchCell *cell1 = (TOPChildBatchCell*)cell;
            cell1.model = model;
            if (model.selectStatus) {
                self.selectCount++;
            }else{
                self.selectCount--;
            }
            [self top_changeBottomViewState];
        }
    }else{
        NSInteger processType = [[TOPPictureProcessTool top_processTypeArray][indexPath.item] integerValue];
        self.isEdit = NO;
        [self top_addFIRAnalytics:processType];
        [self top_clickTip];
        [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedNone];
        [self.progressView show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self top_filterFuction:processType];
            for (TOPReEditModel * model in self.filterShowArray) {
                if (model.isSelect) {
                    model.isSelect = NO;
                    break;
                }
            }
            TOPReEditModel * model = self.filterShowArray[indexPath.item];
            model.isSelect = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.filterCollectionView reloadData];
            });
        });
    }
}
#pragma mark -- collectioview列数
- (NSInteger)top_getDefaultParamete{
    NSInteger lineNum = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (IS_IPAD) {
            lineNum = 3;
        }else{
            lineNum = 2;
        }
    }else{
        lineNum = 5;
    }
    return lineNum;
}

#pragma mark -- 添加埋点
- (void)top_addFIRAnalytics:(NSInteger)processType{
    switch (processType) {
        case TOPProcessTypeOriginal:
            [FIRAnalytics logEventWithName:@"childBatch_ProcessTypeOriginal" parameters:nil];
            break;
        case TOPProcessTypeMagicColor:
            [FIRAnalytics logEventWithName:@"childBatch_ProcessTypeMagicColor" parameters:nil];
            break;
        case TOPProcessTypeBW:
            [FIRAnalytics logEventWithName:@"childBatch_ProcessTypeBW" parameters:nil];
            break;
        case TOPProcessTypeBW2:
            [FIRAnalytics logEventWithName:@"childBatch_ProcessTypeBW2" parameters:nil];
            break;
        case TOPProcessTypeGrayscale:
            [FIRAnalytics logEventWithName:@"childBatch_ProcessTypeGrayscale" parameters:nil];
            break;
        case TOPProcessTypeNostalgic:
            [FIRAnalytics logEventWithName:@"childBatch_ProcessTypeNostalgic" parameters:nil];
            break;
        default:
            break;
    }
}

#pragma mark --选择渲染模式后开始处理图片
- (void)top_filterFuction:(NSInteger)processType{
    NSMutableArray * origianlArray = [NSMutableArray new];
    NSMutableArray * noOriginalImgArray = [NSMutableArray new];
    NSInteger count = 0;
    NSInteger allCount = 0;
    if (!self.isSetPoints) {
        allCount = self.allBatchArray.count*2;
    }else{
        allCount = self.allBatchArray.count;
    }
    for (TOPBatchEditModel * model in self.allBatchArray) {
        count++;
        UIImage * img = [UIImage imageWithContentsOfFile:model.originalPath];
        if (model.selectStatus) {//有原图
            if (img) {
                model.isChange = YES;
                model.isShow = YES;
                [origianlArray addObject:model];
            }else{
                [noOriginalImgArray addObject:model.indexString];
            }
        }
        CGFloat stateF = (count*10.0)/((allCount+self.selectCount)*10.0);
        [self.progressView top_showProgress:stateF];
    }
    if (origianlArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_alldatanooriginalimgfilter", @"") duration:1.5];
            [self.progressView dismiss];
            self.isEdit = YES;
            [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedOnePic];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self top_showToast:noOriginalImgArray];
        });
        __weak typeof(self) weakSelf = self;
        [self top_setCropPointsDataCompletion:^{
            [weakSelf top_starFilterPic:@(processType) dealArray:origianlArray processCount:allCount+noOriginalImgArray.count allCount:allCount+self.selectCount];
        }];
    }
}

#pragma mark --批量处理 先处理前8个 后面的一起处理
- (void)top_starFilterPic:(NSNumber *)num dealArray:(NSMutableArray *)origianlArray processCount:(NSInteger)count allCount:(NSInteger)allCount{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPProcessType processType = [num integerValue];
        WS(weakSelf);
        for (int i = 0; i<8; i++) {
            @autoreleasepool {
                if (i < origianlArray.count) {
                    TOPBatchEditModel * model  = origianlArray[i];
                    [weakSelf top_saveCropImageWithModel:model];
                    [weakSelf top_filterImage:model processType:processType];
                    CGFloat stateF = ((count+i+1)*10.0)/(allCount*10.0);
                    [weakSelf.progressView top_showProgress:stateF];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
        if (origianlArray.count > 8) {
            for (int i = 8; i < origianlArray.count; i++) {
                @autoreleasepool {
                    TOPBatchEditModel * model  = origianlArray[i];
                    [weakSelf top_saveCropImageWithModel:model];
                    [weakSelf top_filterImage:model processType:processType];
                    CGFloat stateF = ((count+i+1)*10.0)/(allCount*10.0);
                    [weakSelf.progressView top_showProgress:stateF];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedOnePic];
            [weakSelf.collectionView reloadData];
            weakSelf.isEdit = YES;
            [weakSelf.progressView dismiss];
        });
    });
}

#pragma mark -- 渲染没有原图时的提示
- (void)top_showToast:(NSMutableArray *)noOriginalImgArray{
    NSString * toastString = [NSString new];
    if (noOriginalImgArray.count>0) {
        if (noOriginalImgArray.count == 1) {
            toastString = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topscan_nooriginalimgfilter", @""),noOriginalImgArray[0]];
        }
        
        if (noOriginalImgArray.count == 2) {
            toastString = [NSString stringWithFormat:@"%@(%@,%@)",NSLocalizedString(@"topscan_nooriginalimgfilter", @""),noOriginalImgArray[0],noOriginalImgArray[1]];
        }
        
        if (noOriginalImgArray.count == 3) {
            toastString = [NSString stringWithFormat:@"%@(%@,%@,%@)",NSLocalizedString(@"topscan_nooriginalimgfilter", @""),noOriginalImgArray[0],noOriginalImgArray[1],noOriginalImgArray[2]];
        }
        
        if (noOriginalImgArray.count > 3) {
            if ([TOPScanerShare top_saveOriginalImage]==TOPSettingSaveYES) {
                toastString = [NSString stringWithFormat:@"%@(%@,%@,%@ %@)",NSLocalizedString(@"topscan_nooriginalimgfilter", @""),noOriginalImgArray[0],noOriginalImgArray[1],noOriginalImgArray[2],NSLocalizedString(@"topscan_nooriginalimgmore", @"")];
            }
            
            if ([TOPScanerShare top_saveOriginalImage]==TOPSettingSaveNO) {
                toastString = [NSString stringWithFormat:@"%@(%@,%@,%@ %@,%@)",NSLocalizedString(@"topscan_nooriginalimgfilter", @""),noOriginalImgArray[0],noOriginalImgArray[1],noOriginalImgArray[2],NSLocalizedString(@"topscan_nooriginalimgmore", @""),NSLocalizedString(@"topscan_nooriginalimgsetting", @"")];
            }
        }
        [[TOPCornerToast shareInstance] makeToast:toastString duration:1.5];
    }
}

- (void)top_saveCropImageWithModel:(TOPBatchEditModel *)model {
    UIImage * img = [UIImage imageWithContentsOfFile:model.originalPath];
    UIImage * defaultImg = [UIImage imageWithContentsOfFile:model.defaultPath];
    if (!defaultImg) {
        if (model.cropImagePointArray) {
            TOPSaveElementModel * elementModel = [TOPDataModelHandler top_getBatchSavePointData:model.endPoinArray imgPath:model.originalPath imgRect:model.cropImgViewRect];
            defaultImg = [TOPOpenCVWrapper top_getTransformedObjectImage:elementModel.saveW :elementModel.saveH :img :elementModel.pointArray :img.size];
        } else {
            defaultImg = img;
        }
    }
    [TOPDocumentHelper top_saveImage:defaultImg atPath:model.defaultPath];
}

#pragma mark -- 渲染的事件 渲染的时候底图不会做旋转 生成渲染图片后渲染图会根据展示图的图片方向做旋转
- (void)top_filterImage:(TOPBatchEditModel *)model processType:(NSInteger)processType{
    @autoreleasepool {
        UIImage * img = [UIImage imageWithContentsOfFile:model.defaultPath];
        UIImage * showImg = [UIImage imageWithContentsOfFile:model.imgPath];
        if (img) {
            img = [UIImage imageWithCGImage:[img CGImage] scale:[img scale] orientation: showImg.imageOrientation];
            GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:img];
            UIImage * drawImage = [TOPDataTool top_pictureProcessData:imageSource withImg:img withItem:processType];
            [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
        
            [TOPDocumentHelper top_saveImage:drawImage atPath:model.imgPath];

            [TOPDataModelHandler top_updateCoverImage:model.imgPath atPath:model.coverImgPath];
            model.isShow = NO;
            model.processType = processType;
        }
    }
}

#pragma mark -- 原图
- (void)top_reductionPic{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<weakSelf.dataArray.count; i++) {
            DocumentModel * model = weakSelf.dataArray[i];
            for (int j = 0; j<weakSelf.allBatchArray.count; j++) {
                TOPBatchEditModel * batchModel = weakSelf.allBatchArray[j];
                if (batchModel.selectStatus) {
                    if ([batchModel.photoName isEqualToString:model.photoName]) {
                        [TOPWHCFileManager top_copyItemAtPath:model.originalImagePath toPath:batchModel.imgPath overwrite:YES];
                        [TOPDataModelHandler top_updateCoverImage:batchModel.imgPath atPath:batchModel.coverImgPath];
                        batchModel.isShow = NO;
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            weakSelf.isEdit = YES;
        });
    });
}

#pragma mark --删除
- (void)top_deleteSelectItem{
    [FIRAnalytics logEventWithName:@"homeChildBatch_InvokeMenuFunctionDelete" parameters:nil];
    [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedOnePic];
    weakify(self);
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_deleteoption", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf top_deleteImagesHandle];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf top_changeBottomViewState];
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)top_deleteImagesHandle {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempArray = [NSMutableArray new];
        NSMutableArray *originalData = @[].mutableCopy;
        for (int i = 0; i < self.allBatchArray.count; i ++) {
            TOPBatchEditModel * model = self.allBatchArray[i];
            if (model.selectStatus) {
                [self.deleteArray addObject:model];
            } else {
                if (i < self.tempDataArray.count) {
                    DocumentModel *tempModel = self.tempDataArray[i];
                    [originalData addObject:tempModel];
                }
                [tempArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tempDataArray = [originalData mutableCopy];
            [self.allBatchArray removeAllObjects];
            self.selectCount = 0;
            self.allBatchArray = tempArray;
            [self top_changeBottomViewState];
            [self.collectionView reloadData];
        });
    });
}

#pragma mark --crop
- (void)top_topMenuItemsCrop{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * origianlArray = [NSMutableArray new];
        for (TOPBatchEditModel * model in self.allBatchArray) {
            if (model.selectStatus) {
                UIImage * img = [UIImage imageWithContentsOfFile:model.originalPath];
                if (img) {
                    [origianlArray addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (origianlArray.count == 0) {
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_alldatanooriginalimg", @"") duration:1.0];
                [SVProgressHUD dismiss];
            }else{
                self.selectBatchArray = [origianlArray mutableCopy];
                __weak typeof(self) weakSelf = self;
                [self top_setCropPointsDataCompletion:^{
                    [weakSelf top_pushBatchVC];
                }];
            }
        });
    });
}

- (void)top_pushBatchVC{
    WS(weakSelf);
    TOPBatchViewController * batchVC = [TOPBatchViewController new];
    batchVC.currentIndex = 0;
    batchVC.allBatchArray = self.selectBatchArray;
    batchVC.batchCropType = TOPBatchCropTypeChildBatchVC;
    batchVC.top_returnAndReloadData = ^(NSMutableArray * _Nonnull dataArray) {
        self.isEdit = NO;
        [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedNone];
        [self.progressView show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (TOPBatchEditModel * model in self.allBatchArray) {
                if (model.selectStatus) {//选中的图片
                    if ([TOPWHCFileManager top_isExistsAtPath:model.originalPath]) {
                        model.isShow = YES;
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
            NSInteger count = 0;
            for (TOPCropEditModel * cropModel in dataArray) {
                for (TOPBatchEditModel * model in weakSelf.allBatchArray) {
                    if (model.selectStatus) {
                        if ([model.originalPath isEqualToString:cropModel.originalPath]) {
                            count++;
                            if (cropModel.isChange) {
                                model.endPoinArray = cropModel.endPoinArray;
                                UIImage * showImg = [UIImage imageWithContentsOfFile:model.imgPath];
                                if (showImg) {
                                    [TOPDocumentHelper top_saveImage:showImg atPath:model.defaultPath];
                                    [weakSelf top_filterImage:model processType:model.processType];
                                }
                                model.isChange = YES;
                            }else{
                                model.isShow = NO;
                            }
                            CGFloat stateF = ((count)*10.0)/(weakSelf.selectCount*10.0);
                            [weakSelf.progressView top_showProgress:stateF];
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedOnePic];
                [weakSelf.collectionView reloadData];
                [self.progressView dismiss];
                self.isEdit = YES;
            });
        });
    };
    batchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:batchVC animated:YES];
}
#pragma mark -- 旋转
- (void)top_topMenuItemsRotateImage:(UIImageOrientation)imgOrientation{
    [self.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedNone];
    self.isEdit = NO;
    [self.progressView show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (TOPBatchEditModel * model in self.allBatchArray) {
            if (model.selectStatus) {
                model.isChange = YES;
                model.isShow = YES;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self performSelector:@selector(top_starRotate:) withObject:@(imgOrientation) afterDelay:0.5];
        });
    });
}
#pragma mark-- 旋转批量处理
- (void)top_starRotate:(NSNumber *)num{
    UIImageOrientation imgOrientation = [num integerValue];
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger selectNum = 0;
        int lastIndex = 0;
        for (int i = 0; i<weakSelf.allBatchArray.count; i++) {
            @autoreleasepool {
                if (selectNum<8) {
                    TOPBatchEditModel * model  = weakSelf.allBatchArray[i];
                    if (model.selectStatus) {
                        selectNum++;
                        lastIndex = i;
                        [weakSelf top_rotateImage:model imgOrientation:imgOrientation];
                    }
                    CGFloat stateF = ((i+1)*10.0)/(weakSelf.allBatchArray.count*10.0);
                    [weakSelf.progressView top_showProgress:stateF];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
        if (self.selectCount > 8) {
            for (int i = lastIndex; i < weakSelf.allBatchArray.count; i++) {
                @autoreleasepool {
                    TOPBatchEditModel * model  = weakSelf.allBatchArray[i];
                    if (model.selectStatus) {
                        [weakSelf top_rotateImage:model imgOrientation:imgOrientation];
                        CGFloat stateF = ((i+1)*10.0)/(weakSelf.selectCount*10.0);
                        [weakSelf.progressView top_showProgress:stateF];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.pressBatchBootomView top_changePressViewBtnState:TOPItemsSelectedOnePic];
            [weakSelf.collectionView reloadData];
            weakSelf.isEdit = YES;
            [weakSelf.progressView dismiss];
        });
    });
}

#pragma mark -- 获得旋转后的图片并替换原来的图片 旋转只是旋转展示 原图不做旋转
- (void)top_rotateImage:(TOPBatchEditModel *)model imgOrientation:(UIImageOrientation)orientation{
    UIImage * img = [UIImage imageWithContentsOfFile:model.imgPath];//展示图
    if (img) {
        //旋转后的图片
        UIImage * rotationImg = [TOPDocumentHelper top_image:img rotation:orientation];
        if (rotationImg) {
            [TOPDocumentHelper top_saveImage:rotationImg atPath:model.imgPath];
            [TOPDataModelHandler top_updateCoverImage:model.imgPath atPath:model.coverImgPath];
            model.isShow = NO;
        }
    }
}
#pragma mark -- 展示渲染试图
- (void)top_topMenuItemsFilterImage{
    [UIView animateWithDuration:0.3 animations:^{
        [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPBottomSafeHeight+Bottom_H, 0));
        }];
        [self.filterBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
            make.height.mas_equalTo(100);
        }];
        [self.view addSubview:self.bottomCoverView];
        [self.bottomCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.view);
            make.height.mas_equalTo(TOPBottomSafeHeight+Bottom_H);
        }];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark -- 试图的消失处理
- (void)top_clickTip{
    [UIView animateWithDuration:0.3 animations:^{
        [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_bottom).offset(-(Bottom_H+TOPBottomSafeHeight));
            make.height.equalTo(self.view.mas_height).offset(Bottom_H+TOPBottomSafeHeight);
        }];
        [self.filterBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_bottom).offset(-(Bottom_H+TOPBottomSafeHeight));
            make.height.mas_equalTo(100);
        }];
        [self.view layoutIfNeeded];
        [self.bottomCoverView removeFromSuperview];
        self.bottomCoverView = nil;
        [self.pressBatchBootomView top_didSelectedFunctionChangeState:@(TOPMenuItemsFunctionFilter)];
    }];
}

#pragma mark -- 底部透明覆盖层的点击事件
- (void)top_clickBottomTip{
    [self top_clickTip];
}
#pragma mark -- 返回
- (void)top_backAction{
    [FIRAnalytics logEventWithName:@"homeChildBatch_backFatherVC" parameters:nil];
    if (self.isEdit) {
        NSMutableArray * tempArray = [NSMutableArray new];
        for (TOPBatchEditModel * model in self.allBatchArray) {
            if (model.isChange) {
                [tempArray addObject:model];
            }
        }
        if (self.deleteArray.count>0||tempArray.count>0) {
            weakify(self);
            TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_prompt", @"")
                                                                           message:NSLocalizedString(@"topscan_promptcontent", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_no", @"") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBatchImageFileString]];
                [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBatchCoverImageFileString]];
                [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getDefaultBatchImageFileString]];
                [self top_dataStateDefault];
            }];
            UIAlertAction* saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_batchsave", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [weakSelf top_changeDataDeal:weakSelf.deleteArray:tempArray];
            }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleDefault
                                                                 handler:nil];
            [alert addAction:noAction];
            [alert addAction:saveAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBatchImageFileString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBatchCoverImageFileString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getDefaultBatchImageFileString]];
            [self top_dataStateDefault];
        }
    }else{
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_waittip", @"") duration:2.0];
    }
}

#pragma mark -- Save
- (void)top_ClickRightItems{
    [FIRAnalytics logEventWithName:@"homeChildBatch_doneToSaveData" parameters:nil];
    if (self.isEdit) {
        if (self.dataArray.count<100) {
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        }else{
            [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_processing", @"")];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray * tempArray = [NSMutableArray new];
            for (TOPBatchEditModel * model in self.allBatchArray) {
                if (model.isChange) {
                    [tempArray addObject:model];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.deleteArray.count>0||tempArray.count>0) {
                    [self top_changeDataDeal:self.deleteArray:tempArray];
                }else{
                    [SVProgressHUD dismiss];
                    [[TOPProgressStripeView shareInstance] dismiss];
                    [self top_dataStateDefault];
                }
            });
        });
    }else{
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_waittip", @"") duration:2.0];
    }
}

#pragma mark -- 保持原来的数据状态(返回按钮点击no时的处理)
- (void)top_dataStateDefault{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --当数据都被删除时不需要做替换效果图片的操作
- (void)top_changeDataDeal:(NSMutableArray *)deleteArray :(NSMutableArray *)changeArray{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (deleteArray.count ==weakSelf.dataArray.count) {
            [weakSelf top_deleteModelData:weakSelf.dataArray dataCount:weakSelf.dataArray.count];
        }else{
            if (deleteArray.count>0) {
                NSMutableArray * tempArray = [NSMutableArray new];
                for (int i = 0; i<weakSelf.dataArray.count; i++) {
                    @autoreleasepool {
                        DocumentModel * dataModel = weakSelf.dataArray[i];
                        for (int j = 0; j<deleteArray.count; j++) {
                            TOPBatchEditModel * batchModel = weakSelf.deleteArray[j];
                            if ([batchModel.photoName isEqualToString:dataModel.photoName]) {
                                [tempArray addObject:dataModel];
                            }
                        }
                    }
                }
                [weakSelf top_deleteModelData:tempArray dataCount:deleteArray.count+changeArray.count];
            }

            if (changeArray.count>0) {//替换效果图
                NSInteger count = 0;
                for (int i = 0; i<weakSelf.dataArray.count; i++) {
                    @autoreleasepool {
                        DocumentModel * dataModel = weakSelf.dataArray[i];
                        for (int j = 0; j<changeArray.count; j++) {
                            TOPBatchEditModel * batchModel = changeArray[j];
                            if ([batchModel.photoName isEqualToString:dataModel.photoName]) {
                                count++;
                                [TOPWHCFileManager top_copyItemAtPath:batchModel.imgPath toPath:dataModel.imagePath overwrite:YES];
                                [TOPWHCFileManager top_copyItemAtPath:batchModel.coverImgPath toPath:dataModel.coverImagePath overwrite:YES];
                                [TOPEditDBDataHandler top_updateImagesWithIds:@[dataModel.docId]];
                                RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesWithImageIds:@[dataModel.docId]];
                                if (images.count) {
                                    for (TOPImageFile *image in images) {
                                        [self top_updateFilterData:image];
                                    }
                                }
                                CGFloat progressValue = ((count+deleteArray.count) * 10.0) / ((deleteArray.count+changeArray.count) * 10.0);
                                [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
                            }
                        }
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[TOPProgressStripeView shareInstance] dismiss];
            [weakSelf top_backActionJudge];
        });
    });
}

#pragma mark -- 图片裁剪、渲染等处理数据
- (void)top_updateFilterData:(TOPImageFile *)imgFile {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"docId = %@",imgFile.Id];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (TOPBatchEditModel * model in self.allBatchArray) {
        if (model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    NSArray *results = [tempArray filteredArrayUsingPredicate:predicate];
    if (results.count) {
        TOPBatchEditModel * model = results.firstObject;
        NSMutableArray *points = @[].mutableCopy;
        NSMutableArray *autoPoints = @[].mutableCopy;
        if (model.endPoinArray.count) {
            TOPSaveElementModel * eleModel = [TOPDataModelHandler top_getBatchSavePointData:model.endPoinArray imgPath:model.originalPath imgRect:model.cropImgViewRect];
            points = [TOPDataModelHandler top_pointsFromModel:eleModel];
        }
        if (model.autoEndPoinArray.count) {
            TOPSaveElementModel * elementModel = [TOPDataModelHandler top_getBatchSavePointData:model.autoEndPoinArray imgPath:model.originalPath imgRect:model.cropImgViewRect];
            autoPoints = [TOPDataModelHandler top_pointsFromModel:elementModel];
        }
        
        UIImage * showImg = [UIImage imageWithContentsOfFile:model.imgPath];
        NSDictionary *param = @{@"orientation":@(showImg.imageOrientation),
                                @"filter":@(model.processType),
                                @"points":points,
                                @"autoPoints":autoPoints};
        [TOPEditDBDataHandler top_updateImageWithHandler:param byId:imgFile.Id];
    }
}

#pragma mark -- 返回到上层的处理
- (void)top_backActionJudge{
    if (self.deleteArray.count ==self.dataArray.count) {
        if (self.isAllData) {
            NSMutableArray * vcArray = [NSMutableArray new];
            for (UIViewController * vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[TOPNextFolderViewController class]]) {
                    [vcArray addObject:vc];
                }
            }
            [TOPWHCFileManager top_removeItemAtPath:self.childVCPath];
            
            if (vcArray.count>0) {
                TOPNextFolderViewController * backVC = vcArray.lastObject;
                [self.navigationController popToViewController:backVC animated:YES];
            }else{
                if (self.isCollectionBox) {
                    [self top_backFatherVC];
                }else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }else{//如果一开始的数据是childVC的一部分数据
            [self top_backFatherVC];
        }
    }else{
        [self top_backFatherVC];
    }
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBatchImageFileString]];//清空临时路径
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBatchCoverImageFileString]];//清空临时路径
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getDefaultBatchImageFileString]];//清空模版图
}
#pragma mark -- 删除数据
- (void)top_deleteModelData:(NSMutableArray*)array dataCount:(NSInteger)allCount{
    [self top_deleteImages:array dataCount:allCount];
}

#pragma mark -- 删除图片至回收站
- (void)top_deleteImages:(NSArray *)dataArray dataCount:(NSInteger)allCount {
    if (dataArray) {
        DocumentModel *tempModel = dataArray[0];
        BOOL newDoc = [TOPBinDataHandler top_needCreateBinDocument:tempModel.docId];
        NSMutableArray *filePathArr = @[].mutableCopy;
        NSMutableArray *deleteIds = @[].mutableCopy;
        for (int i = 0; i < dataArray.count; i ++ ) {
            BOOL isNew = newDoc;
            if (i>0) {
                isNew = NO;
            }
            DocumentModel *model = dataArray[i];
            [deleteIds addObject:model.docId];
            NSString *binImgPath = [TOPBinHelper top_moveImageToBin:model.path atNewDoc:isNew];//图片在回收站的路径
            [filePathArr addObject:binImgPath];
            NSString * stateStr = [NSString stringWithFormat:@"%.3f",(([dataArray indexOfObject:model]+1)*10.00)/(allCount*10.00)];
            [[TOPProgressStripeView shareInstance] top_showProgress:[stateStr doubleValue] withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
        }
        TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:tempModel.docId];
        if (filePathArr.count) {
            if (newDoc) {
                NSString *binImgPath = filePathArr[0];
                NSString *docPath = [TOPWHCFileManager top_directoryAtPath:binImgPath];
                [TOPBinEditDataHandler top_saddBinDocWithParentId:imgFile.pathId atPath:docPath];
            } else {
                NSMutableArray *fileArr = @[].mutableCopy;
                for (NSString *binImgPath in filePathArr) {
                    NSString *fileName = [TOPWHCFileManager top_fileNameAtPath:binImgPath suffix:YES];
                    [fileArr addObject:fileName];
                }
                TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:imgFile.parentId];
                [TOPBinEditDataHandler top_addBinImageAtDocument:fileArr WithId:doc.pathId];
            }
        }
        [TOPEditDBDataHandler top_deleteImagesWithIds:deleteIds];
    }
}

#pragma mark -- 数据更改后回到childVC需要回调刷新
- (void)top_backFatherVC{
    if (self.top_dataChangeAndLoadData) {
        self.top_dataChangeAndLoadData();
    }
    [self.navigationController popViewControllerAnimated:YES];//直接回到childVC
}

#pragma mark -- lazy
- (NSMutableArray *)allBatchArray{
    if (!_allBatchArray) {
        _allBatchArray = [NSMutableArray new];
    }
    return _allBatchArray;
}

- (NSMutableArray *)selectArray{
    if (!_selectArray) {
        _selectArray = [NSMutableArray new];
    }
    return _selectArray;
}

- (NSMutableArray *)selectBatchArray {
    if (!_selectBatchArray) {
        _selectBatchArray = [NSMutableArray new];
    }
    return _selectBatchArray;
}

- (NSMutableArray *)deleteArray{
    if (!_deleteArray) {
        _deleteArray = [NSMutableArray new];
    }
    return _deleteArray;
}

- (NSMutableArray *)filterShowArray{
    if (!_filterShowArray) {
        _filterShowArray = [NSMutableArray new];
    }
    return _filterShowArray;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-Bottom_H, TOPScreenWidth, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-Bottom_H)];
        _coverView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTip)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

- (UIView *)bottomCoverView{
    if (!_bottomCoverView) {
        _bottomCoverView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-Bottom_H, TOPScreenWidth, TOPBottomSafeHeight+Bottom_H)];
        _bottomCoverView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickBottomTip)];
        [_bottomCoverView addGestureRecognizer:tap];
    }
    return _bottomCoverView;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPChildBatchCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPChildBatchCell class])];
    }
    return _collectionView;
}

- (UIView *)filterBackView{
    if (!_filterBackView) {
        _filterBackView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-Bottom_H,TOPScreenWidth,100)];
        _filterBackView.backgroundColor  = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
    return _filterBackView;
}

- (UICollectionView *)filterCollectionView{
    if (!_filterCollectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(80, 80);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _filterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-Bottom_H,TOPScreenWidth , 100) collectionViewLayout:layout];
        _filterCollectionView.dataSource = self;
        _filterCollectionView.delegate = self;
        _filterCollectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _filterCollectionView.showsVerticalScrollIndicator = NO;
        _filterCollectionView.showsHorizontalScrollIndicator = NO;
        [_filterCollectionView registerClass:[TOPReEditCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class])];
    }
    return _filterCollectionView;
}
- (TOPProcessBatchView *)progressView{
    if (!_progressView) {
        _progressView = [[TOPProcessBatchView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPTabBarHeight-TOPNavBarAndStatusBarHeight-3, TOPScreenWidth, 3)];
        _progressView.backgroundColor = [UIColor clearColor];
    }
    return _progressView;
}
#pragma mark -- 编辑选中文件时 底部菜单的数据源
- (NSArray *)sendBatchPicArray {
    NSArray * temp = @[@"top_scamerbatch_left",@"top_scamerbatch_rote",@"top_scamerbatch_crop",@"top_scamerbatch_filter",@"top_downview_selectdelete"];
    return temp;
}

- (NSArray *)sendBatchSelectPicArray {
    NSArray * temp = @[@"top_scamerbatch_left",@"top_scamerbatch_rote",@"top_scamerbatch_crop",@"top_scamerbatch_filterSelect",@"top_downview_selectdelete"];
    return temp;
}

- (NSArray *)batchPicArray {
    NSArray * temp = @[@"top_scamerbatch_noLeft",@"top_scamerbatch_noRote",@"top_scamerbatch_noCrop",@"top_scamerbatch_noFilter",@"top_downview_disabledelete"];
    return temp;
}

- (NSArray *)batchfuncItems {
    NSArray * temp = @[@(TOPMenuItemsFunctionLeft),@(TOPMenuItemsFunctionRight),@(TOPMenuItemsFunctionCrop),@(TOPMenuItemsFunctionFilter),@(TOPMenuItemsFunctionDelete)];
    return temp;
}

- (NSArray *)sendBatchNameArray{
    NSArray * temp = @[NSLocalizedString(@"topscan_left", @""),NSLocalizedString(@"topscan_right", @""),NSLocalizedString(@"topscan_crop", @""),NSLocalizedString(@"topscan_filter", @""),NSLocalizedString(@"topscan_delete", @"")];
    return temp;
}
- (NSArray *)funcItems {
    NSArray * temp = @[@(TOPMenuItemsFunctionLeft),@(TOPMenuItemsFunctionRight),@(TOPMenuItemsFunctionCrop),@(TOPMenuItemsFunctionFilter),@(TOPMenuItemsFunctionDelete)];
    return temp;
}

@end
