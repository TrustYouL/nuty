#define BottomViewH 49
#define PageViewH   25
#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)
#define CropView_Y 45
#define CropView_X 15

#import "TOPBatchViewController.h"
#import "TOPBatchBottomView.h"
#import "TOPShowPagesView.h"
#import "TOPBatchCell.h"
#import "TOPBatchEditModel.h"
#import "TOPCropEditModel.h"
#import "TOPCameraBatchModel.h"
#import "TOPOpenCVWrapper.h"
#import "TOPSaveElementModel.h"
#import "TOPDataTool.h"

@interface TOPBatchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong)TOPBaseCollectionView * collectionView;
@property (nonatomic,strong)TOPBatchBottomView * bottomView;
@property (nonatomic,strong)TOPShowPagesView * pageView;
@property (nonatomic,strong)UIButton * rightBtn;
@property (nonatomic,strong)NSMutableArray * myArray;
@property (nonatomic,strong)NSMutableDictionary * saveDic;
@property (nonatomic,assign)CGFloat picH;
@property (nonatomic,assign)BOOL batchAutoCrop;
@end

@implementation TOPBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.batchAutoCrop = NO;
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_batchView_ClickToBack)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_batchView_ClickToBack)];
    }
    if (![TOPWHCFileManager top_isExistsAtPath:TOPBatchCropAgainShow_Path]) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPBatchCropAgainShow_Path];
    }
    _picH = ((TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)*(TOPScreenWidth-30))/TOPScreenWidth;
    [self top_setupUI];
    [self top_loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
- (void)top_clickRightBtn:(UIButton *)sender {
    self.batchAutoCrop = !self.batchAutoCrop;
    if (self.batchAutoCrop) {
        sender.selected = !sender.selected;
        [self top_batchFunctionAllOriginal];
    }else{
        if (sender.selected) {
            sender.selected = !sender.selected;
        }
        [self top_batchFunctionAllAuto];
    }
}
#pragma mark -- 所有图片的裁剪框是图片大小
- (void)top_batchFunctionAllOriginal{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<self.myArray.count; i++) {
            TOPCropEditModel * editeModel = self.myArray[i];
            editeModel.isAutomatic = NO;
            editeModel.isChange = YES;
            editeModel.isChangeType = YES;
            editeModel.showEndPoinArray = [editeModel.notAutoEndPoinArray mutableCopy];
            editeModel.cropState = TOPCropBtnStateAuto;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            TOPCropEditModel * editeModel = self.myArray[self.currentIndex];
            editeModel.cropState = TOPCropBtnStateAuto;
            [self.bottomView top_updateAllBtn:editeModel];
        });
    });
}
#pragma mark -- 所有图片裁剪框自适应
- (void)top_batchFunctionAllAuto{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<self.myArray.count; i++) {
            TOPCropEditModel * editeModel = self.myArray[i];
            editeModel.isAutomatic = YES;
            editeModel.isChangeType = YES;
            editeModel.isChange = YES;
            editeModel.showEndPoinArray = [editeModel.autoEndPoinArray mutableCopy];
            editeModel.cropState = TOPCropBtnStateFull;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            TOPCropEditModel * editeModel = self.myArray[self.currentIndex];
            [self.bottomView top_updateAllBtn:editeModel];
        });
    });
}
#pragma mark -- 处理加载数据
- (void)top_loadData{
    if (self.batchCropType == TOPBatchCropTypeChildBatchVC) {
        [self top_setChildBatchArray];
    }
    
    if (self.batchCropType == TOPBatchCropTypeCamera) {
        [self top_setCameraBatchArray];
    }
}
#pragma mark -- 从Child的Batch edit功能进入的数据
- (void)top_setChildBatchArray{
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * noOriginalImgArray = [NSMutableArray new];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<self.allBatchArray.count; i++) {
            @autoreleasepool {
                TOPBatchEditModel * batchModel = self.allBatchArray[i];
                NSString * originalPath = batchModel.originalPath;
                UIImage * originalImg = [UIImage imageWithContentsOfFile:originalPath];
                NSString * showPath = [TOPBatchCropAgainShow_Path stringByAppendingPathComponent:batchModel.photoName];
                if (originalImg) {
                    TOPCropEditModel * model = [TOPCropEditModel new];
                    model.originalPath = batchModel.originalPath;
                    model.imgPath = batchModel.imgPath;
                    model.coverImgPath = batchModel.coverImgPath;
                    model.notAutoEndPoinArray = [[self top_getModelNotAutoPoinArray:model] mutableCopy];
                    if (!batchModel.endPoinArray.count) {
                        [self top_getAutoPointsWithModel:batchModel];
                        if (!batchModel.autoEndPoinArray) {
                            batchModel.autoEndPoinArray = [model.notAutoEndPoinArray mutableCopy];
                        }
                        batchModel.endPoinArray = [model.notAutoEndPoinArray mutableCopy];
                        model.showEndPoinArray = [batchModel.autoEndPoinArray mutableCopy];
                    } else {
                        model.showEndPoinArray = [batchModel.endPoinArray mutableCopy];
                    }
                    model.endPoinArray = [batchModel.endPoinArray mutableCopy];
                    model.autoEndPoinArray = [batchModel.autoEndPoinArray mutableCopy];
                    model.picName = batchModel.photoName;
                    model.processType = batchModel.processType;
                    model.showPath = showPath;
                    model.index = i;
                    model.isChange = NO;
                    model.isChangeType = YES;
                    model.isAutomatic = YES;
                    BOOL potEqual = ![self top_compareArray:model.endPoinArray withArray:model.autoEndPoinArray];
                    model.leftCropBtnStates = potEqual ? @[@(TOPCropBtnStateFull), @(TOPCropBtnStateAuto)] : @[@(TOPCropBtnStateAuto), @(TOPCropBtnStateFull), @(TOPCropBtnStateFit)];
                    model.cropState = [model.leftCropBtnStates.firstObject integerValue];
                    [tempArray addObject:model];
                }else{
                    [noOriginalImgArray addObject:batchModel.indexString];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.myArray = tempArray;
            [self top_setViewDefaultState];
            [self.collectionView reloadData];
            [self top_showToast:noOriginalImgArray];
        });
    });
}

