#define AdjustView_H 120
#define PageViewH   25
#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)
#define FilterShow_H 130

#import "TOPCamerBatchViewController.h"
#import "TOPScameraBatchBottomView.h"
#import "TOPReEditCollectionViewCell.h"
#import "TOPSCameraViewController.h"
#import "TOPHomeChildViewController.h"
#import "TOPBatchViewController.h"
#import "TOPScameraBatchCell.h"
#import "TOPPhotoAdjustView.h"
#import "TOPShowPagesView.h"
#import "TOPBatchAddPicCell.h"
#import "TOPDataTool.h"
#import "TOPCameraBatchModel.h"
#import "TOPOpenCVWrapper.h"
#import "TOPSaveElementModel.h"
#import "TOPCropEditModel.h"
#import "TOPCoverView.h"
#import "TOPProcessBatchView.h"
#import "TOPTrackingSliderView.h"
@interface TOPCamerBatchViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,TOPTrackingSliderViewDelegate>
@property (nonatomic, strong)TOPTrackingSliderView * brightnessSliderView;
@property (nonatomic, strong)TOPTrackingSliderView * contrastSliderView;
@property (nonatomic, strong)UIView * brightnessBackView;
@property (nonatomic, strong)UIView * contrastBackView;
@property (nonatomic, strong) TOPImageTitleButton *backBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *adjustBtn;
@property (nonatomic, strong) UIButton *addPicBtn;
@property (nonatomic, strong) UIButton *filterTypeBtn;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) TOPCoverView *coverView;
@property (nonatomic, strong) UIView *bottomCoverView;
@property (nonatomic, strong) TOPBaseCollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *filterCollectionView;
@property (nonatomic, strong) TOPScameraBatchBottomView *bottomView;
@property (nonatomic, strong) UIView *filterShowView;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIFilter *colorControlsFilter;
@property (nonatomic, strong) TOPShowPagesView *pageView;
@property (nonatomic, assign) BOOL isloadFinish;
@property (nonatomic, assign) BOOL isFilterShow;
@property (nonatomic, assign) BOOL isDispath;
@property (nonatomic, assign) BOOL isCIContextDispath;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *showArray;
@property (nonatomic, strong) NSMutableDictionary *saveShowDic;
@property (nonatomic, assign) CGFloat picH;
@property (nonatomic, assign) BOOL isClickFinish;
@property (nonatomic, assign) NSInteger currentItem;
@property (nonatomic, assign) NSInteger handleCount;
@property (nonatomic, assign) NSInteger bottomFuncIndex;
@property (nonatomic, assign) CGFloat navBarAndStatusBarHeight;
@property (nonatomic ,strong) TOPProcessBatchView * progressView;
@end

@implementation TOPCamerBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isClickFinish = NO;
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.navBarAndStatusBarHeight = self.navigationController.navigationBar.frame.size.height;
    self.isDispath = NO;
    self.isCIContextDispath = NO;
    
    self.context = [CIContext contextWithOptions:nil];
    self.colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
    [self top_setupUI];
    
    if ([TOPScameraBatchSave save].images.count>0) {
        [self top_LoadLocalSaveData];
    }else{
        [self top_dealSnackFiles];
        [self top_loadData];
    }
}

#pragma mark --操作临时文件
- (void)top_dealSnackFiles{
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCameraBatchDefaultDraw_Path];//展示的效果图
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCameraBatchAdjustDraw_Path];//调节亮度等功能的模版图
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCameraBatchCropDraw_Path];//刚进入界面时开始裁剪 完成之后保存图片的路径
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCameraBatchCropDefaultDraw_Path];//刚进入界面时开始裁剪 完成之后保存原图处理之后的图（对原图进行像素处理）
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCameraBatchProcessIcon_Path];//图片对应的渲染小图
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
}
#pragma mark -- 出现之后在该界面禁止侧滑
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
#pragma mark -- 当单例保存的有数据时 数据源的处理
- (void)top_LoadLocalSaveData{
    [self childViewDefaultState];
    [self.progressView show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
        [self top_setDefaultSaveModel:picArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.saveShowDic = [TOPScameraBatchSave save].saveShowDic;
            [self top_getCurrentLocation];
            self.pageView.allCount = picArray.count;
            [self top_childViewLoadPartState];
        });
        
        for (int i = 0; i<self.images.count; i++) {
            @autoreleasepool {
                TOPCameraBatchModel * model = self.images[i];
                if (i>=[TOPScameraBatchSave save].images.count) {//拍照新添加的进行裁剪处理
                    if (!self.isClickFinish) {
                        [self top_setModelElement:model];
                        CGFloat stateF = ((i-[TOPScameraBatchSave save].images.count+1) * 10.0)/((self.images.count-[TOPScameraBatchSave save].images.count) * 10.0);
                        [self.progressView top_showProgress:stateF];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView dismiss];
            [self top_childViewLoadFinishState];
        });
    });
}

- (void)top_setDefaultSaveModel:(NSArray *)picArray{
    for (int i = 0; i<picArray.count+1; i++) {
        @autoreleasepool {
            TOPCameraBatchModel * model = [TOPCameraBatchModel new];
            if (i<picArray.count) {
                if (i<[TOPScameraBatchSave save].images.count) {//单例保存的数据
                    model = [TOPScameraBatchSave save].images[i];
                }else{//拍照新添加的
                    model.brightnessValue = 0.0;
                    model.staturationValue = 1.0;
                    model.contrastValue = 1.0;
                    model.PicName = picArray[i];
                    model.processType = [TOPScanerShare top_defaultProcessType];
                    model.isSelect = NO;
                    if (i == [TOPScameraBatchSave save].images.count) {
                        model.isFirstEnter = YES;
                    }else{
                        model.isFirstEnter = NO;
                    }
                }
                [self.images addObject:model];
            }else{
                model.cellType = 1;
            }
            [self.showArray addObject:model];//showArray这个数组的数据只用于展示
        }
    }
}
#pragma mark -- 返回拍照界面之后再回来 设置显示cell的下标
- (void)top_getCurrentLocation{
    if ([TOPScameraBatchSave save].backType) {
        if (self.images.count>[TOPScameraBatchSave save].images.count) {
            self.currentIndex = [TOPScameraBatchSave save].images.count;
        }else{
            if ([TOPScameraBatchSave save].currentIndex<=self.images.count) {
                self.currentIndex = [TOPScameraBatchSave save].currentIndex;
            }
        }
    }else{
        if (self.images.count>[TOPScameraBatchSave save].images.count) {
            self.currentIndex = [TOPScameraBatchSave save].images.count;
        }else{
            self.currentIndex = [TOPScameraBatchSave save].images.count-1;
        }
    }
    self.currentItem = self.currentIndex;
}
#pragma mark -- 数据处理 loadData
- (void)top_loadData{
    [self childViewDefaultState];
    [self.progressView show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
        [self top_setDefaultModel:picArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pageView.allCount = picArray.count;
            [self top_childViewLoadPartState];
        });
        
        for (int i = 0; i<self.images.count; i++) {
            @autoreleasepool {
                TOPCameraBatchModel * model = self.images[i];
                if (!self.isClickFinish) {
                    [self top_setModelElement:model];
                    CGFloat stateF = ((i+1) * 10.0)/(self.images.count * 10.0);
                    [self.progressView top_showProgress:stateF];
                }else{
                    return;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView dismiss];
            [self top_childViewLoadFinishState];
        });
    });
}

