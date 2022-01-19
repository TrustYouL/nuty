#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)
#define KAnimateImgW 250
#define kPickViewItemH 30
#define KCodeResultViewH 105

#import "TOPSCameraViewController.h"
#import "TOPHomeChildViewController.h"
#import "TOPSingleBatchViewController.h"
#import "TOPCaptureView.h"
#import "PHAsset+Method.h"
#import "TOPPictureProcessTool.h"
#import "TOPCameraShowViewController.h"
#import "TOPCamerBatchViewController.h"
#import "TopScanner-Swift.h"
#import "TOPCameraCropSetView.h"
#import "TOPCameraFilterView.h"
#import "TOPCameraFilterRemindView.h"
#import "TOPCameraAutocropView.h"
#import "TOPIDCardCollageViewController.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPCodeReaderView.h"
#import "TOPCodeReaderResultView.h"
#import "TOPCameraTorchView.h"
#import "BEzPicker.h"
#import "TOPOpenCVWrapper.h"
#import "TOPSaveElementModel.h"
#import "TOPDataTool.h"
#import "TOPCameraBatchModel.h"

#define PhotoNumMax    1000
@interface TOPSCameraViewController ()<TOPCaptureViewDelegate,TZImagePickerControllerDelegate, BEzPickerDelegate, BEzPickerViewDataSource> {
    NSMutableArray *data;
}
@property (nonatomic ,strong) TOPCodeReaderResultView * codeResultView;
@property (nonatomic ,strong) TOPCodeReaderView * codeReaderView;
@property (nonatomic ,strong) UIView * blueLine;
@property (nonatomic ,strong) UIImageView * animateImg;
@property (nonatomic ,strong) UIView * coverView;
@property (nonatomic ,strong) TOPCameraFilterView * filterView;
@property (nonatomic ,strong) TOPCameraFilterRemindView * filterRemindView;
@property (nonatomic ,strong) TOPCameraAutocropView * autocropView;
@property (nonatomic ,strong) TOPCameraCropSetView * cropView;
@property (nonatomic ,strong) TOPCaptureView *captureView;
@property (nonatomic ,strong) TOPCameraTorchView *torchView;
@property (nonatomic ,strong) BEzPicker *pickerView;
@property (nonatomic ,strong) UILabel *takeModeTitleLab;
@property (nonatomic ,strong) UILabel * showFilterLab;
@property (nonatomic ,strong) UIButton * captureButton;
@property (nonatomic ,strong) UIButton * flashBtn;
@property (nonatomic ,strong) UIButton * cutStateBtn;
@property (nonatomic ,strong) UIButton * filterBtn;
@property (nonatomic ,strong) UIButton * lineBtn;

@property (nonatomic ,strong) UIView * topView;
@property (nonatomic ,strong) UIView * toolsView;
@property (nonatomic ,strong) UIView * tempView;
@property (nonatomic ,strong) UIImageView * tempImageView;
@property (nonatomic ,strong) UIButton * checkBtn;
@property (nonatomic ,strong) UILabel * alertLab;
@property (nonatomic ,strong) UIButton * closeBtn;
@property (nonatomic ,strong) UILabel * idCardTipLab;
@property (nonatomic ,strong) UILabel * idCardTitleLab;
@property (nonatomic ,strong) CAShapeLayer *rectShape;
@property (nonatomic ,strong) UIImageView *arrowView;
@property (nonatomic ,strong) NSMutableArray * picArray;
@property (nonatomic ,strong) UILabel * numberLab;
@property (nonatomic ,strong) UIButton * picBtn;
@property (nonatomic ,strong) UIButton * duiBtn;
@property (nonatomic ,strong) UIButton * resetBtn;
@property (nonatomic ,copy) NSString * addStr;
@property (nonatomic ,copy) NSString * codeResultString;
@property (nonatomic ,assign) BOOL statusHiden;
@property (nonatomic ,assign) BOOL CodeResultShow;
@property (nonatomic ,assign) NSInteger count;
@property (nonatomic ,copy) NSArray *titles;
@property (nonatomic ,assign) BOOL showModeToast;
@property (nonatomic ,assign) NSInteger takeNum;
@property (nonatomic ,assign) NSInteger pickImageNum;
@property (nonatomic ,assign) TOPScameraType scameraType;
@property (nonatomic ,assign) TOPScameraTakeMode takeMode;
@property (nonatomic ,assign) BOOL modeUnable;
@property (nonatomic ,copy) NSString * takeModeString;
@property (nonatomic ,assign) UIInterfaceOrientation * currentOrientation;
@property (nonatomic ,assign) CGFloat picH;
@property (nonatomic ,strong) NSMutableArray * cameraArray;

@end

@implementation TOPSCameraViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _fileType = TOPShowFolderCameraType;
        _takeNum = 1;
        _pickImageNum = PhotoNumMax;
        _takeMode = TOPScameraTakeModeBatch;
        if ([TOPScanerShare top_cameraTakeMode] == TOPScameraTakeModeBatch) {
            _takeNum = PhotoNumMax;
            _takeMode = TOPScameraTakeModeBatch;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 0;
    _CodeResultShow = NO;
    NSString * documentStr = [TOPDocumentHelper top_appBoxDirectory];
    NSString * addStr = [[self.pathString componentsSeparatedByString:documentStr] objectAtIndex:1];
    self.addStr = addStr;
    self.showModeToast = YES;
    self.picH = ((TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)*(TOPScreenWidth-30))/TOPScreenWidth;
    [self top_setupImageFile];
    [self top_customUI];
    if (self.fileType == TOPEnterHomeCameraTypeLibrary||self.fileType == TOPEnterNextFolderCameraTypeLibrary||self.fileType == TOPEnterDocumentCameraTypeLibrary) {
        [self top_cameraTypeLibraryState];
        [self top_codeReaderViewHideState];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"clearPhotoKey"];
    [self top_judgeAccidentPathData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(top_codeReaderAnimation) name:TOP_TRCodeReaderReStatr object:nil];
    
    [self.captureView top_startAccelerometerUpdates];
    [self top_clearPhotoFile];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.captureView top_endAccelerometerUpdates];
    [self.captureView top_flashSwitchOff];
}

- (void)setFileType:(TOPEnterCameraType)fileType {
    _fileType = fileType;
    [self top_configCameraParam];
}

- (void)top_configCameraParam {
    switch (_fileType) {
        case TOPShowFolderCameraType:
            [self top_setupFolderCamera];
            break;
        case TOPShowNextFolderCameraType:
            [self top_setupNextFolderCamera];
            break;
        case TOPShowDocumentCameraType:
            [self top_setupDocumentCamera];
            break;
        case TOPShowPhotoShowCameraType:
            [self top_setupPhotoShowCamera];
            break;
        case TOPShowToTextCameraType:
            [self top_setupToTextCamera];
            break;
        case TOPShowIDCardCameraType:
            [self top_setupIDCardCamera];
            break;
        case TOPShowSCamerBatchRetakeCameraType:
            [self top_setupSCamerBatchRetake];
            break;
        case TOPEnterCameraTypePDFSignature:
            [self top_setupPDFSignature];
            break;
        case TOPEnterCameraTypeQRCode:
            [self top_setupQRCode];
            break;
        case TOPEnterHomeCameraTypeLibrary:
        case TOPEnterNextFolderCameraTypeLibrary:
        case TOPEnterDocumentCameraTypeLibrary:
            [self top_setupLibrary];
            break;
        default:
            break;
    }
}
#pragma mark --AccidentView展示与否的判定
- (void)top_judgeAccidentPathData{
    if ([self top_canUserCamear]) {
        if (self.scameraType != TOPScameraTypeRetake) {
            if (self.fileType != TOPEnterHomeCameraTypeLibrary&&self.fileType !=TOPEnterNextFolderCameraTypeLibrary&&self.fileType != TOPShowPhotoShowCameraType&&self.fileType != TOPEnterDocumentCameraTypeLibrary) {
                [self top_showAccidentView];
            }
        }
    }
}
#pragma mark -- TOPHomeViewController相机入口
- (void)top_setupFolderCamera {
    self.modeUnable = NO;
}

#pragma mark -- TOPNextFolderViewController相机入口
- (void)top_setupNextFolderCamera {
    self.modeUnable = NO;
}

#pragma mark -- TOPHomeChildViewController相机入口
- (void)top_setupDocumentCamera {
    self.modeUnable = NO;
}

#pragma mark -- To text 拍照入口
- (void)top_setupToTextCamera {
    self.modeUnable = NO;
    self.takeMode = TOPScameraTakeModeOCR;
    self.takeModeString = NSLocalizedString(@"topscan_cameratypetotext", @"");
}

#pragma mark -- Id card 拍照入口
- (void)top_setupIDCardCamera {
    self.modeUnable = NO;
    self.takeMode = TOPScameraTakeModeIDCard;
    self.takeModeString = NSLocalizedString(@"topscan_collageidcard", @"");
}

#pragma mark -- TOPPhotoShowViewController相机入口retake
- (void)top_setupPhotoShowCamera {
    self.modeUnable = YES;
    self.pickImageNum = 1;
    self.takeNum = 1;
    self.takeMode = TOPScameraTakeModeSingle;
    self.takeModeString = NSLocalizedString(@"topscan_cameratypesingle", @"");
}

#pragma mark -- TOPCamerBatchViewController 拍照入口 retake
- (void)top_setupSCamerBatchRetake {
    self.modeUnable = YES;
    self.pickImageNum = 1;
    self.takeNum = 1;
    self.scameraType = TOPScameraTypeRetake;
    self.takeMode = TOPScameraTakeModeSingle;
    self.takeModeString = NSLocalizedString(@"topscan_cameratypesingle", @"");
}