- (NSMutableArray *)top_getModelNotAutoPoinArray:(TOPCropEditModel *)editeModel{
    NSData *cropImgData = [NSData dataWithContentsOfFile:editeModel.originalPath];
    UIImage * cropImg =  [TOPPictureProcessTool top_scaleImageWithData:cropImgData withSize:CGSizeMake(TOPScreenWidth-30, _picH)];
    CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:cropImg fatherW:TOPScreenWidth-30 fatherH:_picH];
    NSMutableArray * notAutoPoinArray = [NSMutableArray new];
    [notAutoPoinArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [notAutoPoinArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, 0)]];
    [notAutoPoinArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, imgRect.size.height)]];
    [notAutoPoinArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, imgRect.size.height)]];
    return notAutoPoinArray;
}

#pragma mark -- 获取自动识别的裁剪坐标
- (void)top_getAutoPointsWithModel:(TOPBatchEditModel *)batchModel {
    NSData *imgData = [NSData dataWithContentsOfFile:batchModel.originalPath];
    UIImage * cropImg =  [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(TOPScreenWidth-30, self.picH)];
    CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:cropImg fatherW:TOPScreenWidth-30 fatherH:self.picH];
    NSMutableArray * pointArray = [[TOPOpenCVWrapper top_getLargestSquarePoints:cropImg :imgRect.size :YES] mutableCopy];
    batchModel.autoEndPoinArray = pointArray;
}