#pragma mark --创建数据模型只做赋值操作 没有耗时操作
- (void)top_setDefaultModel:(NSArray *)picArray{
    for (int i = 0; i<picArray.count+1; i++) {
        @autoreleasepool {
            TOPCameraBatchModel * model = [TOPCameraBatchModel new];
            if (i<picArray.count) {
                model.brightnessValue = 0.0;
                model.staturationValue = 1.0;
                model.contrastValue = 1.0;
                model.PicName = picArray[i];
                model.processType = [TOPScanerShare top_defaultProcessType];
                model.isSelect = NO;
                model.cellType = 0;
                if (i == 0) {
                    model.isFirstEnter = YES;
                }else{
                    model.isFirstEnter = NO;
                }
                [self.images addObject:model];
            }else{
                model.cellType = 1;
            }
            [self.showArray addObject:model];
        }
    }
}
#pragma mark -- 创建数据模型
- (void)top_setModelElement:(TOPCameraBatchModel*)model{
    @autoreleasepool {
        NSString * picPath = [TOPCamerPic_Path stringByAppendingPathComponent:model.PicName];
        NSString * cropDefaultPath = [TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:model.PicName];
        NSString * originalDealPath = [TOPCameraBatchCropDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
        NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
        NSString * adjustPicPath = [TOPCameraBatchAdjustDraw_Path stringByAppendingPathComponent:model.PicName];
        NSData * imgData = [NSData dataWithContentsOfFile:picPath];
        UIImage * getPicImg = [TOPPictureProcessTool top_fetchOriginalImageWithData:imgData];
        UIImage * picImg = [UIImage imageWithContentsOfFile:picPath];
        UIImage * originalImg = [UIImage new];
        
        if (getPicImg.size.width>0&&getPicImg.size.height>0) {
            originalImg = getPicImg;
        }else{
            originalImg = picImg;
        }
        [TOPDocumentHelper top_saveImage:originalImg atPath:originalDealPath];
        [TOPWHCFileManager top_copyItemAtPath:originalDealPath toPath:picPath overwrite:YES];
        model.originalImgPath = picPath;
        model.cropPath = cropDefaultPath;
        model.adjustPicPath = adjustPicPath;
        model.imgPath = filterPicPath;
        
        NSData *cropImgData = [NSData dataWithContentsOfFile:originalDealPath];
        UIImage * cropImg =  [TOPPictureProcessTool top_scaleImageWithData:cropImgData withSize:CGSizeMake(TOPScreenWidth-30, _picH)];
        CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:cropImg fatherW:TOPScreenWidth-30 fatherH:_picH];
        model.cropImgViewRect = imgRect;
        
        UIImage * sourceImg = [UIImage new];
        if ([TOPScanerShare top_saveBatchImage] == TOPSettingSaveYES) {
            UIImage * saveImage = [UIImage new];
            if (!originalImg.size.width) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [FIRAnalytics logEventWithName:@"SCamerBatch_top_setModelElement" parameters:nil];
                    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_processingerror", @"")];
                });
            }
            NSMutableArray * pointArray = [[TOPOpenCVWrapper top_getLargestSquarePoints:cropImg :imgRect.size :YES] mutableCopy];
            [self top_setBatchPointWithModel:model AndDefaultPointArray:pointArray AndBatchRect:imgRect];
            model.endPoinArray = [model.autoEndPoinArray mutableCopy];
            if (pointArray.count) {
                saveImage = [TOPOpenCVWrapper top_getTransformedObjectImage:model.elementModel.saveW :model.elementModel.saveH :originalImg :model.elementModel.pointArray :originalImg.size];//生成裁剪的图片
            }else{
                saveImage = originalImg;
            }
            [TOPDocumentHelper top_saveImage:saveImage atPath:cropDefaultPath];
            sourceImg = saveImage;
            model.isFinishCrop = YES;
        }else{
            sourceImg = originalImg;
            [TOPDocumentHelper top_saveImage:originalImg atPath:cropDefaultPath];
            model.isFinishCrop = NO;
        }
        if (sourceImg.size.width>0&&sourceImg.size.height>0) {
            GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:sourceImg];
            UIImage *image = [TOPDataTool top_pictureProcessData:imageSource withImg:sourceImg withItem:model.processType];
            [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
            [TOPWHCFileManager top_removeItemAtPath:filterPicPath];
            [TOPWHCFileManager top_removeItemAtPath:adjustPicPath];
            
            [TOPDocumentHelper top_saveImage:image atPath:filterPicPath];
            [TOPDocumentHelper top_saveImage:image atPath:adjustPicPath];
        }
    }
}

- (void)top_setBatchPointWithModel:(TOPCameraBatchModel *)model AndDefaultPointArray:(NSMutableArray *)pointArray AndBatchRect:(CGRect)imgRect{
    NSMutableArray * apexArray = @[].mutableCopy;
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, 0)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, imgRect.size.height)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, imgRect.size.height)]];
    model.notAutoEndPoinArray = [apexArray mutableCopy];
    NSMutableArray * savePoints = @[].mutableCopy;
    if (!pointArray.count) {
        savePoints = apexArray;
    }else{
        savePoints = pointArray;
    }
    if (!model.autoEndPoinArray.count) {
        model.autoEndPoinArray = [savePoints mutableCopy];
    }
    NSString * originalDealPath = [TOPCameraBatchCropDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
    TOPSaveElementModel * elementModel = [TOPDataModelHandler top_getBatchSavePointData:savePoints imgPath:originalDealPath imgRect:imgRect];
    model.elementModel = elementModel;
}
- (void)top_top_touchToHideView{
    [self top_hideFilterView];
}
- (void)top_tipAction:(UITapGestureRecognizer *)tap{
    [self top_hideFilterView];
}

- (void)top_hideFilterView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.bottomView top_changeFilterBtnSelectState:NO atIndex:self.bottomFuncIndex];
        [self.filterShowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_bottom).offset(-TOPTabBarHeight);
            make.height.mas_equalTo(FilterShow_H);
        }];
        
        [self.pageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(30+TOPTabBarHeight));
            make.height.mas_equalTo(PageViewH);
        }];
        [self.view layoutIfNeeded];
    }];
}
- (void)top_showFilterView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.bottomView top_changeFilterBtnSelectState:YES atIndex:self.bottomFuncIndex];
        [self.filterShowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
            make.height.mas_equalTo(FilterShow_H);
        }];
        
        [self.pageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+FilterShow_H+5));
            make.height.mas_equalTo(PageViewH);
        }];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark -- 左右滑动按钮的点击事件
- (void)top_showPageViewfunctionBtnTag:(NSInteger)tag{
    NSArray * numArray = [self top_showPagefunctionArray];
    switch ([numArray[tag] integerValue]) {
        case TOPBatchEditActionTypeImageOrientationLeft:
            [self top_showPageViewFunction:TOPBatchEditActionTypeImageOrientationLeft];
            break;
        case TOPBatchEditActionTypeImageOrientationRight:
            [self top_showPageViewFunction:TOPBatchEditActionTypeImageOrientationRight];
            break;
        default:
            break;
    }
}

#pragma mark -- 左右滑动按钮的点
- (void)top_showPageViewFunction:(NSInteger)tag{
    if (tag == TOPBatchEditActionTypeImageOrientationLeft) {
        [FIRAnalytics logEventWithName:@"SCamerBatch_PageViewfunctionLeftBtn" parameters:nil];
        int pageIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width ;
        if (self.currentIndex>0) {
            if (pageIndex != self.images.count) {
                self.currentIndex--;
                self.pageView.currentIndex = self.currentIndex+1;
            }else{
                self.currentIndex = pageIndex-1;
                self.pageView.currentIndex = pageIndex;
            }
        }
    }
    if (tag ==TOPBatchEditActionTypeImageOrientationRight) {
        [FIRAnalytics logEventWithName:@"SCamerBatch_PageViewfunctionRightBtn" parameters:nil];
        if (self.currentIndex+1<self.images.count) {
            self.currentIndex++;
            self.pageView.currentIndex = self.currentIndex+1;
        }else{
            self.currentIndex = self.images.count;
        }
    }
    self.pageView.cameraIndex = self.currentIndex;
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth, 0) animated:NO];
    [self top_changeBtnState];
}
#pragma mark -- 点左右滑动的按钮之后改变特定按钮的状态
- (void)top_changeBtnState{
    int pageIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width ;
    if (pageIndex < self.images.count) {
        [self top_bottomFunctionFilter];
        if (self.isloadFinish) {
            [self top_btnShow];
            [self.bottomView top_changeBtnState:YES];
        }else{//数据没有处理完 底部按钮都不能点击
            [self top_btnHide];
            [self.bottomView top_changeBtnState:NO];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isFilterShow) {
                [self top_showFilterView];
            }else{
                [self top_hideFilterView];
            }
        });
    }else{
        self.currentIndex --;
        [self top_btnHide];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self top_hideFilterView];
        });
        if (self.isloadFinish) {
            [self.bottomView top_changeFinishBtnState:YES];
        }else{
            [self.bottomView top_changeBtnState:NO];
        }
    }
    [self top_hideSliderView];
}

- (void)top_btnHide{
    self.deleteBtn.hidden = YES;
    self.adjustBtn.hidden = YES;
    self.addPicBtn.hidden = YES;
}

- (void)top_btnShow{
    self.deleteBtn.hidden = NO;
    self.adjustBtn.hidden = NO;
    self.addPicBtn.hidden = NO;
}
#pragma mark -- 底部试图的功能按钮
- (void)top_bottomViewFunctionTip:(NSInteger)index{
    NSArray * num = [self top_bottomFunctionArray];
    switch ([num[index] integerValue]) {
        case TOPScamerBatchBottomViewFunctionRetake:
            [self top_BatchZoomViewRestoreZoomSCale];
            [self top_bottomFunctionRetake];
            break;
        case TOPScamerBatchBottomViewFunctionRota:
            [self top_BatchZoomViewRestoreZoomSCale];
            [self top_bottomFunctionRota];
            break;
        case TOPScamerBatchBottomViewFunctionCrop:
            [self top_BatchZoomViewRestoreZoomSCale];
            [self top_bottomFunctionCrop];
            break;
        case TOPScamerBatchBottomViewFunctionFilter:
            self.bottomFuncIndex = index;
            self.isFilterShow = !self.isFilterShow;
            if (self.isFilterShow) {
                [self top_showFilterView];
            }else{
                [self top_hideFilterView];
            }
            [self top_bottomFunctionFilter];
            break;
        case TOPScamerBatchBottomViewFunctionFinish:
            [self top_bottomFunctionFinish];
            break;
        default:
            break;
    }
}