#pragma mark -- PDF签名拍照入口
- (void)top_setupPDFSignature {
    self.modeUnable = YES;
    self.pickImageNum = 0;
    self.takeNum = 1;
    self.takeMode = TOPScameraTakeModeSingle;
    self.takeModeString = NSLocalizedString(@"topscan_cameratypesingle", @"");
}

#pragma mark -- 扫码入口
- (void)top_setupQRCode {
    self.modeUnable = YES;
    self.takeMode = TOPScameraTakeModeCodeReader;
    self.takeModeString = NSLocalizedString(@"topscan_cameratypeqrbarcode", @"");
}

- (void)top_setupLibrary {
    self.modeUnable = NO;
    self.takeNum = PhotoNumMax;
    self.takeMode = TOPScameraTakeModeBatch;
}
#pragma mark -- 清除临时图片 根据信号 -- clearPhotoKey (从图库选择图片到批处理 然后再返回相机界面时 要清空从图库选择的图片)
- (void)top_clearPhotoFile {
    BOOL isClear = [[NSUserDefaults standardUserDefaults] boolForKey:@"clearPhotoKey"];
    if (isClear) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"clearPhotoKey"];
        [self top_removeSaveFile];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
        [self.picBtn setImage:[UIImage imageNamed:@"top_tupian"] forState:UIControlStateNormal];
        self.picBtn.layer.borderColor = [UIColor clearColor].CGColor;
        self.duiBtn.hidden = YES;
        self.numberLab.hidden = YES;
        self.count = 0;
    }
}

#pragma mark -- 后台进入前台重新开始动画的通知 如果是在拍照就激活相机拍照功能
- (void)top_codeReaderAnimation{
    if (!self.codeReaderView.hidden) {
        [FIRAnalytics logEventWithName:@"top_codeReaderAnimation" parameters:nil];
        [self.codeReaderView animationAction];
    }
    
    if (!self.captureView.hidden) {
        [FIRAnalytics logEventWithName:@"captureViewCaptureSession_startRunning" parameters:nil];
        [self.captureView.captureSession startRunning];
    }
    [self top_switchFlashType];
}

#pragma mark -- 预备一个空文件夹暂存图片
- (void)top_setupImageFile {
    if (self.scameraType != TOPScameraTypeRetake) {
        if (self.fileType != TOPEnterHomeCameraTypeLibrary&&self.fileType !=TOPEnterNextFolderCameraTypeLibrary&&self.fileType != TOPEnterDocumentCameraTypeLibrary) {
            [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
            [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
            if (![TOPWHCFileManager top_isExistsAtPath:TOPAccidentCamerPic_Path]) {
                [TOPWHCFileManager top_createDirectoryAtPath:TOPAccidentCamerPic_Path];
            }
        }
    }else{
        [TOPWHCFileManager top_removeItemAtPath:TOPRetakeCamerPic_Path];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPRetakeCamerPic_Path];
    }
}

#pragma mark -- 新手指导NextStep
- (void)top_hideFilterAndShowCrop{
    [self.filterRemindView removeFromSuperview];
    self.filterRemindView = nil;
    [self.view addSubview:self.autocropView];

}
#pragma mark -- 新手指导最后一步
- (void)top_hideCropShowView{
    [self.autocropView removeFromSuperview];
    self.autocropView = nil;
    [TOPScanerShare top_writeCameraRemindHadShow:YES];
}
#pragma mark -- 渲染模式列表cell的点击事件
- (void)top_filterViewCellAction:(TOPReEditModel *)model{
    [self top_hideCropView];
    self.filterBtn.selected = NO;
    self.showFilterLab.alpha = 1;
    self.showFilterLab.text = model.dic[@"name"];
    CGFloat getWidth = [TOPDocumentHelper top_getSizeWithStr:self.showFilterLab.text Height:45 Font:18].width+45;
    self.showFilterLab.frame = CGRectMake((TOPScreenWidth-getWidth)/2, (TOPScreenHeight-45)/2, getWidth, 45);
    [UIView animateWithDuration:1 animations:^{
        self.showFilterLab.alpha = 0;
    }];
}
#pragma mark -- 网格线
- (void)top_sCamera_lineShow:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self.captureView top_cameraLineShowState:sender.selected];
}
#pragma mark -- 设置图片的默认裁剪状态
- (void)top_sCamera_CutState:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.view addSubview:self.coverView];
        [self.view addSubview:self.cropView];
        [UIView animateWithDuration:0.3 animations:^{
            self.cropView.alpha = 1;
        }];
    }else{
        [self top_hideCropView];
    }
}
#pragma mark -- 默认渲染模式的选择
- (void)top_sCamera_FilterBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.view addSubview:self.coverView];
        [self.view addSubview:self.filterView];
        [UIView animateWithDuration:0.3 animations:^{
            self.filterView.alpha = 1;
        }];
    }else{
        [self top_hideCropView];
    }
}
#pragma mark -- 覆盖层手势事件
- (void)top_tapClick:(UITapGestureRecognizer *)tap{
    [self top_hideCropView];
    self.cutStateBtn.selected = NO;
    self.filterBtn.selected = NO;
    self.flashBtn.selected = NO;
}
#pragma mark -- 隐藏视图
- (void)top_hideCropView{
    [UIView animateWithDuration:0.2 animations:^{
        self.cropView.alpha = 0;
        self.filterView.alpha = 0;
        self.torchView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [self.cropView removeFromSuperview];
        [self.filterView removeFromSuperview];
        [self.torchView removeFromSuperview];
        self.cropView = nil;
        self.filterView = nil;
        self.coverView = nil;
        self.torchView = nil;
    }];
}
#pragma mark - 检查相机权限
- (BOOL)top_canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus ==AVAuthorizationStatusDenied) {
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_camerapermissiontitle", @"")
                                                                       message:NSLocalizedString(@"topscan_camerapermissionguide", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_questionsetting", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            self.captureButton.enabled = NO;
            if (self.scameraType != TOPScameraTypeRetake) {
                [self top_showAccidentView];
            }
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }else{
        return YES;
    }
}

#pragma mark -- 相机相关功能
- (void)top_sCamera_ShutterCamera{
    [FIRAnalytics logEventWithName:@"sCamera_ShutterCamera" parameters:nil];
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    if (freeSize<TOPFreeSize) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
        [SVProgressHUD dismiss];
        return;
    }
    [self.view addSubview:self.blueLine];
    self.captureButton.enabled = NO;
    self.duiBtn.enabled = NO;
    [self top_updateTakeModeUI];
    NSArray *imgs = [TOPDocumentHelper top_sortPicsAtPath:TOPCamerPic_Path];
    if (imgs.count == 1 && self.takeMode == TOPScameraTakeModeSingle) {
        [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
    }
    [self.captureView top_shutterCamera];
}

#pragma mark -- 锁定模式调整UI
- (void)top_updateTakeModeUI {
    self.resetBtn.hidden = NO;
    self.pickerView.hidden = YES;
    self.takeModeTitleLab.hidden = NO;
    self.picBtn.hidden = NO;
    if (self.takeMode == TOPScameraTakeModeSingle) {
//        self.picBtn.hidden = YES;
        self.numberLab.hidden = YES;
    } else {
        [self top_updatePicBtn];
    }
}

- (void)top_sCamera_FlashSwitch:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        [self.view addSubview:self.coverView];
        [self.view addSubview:self.torchView];
        [self.torchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(TOPNavBarAndStatusBarHeight-7);
            make.centerX.equalTo(self.view);
            make.width.mas_equalTo(310);
            make.height.mas_equalTo(75);
        }];
        [UIView animateWithDuration:0.2 animations:^{
            self.torchView.alpha = 1;
        }];
    }else{
        [self top_hideCropView];
    }
}