- (void)top_showToast:(NSMutableArray *)noOriginalImgArray{
    NSString * toastString = [NSString new];
    if (noOriginalImgArray.count>0) {
        if (noOriginalImgArray.count == 1) {
            toastString = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topscan_nooriginalimgdefault", @""),noOriginalImgArray[0]];
        }
        
        if (noOriginalImgArray.count == 2) {
            toastString = [NSString stringWithFormat:@"%@(%@,%@)",NSLocalizedString(@"topscan_nooriginalimgdefault", @""),noOriginalImgArray[0],noOriginalImgArray[1]];
        }
        
        if (noOriginalImgArray.count == 3) {
            toastString = [NSString stringWithFormat:@"%@(%@,%@,%@)",NSLocalizedString(@"topscan_nooriginalimgdefault", @""),noOriginalImgArray[0],noOriginalImgArray[1],noOriginalImgArray[2]];
        }
        
        if (noOriginalImgArray.count > 3) {
            if ([TOPScanerShare top_saveOriginalImage]==TOPSettingSaveYES) {
                toastString = [NSString stringWithFormat:@"%@(%@,%@,%@ %@)",NSLocalizedString(@"topscan_nooriginalimgdefault", @""),noOriginalImgArray[0],noOriginalImgArray[1],noOriginalImgArray[2],NSLocalizedString(@"topscan_nooriginalimgmore", @"")];
            }
            
            if ([TOPScanerShare top_saveOriginalImage]==TOPSettingSaveNO) {
                toastString = [NSString stringWithFormat:@"%@(%@,%@,%@ %@,%@)",NSLocalizedString(@"topscan_nooriginalimgdefault", @""),noOriginalImgArray[0],noOriginalImgArray[1],noOriginalImgArray[2],NSLocalizedString(@"topscan_nooriginalimgmore", @""),NSLocalizedString(@"topscan_nooriginalimgsetting", @"")];
            }
        }
        [[TOPCornerToast shareInstance] makeToast:toastString duration:1.5];
    }
}
#pragma mark -- 从相机进入的数据
- (void)top_setCameraBatchArray{
    NSMutableArray * tempArray = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<self.cameraArray.count; i++) {
            @autoreleasepool {
                TOPCameraBatchModel * cameraModel = self.cameraArray[i];
                NSString * picName = cameraModel.PicName;
                NSString * showPath = [TOPBatchCropAgainShow_Path stringByAppendingPathComponent:picName];
                
                TOPCropEditModel * model = [TOPCropEditModel new];
                model.picName = picName;
                model.originalPath = cameraModel.originalImgPath;
                model.imgPath = cameraModel.imgPath;
                model.cropImgPath = cameraModel.cropPath;
                model.adjustPicPath = cameraModel.adjustPicPath;
                model.processType = cameraModel.processType;
                if (!cameraModel.endPoinArray.count) {
                    [self top_setBatchPointModel:cameraModel];
                    model.endPoinArray = [cameraModel.notAutoEndPoinArray mutableCopy];
                } else {
                    model.endPoinArray = [cameraModel.endPoinArray mutableCopy];
                }
                model.showEndPoinArray = [cameraModel.endPoinArray mutableCopy];
                model.autoEndPoinArray = [cameraModel.autoEndPoinArray mutableCopy];
                model.notAutoEndPoinArray = [cameraModel.notAutoEndPoinArray mutableCopy];
                model.elementModel = cameraModel.elementModel;
                model.showPath = showPath;
                BOOL potEqual = ![self top_compareArray:cameraModel.endPoinArray withArray:cameraModel.autoEndPoinArray];
                model.leftCropBtnStates = potEqual ? @[@(TOPCropBtnStateFull), @(TOPCropBtnStateAuto)] : @[@(TOPCropBtnStateAuto), @(TOPCropBtnStateFull), @(TOPCropBtnStateFit)];
                model.cropState = [model.leftCropBtnStates.firstObject integerValue];
                model.index = i;
                if (!cameraModel.isFinishCrop) {
                    if (cameraModel.autoEndPoinArray == cameraModel.notAutoEndPoinArray) {//裁剪区域就是原图区域
                        model.isChange = NO;
                    }else{
                        model.isChange = YES;
                    }
                }else{
                    model.isChange = NO;
                }
                model.isChangeType = YES;
                model.isAutomatic = YES;
                [tempArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myArray = tempArray;
            [self top_setViewDefaultState];
            [self.collectionView reloadData];
        });
    });
}
#pragma mark -- 自动裁剪没开启，需要获取裁剪坐标点
- (void)top_setBatchPointModel:(TOPCameraBatchModel *)batchModel {
    NSData *imgData = [NSData dataWithContentsOfFile:batchModel.originalImgPath];
    UIImage * cropImg =  [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(TOPScreenWidth-30, self.picH)];
    CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:cropImg fatherW:TOPScreenWidth-30 fatherH:self.picH];
    NSMutableArray * pointArray = [[TOPOpenCVWrapper top_getLargestSquarePoints:cropImg :imgRect.size :YES] mutableCopy];
    [self top_setBatchPointWithModel:batchModel AndDefaultPointArray:pointArray AndBatchRect:imgRect];
    batchModel.cropImgViewRect = imgRect;
    batchModel.endPoinArray = batchModel.autoEndPoinArray;
}