#pragma mark -- 重拍
- (void)top_bottomFunctionRetake{
    [FIRAnalytics logEventWithName:@"SCamerBatch_bottomFunctionRetake" parameters:nil];
    TOPCameraBatchModel * model = self.images[self.currentIndex];

    WS(weakSelf);
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.fileType = TOPShowSCamerBatchRetakeCameraType;
    camera.imageName = model.PicName;
    camera.top_dismissAndReloadData = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //清空底部保存的渲染模式
            NSString *dicKey = [self top_currentPicName:self.currentIndex];//以图片名称作为字典的key值
            NSMutableArray *selectArray = weakSelf.saveShowDic[dicKey];
            for (TOPReEditModel * model in selectArray) {//删除替换图片本地保存的对应渲染小图
                NSString * iconPath = model.dic[@"image"];
                [TOPWHCFileManager top_removeItemAtPath:iconPath];
            }
            [selectArray removeAllObjects];
            
            TOPCameraBatchModel * model = self.images[self.currentIndex];
            [model.endPoinArray removeAllObjects];
            [model.autoEndPoinArray removeAllObjects];
            [model.notAutoEndPoinArray removeAllObjects];
            [weakSelf top_setModelElement:model];//重新对model赋值
            [weakSelf top_bottomFunctionFilter];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0]]];
            });
        });
    };
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 旋转 旋转展示图 还要旋转调整的模版图
- (void)top_bottomFunctionRota{
    WS(weakSelf);
    [FIRAnalytics logEventWithName:@"SCamerBatch_bottomFunctionRota" parameters:nil];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageOrientation  imgOrientation;
        imgOrientation = UIImageOrientationLeft;
        TOPCameraBatchModel * model = weakSelf.images[weakSelf.currentIndex];
        NSString *dicKey = [self top_currentPicName:self.currentIndex];//以图片名称作为字典的key值
        NSMutableArray *selectArray = weakSelf.saveShowDic[dicKey];
        for (TOPReEditModel * model in selectArray) {//删除当前图片本地保存的对应渲染小图
            NSString * iconPath = model.dic[@"image"];
            [TOPWHCFileManager top_removeItemAtPath:iconPath];
        }
        [selectArray removeAllObjects];
        //旋转展示图原图
        NSString * cameraImagePath = model.PicName;
        NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
        UIImage * filterImg = [UIImage imageWithContentsOfFile:filterPicPath];
        
        if (filterImg) {
            //旋转展示图
            UIImage * FilterRotationImg = [TOPDocumentHelper top_image:filterImg rotation:imgOrientation];

            //旋转原图
            NSString * picPath = [NSString new];
            picPath = [TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:cameraImagePath];

            UIImage * img = [UIImage imageWithContentsOfFile:picPath];
            //旋转后的原图片
            UIImage * rotationImg = [TOPDocumentHelper top_image:img rotation:imgOrientation];
            
            //旋转调节模版图的原图
            NSString * adjustPicPath = [TOPCameraBatchAdjustDraw_Path stringByAppendingPathComponent:cameraImagePath];
            UIImage * adjustImg = [UIImage imageWithContentsOfFile:adjustPicPath];
            //旋转后的调节模版图片
            UIImage * adjustRotationImg = [TOPDocumentHelper top_image:adjustImg rotation:imgOrientation];

            [TOPDocumentHelper top_saveImage:rotationImg atPath:picPath];
            [TOPDocumentHelper top_saveImage:FilterRotationImg atPath:filterPicPath];
            [TOPDocumentHelper top_saveImage:adjustRotationImg atPath:adjustPicPath];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentIndex inSection:0]]];
            [self top_bottomFunctionFilter];
        });
    });
}

- (void)top_jumpToCrop {
    WS(weakSelf);
    [FIRAnalytics logEventWithName:@"SCamerBatch_bottomFunctionCrop" parameters:nil];
    TOPBatchViewController * batchVC = [TOPBatchViewController new];
    batchVC.currentIndex = self.currentIndex;
    batchVC.batchCropType = TOPBatchCropTypeCamera;
    batchVC.cameraArray = self.images;
    batchVC.top_returnAndReloadData = ^(NSMutableArray * _Nonnull dataArray) {
        for (TOPCropEditModel *cropModel in dataArray) {
            for (TOPCameraBatchModel * cameraModel in weakSelf.images) {
                if ([cameraModel.PicName isEqualToString:cropModel.picName]&&cropModel.isChange) {//确定裁剪过的数据
                    cameraModel.endPoinArray = cropModel.endPoinArray;//保存坐标数据
                    if (!cameraModel.autoEndPoinArray.count) {//没有开启自动裁剪的情况下是没有auto点
                        cameraModel.autoEndPoinArray = cropModel.autoEndPoinArray;
                    }
                    [self top_setBatchPointWithModel:cameraModel AndDefaultPointArray:cameraModel.endPoinArray AndBatchRect:cameraModel.cropImgViewRect];
                    if (cameraModel.endPoinArray == cameraModel.notAutoEndPoinArray) {
                        if ([TOPScanerShare top_saveBatchImage] == TOPSettingSaveYES) {//默认做裁剪时当最后保存的是原图也算裁剪过
                            cameraModel.isFinishCrop = YES;
                        }else{
                            cameraModel.isFinishCrop = NO;//默认不做裁剪时保存的是原图不算裁剪
                        }
                    }else{
                        cameraModel.isFinishCrop = YES;
                    }
                    NSString *dicKey = cameraModel.PicName;
                    NSMutableArray *selectArray = weakSelf.saveShowDic[dicKey];
                    for (TOPReEditModel * model in selectArray) {//删除当前图片本地保存的对应渲染小图
                        NSString * iconPath = model.dic[@"image"];
                        [TOPWHCFileManager top_removeItemAtPath:iconPath];
                    }
                    [selectArray removeAllObjects];
                }
            }
        }
        [weakSelf.collectionView reloadData];
        [weakSelf top_bottomFunctionFilter];
    };
    batchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:batchVC animated:YES];
}

#pragma mark -- 批处理
- (void)top_bottomFunctionCrop{
    [self top_jumpToCrop];
}
#pragma mark -- 渲染
- (void)top_bottomFunctionFilter{
    [FIRAnalytics logEventWithName:@"SCamerBatch_bottomFunctionFilter" parameters:nil];
    if (!self.isDispath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.isDispath = YES;
            if (![self top_getDicCurrentArray].count) {//没有保存过渲染模型 就创建 保存过就不做处理
                if ([self top_getBatchCropDrawImg].size.width>0) {//裁剪图片已经有了
                    NSData *imgData = [TOPDocumentHelper top_saveImageForData:[self top_getBatchCropDrawImg]];
                    UIImage * drawImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(80*3, 90*3)];
                    [self top_setFilterDataAndSaveDic:drawImg];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger scrollIndex = [self top_scrollCurrentProcessTypeLocation];
                self.isDispath = NO;
                [SVProgressHUD dismiss];
                [self.filterCollectionView reloadData];
                if (scrollIndex<[self.filterCollectionView numberOfItemsInSection:0]) {
                    [self.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:scrollIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                }
            });
        });
    }
}
#pragma mark --获取filterCollectionView的数据模型 和saveShowDic保存的数据
- (void)top_setFilterDataAndSaveDic:(UIImage *)drawImg{
    if (drawImg) {
        NSString *dicKey = [self top_currentPicName:self.currentIndex];//以图片名称作为字典的key值
        NSString *processTypeKey = [NSString stringWithFormat:@"processType%@",dicKey];
        GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:drawImg];
        NSArray *processArray = [TOPPictureProcessTool top_processTypeArray];//渲染类型的集合
        NSMutableArray * tempArray = [NSMutableArray new];
        for (int i = 0; i<processArray.count; i++) {
            @autoreleasepool {
                NSInteger processType = [processArray[i] integerValue];
                UIImage * drawImage = [TOPDataTool top_pictureProcessData:imageSource withImg:drawImg withItem:processType];
                [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];//完成后清除渲染的缓存
                
                NSString *fileName  = [NSString stringWithFormat:@"%@%@%@%@",dicKey,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i+1],TOP_TRJPGPathSuffixString];
                NSString *fileEndPath =  [TOPCameraBatchProcessIcon_Path stringByAppendingPathComponent:fileName];
                [TOPDocumentHelper top_saveImage:drawImage atPath:fileEndPath];

                TOPReEditModel * model = [[TOPReEditModel alloc] init];
                model.processType = processType;//将渲染类型保存起来
                if (drawImage) {
                    model.dic = [TOPDataTool top_pictureProcessDatawithImgPath:fileEndPath currentItem:processType];
                }
                if (model.processType == [self.saveShowDic[processTypeKey] integerValue]) {//字典保存的渲染类型即是默认渲染类型 给一个选中的状态
                    model.isSelect = YES;
                }else{
                    model.isSelect = NO;
                }
                [tempArray addObject:model];
            }
        }
        NSMutableArray *selectArray = self.saveShowDic[dicKey];
        if (!selectArray.count) {
            self.saveShowDic[dicKey] = tempArray;
        }
    }
}
#pragma mark --当前展示的图片裁剪之后的图片
- (UIImage *)top_getBatchCropDrawImg{
    UIImage * img = [UIImage new];
    NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
    if (self.currentIndex<picArray.count) {
        NSString * cameraImagePath = picArray[self.currentIndex];
        NSString * picPath = [NSString new];
        picPath = [TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:cameraImagePath];//图片裁剪之后的图片保存路径
        img = [UIImage imageWithContentsOfFile:picPath];
    }
    return img;
}
- (NSString *)top_currentPicName:(NSInteger)currentIndex{
    NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
    NSString * cameraImagename = [NSString new];
    if (self.currentIndex<picArray.count) {
        cameraImagename = picArray[currentIndex];
    }
    return cameraImagename;
}
#pragma mark --filterCollectionView滚动到当前的渲染模式的位置
- (NSInteger)top_scrollCurrentProcessTypeLocation{
    NSString *processTypeKey = [NSString stringWithFormat:@"processType%@",[self top_currentPicName:self.currentIndex]];
    NSNumber * processType = self.saveShowDic[processTypeKey];//字典保存的渲染类型
    NSArray *processArray = [TOPPictureProcessTool top_processTypeArray];//渲染类型的集合
    for (NSNumber * tempNum in processArray) {
        if (tempNum == processType) {
            return [processArray indexOfObject:tempNum];
        }
    }
    return 0;
}
#pragma mark --没有保存过渲染模型 就创建 保存过就不做处理
- (NSMutableArray *)top_getDicCurrentArray{
    NSString *dicKey = [self top_currentPicName:self.currentIndex];
    NSString *processTypeKey = [NSString stringWithFormat:@"processType%@",dicKey];
    NSMutableArray *selectArray = self.saveShowDic[dicKey];//字典保存的数据
    NSNumber * processType = self.saveShowDic[processTypeKey];//字典保存的渲染类型
    if (!processType) {//没有保存过渲染类型 给一个默认值
        [self.saveShowDic setValue:@([TOPScanerShare top_defaultProcessType]) forKey:processTypeKey];
    }
    return selectArray;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.filterCollectionView) {
        NSString *dicKey = [self top_currentPicName:self.currentIndex];
        NSMutableArray *selectArray = self.saveShowDic[dicKey];
        return selectArray.count;
    }else{
        return self.showArray.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    if (collectionView == self.collectionView) {
        TOPCameraBatchModel * model = self.showArray[indexPath.item];
        if (model.cellType == 1) {
            TOPBatchAddPicCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPBatchAddPicCell class]) forIndexPath:indexPath];
            cell.isFinish = self.isloadFinish;
            cell.top_clickAddBtn = ^{
                [weakSelf top_backActionClick];
            };
            return cell;
        }else{
            TOPScameraBatchCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPScameraBatchCell class]) forIndexPath:indexPath];
            cell.top_sendZoomScale = ^(CGFloat zoomScale) {
                [weakSelf top_setCollectionScrollState:zoomScale];
            };
            cell.top_changAdjustModelImg = ^{
            };
            cell.model = model;
            return cell;
        }
    }else{
        NSString *dicKey = [self top_currentPicName:self.currentIndex];
        NSMutableArray *selectArray = self.saveShowDic[dicKey];
        TOPReEditCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class]) forIndexPath:indexPath];
        if (selectArray.count) {
            TOPReEditModel * model = selectArray[indexPath.item];
            cell.model = model;
        }

        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.filterCollectionView) {
        [self top_BatchZoomViewRestoreZoomSCale];
        [self top_hideSliderView];
        [self top_handleShowPhoto:indexPath];
    }
}