#pragma mark -- 闪光灯的状态选择
- (void)cameraFlashType:(TOPCameraFlashType)type{
    [TOPScanerShare top_writeCameraFlashType:type];
    [self top_switchFlashType];
    [self.flashBtn setImage:[UIImage imageNamed:[self top_flashDefaultPicName:type]] forState:UIControlStateNormal];
    self.flashBtn.selected = NO;
}
#pragma mark -- 切换二维码扫描时 闪光灯的处理
- (void)top_switchFlashType{
    if (!self.captureView.hidden) {
        [self.codeReaderView toggleTorchClose];
        [self.captureView top_flashSwitch];
    }else{
        [self.codeReaderView toggleTorch];
    }
}
#pragma mark -- 底部左下方按钮
- (void)top_sCamera_ClickPicBtn {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arr = [TOPWHCFileManager top_listFilesInDirectoryAtPath:TOPCamerPic_Path deep:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!arr.count||self.scameraType == TOPScameraTypeRetake) {
                CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
                if (freeSize<TOPFreeSize) {
                    [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
                    return;
                }
                TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.pickImageNum columnNumber:4 delegate:self pushPhotoPickerVc:YES];
                imagePickerVc.isSelectOriginalPhoto = YES;
                imagePickerVc.allowTakePicture = NO;
                imagePickerVc.allowTakeVideo = NO;
                imagePickerVc.allowPickingVideo = NO;
                imagePickerVc.allowPickingImage = YES;
                imagePickerVc.allowPickingOriginalPhoto = NO;
                imagePickerVc.allowPickingGif = NO;
                imagePickerVc.allowPickingMultipleVideo = NO;
                if (self.scameraType == TOPScameraTypeRetake) {
                    imagePickerVc.maxImagesCount = 1;
                }
                imagePickerVc.sortAscendingByModificationDate = YES;
                imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:imagePickerVc animated:YES completion:nil];
            }else{
                WS(weakSelf);
                TOPCameraShowViewController * showPicVC = [TOPCameraShowViewController new];
                showPicVC.top_showBackBlock = ^(NSMutableArray * _Nonnull imageArray) {
                    if (imageArray.count == 0) {
                        [weakSelf.picBtn setImage:[UIImage imageNamed:@"top_tupian"] forState:UIControlStateNormal];
                        weakSelf.picBtn.layer.borderColor = [UIColor clearColor].CGColor;
                        weakSelf.duiBtn.hidden = YES;
                        weakSelf.numberLab.hidden = YES;
                        weakSelf.count = 0;
                        weakSelf.cutStateBtn.hidden = YES;
                        weakSelf.filterBtn.hidden = YES;
                    }else{
                        if (imageArray.count>1) {
                            weakSelf.cutStateBtn.hidden = NO;
                            weakSelf.filterBtn.hidden = NO;
                        }else{
                            weakSelf.cutStateBtn.hidden = YES;
                            weakSelf.filterBtn.hidden = YES;
                        }
                        NSString * picName = imageArray.lastObject;
                        NSString * picPath = [TOPCamerPic_Path stringByAppendingPathComponent:picName];
                        UIImage * picImg = [UIImage imageWithContentsOfFile:picPath];
                        [weakSelf.picBtn setImage:picImg forState:UIControlStateNormal];
                        weakSelf.count = imageArray.count;
                        weakSelf.numberLab.text = [NSString stringWithFormat:@"%ld",(long)weakSelf.count];
                    }
                };
                showPicVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:showPicVC animated:YES];
            }
        });
    });
}
#pragma mark -- 底部右下方按钮
- (void)top_sCamera_ClickDuiBtn{
    [FIRAnalytics logEventWithName:@"sCamera_ClickDuiBtn" parameters:nil];
    NSArray * compareArray = [TOPDocumentHelper top_sortPicsAtPath:TOPCamerPic_Path];
    if (!compareArray.count) {
        [FIRAnalytics logEventWithName:@"sCamera_noJPG" parameters:nil];
        if (![TOPWHCFileManager top_isExistsAtPath:TOPCamerPic_Path]) {
            [FIRAnalytics logEventWithName:@"sCamera_noDirectory" parameters:nil];
        }
        compareArray = [TOPDocumentHelper top_sortItemAthPath:TOPCamerPic_Path];
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_importimgerror", @"")];
        return;
    }
    if (compareArray.count) {
        [FIRAnalytics logEventWithName:@"sCamera_Item" parameters:@{@"content": compareArray[0]}];
        if (compareArray.count < self.count) {
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_somefileloss", @"")];
        }
    }
    if (self.takeMode == TOPScameraTakeModeOCR) {
        [self top_sCamera_RecognizeTextWithSelectPhotos:compareArray];
    } else if (self.takeMode == TOPScameraTakeModeIDCard) {
        [self top_sCamera_CollageWithSelectPhotos:compareArray];
    } else {
        [self top_sCamera_CreateFolderWithSelectPhotos:compareArray];
    }
}

#pragma mark -- 关闭
- (void)top_sCamera_ClickCloseBtn {
    self.tempView.hidden = YES;
    self.captureButton.enabled = YES;
    if (self.takeMode == TOPScameraTakeModeIDCard) {
        self.rectShape.hidden = NO;
        NSInteger count = [TOPScanerShare top_cameraIDCardTipCount];
        count ++;
        [TOPScanerShare top_writeCameraIDCardTipCount:count];
        if (count == 3) {
            [TOPScanerShare top_writeCameraIDCardTip:YES];
        }
    } else {
        NSInteger count = [TOPScanerShare top_cameraOCRTipCount];
        count ++;
        [TOPScanerShare top_writeCameraOCRTipCount:count];
        if (count == 3) {
            [TOPScanerShare top_writeCameraOCRTip:YES];
        }
    }
}

#pragma mark -- 选中
- (void)top_sCamera_ClickCheckBtn {
    if (self.checkBtn.isSelected) {
        self.checkBtn.selected = NO;
        [self.checkBtn setImage:[UIImage imageNamed:@"top_camera_unCheck"] forState:UIControlStateNormal];
        if (self.takeMode == TOPScameraTakeModeOCR) {
            [TOPScanerShare top_writeCameraOCRTip:NO];
        } else {
            [TOPScanerShare top_writeCameraIDCardTip:NO];
        }
    } else {
        self.checkBtn.selected = YES;
        [self.checkBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateNormal];
        if (self.takeMode == TOPScameraTakeModeOCR) {
            [TOPScanerShare top_writeCameraOCRTip:YES];
        } else {
            [TOPScanerShare top_writeCameraIDCardTip:YES];
        }
    }
}

#pragma mark -- 清空照片提示
- (void)top_saveImageAlert {
    WS(weakSelf);
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_clearphotos", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_discard", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf top_setupPickView];
        [weakSelf top_resetPicBtn];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 重置 删除已拍照片
- (void)top_sCamera_ClickResetBtn {
    [self top_saveImageAlert];
}

- (void)top_clearImageFile {
    if (self.scameraType != TOPScameraTypeRetake) {
        [self top_removeSaveFile];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
        [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPAccidentCamerPic_Path];
    }else{
        [TOPWHCFileManager top_removeItemAtPath:TOPRetakeCamerPic_Path];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPRetakeCamerPic_Path];
    }
}

- (void)top_resetPicBtn {
    [self top_clearImageFile];
    self.count = 0;
    self.duiBtn.hidden = YES;
    self.filterBtn.hidden = YES;
    self.cutStateBtn.hidden = YES;
    
    self.picBtn.hidden = NO;
    self.picBtn.frame = CGRectMake(20, 0, 60, 60);
    self.picBtn.centerY = self.captureButton.centerY;
    [self.picBtn setImage:[UIImage imageNamed:@"top_tupian"] forState:UIControlStateNormal];
    self.picBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [self top_getNumberLabState];
    self.numberLab.hidden = YES;
    
    self.resetBtn.hidden = YES;
    self.captureButton.enabled = YES;
    self.arrowView.hidden = YES;
    
    self.pickerView.hidden = NO;
    self.takeModeTitleLab.hidden = YES;
}

- (void)top_updatePicBtn {
    self.picBtn.hidden = NO;
    self.picBtn.frame = CGRectMake(CGRectGetMaxX(self.captureButton.frame) + 50, 10, 39, 39);
    [self top_getNumberLabState];
    self.arrowView.hidden = NO;
    self.arrowView.frame = CGRectMake(CGRectGetMaxX(self.picBtn.frame) + 5, 0, 12, 12);
    self.arrowView.centerY = self.picBtn.centerY;
}

- (void)top_getNumberLabState{
    CGFloat numLabW = [TOPDocumentHelper top_getSizeWithStr:[NSString stringWithFormat:@"%ld",(long)_count] Height:15 Font:10].width+5;
    if (numLabW<15.0) {
        numLabW = 15.0;
    }
    self.numberLab.text = [NSString stringWithFormat:@"%ld",(long)_count];
        self.numberLab.frame = CGRectMake(CGRectGetMaxX(self.picBtn.frame)-numLabW/2, CGRectGetMinY(self.picBtn.frame)-15/2, numLabW, 15);
    self.numberLab.layer.cornerRadius = 15/2;
    self.numberLab.font = [UIFont systemFontOfSize:10];
}
#pragma mark -- Cancel
- (void)top_clickCancleBtn{
    if (self.scameraType == TOPScameraTypeRetake) {
        [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSArray * array = [TOPDocumentHelper top_sortPicsAtPath:TOPCamerPic_Path];
        if (array.count>0) {
            WS(weakSelf);
            TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_cameradiscardtitle", @"")
                                                                           message:NSLocalizedString(@"topscan_cameradiscardmssage", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [weakSelf top_removeSaveFile];
                [weakSelf isDismiss];
            }];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
            }];
            
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [self top_removeSaveFile];
            [self isDismiss];
        }
    }
}

- (void)top_removeSaveFile{
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchDefaultDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchAdjustDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchCropDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchCropDefaultDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchProcessIcon_Path];
    
    [[TOPScameraBatchSave save].images removeAllObjects]; 
    [[TOPScameraBatchSave save].saveShowDic removeAllObjects];
}
- (void)isDismiss{
    if (self.navigationController.viewControllers.count>1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)top_showAccidentView{
    NSArray * accidentArray = [TOPDocumentHelper top_sortPicsAtPath:TOPAccidentCamerPic_Path];
    if (accidentArray.count>0) {
        WS(weakSelf);
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_cameraaccidenttitle", @"")
                                                                       message:NSLocalizedString(@"topscan_cameraaccidentmssage", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_yes", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [weakSelf top_saveAccidentPic];
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_no", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -- 将保存本地路径TOPAccidentCamerPic_Path下的数据写入
- (void)top_saveAccidentPic{
    WS(weakSelf);
    NSArray * accidentArray = [TOPDocumentHelper top_sortPicsAtPath:TOPAccidentCamerPic_Path];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(1/%@)",NSLocalizedString(@"topscan_processing", @""),@(accidentArray.count)]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<accidentArray.count; i++) {
            @autoreleasepool {
                NSString * picName = accidentArray[i];
                NSString * picPath = [TOPAccidentCamerPic_Path stringByAppendingPathComponent:picName];
                UIImage * image = [UIImage imageWithContentsOfFile:picPath];
                if (weakSelf.count == 0) {
                    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
                    [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
                }
                NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:weakSelf.count],TOP_TRJPGPathSuffixString];
                NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
                BOOL result = [TOPDocumentHelper top_saveImage:image atPath:fileEndPath];
                if (result) {
                    weakSelf.count++;
                }
                CGFloat stateF = ((i+1) * 10.0)/(accidentArray.count * 10.0);
                [[TOPProgressStripeView shareInstance] top_showProgress:stateF withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(i +1),@(accidentArray.count)]];
                if (i == accidentArray.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[TOPProgressStripeView shareInstance] dismiss];
                        [weakSelf top_setTakeModeBatch];
                        [weakSelf top_getChildViewState:image];
                    });
                }
            }
        }
    });
}