- (void)top_setBatchPointWithModel:(TOPCameraBatchModel *)model AndDefaultPointArray:(NSMutableArray *)pointArray AndBatchRect:(CGRect)imgRect{
    NSMutableArray * apexArray = @[].mutableCopy;
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, 0)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, imgRect.size.height)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, imgRect.size.height)]];
    model.notAutoEndPoinArray = apexArray;
    if (!pointArray.count) {
        model.autoEndPoinArray = apexArray;
    }else{
        model.autoEndPoinArray = pointArray;
    }
    NSString * originalDealPath = model.originalImgPath;
    TOPSaveElementModel * elementModel = [TOPDataModelHandler top_getBatchSavePointData:model.autoEndPoinArray imgPath:originalDealPath imgRect:imgRect];
    model.elementModel = elementModel;
}

- (void)top_setViewDefaultState{
    self.pageView.allCount = self.myArray.count;
    self.pageView.currentIndex = self.currentIndex+1;
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth, 0) animated:NO];
    [self top_setBtnDefaultState:self.currentIndex];
    [self top_setRightBtnState:self.currentIndex];
}

- (void)top_setBtnDefaultState:(NSInteger)index{
    TOPCropEditModel * model = self.myArray[index];
    [self.bottomView top_updateAllBtn:model];
}
- (void)top_setRightBtnState:(NSInteger)index{
    TOPCropEditModel * model = self.myArray[index];
    BOOL notPotEqual = ![self top_compareArray:model.showEndPoinArray withArray:model.notAutoEndPoinArray];
    model.isNotAutoEndPoint = notPotEqual;
    if (model.isNotAutoEndPoint) {
        BOOL potEqual = ![self top_compareArray:model.endPoinArray withArray:model.notAutoEndPoinArray];//保存的坐标是四个顶点坐标
        if (potEqual) {
            if (model.cropState == TOPCropBtnStateFull) {
                self.batchAutoCrop = NO;
                self.rightBtn.selected = NO;
            }else{
                self.batchAutoCrop = YES;
                self.rightBtn.selected = YES;
            }
        }else{
            self.batchAutoCrop = YES;
            self.rightBtn.selected = YES;
        }
    }else{
        self.batchAutoCrop = NO;
        self.rightBtn.selected = NO;
    }
}
- (void)top_bottomViewFunctionWithBtnTag:(NSInteger)tag selectState:(BOOL)isSelect{
    NSArray * numArray = [self top_functionArray];
    switch ([numArray[tag] integerValue]) {
        case TOPBatchEditActionTypeImageAll:
            if (isSelect) {
                [self top_batchFunctionAll];
            }else{
                [self top_batchFunctionAuto];
            }
            break;
        case TOPBatchEditActionTypeImageAuto:
            break;
        case TOPBatchEditActionTypeImageOrientationLeft:
//            [self batchFunctionImageOrientationLeft];
            break;
        case TOPBatchEditActionTypeImageOrientationRight:
//            [self batchFunctionImageOrientationRight];
            break;
        case TOPBatchEditActionTypeImageFinish:
            [self top_batchFunctionFinish];
            break;
        default:
            break;
    }
}

#pragma mark -- 裁剪状态切换
- (void)top_updateCropViewPointsData:(NSInteger)state {
    TOPCropEditModel * model = self.myArray[self.currentIndex];
    model.isChange = YES;
    model.isChangeType = YES;
    switch (state) {
        case TOPCropBtnStateAuto:
            model.isAutomatic = YES;
            model.showEndPoinArray = model.autoEndPoinArray.mutableCopy;
            self.batchAutoCrop = NO;
            self.rightBtn.selected = NO;
            break;
        case TOPCropBtnStateFull:
            model.isAutomatic = NO;
            model.showEndPoinArray = model.notAutoEndPoinArray.mutableCopy;
            self.batchAutoCrop = YES;
            self.rightBtn.selected = YES;
            break;
        case TOPCropBtnStateFit:
            model.isAutomatic = NO;
            model.showEndPoinArray = model.endPoinArray.mutableCopy;
            self.batchAutoCrop = YES;
            self.rightBtn.selected = NO;
            break;
        default:
            break;
    }
    [self.collectionView reloadData];
}