#pragma mark -- 缩放的展示图片回到正常大小
- (void)top_BatchZoomViewRestoreZoomSCale{
    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    TOPScameraBatchCell * currentCell = (TOPScameraBatchCell *)cell;
    currentCell.zoomView.zoomScale = 1.0;
}
#pragma mark -- Apply to all pages按钮的点击处理
- (void)top_clickFilterTypeBtn:(UIButton *)sender{
    [self top_BatchZoomViewRestoreZoomSCale];
    sender.selected = !sender.selected;
    NSString *processTypeKey = [NSString stringWithFormat:@"processType%@",[self top_currentPicName:self.currentIndex]];
    NSNumber * processTypeNum = self.saveShowDic[processTypeKey];
    if (sender.selected) {
        [self top_changeAllPageProcessType:[processTypeNum integerValue]];
    }else{
        [self top_dealProcessTypeDataWithRow:self.currentIndex AndProcessType:[processTypeNum integerValue]];
        [self.filterCollectionView reloadData];
        [self.collectionView reloadData];
    }
}
#pragma mark -- 处理加载当前渲染模式的图片
- (void)top_handleShowPhoto:(NSIndexPath *)indexPath {
    NSInteger processType = [[TOPPictureProcessTool top_processTypeArray][indexPath.item] integerValue];
    if (self.filterTypeBtn.selected) {
        [self top_changeAllPageProcessType:processType];
    }else{
        [self top_dealProcessTypeDataWithRow:self.currentIndex AndProcessType:processType];
        [self.filterCollectionView reloadData];
        [self.collectionView reloadData];
    }
}
#pragma mark -- 选中的渲染类型作用在所有图片
- (void)top_changeAllPageProcessType:(NSInteger)processType {
    for (int i = 0; i<self.images.count; i++) {
        [self top_dealProcessTypeDataWithRow:i AndProcessType:processType];
    }
    [self.filterCollectionView reloadData];
    [self.collectionView reloadData];
}
#pragma mark -- 选中的渲染类型作用在单张图片
- (void)top_dealProcessTypeDataWithRow:(NSInteger)currentIndex AndProcessType:(NSInteger)processType{
    @autoreleasepool {
        NSString *dicKey = [self top_currentPicName:currentIndex];
        NSString *processTypeKey = [NSString stringWithFormat:@"processType%@",dicKey];
        NSMutableArray *selectArray = self.saveShowDic[dicKey];
        NSInteger dicProcessType = [self.saveShowDic[processTypeKey] integerValue];
        if (selectArray.count) {
            for (TOPReEditModel * filterModel in selectArray) {
                if (filterModel.processType == processType) {
                    filterModel.isSelect = YES;
                }else{
                    filterModel.isSelect = NO;
                }
            }
        }
        
        TOPCameraBatchModel * model = self.images[currentIndex];
        if (dicProcessType != processType) {
            model.processType = processType;
            model.isSelect = YES;
            model.brightnessValue = 0.0;
            model.staturationValue = 1.0;
            model.contrastValue = 1.0;
            [self.saveShowDic setValue:@(processType) forKey:processTypeKey];
        }
    }
}
#pragma mark -- 当图片在放缩状态时不让collectionView滑动
- (void)top_setCollectionScrollState:(CGFloat)zoomScale{
    if (zoomScale == 1.0) {
        self.pageView.leftBtn.enabled = YES;
        self.pageView.rightBtn.enabled = YES;
        self.collectionView.scrollEnabled = YES;
    }else{
        self.collectionView.scrollEnabled = NO;
        self.pageView.leftBtn.enabled = NO;
        self.pageView.rightBtn.enabled = NO;
    }
}

#pragma mark -- 返回
- (void)top_backActionClick{
    if (self.isloadFinish) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray * tempArray = [NSMutableArray new];
            tempArray = [self.navigationController.viewControllers mutableCopy];
            if (![self top_getIsHave]) {
                TOPEnterCameraType myType;
                if (self.fileType == TOPShowFolderCameraType) {
                    myType = TOPEnterHomeCameraTypeLibrary;
                }else if(self.fileType == TOPShowDocumentCameraType){
                    myType = TOPEnterDocumentCameraTypeLibrary;
                }else {
                    myType = TOPEnterNextFolderCameraTypeLibrary;
                }
                TOPSCameraViewController * scameraVC = [TOPSCameraViewController new];
                scameraVC.pathString = self.pathString;
                scameraVC.fileType = myType;
                scameraVC.backType = self.backType;
                NSInteger index = [tempArray indexOfObject:self];
                [tempArray insertObject:scameraVC atIndex:index];
                [self.navigationController setViewControllers:tempArray];
            }
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPScameraBatchSave save].images = self.images;
            [TOPScameraBatchSave save].saveShowDic = self.saveShowDic;
            [TOPScameraBatchSave save].backType = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.top_backAndReloadData) {
                    self.top_backAndReloadData();
                }
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }
}

- (void)top_backVCPop {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self top_getIsHave]) {
            [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [TOPScameraBatchSave save].images = self.images;
                [TOPScameraBatchSave save].saveShowDic = self.saveShowDic;
                [TOPScameraBatchSave save].backType = YES;
                [TOPScameraBatchSave save].currentIndex = self.currentIndex;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.top_backAndReloadData) {
                        self.top_backAndReloadData();
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
        }
    });
}

#pragma mark -- 导航上的添加按钮的事件
- (void)top_addPicBtnAction{
    if (![self top_getIsHave]) {
        [self top_backActionClick];
    }else{
        [self top_backVCPop];
    }
}
#pragma mark --TOPSCameraViewController是否在堆栈里
- (BOOL)top_getIsHave{
    BOOL isHave = NO;
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[TOPSCameraViewController class]]) {
            isHave = YES;
            break;
        }
    }
    return isHave;
}
#pragma mark -- 更新滤镜
- (void)top_updateControlsFilter {
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPCameraBatchModel * model = self.images[self.currentIndex];
        NSString * filterPicPath = [TOPCameraBatchAdjustDraw_Path stringByAppendingPathComponent:model.PicName];
        UIImage * img = [UIImage imageWithContentsOfFile:filterPicPath];
        if (img.CGImage) {
            CIImage * get = [CIImage imageWithCGImage:img.CGImage];
            [weakSelf.colorControlsFilter setValue:get forKey:@"inputImage"];
        }
    });
}