#pragma mark -- 设定为多拍模式
- (void)top_setTakeModeBatch {
    self.takeMode = TOPScameraTakeModeBatch;
    self.takeNum = PhotoNumMax;
    self.pickImageNum = PhotoNumMax;
    self.takeModeTitleLab.text = NSLocalizedString(@"topscan_cameratypebatch", @"");
    [self top_updateTakeModeUI];
}

#pragma mark -- TOPCaptureViewDelegate
- (void)top_captureAuthorizationFail
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 拍照完成之后的图片数据返回
- (void)top_shutterCameraWithImage:(UIImage *)image{
    [self top_startAnimation:image];
}
#pragma mark -- 拍完照之后的动画
- (void)top_startAnimation:(UIImage *)image{
    [self.blueLine removeFromSuperview];
    self.blueLine = nil;
    
    [self.view addSubview:self.animateImg];
    self.animateImg.image = image;
   
    [UIView animateWithDuration: 0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:0 animations:^{
        [self.animateImg setTransform:CGAffineTransformMakeRotation(M_PI*2)];
        self.animateImg.frame= CGRectMake(CGRectGetMaxX(self.captureButton.frame) + 50, 10 + CGRectGetMinY(self.toolsView.frame), 39, 39);
        self.picBtn.layer.borderColor = kTopicBlueColor.CGColor;
        [self top_animationFinish:image];
    } completion:^(BOOL finished) {
        [self.animateImg removeFromSuperview];
        self.animateImg = nil;
    }];
}
#pragma mark -- 动画之后的数据处理
- (void)top_animationFinish:(UIImage *)image{
    if (self.scameraType == TOPScameraTypeRetake) {//没有数据模型时的重拍 即是拍多张图片批量处理界面的重拍功能
        [self top_saveRetakeImage:image];
    }else{
        NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:_count],TOP_TRJPGPathSuffixString];
        NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
        NSString *accidentFileEndPath = [TOPAccidentCamerPic_Path stringByAppendingPathComponent:fileName];
        [TOPDocumentHelper top_saveImage:image atPath:accidentFileEndPath];
        BOOL result = [TOPDocumentHelper top_saveImage:image atPath:fileEndPath];
        
        if (result) {
            _count++;
        }
        [self top_getChildViewState:image];
    }
}
#pragma mark -- 确定控件的状态
- (void)top_getChildViewState:(UIImage *)image{
    if (_count>1) {
        self.cutStateBtn.hidden = NO;
        self.filterBtn.hidden = NO;
        self.numberLab.hidden = NO;
        if (![TOPScanerShare top_cameraRemindHadShow]) {
            [self.view addSubview:self.filterRemindView];
            [UIView animateWithDuration:0.2 animations:^{
                self.filterRemindView.alpha = 1;
            }];
        }
    }
    [self top_getNumberLabState];
    [self.picBtn setImage:image forState:UIControlStateNormal];
    self.duiBtn.hidden = NO;
    self.duiBtn.enabled = YES;
    if (_count >= self.takeNum) {
        [self top_sCamera_ClickDuiBtn];
        if (_count == 1) {
            self.captureButton.enabled = YES;
            _count = 0;
        } else {
            self.captureButton.enabled = NO;
        }
    } else {
        self.captureButton.enabled = YES;
    }
}

- (void)top_cameraTypeLibraryState{
    NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
    if (picArray.count>0) {
        NSString * picName = picArray.lastObject;
        NSString * picPath = [TOPCamerPic_Path stringByAppendingPathComponent:picName];
        UIImage * picImg = [UIImage imageWithContentsOfFile:picPath];
        _count = picArray.count;
        [self top_updateTakeModeUI];
        [self.picBtn setImage:picImg forState:UIControlStateNormal];
        self.takeModeTitleLab.text = NSLocalizedString(@"topscan_cameratypebatch", @"");
        self.numberLab.hidden = NO;
        self.numberLab.text = [NSString stringWithFormat:@"%ld",_count];
        self.duiBtn.hidden = NO;
    }
}
#pragma mark -- 图片批量处理界面重拍时的数据处理
- (void)top_saveRetakeImage:(UIImage *)image{
    NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:self.imageName];//原图
    NSString *accidentFileEndPath =  [TOPAccidentCamerPic_Path stringByAppendingPathComponent:self.imageName];
    NSString *cropDefaultPath =  [TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:self.imageName];
    NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:self.imageName];
    
    [TOPWHCFileManager top_removeItemAtPath:fileEndPath];
    [TOPWHCFileManager top_removeItemAtPath:accidentFileEndPath];
    [TOPWHCFileManager top_removeItemAtPath:filterPicPath];
    [TOPWHCFileManager top_removeItemAtPath:cropDefaultPath];
    
    [TOPDocumentHelper top_saveImage:image atPath:fileEndPath];
    [TOPDocumentHelper top_saveImage:image atPath:accidentFileEndPath];
    [TOPDocumentHelper top_saveImage:image atPath:cropDefaultPath];
    if (self.top_dismissAndReloadData) {
        self.top_dismissAndReloadData();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    if (self.takeMode == TOPScameraTakeModeSingle && assets.count > 1) {
        self.takeMode = TOPScameraTakeModeBatch;
        NSInteger seIndex = [[self takeModeArray] indexOfObject:@(self.takeMode)];
        self.showModeToast = NO;
        [self.pickerView selectItem:seIndex animated:NO];
        self.showModeToast = YES;
    }
    [self top_saveAssetsRefreshUI:assets];
}

- (void)top_saveAssetsRefreshUI:(NSArray *)assets {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    __weak typeof(self) weakSelf = self;
    [self top_handleLibiaryPhoto:assets completion:^(NSArray *imagePaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imagePaths.count) {
                NSString * picPath = [TOPCamerPic_Path stringByAppendingPathComponent:imagePaths[0]];
                UIImage * picImg = [UIImage imageWithContentsOfFile:picPath];
                [weakSelf.picBtn setImage:picImg forState:UIControlStateNormal];
                weakSelf.count = imagePaths.count;
                weakSelf.numberLab.hidden = NO;
                weakSelf.numberLab.text = [NSString stringWithFormat:@"%ld",(long)weakSelf.count];
                weakSelf.duiBtn.hidden = NO;
            }
            [SVProgressHUD dismiss];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"clearPhotoKey"];
            [weakSelf top_sCamera_ClickDuiBtn];
        });
    }];
}

#pragma mark -- 处理相册图片 -- 大图压缩控制在1200w像素内，保存，返回图片路径
- (void)top_handleLibiaryPhoto:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion {
    WS(weakSelf);
    dispatch_queue_t queueE = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t groupE = dispatch_group_create();
    dispatch_queue_t serialQue= dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    for (int i = 0; i < assets.count; i ++) {
        dispatch_async(serialQue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_group_async(groupE, queueE, ^{
                dispatch_group_enter(groupE);
                [[TZImageManager manager] getOriginalPhotoDataWithAsset:assets[i] completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if ([info[@"PHImageResultIsDegradedKey"] boolValue] == NO) {
                            CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
                            if (freeSize<50) {
                                CGFloat imgSize;
                                if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveNO) {
                                    imgSize = data.length/1024/1024+4;
                                }else{
                                    imgSize = (data.length/1024/1024)*2+4;
                                }
                                if (freeSize<imgSize) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
                                    });
                                }else{
                                    [weakSelf top_savePicData:data index:i];
                                }
                            }else{
                                [weakSelf top_savePicData:data index:i];
                            }
                        }
                        dispatch_semaphore_signal(semaphore);
                        dispatch_group_leave(groupE);
                    });
                }];
            });
            if (i == assets.count - 1) {
                dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
                    NSArray * array = [NSArray array];
                    if (self.scameraType == TOPScameraTypeRetake) {
                        array = [TOPDocumentHelper top_sortPicsAtPath:TOPRetakeCamerPic_Path];
                    }else{
                        array = [TOPDocumentHelper top_sortPicsAtPath:TOPCamerPic_Path];
                    }
                    if (array.count) {
                        if (completion) completion(array);
                    } else {
                        [FIRAnalytics logEventWithName:@"SCameraView_noJPG" parameters:nil];
                        NSArray * items = [NSArray array];
                        if (self.scameraType == TOPScameraTypeRetake) {
                            items = [TOPDocumentHelper top_sortPicsAtPath:TOPRetakeCamerPic_Path];
                        }else{
                            items = [TOPDocumentHelper top_sortPicsAtPath:TOPCamerPic_Path];
                        }
                        if (items.count) {
                            [FIRAnalytics logEventWithName:@"SCameraView_Item" parameters:@{@"content": items[0]}];
                            if (completion) completion(items);
                        } else {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_savefail", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                        }
                    }
                });
            }
        });
    }
}

- (void)top_savePicData:(NSData *)data index:(NSInteger)i{
    if (data) {
        NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
        NSString * fileEndPath = [NSString new];
        if (self.scameraType == TOPScameraTypeRetake) {
            fileEndPath = [TOPRetakeCamerPic_Path stringByAppendingPathComponent:fileName];
        }else{
            fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
            NSString *accidentFileEndPath = [TOPAccidentCamerPic_Path stringByAppendingPathComponent:fileName];
            [data writeToFile:accidentFileEndPath atomically:YES];
        }
        BOOL result = [data writeToFile:fileEndPath atomically:YES];
        if (!result) {
            if (fileEndPath == nil) {
                fileEndPath = @"";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [FIRAnalytics logEventWithName:@"SCameraView_pathError" parameters:@{@"path": fileEndPath}];
                [FIRAnalytics logEventWithName:@"SCameraView_contentError" parameters:@{@"content": @(data.length)}];
            });
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [FIRAnalytics logEventWithName:@"SCameraView_dataError" parameters:nil];
        });
    }
}
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self top_switchFlashType];
}