#pragma mark -- 裁剪框是图片大小
- (void)top_batchFunctionAll{
    [FIRAnalytics logEventWithName:@"SCBatchVC_batchFunctionAll" parameters:nil];
    TOPCropEditModel * editeModel = self.myArray[self.currentIndex];
    editeModel.isAutomatic = NO;
    editeModel.isChange = YES;
    editeModel.isChangeType = YES;
    if (self.batchCropType == TOPBatchCropTypeCamera) {
        editeModel.showEndPoinArray = [editeModel.notAutoEndPoinArray mutableCopy];
    }else{
        editeModel.showEndPoinArray = [editeModel.notAutoEndPoinArray mutableCopy];
    }
    [self.collectionView reloadData];
}
#pragma mark -- 裁剪框自适应
- (void)top_batchFunctionAuto{
    [FIRAnalytics logEventWithName:@"SCBatchVC_batchFunctionAuto" parameters:nil];
    TOPCropEditModel * editeModel = self.myArray[self.currentIndex];
    editeModel.isAutomatic = YES;
    editeModel.isChange = YES;
    editeModel.isChangeType = YES;
    if (self.batchCropType == TOPBatchCropTypeCamera) {
        editeModel.showEndPoinArray = [editeModel.autoEndPoinArray mutableCopy];
    }else{
        editeModel.showEndPoinArray = [editeModel.endPoinArray mutableCopy];
    }
    [self.collectionView reloadData];
}
#pragma mark -- 需要保存的数据
- (NSArray *)top_getDealData{
    NSMutableArray * changeArray = [NSMutableArray new];
    for (TOPCropEditModel * model in self.myArray) {
        if (model.isChange) {
            if ([self top_compareArray:model.endPoinArray withArray:model.showEndPoinArray]) {
                NSData *imgData = [NSData dataWithContentsOfFile:model.originalPath];
                UIImage * cropImg =  [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(TOPScreenWidth-30, self.picH)];
                CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:cropImg fatherW:TOPScreenWidth-30 fatherH:self.picH];
                TOPSaveElementModel * elementModel = [TOPDataModelHandler top_getBatchSavePointData:model.showEndPoinArray imgPath:model.originalPath imgRect:imgRect];
                model.elementModel = elementModel;
                [changeArray addObject:model];
            }else{
                model.isChange = NO;
            }
        }else{
            if(self.batchCropType == TOPBatchCropTypeChildBatchVC){
                [self top_judgeChangeModel:model toDealArray:changeArray];
            }
        }
    }
    return [changeArray copy];
}
#pragma mark -- TOPBatchCropTypeChildBatchVC入口 点击保存按钮时获取需要处理的数据
- (void)top_judgeChangeModel:(TOPCropEditModel *)model toDealArray:(NSMutableArray *)changeArray{
    if ([self top_compareArray:model.endPoinArray withArray:model.showEndPoinArray]) {
        model.isChange = YES;
        model.isChangeType = YES;
        [changeArray addObject:model];
    }else{
        UIImage * showImage = [UIImage imageWithContentsOfFile:model.imgPath];
        UIImageOrientation imgOrientation = showImage.imageOrientation;
        if (imgOrientation != UIImageOrientationUp) {
            model.isChange = YES;
            model.isChangeType = YES;
            [changeArray addObject:model];
        }else{
            model.isChange = NO;
        }
    }
}
#pragma mark -- 完成事件 跳转
- (void)top_batchFunctionFinish{
    if (self.batchCropType == TOPBatchCropTypeCamera) {
        [FIRAnalytics logEventWithName:@"SCBatchVC_batchFunctionCameraFinish" parameters:nil];
    }
    
    if (self.batchCropType == TOPBatchCropTypeChildBatchVC) {
        [FIRAnalytics logEventWithName:@"SCBatchVC_batchFunctionBatchFinish" parameters:nil];
    }
    
    WS(weakSelf);
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * changeArray = [weakSelf top_getDealData];
        if (changeArray.count>1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(1/%@)",NSLocalizedString(@"topscan_processing", @""),@(changeArray.count)]];
            });
        }
        
        if (changeArray.count>0) {
            for (int i = 0; i<changeArray.count; i++) {
                @autoreleasepool {
                    TOPCropEditModel * editeModel = changeArray[i];
                    if (editeModel.isChange) {
                        if (weakSelf.batchCropType == TOPBatchCropTypeCamera) {
                            [weakSelf top_saveBatchCropTypeCameraImgData:editeModel];
                        }
                        if (weakSelf.batchCropType == TOPBatchCropTypeChildBatchVC) {
                            [weakSelf top_saveBatchCropTypeChildBatchVCImgData:editeModel];
                        }
                    }
                    if (changeArray.count>1) {
                        CGFloat stateF = ((i+1) * 10.0)/(changeArray.count * 10.0);
                        [[TOPProgressStripeView shareInstance] top_showProgress:stateF withStatus:[NSString stringWithFormat:@"%@... (%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(i +1),@(changeArray.count)]];
                    }
                }
            }
        }
        [TOPWHCFileManager top_removeItemAtPath:TOPBatchCropAgainShow_Path];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[TOPProgressStripeView shareInstance] dismiss];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if (weakSelf.top_returnAndReloadData) {
                weakSelf.top_returnAndReloadData(weakSelf.myArray);
            }
        });
    });
}