#pragma mark -- 删除
- (void)top_deleteImageClick:(UIButton *)sender{
    WS(weakSelf);
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_deletecurrentpage", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [FIRAnalytics logEventWithName:@"SCamerBatch_deleteImageClick" parameters:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TOPCameraBatchModel * model = weakSelf.images[weakSelf.currentIndex];
            [weakSelf top_deleteCurrentPageData:model];
            if (weakSelf.images.count != 0) {
                if (weakSelf.currentIndex == 0) {
                    weakSelf.currentIndex = 0;
                }else{
                    weakSelf.currentIndex -=1 ;
                }
                [weakSelf top_bottomFunctionFilter];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf top_changeAdjustStateWhenDelete];
                    [weakSelf.collectionView reloadData];
                    [weakSelf.collectionView setContentOffset:CGPointMake(weakSelf.currentIndex * weakSelf.view.frame.size.width, 0) animated:NO];
                    weakSelf.pageView.allCount = weakSelf.images.count;
                    weakSelf.pageView.currentIndex = weakSelf.currentIndex+1;
                    weakSelf.pageView.cameraIndex = weakSelf.currentIndex;
                });
            }else{
                [weakSelf top_backActionClick];
            }
        });
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -- 当调节亮度视图展示出来 然后删除当前图片后 需要更新调节亮度视图的数据
- (void)top_changeAdjustStateWhenDelete{
    if (self.images.count) {
        if (!self.adjustBtn.hidden) {
            TOPCameraBatchModel * model = self.images[self.currentIndex];
            [self top_resetSliderValue:model];
        }
    }
}
#pragma mark -- 删除当前的图片模型数据 对应的字典数据
- (void)top_deleteCurrentPageData:(TOPCameraBatchModel *)model{
    NSString *imagePath = model.PicName;
    NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
    NSString * adjustPicPath = [TOPCameraBatchAdjustDraw_Path stringByAppendingPathComponent:model.PicName];
    NSString * cropPicPath = [TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:model.PicName];
    NSString * cropDefaultPath = [TOPCameraBatchCropDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
    [self.images removeObject:model];
    [self.showArray removeObject:model];
    [TOPWHCFileManager top_removeItemAtPath:filterPicPath];
    [TOPWHCFileManager top_removeItemAtPath:adjustPicPath];
    [TOPWHCFileManager top_removeItemAtPath:cropPicPath];
    [TOPWHCFileManager top_removeItemAtPath:cropDefaultPath];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:[TOPCamerPic_Path stringByAppendingPathComponent:imagePath]];
    if (isExist) {
    [TOPWHCFileManager top_removeItemAtPath:[TOPCamerPic_Path stringByAppendingPathComponent:imagePath]];
    }
    NSString *dicKey = model.PicName;
    NSString *processTypeKey = [NSString stringWithFormat:@"processType%@",dicKey];
    NSMutableArray *selectArray = self.saveShowDic[dicKey];
    for (TOPReEditModel * model in selectArray) {
        NSString * iconPath = model.dic[@"image"];
        [TOPWHCFileManager top_removeItemAtPath:iconPath];
    }

    [self.saveShowDic removeObjectForKey:dicKey];
    [self.saveShowDic removeObjectForKey:processTypeKey];
}
#pragma mark -- 保存色彩调整后的图片
- (void)top_setImageWithModel:(TOPCameraBatchModel *)model{
    [FIRAnalytics logEventWithName:@"SCamerBatch_setImage" parameters:nil];
    if (!self.isCIContextDispath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.isCIContextDispath = YES;
            NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
            UIImage * img = [UIImage imageWithContentsOfFile:filterPicPath];
            
            CIImage * outputImage = [self.colorControlsFilter outputImage];
            CGImageRef temp = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
            UIImage * showImage = [UIImage imageWithCGImage:temp];
            UIImage * saveImg = [UIImage imageWithCGImage:showImage.CGImage scale:showImage.scale orientation:img.imageOrientation];
            
            [TOPWHCFileManager top_removeItemAtPath:filterPicPath];
            [TOPDocumentHelper top_saveImage:saveImg atPath:filterPicPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isCIContextDispath = NO;
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentIndex inSection:0]]];
                CGImageRelease(temp);
            });
        });
    }
}

#pragma mark -- 图片色彩调整
- (void)top_adjustClick:(UIButton *)sender{
    [self top_updateControlsFilter];
    sender.selected = !sender.selected;
    if (!self.brightnessBackView||!self.contrastBackView) {
        [self top_addSliderBackView];
        [self top_setBrightnessBackViewChild];
        [self top_setcontrastBackViewChild];
    }
    if (sender.selected) {
        [self top_resetSliderValue:self.images[self.currentIndex]];
        [self top_showSliderView];
    }else{
        [self top_hideSliderView];
    }
}
#pragma mark -- 收起调节试图
- (void)top_hideSliderView{
    self.adjustBtn.selected = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.brightnessBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view).offset(-50);
                make.trailing.equalTo(self.view.mas_leading);
                make.size.mas_equalTo(CGSizeMake(80, 350));
            }];
            [self.contrastBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view).offset(-50);
                make.leading.equalTo(self.view.mas_trailing);
                make.size.mas_equalTo(CGSizeMake(80, 350));
            }];
            [self.view layoutIfNeeded];
        }];
    });
}
#pragma mark -- 展开调节试图
- (void)top_showSliderView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.brightnessBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view).offset(-50);
                make.leading.equalTo(self.view).offset(-10);
                make.size.mas_equalTo(CGSizeMake(80, 350));
            }];
            [self.contrastBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view).offset(-50);
                make.trailing.equalTo(self.view).offset(10);
                make.size.mas_equalTo(CGSizeMake(80, 350));
            }];
            [self.view layoutIfNeeded];
        }];
    });
}
#pragma mark -- 减速结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width ;
        [self top_setcurrentPage:pageIndex];
    }
}
#pragma mark -- 停止拖拽
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width ;
        [self top_setcurrentPage:pageIndex];
    }
}
#pragma mark -- 滑动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        NSArray *gestureArray = self.navigationController.view.gestureRecognizers;
        for (UIGestureRecognizer *gestureRecognizer in gestureArray) {
            if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
                [scrollView.panGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
            }
        }
    }
}
- (void)top_setcurrentPage:(NSInteger)pageIndex{
    if (self.collectionView.contentOffset.x>pageIndex*self.collectionView.frame.size.width && pageIndex == self.images.count-1) {
        [self top_btnHide];
        self.pageView.cameraIndex = pageIndex+1;
    }else{
        if (pageIndex < self.images.count) {
            self.currentIndex = pageIndex;
            self.pageView.currentIndex = pageIndex+1;
            [self top_bottomFunctionFilter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.isloadFinish) {
                    [self top_btnShow];
                    [self.bottomView top_changeBtnState:YES];
                }else{
                    [self top_btnHide];
                    [self.bottomView top_changeBtnState:NO];
                }
                if (self.isFilterShow) {
                    [self top_showFilterView];
                }else{
                    [self top_hideFilterView];
                }
            });
        }else{
            [self top_btnHide];
            [self top_hideFilterView];
            if (self.isloadFinish) {
                [self.bottomView top_changeFinishBtnState:YES];
            }else{
                [self.bottomView top_changeBtnState:NO];
            }
            self.currentIndex = pageIndex-1;
            self.pageView.currentIndex = pageIndex;
        }
        self.pageView.cameraIndex = pageIndex;
    }
    [self top_hideSliderView];
}
#pragma mark -- 完成
- (void)top_bottomFunctionFinish{
    switch (self.fileType) {
        case TOPShowFolderCameraType:
        case TOPShowNextFolderCameraType:
        case TOPEnterHomeCameraTypeLibrary:
        case TOPEnterNextFolderCameraTypeLibrary:
        case TOPShowToTextCameraType:
        case TOPShowIDCardCameraType:
        {
            self.isClickFinish = YES;
            [self top_goBackFromFolderCameraVC];
        }
            break;
        case TOPShowDocumentCameraType:
        case TOPEnterDocumentCameraTypeLibrary:
        {
            self.isClickFinish = YES;
            [self top_goBackFromDocumentCameraVC];
        }
            break;
        default:
            break;
    }
}

#pragma mark -- 完成的处理
- (void)top_goBackFromFolderCameraVC{
    [FIRAnalytics logEventWithName:@"SCamerBatch_goBackFromFolderCameraVC" parameters:nil];
    DocumentModel *fileModel = [TOPFileDataManager shareInstance].docModel;
    NSString *filePath = fileModel.path;
    NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:filePath];

    if (self.images.count>1) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(1/%@)",NSLocalizedString(@"topscan_processing", @""),@(self.images.count)]];
    }else{
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    
    self.handleCount = 0;
    dispatch_queue_t queueE = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t groupE = dispatch_group_create();
    dispatch_queue_t serialQue= dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    for (int i = 0; i < self.images.count; i ++) {
        dispatch_async(serialQue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_group_async(groupE, queueE, ^{
                dispatch_group_enter(groupE);
                [self top_handleOriginalImage:i atPath:endPath];
                dispatch_semaphore_signal(semaphore);
                dispatch_group_leave(groupE);
            });
            if (i == self.images.count - 1) {
                dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
                    [self top_writeToDB:endPath model:fileModel];
                });
            }
        });
    }
}

#pragma mark -- 处理裁剪图片并保存
- (void)top_handleOriginalImage:(int)i atPath:(NSString *)endPath {
    TOPCameraBatchModel * model = self.images[i];
    UIImage * originImage = [self top_getOriginalImg:model];
    UIImage * saveImg = [self top_getSaveImg:model];
    
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [endPath stringByAppendingPathComponent:fileName];
    NSString *soureFileEndPath =  [TOPDocumentHelper top_originalImage:fileEndPath];
    [TOPDocumentHelper top_saveImage:saveImg atPath:fileEndPath];
    if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
        if (originImage) {
            [TOPDocumentHelper top_saveImage:originImage atPath:soureFileEndPath];
        }
    }
    if (self.images.count>1) {
        self.handleCount ++;
        CGFloat stateF = ((self.handleCount) * 10.0)/(self.images.count * 10.0);
        [[TOPProgressStripeView shareInstance] top_showProgress:stateF withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(self.handleCount),@(self.images.count)]];
    }
}