- (void)top_sCamera_OnlyToSendData:(NSArray *)assets{
    TOPCamerBatchViewController * scamerBatch = [TOPCamerBatchViewController new];
    scamerBatch.pathString = self.pathString;
    scamerBatch.fileType = self.fileType;
    scamerBatch.backType = self.backType;
    scamerBatch.dataArray = self.dataArray;
    scamerBatch.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scamerBatch animated:YES];
}
#pragma mark -- 处理高清图片保存到本地
- (NSString *)top_saveOriginalPic:(NSString *)fileName atFilePath:(NSString*)path {
    NSString *imgPath = [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:imgPath];
    if (self.fileType == TOPShowDocumentCameraType||self.fileType == TOPEnterDocumentCameraTypeLibrary) {
        fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:([TOPDocumentHelper top_maxImageNumIndexAtPath:path])],TOP_TRJPGPathSuffixString];
    }
    NSString *fileEndPath =  [path stringByAppendingPathComponent:fileName];
    UIImage *resizeImg = [TOPPictureProcessTool top_fetchOriginalImageWithData:data];
    [TOPDocumentHelper top_saveImage:resizeImg atPath:fileEndPath];
    NSString *soureFileEndPath = [TOPDocumentHelper top_originalImage:fileEndPath];
    [TOPDocumentHelper top_saveImage:resizeImg atPath:soureFileEndPath];
    return fileName;
}

- (NSString *)top_newDocPath {
    NSString *docFile = self.pathString;
    if (self.fileType == TOPShowDocumentCameraType||self.fileType == TOPEnterDocumentCameraTypeLibrary) {
        docFile = self.pathString;
    } else if (self.fileType == TOPShowFolderCameraType||self.fileType == TOPShowToTextCameraType||self.fileType == TOPShowIDCardCameraType||self.fileType == TOPEnterHomeCameraTypeLibrary) {
        docFile = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    } else if (self.fileType == TOPShowNextFolderCameraType||self.fileType == TOPEnterNextFolderCameraTypeLibrary) {
        docFile = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:self.pathString];
    }
    return docFile;
}

#pragma mark -- 跳转去ocr
- (void)top_sCamera_RecognizeTextWithSelectPhotos:(NSArray *)photos {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *docFile = [self top_newDocPath];
        NSMutableArray *temp = @[].mutableCopy;
        NSMutableArray *newImgs = @[].mutableCopy;
        for (NSString *imgName in photos) {
            NSString *fileName = [self top_saveOriginalPic:imgName atFilePath:docFile];
            [newImgs addObject:fileName];
            DocumentModel *model = [TOPDataModelHandler top_buildImageModelWithName:fileName atPath:docFile];
            [temp addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            TOPPhotoShowOCRVC *showOCR = [[TOPPhotoShowOCRVC alloc] init];
            showOCR.docModel = [TOPFileDataManager shareInstance].docModel;
            showOCR.dataArray = temp;
            showOCR.imagePathArray = newImgs;
            showOCR.filePath = docFile;
            showOCR.finishType = TOPPhotoShowOCRVCAgainFinishNot;
            showOCR.backType = TOPPhotoShowTextAgainVCBackTypeDismiss;
            showOCR.enterType = TOPEnterShowOCRVCTypeCamera;
            showOCR.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:showOCR animated:YES];
        });
    });
}

#pragma mark -- 批量裁剪IDcard 图片
- (void)top_batchCropImage:(NSArray *)photos atFilePath:(NSString *)docFile {
    [self.cameraArray removeAllObjects];
    NSInteger processType = [TOPScanerShare top_defaultProcessType];
    for (NSString *imgName in photos) {
        NSString *imgPath = [docFile stringByAppendingPathComponent:imgName];
        UIImage *originalImg = [UIImage imageWithContentsOfFile:imgPath];
        if (originalImg.size.width > 0) {
            NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
            UIImage * cropImg =  [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(TOPScreenWidth-30, self.picH)];
            CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:cropImg fatherW:TOPScreenWidth-30 fatherH:self.picH];
            TOPCameraBatchModel *batchModel = [[TOPCameraBatchModel alloc] init];
            batchModel.PicName = imgName;
            batchModel.imgPath = imgPath;
            batchModel.originalImgPath = [TOPDocumentHelper top_originalImage:imgPath];
            UIImage * dealOriginImage = [UIImage new];
            NSMutableArray * pointArray = [[TOPOpenCVWrapper top_getLargestSquarePoints:cropImg :imgRect.size :YES] mutableCopy];
            [self top_setBatchPointWithModel:batchModel AndDefaultPointArray:pointArray AndBatchRect:imgRect];
            batchModel.cropImgViewRect = imgRect;
            batchModel.endPoinArray = batchModel.autoEndPoinArray;
            batchModel.isFinishCrop = YES;
            [self.cameraArray addObject:batchModel];
            if (!pointArray.count) {
                dealOriginImage = originalImg;
            }else{
                TOPSaveElementModel * model = [TOPDataModelHandler top_getBatchSavePointData:pointArray img:originalImg imgRect:imgRect];
                dealOriginImage = [TOPOpenCVWrapper top_getTransformedObjectImage:model.saveW :model.saveH :model.originalImage :model.pointArray :model.originalImage.size];
            }
            NSString *backupPic = [TOPDocumentHelper top_backupImage:imgPath];
            if (![TOPWHCFileManager top_isExistsAtPath:backupPic]) {
                [TOPDocumentHelper top_saveImage:dealOriginImage atPath:backupPic];
            }
            GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:dealOriginImage];
            UIImage *filterImage = [TOPDataTool top_pictureProcessData:imageSource withImg:dealOriginImage withItem:processType];
            [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
            [TOPDocumentHelper top_saveImage:filterImage atPath:imgPath];
        }
    }
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

#pragma mark -- 跳转去collage
- (void)top_sCamera_CollageWithSelectPhotos:(NSArray *)photos {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *docFile = [self top_newDocPath];
        NSMutableArray *temp = @[].mutableCopy;
        for (NSString *imgName in photos) {
            NSString *fileName = [self top_saveOriginalPic:imgName atFilePath:docFile];
            [temp addObject:fileName];
        }
        [self top_batchCropImage:temp atFilePath:docFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            TOPIDCardCollageViewController *collageVC = [[TOPIDCardCollageViewController alloc] init];
            collageVC.docModel = [TOPFileDataManager shareInstance].docModel;
            collageVC.imagePathArr = temp;
            collageVC.filePath = docFile;
            collageVC.cameraArray = self.cameraArray;
            collageVC.enterCameraType = self.fileType;
            collageVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:collageVC animated:YES];
        });
    });
}

#pragma mark -- 跳转去裁剪界面
- (void)top_sCamera_CreateFolderWithSelectPhotos:(NSArray *)photos{
    if (self.scameraType == TOPScameraTypeRetake) {
        NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPRetakeCamerPic_Path];
        NSString * picName = picArray.lastObject;
        NSString * picPath = [TOPRetakeCamerPic_Path stringByAppendingPathComponent:picName];
        UIImage * picImg = [UIImage imageWithContentsOfFile:picPath];
        [self top_saveRetakeImage:picImg];
    } else {
        if (photos.count>1) {
            WS(weakSelf);
            TOPCamerBatchViewController * scamerBatch = [TOPCamerBatchViewController new];
            scamerBatch.pathString = self.pathString;
            scamerBatch.fileType = self.fileType;
            scamerBatch.backType = self.backType;
            scamerBatch.dataArray = self.dataArray;
            scamerBatch.currentIndex = 0;
            scamerBatch.top_backAndReloadData = ^{
                [weakSelf top_scamerBatchBackAction];
            };
            scamerBatch.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:scamerBatch animated:YES];
        }else{
            TOPSingleBatchViewController * batch = [TOPSingleBatchViewController new];
            batch.pathString = self.pathString;
            batch.dataArray = self.dataArray;
            batch.batchArray = [photos mutableCopy];
            batch.fileType = self.fileType;
            batch.backType = self.backType;
            batch.model = self.sendModel;
            batch.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:batch animated:YES];
        }
    }
}

- (void)top_scamerBatchBackAction{
    NSArray * picArray = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
    if (picArray.count == 0) {
        [self top_resetPicBtn];
    }else{
        self.duiBtn.hidden = NO;
        self.numberLab.hidden = NO;
        if (picArray.count>1) {
            self.cutStateBtn.hidden = NO;
            self.filterBtn.hidden = NO;
        }else{
            self.cutStateBtn.hidden = YES;
            self.filterBtn.hidden = YES;
        }
        NSString * picName = picArray.lastObject;
        NSString * picPath = [TOPCamerPic_Path stringByAppendingPathComponent:picName];
        UIImage * picImg = [UIImage imageWithContentsOfFile:picPath];
        [self.picBtn setImage:picImg forState:UIControlStateNormal];
        self.count = picArray.count;
        self.numberLab.text = [NSString stringWithFormat:@"%ld",(long)self.count];
    }
    [self top_switchFlashType];
    TOPCameraFlashType type = [TOPScanerShare top_cameraFlashType];
    [self.flashBtn setImage:[UIImage imageNamed:[self top_flashDefaultPicName:type]] forState:UIControlStateNormal];
}

#pragma mark - BEzPickerViewDataSource
- (NSUInteger)numberOfItemsInPickerView:(BEzPicker *)pickerView {
    return [self.titles count];
}

- (NSString *)pickerView:(BEzPicker *)pickerView titleForItem:(NSInteger)item {
    return self.titles[item];
}

#pragma mark - BEzPickerDelegate
- (void)pickerView:(BEzPicker *)pickerView didSelectItem:(NSInteger)item {
    [self top_didSelectTakeModel:item];
    if (self.showModeToast) {
        [[TOPCornerToast shareInstance] makeToast:self.titles[item]];
    }
}