#pragma mark -- 入口在相机
- (void)top_saveBatchCropTypeCameraImgData:(TOPCropEditModel *)editeModel{
    WS(weakSelf);
    UIImage * saveImage = [UIImage new];
    if (editeModel.isChange) {
        if ([self top_compareArray:editeModel.endPoinArray withArray:editeModel.showEndPoinArray]) {
            if (![self top_compareArray:editeModel.notAutoEndPoinArray withArray:editeModel.showEndPoinArray]) {
                saveImage = [UIImage imageWithContentsOfFile:editeModel.originalPath];
            } else {
                if (editeModel.isChangeType) {
                    UIImage * img = [UIImage imageWithContentsOfFile:editeModel.elementModel.originalPath];
                    saveImage = [TOPOpenCVWrapper top_getTransformedObjectImage:editeModel.elementModel.saveW :editeModel.elementModel.saveH :img :editeModel.elementModel.pointArray :img.size];
                } else {
                    TOPSaveElementModel * model = [weakSelf.saveDic valueForKey:[NSString stringWithFormat:@"%@",@(editeModel.index)]];
                    UIImage * img = [UIImage imageWithContentsOfFile:model.originalPath];
                    saveImage = [TOPOpenCVWrapper top_getTransformedObjectImage:model.saveW :model.saveH :img :model.pointArray :img.size];
                }
            }
            editeModel.endPoinArray = editeModel.showEndPoinArray;
        }

        CGImageRef cgref = [saveImage CGImage];
        CIImage *cim = [saveImage CIImage];
        if (cim == nil && cgref == NULL) {
        }else{
            [weakSelf top_saveCropImg:saveImage targetModel:editeModel];
        }
    }
}

- (BOOL)top_compareArray:(NSMutableArray *)array1 withArray:(NSMutableArray *)array2{
    if (!array1.count || !array2.count) {
        return NO;
    }
    NSSet * set1 = [NSSet setWithArray:[array1 copy]];
    NSSet * set2 = [NSSet setWithArray:[array2 copy]];
    if ([set1 isEqualToSet:set2]) {
        return NO;
    }
    return YES;
}
#pragma mark -- 入口在TOPHomeChildBatchViewController
- (void)top_saveBatchCropTypeChildBatchVCImgData:(TOPCropEditModel *)editeModel{
    WS(weakSelf);
    UIImage * saveImage = [UIImage new];
    if (editeModel.isChange) {
        if (editeModel.isChangeType) {
           saveImage = [self top_judgeImageOrientationAndDeal:editeModel];
        }else{
            TOPSaveElementModel * model = [weakSelf.saveDic valueForKey:[NSString stringWithFormat:@"%@",@(editeModel.index)]];
            saveImage = [TOPOpenCVWrapper top_getTransformedObjectImage:model.saveW :model.saveH :[UIImage imageWithContentsOfFile:model.originalPath] :model.pointArray :[UIImage imageWithContentsOfFile:model.originalPath].size];
            editeModel.endPoinArray = [editeModel.showEndPoinArray mutableCopy];
        }
    }

    if (saveImage) {
        [weakSelf top_saveCropImg:saveImage targetModel:editeModel];
    }
}
- (UIImage *)top_judgeImageOrientationAndDeal:(TOPCropEditModel *)editeModel{
    UIImage * saveImage = [UIImage new];
    saveImage = [UIImage imageWithContentsOfFile:editeModel.imgPath];
    UIImageOrientation imgOrientation = saveImage.imageOrientation;
    if (imgOrientation != UIImageOrientationUp) {
        saveImage =  [self top_saveNotChangeImage:editeModel];
    }else{
        if ([self top_compareArray:editeModel.endPoinArray withArray:editeModel.showEndPoinArray]) {
            saveImage =  [self top_saveNotChangeImage:editeModel];
        }
    }
    return saveImage;
}
#pragma mark -- 获取裁剪框的图片
- (UIImage *)top_saveNotChangeImage:(TOPCropEditModel *)editeModel{
    UIImage * saveImage = [UIImage new];
    UIImage * img = [UIImage imageWithContentsOfFile:editeModel.originalPath];//原图
    NSData *cropImgData = [NSData dataWithContentsOfFile:editeModel.originalPath];
    UIImage * cropImg =  [TOPPictureProcessTool top_scaleImageWithData:cropImgData withSize:CGSizeMake(TOPScreenWidth-30, _picH)];//生成小图
    CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:cropImg fatherW:TOPScreenWidth-30 fatherH:_picH];

    NSMutableArray * pointArray = editeModel.showEndPoinArray;
    if (pointArray.count&&[self top_compareArray:editeModel.notAutoEndPoinArray withArray:editeModel.showEndPoinArray]) {
        TOPSaveElementModel * model = [TOPDataModelHandler top_getBatchSavePointData:pointArray img:img imgRect:imgRect];
        saveImage = [TOPOpenCVWrapper top_getTransformedObjectImage:model.saveW :model.saveH :model.originalImage :model.pointArray :model.originalImage.size];
    }else{
        saveImage = img;
    }
    editeModel.endPoinArray = [editeModel.showEndPoinArray mutableCopy];
    return saveImage;
}