#pragma mark -- 写入数据库后跳转界面
- (void)top_writeToDB:(NSString *)endPath model:(DocumentModel *)fileModel {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
        TOPAppDocument *appDoc = [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:fileModel.docId];
        DocumentModel *newDoc = [TOPDBDataHandler top_buildDocumentModelWithData:appDoc];
        [TOPDocumentHelper top_createDocumentAddTags:endPath];
        [self top_writeImageFilterData:appDoc];
        NSString *tagsPaht = [endPath stringByAppendingPathComponent:TOP_TRTagsPathString];
        NSArray *contents = [TOPWHCFileManager top_listFilesInDirectoryAtPath:tagsPaht deep:NO];
        if (contents.count) {
            NSString *tag = contents.firstObject;
            [TOPEditDBDataHandler top_updateDocumentTags:@{@"tags": [NSString stringWithFormat:@"%@/",tag]} byDocIds:@[appDoc.Id]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[TOPProgressStripeView shareInstance] dismiss];
            [self top_deleteTempFolder];
            TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
            childVC.docModel = newDoc;
            childVC.pathString = endPath;
            childVC.upperPathString = self.pathString;
            childVC.fileNameString = [TOPWHCFileManager top_fileNameAtPath:endPath suffix:YES];
            childVC.startPath = fileModel.path;
            childVC.addType = @"add";
            childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
            childVC.hidesBottomBarWhenPushed = YES;
            [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
            [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

#pragma mark -- 写入图片的裁剪、渲染、朝向数据
- (void)top_writeImageFilterData:(TOPAppDocument *)appDoc {
    if (appDoc.images.count) {
        for (int i = 0; i < appDoc.images.count; i ++) {
            TOPImageFile *imgFile = appDoc.images[i];
            [self top_updateFilterData:imgFile atIndex:i];
        }
    }
}

- (void)top_updateFilterData:(TOPImageFile *)imgFile atIndex:(NSInteger)index {
    TOPCameraBatchModel * model = self.images[index];
    
    NSMutableArray *points = [TOPDataModelHandler top_pointsFromModel:model.elementModel];
    
    TOPSaveElementModel * elementModel = [TOPDataModelHandler top_getBatchSavePointData:model.autoEndPoinArray imgPath:model.originalImgPath imgRect:model.cropImgViewRect];
    NSMutableArray *autoPoints = [TOPDataModelHandler top_pointsFromModel:elementModel];

    NSDictionary *param = @{@"orientation":@(model.showImg.imageOrientation),
                            @"filter":@(model.processType),
                            @"points":points,
                            @"autoPoints":autoPoints};
    [TOPEditDBDataHandler top_updateImageWithHandler:param byId:imgFile.Id];
}

- (void)top_writeNewImagesFilter:(NSArray *)fileNames {
    for (int i = 0; i < fileNames.count; i ++) {
        NSString *fileName = fileNames[i];
        RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:[TOPFileDataManager shareInstance].docModel.docId withName:fileName];
        if (images.count) {
            [self top_updateFilterData:images.firstObject atIndex:i];
        }
    }
}

#pragma mark -- 完成的处理
- (void)top_goBackFromDocumentCameraVC{
    [FIRAnalytics logEventWithName:@"SCamerBatch_bottomFunctionChildCameraFinish" parameters:nil];
    WS(weakSelf);
    if (self.images.count>1) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(1/%@)",NSLocalizedString(@"topscan_processing", @""),@(self.images.count)]];
    }else{
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *sortArray = [weakSelf.dataArray sortedArrayUsingComparator:^NSComparisonResult(DocumentModel *model1, DocumentModel *model2) {
            return [model1.numberIndex compare:model2.numberIndex options:NSNumericSearch];
        }];
        DocumentModel *docModel  = sortArray.lastObject;
        NSMutableArray *newImageNames = @[].mutableCopy;
        self.handleCount = 0;
        dispatch_queue_t queueE = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t groupE = dispatch_group_create();
        dispatch_queue_t serialQue= dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
        for (int i = 0; i < self.images.count; i ++) {
            dispatch_async(serialQue, ^{
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_group_async(groupE, queueE, ^{
                    dispatch_group_enter(groupE);
                    TOPCameraBatchModel * model = weakSelf.images[i];
                    UIImage * originImage = [weakSelf top_getOriginalImg:model];
                    UIImage * saveImg = [weakSelf top_getSaveImg:model];
                    
                    NSString *endNum = [NSString stringWithFormat:@"%ld",[docModel.numberIndex integerValue] + 1 + i];
                    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],endNum,TOP_TRJPGPathSuffixString];
                    
                    NSString *fileEndPath =  [weakSelf.pathString stringByAppendingPathComponent:fileName];
                    NSString *soureFileEndPath =  [TOPDocumentHelper top_originalImage:fileEndPath];
                    BOOL result = [TOPDocumentHelper top_saveImage:saveImg atPath:fileEndPath];
                    if (result) {
                        if (fileName.length > 0) {
                            [newImageNames addObject:fileName];
                        } else {
                            NSLog(@"error image = %@ -- %@", endNum,fileName);
                        }
                        if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
                            if (originImage) {
                                [TOPDocumentHelper top_saveImage:originImage atPath:soureFileEndPath];
                            }
                        }
                    }
                    
                    if (weakSelf.images.count>1) {
                        self.handleCount ++;
                        CGFloat stateF = ((self.handleCount) * 10.0)/(weakSelf.images.count * 10.0);
                        [[TOPProgressStripeView shareInstance] top_showProgress:stateF withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(self.handleCount),@(weakSelf.images.count)]];
                    }
                    dispatch_semaphore_signal(semaphore);
                    dispatch_group_leave(groupE);
                });
                if (i == self.images.count - 1) {
                    dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
                            if (newImageNames.count != self.images.count) {
                                NSLog(@"missing image");
                            }
                            NSArray *imgArr = [TOPDocumentHelper top_sortedPicArray:newImageNames];
                            DocumentModel *fileModel = [TOPFileDataManager shareInstance].docModel;
                            [TOPEditDBDataHandler top_addImageFileAtDocument:imgArr WithId:fileModel.docId];
                            [self top_writeNewImagesFilter:imgArr];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD dismiss];
                                [[TOPProgressStripeView shareInstance] dismiss];
                                [self top_deleteTempFolder];
                                if ([TOPScanerShare shared].isPush) {
                                    [TOPScanerShare shared].isPush = NO;
                                    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
                                    childVC.docModel = [TOPFileDataManager shareInstance].docModel;
                                    childVC.pathString = self.pathString;
                                    childVC.addType = @"add";
                                    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
                                    childVC.hidesBottomBarWhenPushed = YES;
                                    [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
                                    [[TOPDocumentHelper top_getPushVC].navigationController dismissViewControllerAnimated:YES completion:nil];
                                    [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
                                }else{
                                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                }
                            });
                        });
                    });
                }
            });
        }
    });
}

#pragma mark -- 获取保存的原图
- (UIImage *)top_getOriginalImg:(TOPCameraBatchModel *)model{
    NSString * originalPicPath = [NSString new];
    UIImage * originImage = [UIImage new];
    originalPicPath = [TOPCameraBatchCropDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
    originImage = [UIImage imageWithContentsOfFile:originalPicPath];
    if (!originImage) {
        NSString * defaultPicPath = [TOPCamerPic_Path stringByAppendingPathComponent:model.PicName];
        NSData *imgData = [NSData dataWithContentsOfFile:defaultPicPath];
        UIImage * getImg = [TOPPictureProcessTool top_fetchOriginalImageWithData:imgData];
        if (getImg.size.width>0&&getImg.size.height>0) {
            originImage = getImg;
        }
    }else{
        if (originImage.imageOrientation != UIImageOrientationUp) {
            UIImage * tempImg = [UIImage imageWithCGImage:originImage.CGImage scale:originImage.scale orientation:UIImageOrientationUp];
            originImage = tempImg;
        }
    }
    return originImage;
}

#pragma mark -- 通过裁剪图获取保存的展示图
- (UIImage *)top_getSaveImg:(TOPCameraBatchModel *)model{
    UIImage * originImage = [self top_getOriginalImg:model];
    UIImage * dealImg = [UIImage new];
    UIImage * cropImg = [UIImage imageWithContentsOfFile:[TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:model.PicName]];
    if (cropImg) {
        dealImg = cropImg;
    }else{
        dealImg = originImage;
    }
    UIImage * sendImg = [self top_getFiltrImage:model originalImg:dealImg];
    return sendImg;
}
#pragma mark -- 获取需要保存的展示图片 本地如果没有就通过原图重新渲染生成
- (UIImage *)top_getFiltrImage:(TOPCameraBatchModel *)model originalImg:(UIImage *)dealImg{
    NSString * cameraImagePath = model.PicName;
    UIImage * dealOriginImage = [UIImage new];
    NSString * filterPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:cameraImagePath];
    UIImage * filterImg = [UIImage imageWithContentsOfFile:filterPath];

    if (!filterImg) {
        CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:dealImg fatherW:TOPScreenWidth-30 fatherH:_picH];
        if (!dealImg.size.width) {
            [FIRAnalytics logEventWithName:@"SCamerBatch_getFiltrImage" parameters:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_processingerror", @"")];
            });
        }
        NSMutableArray * pointArray = [[TOPOpenCVWrapper top_getLargestSquarePoints:dealImg :imgRect.size :YES] mutableCopy];
        [self top_setBatchPointWithModel:model AndDefaultPointArray:pointArray AndBatchRect:imgRect];
        if ([TOPScanerShare top_saveBatchImage] == TOPSettingSaveYES){
            model.endPoinArray = model.autoEndPoinArray;
            if (!pointArray.count) {
                dealOriginImage = dealImg;
            }else{
                TOPSaveElementModel * model = [TOPDataModelHandler top_getBatchSavePointData:pointArray img:dealImg imgRect:imgRect];
                dealOriginImage = [TOPOpenCVWrapper top_getTransformedObjectImage:model.saveW :model.saveH :model.originalImage :model.pointArray :model.originalImage.size];
            }
        }else{
            dealOriginImage = dealImg;
        }
        UIImage *image = [UIImage new];
        if (dealOriginImage) {
            GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:dealOriginImage];
            image = [TOPDataTool top_pictureProcessData:imageSource withImg:dealOriginImage withItem:model.processType];
            [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
        }
        if (image) {
            filterImg = image;
        }
    }else{
        if (model.isSelect) {
            if (dealImg) {
                GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:dealImg];
                UIImage *image = [TOPDataTool top_pictureProcessData:imageSource withImg:dealImg withItem:model.processType];
                [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
                if (image) {
                    filterImg = image;
                }
            }
        }
    }
    return filterImg;
}