- (void)top_didSelectTakeModel:(NSInteger)item {
    NSNumber *mode = [self takeModeArray][item];
    self.takeMode = [mode integerValue];
    [self top_setupTakeNum];
    self.takeModeTitleLab.text = self.titles[item];
    NSArray *arr = [TOPWHCFileManager top_listFilesInDirectoryAtPath:TOPCamerPic_Path deep:NO];
    if (arr.count > 0) {
        [self top_resetPicBtn];
    }
    if (!self.pickImageNum) {
        self.picBtn.hidden = YES;
        self.numberLab.hidden = YES;
    }
}

#pragma mark -- 底部选择拍照模式的滑动试图
- (void)top_setupPickView {
    if (!_pickerView) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.titles = @[NSLocalizedString(@"topscan_cameratypetotext", @""),
                            NSLocalizedString(@"topscan_collageidcard", @""),
                            NSLocalizedString(@"topscan_cameratypesingle", @""),
                            NSLocalizedString(@"topscan_cameratypebatch", @""),
                            NSLocalizedString(@"topscan_cameratypeqrbarcode", @"")];
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect frame = CGRectMake(10, 10, TOPScreenWidth - 20, kPickViewItemH);
                self.pickerView = [[BEzPicker alloc] initWithFrame:frame];
                self.pickerView.delegate = self;
                self.pickerView.dataSource = self;
                self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                self.pickerView.font = PingFang_L_FONT_(15);
                self.pickerView.highlightedFont = PingFang_M_FONT_(15);
                self.pickerView.backgroundColor = [UIColor clearColor];
                self.pickerView.interitemSpacing = 20.0;
                self.pickerView.fisheyeFactor = 0.00001;
                self.pickerView.pickerViewStyle = BEzPickerViewStyleFlat;
                self.pickerView.maskDisabled = NO;
                
                [self.pickerView reloadData];
                NSInteger seIndex = [self top_setupTakeNum];
                [self.pickerView selectItem:seIndex animated:NO];
                
                if (self.modeUnable) {
                    self.pickerView.hidden = YES;
                    self.takeModeTitleLab.text = self.takeModeString;
                    self.takeModeTitleLab.hidden = NO;
                }
            });
        });
    }
}

- (NSInteger)top_setupTakeNum {
    NSInteger seIndex = [[self takeModeArray] indexOfObject:@(self.takeMode)];
    self.idCardTipLab.hidden = YES;
    self.idCardTitleLab.hidden = YES;
    self.rectShape.hidden = YES;
    if (self.takeMode != TOPScameraTakeModeCodeReader) {
        [self top_codeReaderViewHideState];
        [self top_codeReaderResultViewHide];
    }
    switch (self.takeMode) {
        case TOPScameraTakeModeOCR:
            self.takeNum = PhotoNumMax;
            self.captureButton.enabled = [TOPScanerShare top_cameraOCRTip];
            self.tempView.hidden = [TOPScanerShare top_cameraOCRTip];
            self.tempImageView.image = [UIImage imageNamed:@"camera_toText"];
            break;
        case TOPScameraTakeModeIDCard:
            self.takeNum = 2;
            self.captureButton.enabled = [TOPScanerShare top_cameraIDCardTip];
            self.tempView.hidden = [TOPScanerShare top_cameraIDCardTip];
            self.tempImageView.image = [UIImage imageNamed:@"camera_idCard"];
            self.idCardTipLab.hidden = NO;
            self.idCardTitleLab.hidden = NO;
            self.rectShape.hidden = !self.tempView.hidden;
            break;
        case TOPScameraTakeModeSingle:
            self.takeNum = 1;
            self.captureButton.enabled = YES;
            self.tempView.hidden = YES;
            [TOPScanerShare top_writeCameraTakeMode:TOPScameraTakeModeSingle];
            break;
        case TOPScameraTakeModeBatch:
        {
            self.takeNum = PhotoNumMax;
            self.captureButton.enabled = YES;
            self.tempView.hidden = YES;
            [TOPScanerShare top_writeCameraTakeMode:TOPScameraTakeModeBatch];
        }
            break;
        case TOPScameraTakeModeCodeReader:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self top_codeReaderViewShowState];
                [self.codeReaderView animationAction];
                if (self.codeResultString.length) {
                    [self top_codeReaderResultViewShow];
                }
            });
        }
            break;
        default:
            break;
    }
    if (_checkBtn) {
        self.checkBtn.selected = NO;
        [self.checkBtn setImage:[UIImage imageNamed:@"top_camera_unCheck"] forState:UIControlStateNormal];
    }
    if (self.pickImageNum > 1) {
        self.pickImageNum = self.takeMode == TOPScameraTakeModeSingle ? PhotoNumMax : self.takeNum;
    }
    return seIndex;
}

#pragma mark -- 二维码扫描界面的展示与隐藏
- (void)top_codeReaderViewShowState{
    self.captureView.hidden = YES;
    [self.captureView.captureSession stopRunning];
    
    self.captureButton.hidden = YES;
    self.picBtn.hidden = YES;
    self.lineBtn.hidden = YES;
    self.numberLab.hidden = YES;
    self.cutStateBtn.hidden = YES;
    self.filterBtn.hidden = YES;
    
    [self.view addSubview:self.codeReaderView];
    self.codeReaderView.hidden = NO;
    [self.codeReaderView startRun];
    [self top_switchFlashType];
}

- (void)top_codeReaderViewHideState{
    self.captureView.hidden = NO;
    [self.captureView.captureSession startRunning];
         
    self.captureButton.hidden = NO;
    self.picBtn.hidden = NO;
    self.lineBtn.hidden = NO;
    
    [self.codeReaderView removeFromSuperview];
    self.codeReaderView = nil;
    [self top_switchFlashType];
}

#pragma mark -- 二维码结果展示界面的展示与隐藏
- (void)top_codeReaderResultViewHide{
    [self.codeResultView removeFromSuperview];
    self.codeResultView = nil;
}

- (void)top_codeReaderResultViewShow{
    [self.view addSubview:self.codeResultView];
    self.codeResultView.resultString = self.codeResultString;
    [self top_codeReaderAgainShowViewState];
}
#pragma mark -- 二维码 条形码结果处理
- (void)top_codeResultAction:(NSInteger)index{
    NSInteger item = [[self codeResultTypeArray][index] integerValue];
    switch (item) {
        case TOPCameraCodeResultActionTypeShare:
            [self top_cameraCodeResultActionTypeOfShare];
            break;
        case TOPCameraCodeResultActionTypeCopy:
            [self top_cameraCodeResultActionTypeOfCopy];
            break;
        case TOPCameraCodeResultActionTypeDelete:
            [self top_codeReaderResultViewHide];
            break;
        case TOPCameraCodeResultActionTypeOpenURL:
            [self top_cameraCodeResultActionTypeOfOpenURL];
            break;
        default:
            break;
    }
}
#pragma mark --二维码 条形码链接视图完全展开
- (void)top_cameraCodeResultActionTypeOfShow:(BOOL)isSelect{
    _CodeResultShow = isSelect;
    CGFloat changeH = 0;
    if (isSelect) {
        CGFloat yy = KCodeResultViewH-14;
        CGFloat getH = [TOPDocumentHelper top_getSizeWithStr:self.codeResultString Width:(TOPScreenWidth-20-10)*2 Font:13].height;
        changeH = yy + getH+10;
    }else{
        changeH = KCodeResultViewH;
    }
    self.codeResultView.frame = CGRectMake(20, TOPNavBarAndStatusBarHeight+10, TOPScreenWidth-40, changeH);
    [self.codeResultView top_setupUI];
    self.codeResultView.resultString = self.codeResultString;
}
#pragma mark -- 再次二维码扫描时 弹出视图
- (void)top_codeReaderAgainShowViewState{
    if (_CodeResultShow) {
        CGFloat changeH = 0;
        CGFloat getH = [TOPDocumentHelper top_getSizeWithStr:self.codeResultString Height:14 Font:13].width;
        if (getH>(TOPScreenWidth-30)*2) {
            CGFloat yy = KCodeResultViewH-14;
            CGFloat getH = [TOPDocumentHelper top_getSizeWithStr:self.codeResultString Width:(TOPScreenWidth-20-10)*2 Font:13].height;
            changeH = yy + getH+10;
        }else{
            changeH = KCodeResultViewH;
        }
        self.codeResultView.frame = CGRectMake(20, TOPNavBarAndStatusBarHeight+10, TOPScreenWidth-40, changeH);
        [self.codeResultView top_setupUI];
        self.codeResultView.resultString = self.codeResultString;
    }
}
#pragma mark --二维码 条形码链接的分享
- (void)top_cameraCodeResultActionTypeOfShare{
    [FIRAnalytics logEventWithName:@"cameraCodeResultActionTypeOfShare" parameters:nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.codeResultString] applicationActivities:nil];
    if (IS_IPAD) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark --二维码 条形码链接的复制