#pragma mark -- 保存图片的处理
- (void)top_saveCropImg:(UIImage *)saveImage targetModel:(TOPCropEditModel *)editeModel{
    if (saveImage) {
        if ([TOPWHCFileManager top_isExistsAtPath:editeModel.cropImgPath]) {
            [TOPWHCFileManager top_removeItemAtPath:editeModel.cropImgPath];
            [TOPDocumentHelper top_saveImage:saveImage atPath:editeModel.cropImgPath];
            GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:saveImage];
            UIImage *filterImage = [TOPDataTool top_pictureProcessData:imageSource withImg:saveImage withItem:editeModel.processType];
            [TOPDocumentHelper top_saveImage:filterImage atPath:editeModel.imgPath];
            [TOPDocumentHelper top_saveImage:filterImage atPath:editeModel.adjustPicPath];
        }else{
            [TOPDocumentHelper top_saveImage:saveImage atPath:editeModel.imgPath];
        }

        if ([TOPWHCFileManager top_isExistsAtPath:editeModel.coverImgPath]) {//数据源不是来自相机
            [TOPDataModelHandler top_updateCoverImage:editeModel.imgPath atPath:editeModel.coverImgPath];
        }
    }
}

#pragma mark --当前只能是的cell做过移动操作就保存坐标等内容
- (void)top_saveChangeImageElement{
    [FIRAnalytics logEventWithName:@"SCBatchVC_saveChangeImageElement" parameters:nil];
    NSArray * elementArray = [NSArray new];
    TOPCropEditModel * model = self.myArray[self.currentIndex];

    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    TOPBatchCell * batCell = (TOPBatchCell*)cell;
    elementArray = [batCell.cropView cropOriginalImagePoints];
    if (elementArray.count>3) {
        NSMutableArray * pointArray = [NSMutableArray new];
        for (int i = 1; i < elementArray.count; i ++) {
            NSString *pStr = elementArray[i];
            CGPoint cropPoint = CGPointFromString(pStr);
            [pointArray addObject:[NSValue valueWithCGPoint:cropPoint]];
            
        }
        NSString *size = elementArray.firstObject;
        CGPoint sp = CGPointFromString(size);

        TOPSaveElementModel * saveModel = [TOPSaveElementModel new];
        saveModel.saveW = sp.x;
        saveModel.saveH = sp.y;
        saveModel.originalPath = model.originalPath;
        saveModel.pointArray = pointArray;
        [self.saveDic setValue:saveModel forKey:[NSString stringWithFormat:@"%@",@(model.index)]];
    }
}

#pragma mark -- 记录滑动操作时的四点位置
- (void)top_saveChangeImgendPoint{
    TOPCropEditModel * model = self.myArray[self.currentIndex];
    [model.showEndPoinArray removeAllObjects];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    TOPBatchCell * batCell = (TOPBatchCell*)cell;
    model.showEndPoinArray = [[batCell.cropView top_saveChangeEndPointArray] mutableCopy];
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

- (void)top_showPageViewFunction:(NSInteger)tag{
    [FIRAnalytics logEventWithName:@"SCBatchVC_showPageViewFunction" parameters:nil];
    if (tag == TOPBatchEditActionTypeImageOrientationLeft) {
        self.currentIndex--;
    }
    if (tag ==TOPBatchEditActionTypeImageOrientationRight) {
        self.currentIndex++;
    }
    self.pageView.currentIndex = self.currentIndex+1;
    TOPCropEditModel * editeModel = self.myArray[self.currentIndex];
    [self.bottomView top_updateAllBtn:editeModel];
    [self top_setRightBtnState:self.currentIndex];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * TOPScreenWidth, 0) animated:NO];
}
#pragma mark --UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.myArray.count;
}