- (void)top_deleteTempFolder{
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchDefaultDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchAdjustDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchCropDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchCropDefaultDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchProcessIcon_Path];
    
    [[TOPScameraBatchSave save].images removeAllObjects];
    [[TOPScameraBatchSave save].saveShowDic removeAllObjects];
}
- (NSMutableDictionary *)saveShowDic {
    if (!_saveShowDic) {
        _saveShowDic = [[NSMutableDictionary alloc] init];
    }
    return _saveShowDic;
}

- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray new];
    }
    return _images;
}

- (NSMutableArray *)showArray{
    if (!_showArray) {
        _showArray = [NSMutableArray new];
    }
    return _showArray;
}

- (NSArray *)top_bottomFunctionArray{
    NSArray * tempArray = @[@(TOPScamerBatchBottomViewFunctionRetake),@(TOPScamerBatchBottomViewFunctionRota),@(TOPScamerBatchBottomViewFunctionCrop),@(TOPScamerBatchBottomViewFunctionFilter),@(TOPScamerBatchBottomViewFunctionFinish)];
    return tempArray;
}

- (NSArray *)top_showPagefunctionArray{
    NSArray * array = @[@(TOPBatchEditActionTypeImageOrientationLeft),@(TOPBatchEditActionTypeImageOrientationRight)];
    return array;
}

- (TOPShowPagesView *)pageView{
    if (!_pageView) {
        WS(weakSelf);
        _pageView = [[TOPShowPagesView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight-TOPTabBarHeight-75-TOPNavBarAndStatusBarHeight, TOPScreenWidth, PageViewH)];
        _pageView.top_showPageAction = ^(NSInteger tag) {
            [weakSelf top_showPageViewfunctionBtnTag:tag];
        };
    }
    return _pageView;
}

- (TOPCoverView *)coverView{
    WS(weakSelf);
    if (!_coverView) {
        _coverView = [[TOPCoverView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPTabBarHeight)];
        _coverView.backgroundColor = [UIColor clearColor];
        _coverView.userInteractionEnabled = YES;
        _coverView.hidden = YES;
        _coverView.top_touchToHide = ^{
            [weakSelf top_top_touchToHideView];
        };
    }
    return _coverView;
}

- (UIView *)bottomCoverView{
    if (!_bottomCoverView) {
        _bottomCoverView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPTabBarHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth-90, 49)];
        _bottomCoverView.backgroundColor = [UIColor clearColor];
        _bottomCoverView.userInteractionEnabled = YES;
        _bottomCoverView.hidden = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tipAction:)];
        [_bottomCoverView addGestureRecognizer:tap];
    }
    return _bottomCoverView;
}
#pragma mark -- 渲染视图filterCollectionView
- (UICollectionView *)filterCollectionView{
    if (!_filterCollectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(80, 80);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _filterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0,TOPScreenWidth , 90) collectionViewLayout:layout];
        _filterCollectionView.dataSource = self;
        _filterCollectionView.delegate = self;
        _filterCollectionView.backgroundColor = [UIColor clearColor];
        _filterCollectionView.showsVerticalScrollIndicator = NO;
        _filterCollectionView.showsHorizontalScrollIndicator = NO;
        if (IS_IPAD) {
            _filterCollectionView.scrollEnabled = NO;
        }
        [_filterCollectionView registerClass:[TOPReEditCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class])];
    }
    return _filterCollectionView;
}

#pragma mark -- collectionView and delegate
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        //滚动方向
        layout.itemSize = CGSizeMake(TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[TOPBaseCollectionView alloc]initWithFrame:CGRectMake(0,0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPTabBarHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPScameraBatchCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPScameraBatchCell class])];
        [_collectionView registerClass:[TOPBatchAddPicCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPBatchAddPicCell class])];
    }
    return _collectionView;
}
#pragma mark -- 底部试图
- (void)top_addBottomView{
    if (!_bottomView) {
        WS(weakSelf);
        NSArray * picArray = @[@"top_scamerbatch_retake",@"top_scamerbatch_rote",@"top_scamerbatch_crop",@"top_scamerbatch_filter",@"top_scamerbatch_reEditAffirm"];
        NSArray * titles = @[NSLocalizedString(@"topscan_retake", @""),NSLocalizedString(@"topscan_rotate", @""),NSLocalizedString(@"topscan_crop", @""),NSLocalizedString(@"topscan_filter", @""),@""];
        NSArray * reEditArray = @[@"top_scamerbatch_noRetake",@"top_scamerbatch_noRote",@"top_scamerbatch_noCrop",@"top_scamerbatch_noFilter",@"top_scamerbatch_reEditAffirm"];
        TOPScameraBatchBottomView * bottomView = [[TOPScameraBatchBottomView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight - TOPTabBarHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, 49) sendPic:picArray itemNames:titles];
        bottomView.normalStateColor = kCommonBlackTextColor;
        bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        bottomView.normalArray = picArray;
        bottomView.reEditArray = reEditArray;
        bottomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            [weakSelf top_bottomViewFunctionTip:index];
        };
        self.bottomView = bottomView;
        [self.view addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(49);
        }];
    }
}