- (void)top_cameraCodeResultActionTypeOfCopy{
    [FIRAnalytics logEventWithName:@"cameraCodeResultActionTypeOfCopy" parameters:nil];
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.codeResultString;
    if ([TOPDocumentHelper top_achiveStringWithWeb:self.codeResultString]) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_copysuccessful", @"") duration:1.0];
        
    }else{
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_copysuccessful", @"") duration:1.0];
    }
}
#pragma mark -- 跳转到二维码 条形码链接
- (void)top_cameraCodeResultActionTypeOfOpenURL{
    [FIRAnalytics logEventWithName:@"cameraCodeResultActionTypeOfOpenURL" parameters:nil];
    NSURL * url = [NSURL URLWithString:self.codeResultString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}


#pragma mark -- UI 相关
- (void)top_customUI{
    self.view.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:self.codeReaderView];
    [self.view addSubview:self.captureView];
    [self.captureView addSubview:self.tempView];
    [self top_setupTempView];
    [self.view addSubview:self.topView];
    
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButton.frame = CGRectMake(TOPScreenWidth-60, TOPStatusBarHeight, 44, 44);
    TOPCameraFlashType type = [TOPScanerShare top_cameraFlashType];
    [flashButton setImage:[UIImage imageNamed:[self top_flashDefaultPicName:type]] forState:UIControlStateNormal];
    [flashButton addTarget:self action:@selector(top_sCamera_FlashSwitch:) forControlEvents:UIControlEventTouchUpInside];
    self.flashBtn = flashButton;
    
    CGFloat rightW;
    if ([self.captureView.captureDevice hasFlash]&&[self.captureView.captureDevice hasTorch]) {
        rightW = 15+44;
        flashButton.hidden = NO;
    }else{
        rightW = 5;
        flashButton.hidden = YES;
    }

    UIButton * lineBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-rightW-44, TOPStatusBarHeight, 44, 44)];
    [lineBtn setImage:[UIImage imageNamed:@"top_griddefault"] forState:UIControlStateNormal];
    [lineBtn setImage:[UIImage imageNamed:@"top_gridshow"] forState:UIControlStateSelected];
    [lineBtn addTarget:self action:@selector(top_sCamera_lineShow:) forControlEvents:UIControlEventTouchUpInside];
    self.lineBtn = lineBtn;
    
    UIButton * cutStateBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-rightW-44*2, TOPStatusBarHeight, 44, 44)];
    [cutStateBtn setImage:[UIImage imageNamed:@"top_cutImgState"] forState:UIControlStateNormal];
    [cutStateBtn addTarget:self action:@selector(top_sCamera_CutState:) forControlEvents:UIControlEventTouchUpInside];
    cutStateBtn.hidden = YES;
    self.cutStateBtn = cutStateBtn;
    
    UIButton * filterBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-rightW-44*3, TOPStatusBarHeight, 44, 44)];
    [filterBtn setImage:[UIImage imageNamed:@"top_camerafilter"] forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(top_sCamera_FilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    filterBtn.hidden = YES;
    self.filterBtn = filterBtn;
    
    UIButton * cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, TOPStatusBarHeight, 80, 44)];
    cancleBtn.backgroundColor = [UIColor clearColor];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancleBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(top_clickCancleBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * showFilterLab = [[UILabel alloc]initWithFrame:CGRectMake(0, (TOPScreenHeight-45)/2, TOPScreenWidth, 45)];
    showFilterLab.backgroundColor = RGBA(81, 81, 81, 0.7);
    showFilterLab.font = [UIFont boldSystemFontOfSize:19];
    showFilterLab.textAlignment = NSTextAlignmentCenter;
    showFilterLab.textColor = RGBA(245, 245, 245, 1.0);
    showFilterLab.layer.masksToBounds = YES;
    showFilterLab.layer.cornerRadius = 45/2;
    showFilterLab.alpha = 0;
    self.showFilterLab = showFilterLab;
    
    [self.topView addSubview:flashButton];
    [self.topView addSubview:lineBtn];
    [self.topView addSubview:cutStateBtn];
    [self.topView addSubview:filterBtn];
    [self.topView addSubview:cancleBtn];
    
    [self top_cameraToolsBottomView];
    [self.captureView top_cameraLineShowState:lineBtn.selected];
    [self.view addSubview:showFilterLab];
     
}

- (NSString *)top_flashDefaultPicName:(TOPCameraFlashType)type{
    NSString *imageName = [NSString new];
    if (type == TOPCameraFlashTypeAuto) {
        imageName = @"top_flashAutoDefault";
    }else if (type == TOPCameraFlashTypeOn){
        imageName = @"top_flashOnDefault";
    }else if (type == TOPCameraFlashTypeOff){
        imageName = @"top_flashOffDefault";
    }else{
        imageName = @"top_torchOnDefault";
    }
    return imageName;
}
- (void)top_setupTempView {
    [self.tempView addSubview:self.closeBtn];
    [self.tempView addSubview:self.tempImageView];
    [self.tempView addSubview:self.checkBtn];
//    [self.tempView addSubview:self.alertLab];
    [self.tempView addSubview:self.idCardTitleLab];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.tempImageView.frame), CGRectGetMaxY(self.tempImageView.frame) - 72, CGRectGetWidth(self.tempImageView.frame), 72)];
    bgView.backgroundColor = RGBA(36, 196, 164, 0.1);
    [self.tempView addSubview:bgView];
    [self.tempView addSubview:self.idCardTipLab];
}

- (void)top_cameraToolsBottomView{
    UIButton * picBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, 60, 60)];
    picBtn.centerY = self.captureButton.centerY;
    [picBtn setImage:[UIImage imageNamed:@"top_tupian"] forState:UIControlStateNormal];
    [picBtn addTarget:self action:@selector(top_sCamera_ClickPicBtn) forControlEvents:UIControlEventTouchUpInside];
    picBtn.layer.masksToBounds = YES;
    picBtn.layer.borderWidth = 1;
    picBtn.layer.borderColor = [UIColor clearColor].CGColor;
//    picBtn.hidden = YES;
    self.picBtn = picBtn;
    
    CGFloat labH = 15.0;
    UILabel * numberLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(picBtn.frame)-labH/2, CGRectGetMinY(picBtn.frame)-labH/2, labH, labH)];
    numberLab.layer.masksToBounds = YES;
    numberLab.layer.cornerRadius = labH/2;
    numberLab.font = [UIFont systemFontOfSize:11];
    numberLab.textAlignment = NSTextAlignmentCenter;
    numberLab.backgroundColor = kTopicBlueColor;
    numberLab.textColor = [UIColor whiteColor];
    numberLab.hidden = YES;
    self.numberLab = numberLab;
    
    UIButton * duiBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth - 20-80, 0, 60, 60)];
    duiBtn.centerY = picBtn.centerY;
    [duiBtn setImage:[UIImage imageNamed:@"top_duihao"] forState:UIControlStateNormal];
    [duiBtn addTarget:self action:@selector(top_sCamera_ClickDuiBtn) forControlEvents:UIControlEventTouchUpInside];
    duiBtn.hidden = YES;
    self.duiBtn = duiBtn;
    
    [self.toolsView addSubview:picBtn];
    [self.toolsView addSubview:numberLab];
    [self.toolsView addSubview:duiBtn];
    [self.toolsView addSubview:self.captureButton];
    [self.toolsView addSubview:self.resetBtn];
    [self.toolsView addSubview:self.arrowView];
    if (self.fileType != TOPEnterHomeCameraTypeLibrary&&self.fileType !=TOPEnterNextFolderCameraTypeLibrary&&self.fileType != TOPEnterDocumentCameraTypeLibrary) {
        [self top_setupPickView];
    }
}

- (NSArray *)takeModeArray {
    return @[@(TOPScameraTakeModeOCR),
             @(TOPScameraTakeModeIDCard),
             @(TOPScameraTakeModeSingle),
             @(TOPScameraTakeModeBatch),
             @(TOPScameraTakeModeCodeReader)];
}

- (NSArray *)codeResultTypeArray{
    NSArray * tempArray = @[@(TOPCameraCodeResultActionTypeShare),@(TOPCameraCodeResultActionTypeCopy),@(TOPCameraCodeResultActionTypeDelete),@(TOPCameraCodeResultActionTypeOpenURL)];
    return tempArray;
}

#pragma mark -- lazy
- (NSMutableArray *)cameraArray {
    if (!_cameraArray) {
        _cameraArray = @[].mutableCopy;
    }
    return _cameraArray;
}

- (UIImageView *)animateImg{
    if (!_animateImg) {
        _animateImg = [[UIImageView alloc]initWithFrame:CGRectMake(2,TOPNavBarAndStatusBarHeight+2, TOPScreenWidth-4, TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-4)];
        _animateImg.layer.masksToBounds = YES;
        _animateImg.layer.borderColor = kTopicBlueColor.CGColor;
        _animateImg.layer.borderWidth = 2;
    }
    return _animateImg;
}

- (UIButton *)captureButton{
    if (_captureButton == nil) {
        _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _captureButton.frame = CGRectMake(0, 0, 66, 66);
        _captureButton.center = CGPointMake(TOPScreenWidth / 2, kCameraToolsViewHeight/2 + 20);
        [_captureButton setImage:[UIImage imageNamed:@"top_xz_capture_click"]
                        forState: UIControlStateNormal];
        [_captureButton addTarget:self action:@selector(top_sCamera_ShutterCamera)
                 forControlEvents:UIControlEventTouchUpInside];
        _captureButton.enabled = YES;
    }
    return _captureButton;
}

- (TOPCaptureView *)captureView{
    WS(weakSelf);
    if (_captureView == nil) {
        _captureView = [[TOPCaptureView alloc]initWithFrame:CGRectMake(0,TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight) WithDelegate:self];
        _captureView.top_getCurrentState = ^(BOOL currentState) {
            weakSelf.captureButton.enabled = currentState;
        };
    }
    return _captureView;
}

- (TOPCodeReaderResultView *)codeResultView{
    if (!_codeResultView) {
        WS(weakSelf);
        _codeResultView = [[TOPCodeReaderResultView alloc]initWithFrame:CGRectMake(20, TOPNavBarAndStatusBarHeight+10, TOPScreenWidth-40, KCodeResultViewH)];
        _codeReaderView.alpha = 1;
        _codeResultView.top_clickBtnAction = ^(NSInteger tag, NSString * _Nonnull resultString) {
            [weakSelf top_codeResultAction:tag-1];
        };
        
        _codeResultView.top_clickShowBtnAction = ^(BOOL isSelect) {
            [weakSelf top_cameraCodeResultActionTypeOfShow:isSelect];
        };
    }
    return _codeResultView;
}

- (TOPCodeReaderView *)codeReaderView{
    if (!_codeReaderView) {
        WS(weakSelf);
        _codeReaderView = [[TOPCodeReaderView alloc]initWithFrame:CGRectMake(0,TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)];
        _codeReaderView.codeReaderFinish = ^(NSString * _Nonnull resultAsString) {
            weakSelf.codeResultString = resultAsString;
            [weakSelf top_codeReaderResultViewShow];
        };
    }
    return _codeReaderView;
}