- (__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    TOPCropEditModel * model = weakSelf.myArray[indexPath.item];
    TOPBatchCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPBatchCell class]) forIndexPath:indexPath];
    cell.batchCropType = self.batchCropType;
    cell.model = model;
    cell.top_saveChangeData = ^{
        [weakSelf top_saveChangeImageElement];
        [weakSelf top_saveChangeImgendPoint];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-BottomViewH);
}
#pragma mark --scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentIndex = pageIndex;
    self.pageView.currentIndex = self.currentIndex+1;
    if (self.currentIndex<self.myArray.count) {
        TOPCropEditModel * editeModel = self.myArray[self.currentIndex];
        [self.bottomView top_updateAllBtn:editeModel];
        [self top_setRightBtnState:self.currentIndex];
    }
    [self dealGestureConflict:scrollView];
}

#pragma mark -- 处理侧滑和滚动的手势冲突
- (void)dealGestureConflict:(UIScrollView *)scrollView{
    NSArray * gestureArray = self.navigationController.view.gestureRecognizers;
    for (UIGestureRecognizer * gesture in gestureArray) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [scrollView.panGestureRecognizer requireGestureRecognizerToFail:gesture];
        }
    }
}
#pragma mark -- 返回
- (void)top_batchView_ClickToBack{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * changeArray = [self top_getDealData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (changeArray.count>0) {
                WS(weakSelf);
                TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_prompt", @"")
                                                                               message:NSLocalizedString(@"topscan_promptcontent", @"")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_no", @"") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                    [TOPWHCFileManager top_removeItemAtPath:TOPBatchCropAgainShow_Path];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertAction* saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_batchsave", @"") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [weakSelf top_batchFunctionFinish];
                }];
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleDefault
                                                                     handler:nil];
                [alert addAction:noAction];
                [alert addAction:saveAction];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                [TOPWHCFileManager top_removeItemAtPath:TOPBatchCropAgainShow_Path];
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    });
}

- (void)top_setupUI{
    UIView * safeView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    safeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"top_BatchAllOriginal"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"top_BatchAllAuto"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(top_clickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    [self.view addSubview:safeView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageView];
    
    [safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(BottomViewH);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+BottomViewH));
    }];
    
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+BottomViewH+20));
        make.height.mas_equalTo(PageViewH);
    }];
}

- (NSMutableArray *)myArray{
    if (!_myArray) {
        _myArray = [NSMutableArray new];
    }
    return _myArray;
}

- (NSMutableDictionary *)saveDic{
    if (!_saveDic) {
        _saveDic = [NSMutableDictionary new];
    }
    return _saveDic;
}

- (TOPBatchBottomView *)bottomView{
    if (!_bottomView) {
        WS(weakSelf);
        _bottomView = [[TOPBatchBottomView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-BottomViewH, TOPScreenWidth, BottomViewH)];
        _bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _bottomView.top_sendBtnTag = ^(NSInteger tag ,BOOL isSelect) {
            [weakSelf top_bottomViewFunctionWithBtnTag:tag selectState:isSelect];
        };
        _bottomView.top_cropBtnClick = ^(NSInteger state) {
            [weakSelf top_updateCropViewPointsData:state];
        };
    }
    return _bottomView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[TOPBaseCollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-BottomViewH) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPBatchCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPBatchCell class])];
    }
    return _collectionView;
}

- (TOPShowPagesView *)pageView{
    if (!_pageView) {
        WS(weakSelf);
        _pageView = [[TOPShowPagesView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-BottomViewH-PageViewH-20, TOPScreenWidth, PageViewH)];
        _pageView.top_showPageAction = ^(NSInteger tag) {
            [weakSelf top_showPageViewfunctionBtnTag:tag];
        };
    }
    return _pageView;
}
- (NSArray *)top_functionArray{
    NSArray * array = @[@(TOPBatchEditActionTypeImageAll),@(TOPBatchEditActionTypeImageFinish)];
    return array;
}

- (NSArray *)top_showPagefunctionArray{
    NSArray * array = @[@(TOPBatchEditActionTypeImageOrientationLeft),@(TOPBatchEditActionTypeImageOrientationRight)];
    return array;
}

@end