- (TOPProcessBatchView *)progressView{
    if (!_progressView) {
        _progressView = [[TOPProcessBatchView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPTabBarHeight-TOPNavBarAndStatusBarHeight-3, TOPScreenWidth, 3)];
        _progressView.backgroundColor = TOPAPPGreenColor;
    }
    return _progressView;
}
#pragma mark -- top_setupUI
- (void)top_setupUI{
    TOPImageTitleButton * backBtn = [[TOPImageTitleButton alloc]initWithFrame:CGRectMake(0, TOPStatusBarHeight, 44, 44)];
    backBtn.backgroundColor = [UIColor clearColor];
    if (isRTL()) {
        [backBtn setImage:[UIImage imageNamed:@"top_RTLbackItem"] forState:UIControlStateNormal];
        backBtn.style = EImageLeftTitleRightCenter;
    }else{
        [backBtn setImage:[UIImage imageNamed:@"top_backItem"] forState:UIControlStateNormal];
        backBtn.style = EImageLeftTitleRightLeft;
    }
    [backBtn addTarget:self action:@selector(top_backVCPop) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 25)];
    self.backBtn = backBtn;
    
    UIButton *addPicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPicBtn.frame = CGRectMake(TOPScreenWidth-64-50-50, TOPStatusBarHeight, 44, 44);
    addPicBtn.backgroundColor = [UIColor clearColor];
    [addPicBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AddPic"] forState:UIControlStateNormal];
    [addPicBtn addTarget:self action:@selector(top_addPicBtnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc]initWithCustomView:addPicBtn];
    self.addPicBtn = addPicBtn;
    
    UIButton *adjustBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    adjustBtn.frame = CGRectMake(TOPScreenWidth-64-50, TOPStatusBarHeight, 44, 44);
    adjustBtn.backgroundColor = [UIColor clearColor];
    [adjustBtn setImage:[UIImage imageNamed:@"top_scamerbatch_adjust"] forState:UIControlStateNormal];
    [adjustBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AdjustSelect"] forState:UIControlStateSelected];
    [adjustBtn addTarget:self action:@selector(top_adjustClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * adjustItem = [[UIBarButtonItem alloc]initWithCustomView:adjustBtn];
    self.adjustBtn = adjustBtn;
    
    UIButton *deleteImageBut = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteImageBut.frame = CGRectMake(TOPScreenWidth-64, TOPStatusBarHeight, 44, 44);
    deleteImageBut.backgroundColor = [UIColor clearColor];
    [deleteImageBut setImage:[UIImage imageNamed:@"top_scamerbatch_deleteImage"] forState:UIControlStateNormal];
    [deleteImageBut addTarget:self action:@selector(top_deleteImageClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * deleteItem = [[UIBarButtonItem alloc]initWithCustomView:deleteImageBut];
    self.deleteBtn = deleteImageBut;
    
    UIView * filterShow = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPTabBarHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, FilterShow_H)];
    filterShow.backgroundColor = RGBA(0, 0, 0, 0.4);
    self.filterShowView = filterShow;
    
    TOPImageTitleButton * filterTypeBtn = [[TOPImageTitleButton alloc]initWithStyle:(EImageLeftTitleRightCenter)];
    filterTypeBtn.backgroundColor = [UIColor clearColor];
    filterTypeBtn.frame = CGRectMake(0, 90, TOPScreenWidth, 40);
    filterTypeBtn.padding = CGSizeMake(8, -8);
    filterTypeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [filterTypeBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
    [filterTypeBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
    [filterTypeBtn setTitle:NSLocalizedString(@"topscan_flitertypeapplylocation", @"") forState:UIControlStateNormal];
    [filterTypeBtn addTarget:self action:@selector(top_clickFilterTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
    filterTypeBtn.tapAnimationDuration = 0.0;
    self.filterTypeBtn = filterTypeBtn;

    UIBarButtonItem * leftBarItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    NSArray * itemArray = @[deleteItem,adjustItem,addItem];
    self.navigationItem.rightBarButtonItems = itemArray;

    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:filterShow];
    [filterShow addSubview:self.filterCollectionView];
    [filterShow addSubview:filterTypeBtn];
    
    if (IS_IPAD) {
        self.filterCollectionView.frame = CGRectMake((TOPScreenWidth-[TOPPictureProcessTool top_processTypeArray].count*90)/2, 0, [TOPPictureProcessTool top_processTypeArray].count*90, 90);
    }
    [self top_addBottomView];
    UIView * safeView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    safeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:safeView];
    
    _picH = ((TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)*(TOPScreenWidth-30))/TOPScreenWidth;

    [safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
        make.height.mas_equalTo(3);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(30+TOPTabBarHeight));
        make.height.mas_equalTo(PageViewH);
    }];
    [filterShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom).offset(-TOPTabBarHeight);
        make.height.mas_equalTo(FilterShow_H);
    }];
    if (IS_IPAD) {
        [self.filterCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(filterShow);
            make.centerX.equalTo(filterShow);
            make.size.mas_equalTo(CGSizeMake([TOPPictureProcessTool top_processTypeArray].count*90, 90));
        }];
    }else{
        [self.filterCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(filterShow);
            make.height.mas_equalTo(90);
        }];
    }
    [filterTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(filterShow);
        make.top.equalTo(filterShow).offset(90);
        make.height.mas_equalTo(40);
    }];
}
#pragma mark -- 添加左右两边的调节试图
- (void)top_addSliderBackView{
    UIView * brightnessBackView = [[UIView alloc]initWithFrame:CGRectZero];
    brightnessBackView.layer.cornerRadius = 10;
    brightnessBackView.layer.masksToBounds = YES;
    self.brightnessBackView = brightnessBackView;
    
    UIView * contrastBackView = [[UIView alloc]initWithFrame:CGRectZero];
    contrastBackView.layer.cornerRadius = 10;
    contrastBackView.layer.masksToBounds = YES;
    self.contrastBackView = contrastBackView;
    if ([TOPDocumentHelper top_isdark]) {
        brightnessBackView.backgroundColor = RGBA(0, 0, 0, 0.7);
        contrastBackView.backgroundColor = RGBA(0, 0, 0, 0.7);
    }else{
        brightnessBackView.backgroundColor = RGBA(0, 0, 0, 0.5);
        contrastBackView.backgroundColor = RGBA(0, 0, 0, 0.5);
    }
    [self.view addSubview:brightnessBackView];
    [self.view addSubview:contrastBackView];
    [brightnessBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-50);
        make.trailing.equalTo(self.view.mas_leading);
        make.size.mas_equalTo(CGSizeMake(80, 350));
    }];
    
    [contrastBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-50);
        make.leading.equalTo(self.view.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(80, 350));
    }];
}
- (void)top_setBrightnessBackViewChild{
    UIImageView * brightImg = [[UIImageView alloc]initWithFrame:CGRectMake(29, 35, 22, 22)];
    brightImg.image = [UIImage imageNamed:@"top_sliderbright"];
    [self.brightnessBackView addSubview:brightImg];
    [self.brightnessBackView addSubview:self.brightnessSliderView];
}
- (void)top_setcontrastBackViewChild{
    UIImageView * contrastImg = [[UIImageView alloc]initWithFrame:CGRectMake(29, 35, 22, 22)];
    contrastImg.image = [UIImage imageNamed:@"top_slidercontrast"];
    [self.contrastBackView addSubview:contrastImg];
    [self.contrastBackView addSubview:self.contrastSliderView];
}
- (void)childViewDefaultState{
    [self.images removeAllObjects];
    [self.backBtn setImage:[UIImage imageNamed:@"top_backBtnUnEnable"] forState:UIControlStateNormal];
    self.backBtn.enabled = NO;
    self.deleteBtn.hidden = YES;
    self.adjustBtn.hidden = YES;
    self.addPicBtn.hidden = YES;
    self.isloadFinish = NO;
    [self.bottomView top_changeBtnState:NO];
}

- (void)top_childViewLoadFinishState{
    self.isloadFinish = YES;
    if (isRTL()) {
        [self.backBtn setImage:[UIImage imageNamed:@"top_RTLbackItem"] forState:UIControlStateNormal];
        self.backBtn.style = EImageLeftTitleRightCenter;
    }else{
        [self.backBtn setImage:[UIImage imageNamed:@"top_backItem"] forState:UIControlStateNormal];
        self.backBtn.style = EImageLeftTitleRightLeft;
    }
    self.backBtn.enabled = YES;
    [self.collectionView reloadData];
    int pageIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    if (pageIndex != self.images.count) {
        self.pageView.allCount = self.images.count;
        self.pageView.currentIndex = self.currentIndex+1;
        self.pageView.cameraIndex = self.currentIndex;
        self.deleteBtn.hidden = NO;
        self.adjustBtn.hidden = NO;
        self.addPicBtn.hidden = NO;
        [self.bottomView top_changeBtnState:YES];
    }else{
        if (self.isloadFinish) {
            [self.bottomView top_changeFinishBtnState:YES];
        }
    }
}
- (TOPTrackingSliderView *)brightnessSliderView{
    if (!_brightnessSliderView) {
        _brightnessSliderView = [[TOPTrackingSliderView alloc]initWithFrame:CGRectMake(-250/2+40, 350/2, 250, 50)];
        _brightnessSliderView.minValue = -1;
        _brightnessSliderView.maxValue = 1;
        _brightnessSliderView.defaultValue = 0;
        _brightnessSliderView.isVertical = YES;
        _brightnessSliderView.delegate = self;
        _brightnessSliderView.maxmumTrackTintColor = [UIColor whiteColor];
        _brightnessSliderView.minimumTrackTintColor = TOPAPPGreenColor;
        _brightnessSliderView.circleImg = [UIImage imageNamed:@"top_slidercircle"];
    }
    return _brightnessSliderView;
}

- (TOPTrackingSliderView *)contrastSliderView{
    if (!_contrastSliderView) {
        _contrastSliderView = [[TOPTrackingSliderView alloc]initWithFrame:CGRectMake(-250/2+40, 350/2, 250, 50)];
        _contrastSliderView.minValue = 0;
        _contrastSliderView.maxValue = 2;
        _contrastSliderView.defaultValue = 1;
        _contrastSliderView.isVertical = YES;
        _contrastSliderView.delegate = self;
        _contrastSliderView.maxmumTrackTintColor = [UIColor whiteColor];
        _contrastSliderView.minimumTrackTintColor = TOPAPPGreenColor;
        _contrastSliderView.circleImg = [UIImage imageNamed:@"top_slidercircle"];
    }
    return _contrastSliderView;
}
- (void)top_childViewLoadPartState{
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth, 0) animated:NO];
    self.pageView.currentIndex = self.currentIndex+1;
    self.pageView.cameraIndex = self.currentIndex;
}
#pragma mark -- slider的初始值
- (void)top_resetSliderValue:(TOPCameraBatchModel *)model{
    self.brightnessSliderView.defaultValue = model.brightnessValue;
    self.contrastSliderView.defaultValue = model.contrastValue;
}
#pragma mark -- TOPTrackingSliderViewDelegate
- (void)top_topCurrentSlider:(TOPTrackingSlider *)slider{
    TOPCameraBatchModel * model = self.images[self.currentIndex];
    if (self.brightnessSliderView.uiSlider == slider) {
        [FIRAnalytics logEventWithName:@"SCamerBatch_TOPPhotoReEditFilterBrightness" parameters:nil];
        [self.colorControlsFilter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputBrightness"];//设置滤镜参数
        model.brightnessValue = [[NSNumber numberWithFloat:slider.value] floatValue];
        [self top_setImageWithModel:model];
    }
    if (self.contrastSliderView.uiSlider == slider) {
        [FIRAnalytics logEventWithName:@"SCamerBatch_TOPPhotoReEditFilterContrast" parameters:nil];
        [self.colorControlsFilter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputContrast"];
        model.contrastValue = [[NSNumber numberWithFloat:slider.value] floatValue];
        [self top_setImageWithModel:model];
    }
}
- (void)dealloc{
    
}

@end