- (UIView *)toolsView
{
    if (_toolsView == nil) {
        _toolsView = [[UIView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight - kCameraToolsViewHeight-TOPBottomSafeHeight,TOPScreenWidth,kCameraToolsViewHeight)];
        _toolsView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_toolsView];
    }
    return _toolsView;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPNavBarAndStatusBarHeight)];
        _topView.backgroundColor = RGBA(0, 0, 0, 1);
    }
    return _topView;
}

- (NSMutableArray *)picArray{
    if (!_picArray) {
        _picArray = [NSMutableArray new];
    }
    return _picArray;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapClick:)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

- (TOPCameraFilterRemindView *)filterRemindView{
    WS(weakSelf);
    if (!_filterRemindView) {
        _filterRemindView = [[TOPCameraFilterRemindView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _filterRemindView.top_btnAction = ^{
            [weakSelf top_hideFilterAndShowCrop];
        };
    }
    return _filterRemindView;
}

- (TOPCameraAutocropView *)autocropView{
    WS(weakSelf);
    if (!_autocropView) {
        _autocropView = [[TOPCameraAutocropView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _autocropView.top_btnAction = ^{
            [weakSelf top_hideCropShowView];
        };
    }
    return _autocropView;
}
- (TOPCameraFilterView *)filterView{
    WS(weakSelf);
    if (!_filterView) {
        _filterView = [[TOPCameraFilterView alloc]initWithFrame:CGRectMake(0, TOPNavBarAndStatusBarHeight-7, TOPScreenWidth, 100)];
        _filterView.alpha = 0;
        _filterView.top_sendProcessStateTip = ^(TOPReEditModel * _Nonnull model, NSInteger index) {
            [TOPScanerShare top_writeDefaultProcessType:[[TOPPictureProcessTool top_processTypeArray][index] integerValue]];
            [weakSelf top_filterViewCellAction:model];
        };
    }
    return _filterView;
}

- (TOPCameraCropSetView *)cropView{
    if (!_cropView) {
        _cropView = [[TOPCameraCropSetView alloc]initWithFrame:CGRectMake(TOPScreenWidth-190-70, TOPNavBarAndStatusBarHeight-7, 190, 50)];
        _cropView.alpha = 0;
    }
    return _cropView;
}

- (UIView *)blueLine{
    if (!_blueLine) {
        _blueLine = [[UIView alloc]initWithFrame:CGRectMake(0,TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)];
        _blueLine.backgroundColor = [UIColor clearColor];
        _blueLine.layer.masksToBounds = YES;
        _blueLine.layer.borderColor = kTopicBlueColor.CGColor;
        _blueLine.layer.borderWidth = 2;
    }
    return _blueLine;
}


- (UILabel *)takeModeTitleLab {
    if (!_takeModeTitleLab) {
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, TOPScreenWidth, kPickViewItemH)];
        noClassLab.textColor = kTopicBlueColor;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_M_FONT_(15);
        noClassLab.text = @"";
        [self.toolsView addSubview:noClassLab];
        noClassLab.hidden = YES;
        _takeModeTitleLab = noClassLab;
    }
    return _takeModeTitleLab;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        UIButton * duiBtn = [[UIButton alloc]initWithFrame:CGRectMake(48, 0, 60, 60)];
        duiBtn.centerY = self.captureButton.centerY;
        [duiBtn setImage:[UIImage imageNamed:@"camera_reset"] forState:UIControlStateNormal];
        [duiBtn addTarget:self action:@selector(top_sCamera_ClickResetBtn) forControlEvents:UIControlEventTouchUpInside];
        duiBtn.hidden = YES;
        _resetBtn = duiBtn;
    }
    return _resetBtn;
}

- (UIView *)tempView {
    if (!_tempView) {
        _tempView = [[UIView alloc] initWithFrame:self.captureView.bounds];
        _tempView.backgroundColor = RGBA(0, 0, 0, 0.6);
        _tempView.hidden = YES;
    }
    return _tempView;
}

- (UIImageView *)tempImageView {
    if (!_tempImageView) {
        CGFloat view_W = 0.0;
        CGFloat view_H = 0.0;
        CGFloat view_L = 0.0;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (IS_IPAD) {
            if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {
                view_L = 170;
            }else{
                view_L = 350;
            }
        }else{
            view_L = 62;
        }
        view_W = TOPScreenWidth - view_L * 2;
        view_H = view_W * 33.0/25.0;
        _tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(view_L, (CGRectGetHeight(self.captureView.frame) - view_H)/2.0, view_W, view_H)];
        _tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _tempImageView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        CGFloat view_H = 22;
        UIButton * duiBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.tempImageView.frame) - 5 - view_H, CGRectGetMinY(self.tempImageView.frame) - 12 - view_H, view_H, view_H)];
        [duiBtn setImage:[UIImage imageNamed:@"top_camera_close"] forState:UIControlStateNormal];
        [duiBtn addTarget:self action:@selector(top_sCamera_ClickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn = duiBtn;
    }
    return _closeBtn;
}

- (UIButton *)checkBtn {
    if (!_checkBtn) {
        CGFloat view_H = 16, view_W = CGRectGetWidth(self.tempImageView.frame);
        UIButton * duiBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.tempImageView.frame), CGRectGetMaxY(self.tempImageView.frame) + 8, view_W, view_H)];
        [duiBtn setImage:[UIImage imageNamed:@"top_camera_unCheck"] forState:UIControlStateNormal];
        
        [duiBtn setTitle:NSLocalizedString(@"topscan_noalert", @"") forState:UIControlStateNormal];
        duiBtn.titleLabel.font = PingFang_M_FONT_(10);
        duiBtn.titleLabel.textAlignment = NSTextAlignmentNatural;
        [duiBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        CGFloat space = 10;
        if (isRTL()) {
            duiBtn.imageEdgeInsets = UIEdgeInsetsMake(0, space/2, 0,0 );
            duiBtn.titleEdgeInsets = UIEdgeInsetsMake(0,0, 0,  space/2);
        }else{
            duiBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, space/2);
            duiBtn.titleEdgeInsets = UIEdgeInsetsMake(0, space/2, 0, 0);
        }
   
        
        [duiBtn addTarget:self action:@selector(top_sCamera_ClickCheckBtn) forControlEvents:UIControlEventTouchUpInside];
        duiBtn.selected = NO;
        _checkBtn = duiBtn;
    }
    return _checkBtn;
}

- (UILabel *)alertLab {
    if (!_alertLab) {
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.checkBtn.frame) + 12, CGRectGetMaxY(self.tempImageView.frame) + 8, 150, 16)];
        noClassLab.textColor = kWhiteColor;
        noClassLab.textAlignment = NSTextAlignmentNatural;
        noClassLab.font = PingFang_M_FONT_(10);
        noClassLab.text = NSLocalizedString(@"topscan_noalert", @"");
        _alertLab = noClassLab;
    }
    return _alertLab;
}

- (UILabel *)idCardTipLab {
    if (!_idCardTipLab) {
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.tempImageView.frame) + 5, CGRectGetMaxY(self.tempImageView.frame) - 72, CGRectGetWidth(self.tempImageView.frame) - 5*2, 72)];
        noClassLab.textColor = kTopicBlueColor;
        noClassLab.backgroundColor = [UIColor clearColor];
        noClassLab.textAlignment = NSTextAlignmentNatural;
        noClassLab.numberOfLines = 0;
        noClassLab.lineBreakMode = NSLineBreakByWordWrapping;
        noClassLab.font = PingFang_R_FONT_(11);
        noClassLab.text = NSLocalizedString(@"topscan_cardprompt", @"");
        _idCardTipLab = noClassLab;
    }
    return _idCardTipLab;
}

- (UILabel *)idCardTitleLab {
    if (!_idCardTitleLab) {
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.tempImageView.frame) - 115, CGRectGetMinY(self.tempImageView.frame) + 12, 110, 20)];
        noClassLab.textColor = kTopicBlueColor;
        noClassLab.backgroundColor = RGBA(36, 196, 164, 0.1);
        noClassLab.layer.cornerRadius = 10;
        noClassLab.layer.masksToBounds = YES;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(11);
        noClassLab.text = NSLocalizedString(@"topscan_paperexample", @"");
        _idCardTitleLab = noClassLab;
    }
    return _idCardTitleLab;
}

- (CAShapeLayer *)rectShape {
    if (!_rectShape) {
        _rectShape = [CAShapeLayer new];
        _rectShape.fillColor = [UIColor clearColor].CGColor; //填充颜色
        _rectShape.strokeColor = kTopicBlueColor.CGColor; //边框颜色
        _rectShape.lineWidth = 2.0f; //边框的宽度

        //圆角矩形
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((CGRectGetWidth(self.captureView.frame) - 278)*0.5, (CGRectGetHeight(self.captureView.frame) - 441)*0.5, 278, 441) cornerRadius:10];
        _rectShape.path = path.CGPath;
        [self.captureView.layer addSublayer:_rectShape];
        _rectShape.hidden = YES;
    }
    return _rectShape;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _arrowView.contentMode = UIViewContentModeScaleAspectFit;
        _arrowView.image = [UIImage imageNamed:@"top_camera_arrow"];
        _arrowView.hidden = YES;
    }
    return _arrowView;
}

- (TOPCameraTorchView *)torchView{
    if (!_torchView) {
        WS(weakSelf);
        _torchView = [[TOPCameraTorchView alloc]init];
        _torchView.alpha = 0;
        _torchView.top_clickFlashBtnChangeType = ^(TOPCameraFlashType type) {
            [weakSelf cameraFlashType:type];
            [weakSelf top_hideCropView];
        };
    }
    return _torchView;
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
