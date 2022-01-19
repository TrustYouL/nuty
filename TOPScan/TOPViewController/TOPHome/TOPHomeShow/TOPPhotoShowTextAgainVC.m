#define kPanHeight 250
#define kMaxZoom 3.0
#define TopView_H 44
#define Bottom_H 60
#define NoteView_H 300
#define Move_H (IS_IPAD?180.0:150.0)
#define Mid_H (TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H-88)/2+88
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPPhotoShowChildImageView.h"
#import "TOPPhotoShowTextEditView.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPSettingDocumentFormatterView.h"
#import "TOPHomeChildViewController.h"
#import "TOPNextFolderViewController.h"
#import "TOPPhotoReEditVC.h"
#import "TOPPhotoShowTextTranslationVC.h"
#import "TOPPhotoShowViewController.h"

@interface TOPPhotoShowTextAgainVC ()<TOPPhotoShowChildImageViewDelegate>
@property (nonatomic, strong) TOPPhotoShowChildImageView * myView;
@property (nonatomic, strong) TOPPhotoShowTextEditView * editView;
@property (nonatomic, strong) TOPSettingDocumentFormatterView * languageView;
@property (nonatomic, strong) TOPSettingDocumentFormatterView * endpointView;
@property (nonatomic, strong) TOPSettingDocumentFormatterView * exportView;
@property (nonatomic, strong) UILabel * pageLab;
@property (nonatomic, strong) UIImageView * tipRimgV;
@property (nonatomic, strong) UIImageView * tipLimgV;
@property (nonatomic, strong) NSMutableArray * languageArray;
@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) NSString * textString;
@property (nonatomic, strong) UIButton * returnBtn;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) CGFloat moveH;
@property (nonatomic, assign) BOOL isDown;
@property (nonatomic, assign) TOPFormatterViewEnterType formatterType;

@end

@implementation TOPPhotoShowTextAgainVC

- (void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD dismiss];
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [FIRAnalytics logEventWithName:@"TOPPhotoShowTextAgainVC" parameters:nil];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (NSMutableArray *)languageArray{
    if (!_languageArray) {
        _languageArray = [NSMutableArray new];
    }
    return _languageArray;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _backView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (NSArray *)top_exportArray{
    NSArray * tempArray = @[@(TOPExportTypeTxt),@(TOPExportTypeText),@(TOPExportTypeCopyToClipboard)];
    return tempArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.isDown = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self top_getLanguageData];
    [self top_setupChildImageView];
    [self top_setupPageLab];
    [self top_setupTipImg];
    [self top_setupTextEditView];
    self.editView.textView.editable = NO;
    [self performSelector:@selector(top_changeFream) withObject:nil afterDelay:1.0];
}
#pragma mark -- 初始化页码
- (void)top_setupPageLab{
    UILabel * pageLab = [UILabel new];
    pageLab.textColor = [UIColor whiteColor];
    pageLab.textAlignment = NSTextAlignmentCenter;
    pageLab.font = [UIFont systemFontOfSize:13];
    pageLab.backgroundColor = RGBA(51, 51, 51, 0.5);
    pageLab.hidden = NO;
    [self.view addSubview:pageLab];
    self.pageLab = pageLab;
    
    [self top_setupPageFream];
    [self performSelector:@selector(top_pageLabHide) withObject:nil afterDelay:2];
}
#pragma mark --初始化左右箭头
- (void)top_setupTipImg{
    UIImageView * tipImgV = [UIImageView new];
    tipImgV.image = [UIImage imageNamed:@"top_ocr_scrollRTip"];
    tipImgV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipImgV];
    self.tipRimgV = tipImgV;
    
    UIImageView * tipLimgV = [UIImageView new];
    tipLimgV.image = [UIImage imageNamed:@"top_ocr_scrollLTip"];
    tipLimgV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLimgV];
    self.tipLimgV = tipLimgV;
    
    [self top_setupTipImgFream:100];
    [self top_setTipImgShowState];
}
#pragma mark -- 左右箭头的显示状态
- (void)top_setTipImgShowState{
    if (self.dataArray.count>1) {
        if (self.currentIndex ==0) {
            self.tipLimgV.hidden = YES;
            self.tipRimgV.hidden = NO;
        }else if(self.currentIndex == self.dataArray.count-1){
            self.tipLimgV.hidden = NO;
            self.tipRimgV.hidden = YES;
        }else{
            self.tipLimgV.hidden = NO;
            self.tipRimgV.hidden = NO;
        }
    }else{
        self.tipLimgV.hidden = YES;
        self.tipRimgV.hidden = YES;
    }
}
#pragma mark -- 左上角页码的位置设置
- (void)top_setupPageFream{
    NSString * contentString = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.dataArray.count];
    CGFloat pageW = [TOPDocumentHelper top_getSizeWithStr:contentString Height:15 Font:12].width+8;
    self.pageLab.frame = CGRectMake(15, TOPNavBarAndStatusBarHeight+15, pageW, 20);
    self.pageLab.text = contentString;
    [self.pageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(TOPNavBarAndStatusBarHeight+15);
        make.width.mas_equalTo(pageW+5);
        make.height.mas_equalTo(20);
    }];
}
#pragma mark -- 左右提示箭头的位置
- (void)top_setupTipImgFream:(CGFloat)viewH{
    CGFloat ImgW = 16;
    [self.tipRimgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset((viewH-ImgW)/2+TOPNavBarAndStatusBarHeight);
        make.trailing.equalTo(self.view).offset(-5);
        make.size.mas_equalTo(CGSizeMake(ImgW, ImgW));
    }];
    [self.tipLimgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset((viewH-ImgW)/2+TOPNavBarAndStatusBarHeight);
        make.leading.equalTo(self.view).offset(5);
        make.size.mas_equalTo(CGSizeMake(ImgW, ImgW));
    }];
}
#pragma mark -- 上部图片滑动视图
- (void)top_setupChildImageView{
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithArray:self.dataArray];
    TOPPhotoShowChildImageView * myView = [[TOPPhotoShowChildImageView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
    myView.currentIndex = self.currentIndex;
    myView.dataArray = dataArray;
    myView.showType = TOPPhotoShowViewTextAgain;
    myView.delegate = self;
    myView.textAgainCellH = Mid_H+10-88;
    myView.ConstantType = TOPCollectionConstantTypeAuto;
    self.myView = myView;
    [myView top_loadCurrentData];
    [self.view addSubview:myView];
    [myView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}
#pragma mark -- 编辑框
- (void)top_setupTextEditView{
    WS(weakSelf);
    DocumentModel * model = [DocumentModel new];
    if (self.dataArray.count>0) {
        model = self.dataArray[self.currentIndex];
    }
    TOPPhotoShowTextEditView * editView = [[TOPPhotoShowTextEditView alloc]initWithFrame:CGRectMake(0, TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H)];
    editView.top_clickRightBtnChangeFream = ^(BOOL isSelect,BOOL isFirstResponder) {
        [UIView animateWithDuration:0.3 animations:^{
            if (isFirstResponder) {
                if (isSelect) {
                    [weakSelf.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.equalTo(weakSelf.view);
                        make.top.equalTo(weakSelf.view).offset(TOPNavBarAndStatusBarHeight);
                        make.bottom.equalTo(weakSelf.view).offset(-weakSelf.moveH);
                    }];
                }else{
                    [weakSelf.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.equalTo(weakSelf.view);
                        make.top.equalTo(weakSelf.view).offset(TOPNavBarAndStatusBarHeight+Move_H);
                        make.bottom.equalTo(weakSelf.view).offset(-weakSelf.moveH);
                    }];
                }
                weakSelf.myView.textAgainCellH = Move_H+10;
                weakSelf.myView.ConstantType = TOPCollectionConstantTypeSpe;
                [weakSelf top_setupTipImgFream:Move_H+10];
            }else{
                if (isSelect) {
                    [weakSelf.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.equalTo(weakSelf.view);
                        make.top.equalTo(weakSelf.view).offset(TOPNavBarAndStatusBarHeight);
                        make.bottom.equalTo(weakSelf.view).offset(-(TOPBottomSafeHeight+Bottom_H));
                    }];
                }else{
                    [weakSelf.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.equalTo(weakSelf.view);
                        make.top.equalTo(weakSelf.view.mas_centerY).offset(-44);
                        make.bottom.equalTo(weakSelf.view).offset(-(TOPBottomSafeHeight+Bottom_H));
                    }];
                }
                weakSelf.myView.textAgainCellH = Mid_H+10-88;
                weakSelf.myView.ConstantType = TOPCollectionConstantTypeAuto;
                [weakSelf top_setupTipImgFream:Mid_H+10-88];
            }
            [weakSelf.view layoutIfNeeded];
            [weakSelf.myView top_loadCurrentData];
            weakSelf.isDown = isSelect;
        }];
    };
    
    editView.top_sendBackText = ^(NSString * _Nonnull text) {
        weakSelf.textString = text;
    };
    
    editView.top_clickShowLanguageView = ^{
        weakSelf.editView.netWorkState = [TOPScanerShare top_saveWlanFinish];
        [weakSelf top_getLanguageData];
        weakSelf.languageView.enterType = TOPFormatterViewEnterTypeTextAgainLanguage;
        [weakSelf top_showLanguageView];
        [weakSelf.editView.textView resignFirstResponder];
    };
    
    editView.top_clickShowEndPointView = ^(NSString * _Nonnull endpointString) {
        if (endpointString == nil) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"topscan_ocrgoogleendpointprompt", @"")];
            [SVProgressHUD dismissWithDelay:1.5];
        }else{
            weakSelf.endpointView.enterType = TOPFormatterViewEnterTypeTextAgainEndpoint;
            [weakSelf top_showEndpointView];
            [weakSelf.editView.textView resignFirstResponder];
        }
    };
    editView.model = model;
    editView.netWorkState = [TOPScanerShare top_saveWlanFinish];
    editView.topRightBtn.selected = self.isDown;
    self.editView = editView;
    [self.view addSubview:self.editView];
    [editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOPNavBarAndStatusBarHeight);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
    }];
    self.originFrame = editView.frame;
}

- (TOPSettingDocumentFormatterView *)languageView{
    WS(weakSelf);
    if (!_languageView) {
        _languageView = [[TOPSettingDocumentFormatterView alloc]initWithFrame:CGRectMake(20, TOPNavBarAndStatusBarHeight-10, TOPScreenWidth-40, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-10)];
        _languageView.layer.masksToBounds = YES;
        _languageView.layer.cornerRadius = 5;
        _languageView.languageArray = weakSelf.languageArray;
        _languageView.enterType = TOPFormatterViewEnterTypeTextAgainLanguage;
        _languageView.top_clickToDismiss = ^{
            [weakSelf top_clickTap];
        };
        
        _languageView.top_clickCellSendLanguageDic = ^(NSString * _Nonnull keyString, NSInteger row) {
            [weakSelf top_clickTap];
            [weakSelf top_getSelectLanguageType:keyString selectRow:row];
        };
    }
    return _languageView;
}

- (TOPSettingDocumentFormatterView*)endpointView{
    WS(weakSelf);
    if (!_endpointView) {
        _endpointView = [[TOPSettingDocumentFormatterView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-240-50)/2, TOPScreenWidth-40, 240+50)];
        _endpointView.layer.masksToBounds = YES;
        _endpointView.layer.cornerRadius = 5;
        _endpointView.enterType = TOPFormatterViewEnterTypeTextAgainEndpoint;
        _endpointView.top_clickToDismiss = ^{
            [weakSelf top_clickTap];
        };
        
        _endpointView.top_clickCellSendLanguageDic = ^(NSString * _Nonnull keyString, NSInteger row) {
            [weakSelf top_clickTap];
            [weakSelf top_getSelectEndpointType:keyString selectRow:row];
        };
    }
    return _endpointView;
}

- (TOPSettingDocumentFormatterView *)exportView{
    WS(weakSelf);
    if (!_exportView) {
        _exportView = [[TOPSettingDocumentFormatterView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-200)/2, TOPScreenWidth-40, 200)];
        _exportView.layer.masksToBounds = YES;
        _exportView.layer.cornerRadius = 5;
        _exportView.dataArray = weakSelf.dataArray;
        _exportView.enterType = self.formatterType;
        _exportView.top_clickToDismiss = ^{
            [weakSelf top_clickTap];
        };
        
        _exportView.top_clickCellSendExportType = ^(BOOL allBtnSelect, NSInteger row) {
            [weakSelf top_clickTap];
            [weakSelf top_getSelectExportType:allBtnSelect index:row];
        };
    }
    return _exportView;
}

- (void)top_getSelectEndpointType:(NSString *)keyString selectRow:(NSInteger)row{
    [FIRAnalytics logEventWithName:@"TextAgain_top_getSelectEndpointType" parameters:nil];
    NSDictionary * getDic = [TOPDocumentHelper top_getEndpointData][row];
    if (getDic.allKeys.count>0) {
        [TOPScanerShare top_writeSaveOcrEndpoint:getDic];
        self.editView.endpointString = getDic.allValues[0];
    }
    
}

- (void)top_getSelectLanguageType:(NSString *)keyString selectRow:(NSInteger)row{
    [FIRAnalytics logEventWithName:@"TextAgain_top_getSelectLanguageType" parameters:nil];
    NSDictionary * getDic = self.languageArray[row];
    if (getDic.allKeys.count>0) {
        NSLog(@"getDic.allValues[0]==%@",getDic.allValues[0]);
        NSString * lang = getDic.allValues[0];
        self.editView.languBtnTitle = lang.uppercaseString;
        [TOPScanerShare top_writeSaveOcrLanguage:getDic];
    }
    NSString * endpointString = [TOPDocumentHelper top_getEndPoint:getDic];
    self.editView.endpointString = endpointString;
}

#pragma mark -- 展示LanguageView
- (void)top_showLanguageView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [keyWindow addSubview:self.languageView];
    [self top_makCover];
    [self.languageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(keyWindow).offset(20);
        make.trailing.equalTo(keyWindow).offset(-20);
        make.top.equalTo(keyWindow).offset(TOPNavBarAndStatusBarHeight-10);
        make.bottom.equalTo(keyWindow).offset(-(TOPBottomSafeHeight+10));
    }];
}

- (void)top_showEndpointView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [keyWindow addSubview:self.endpointView];
    [self top_makCover];
    if (IS_IPAD) {
        [self.endpointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(keyWindow);
            make.height.mas_equalTo(240+50);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.endpointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(keyWindow);
            make.leading.equalTo(keyWindow).offset(20);
            make.trailing.equalTo(keyWindow).offset(-20);
            make.height.mas_equalTo(240+50);
        }];
    }
}

- (void)top_showExportView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [keyWindow addSubview:self.exportView];
    [self top_makCover];
    if (IS_IPAD) {
        [self.exportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.height.mas_equalTo(200);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.exportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(20);
            make.trailing.equalTo(self.view).offset(-20);
            make.centerY.equalTo(self.view);
            make.height.mas_equalTo(200);
        }];
    }
}
#pragma mark -- 隐藏选择语言界面
- (void)top_clickTap{
    [self.backView removeFromSuperview];
    [self.languageView removeFromSuperview];
    [self.endpointView removeFromSuperview];
    [self.exportView removeFromSuperview];
    
    self.backView = nil;
    self.languageView = nil;
    self.endpointView = nil;
    self.exportView = nil;
}
- (void)top_makCover{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
#pragma mark --LanguageData
- (void)top_getLanguageData{
    NSArray * tempArray = [NSArray new];
    if ([TOPScanerShare top_googleConnection]&&[[TOPScanerShare top_saveWlanFinish] isEqualToString:@"1"]){
        tempArray = [TOPDocumentHelper top_getAllLanguageData];
    }else{
        tempArray = [TOPDocumentHelper top_getThirdLanguageData];
    }
    
    self.languageArray = [tempArray mutableCopy];
}
#define Mid_H (TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H-88)/2+88
#pragma mark -- 一秒延迟后的动画
- (void)top_changeFream{
    [UIView animateWithDuration:0.3 animations:^{
        self.isDown = NO;
        self.editView.topRightBtn.selected = self.isDown;
        [self.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_centerY).offset(-44);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
        }];
        [self.view layoutIfNeeded];
        self.editView.textView.editable = YES;
        self.editView.backgroundColor = [UIColor clearColor];
        self.myView.textAgainCellH = Mid_H+10-88;
        self.myView.ConstantType = TOPCollectionConstantTypeAuto;
        [self.myView top_loadCurrentData];
        [self top_setupTipImgFream:Mid_H+10-88];
    }];
}
#pragma mark --键盘弹出，文本框移动到键盘上方
- (void)keyboardwill:(NSNotification *)notification{
    NSDictionary * info = [notification userInfo];
    CGFloat keyOriginY = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat moveH = TOPScreenHeight-keyOriginY;
    if (!self.isDown) {
        [self.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view).offset(Move_H+TOPNavBarAndStatusBarHeight);
            make.bottom.equalTo(self.view).offset(-(TOPScreenHeight-keyOriginY));
        }];
        
        self.myView.textAgainCellH = Move_H+10;
        self.myView.ConstantType = TOPCollectionConstantTypeSpe;
        [self.myView top_loadCurrentData];
        [self top_setupTipImgFream:Move_H+10];
    }else{
        [self.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view).offset(TOPNavBarAndStatusBarHeight);
            make.bottom.equalTo(self.view).offset(-(TOPScreenHeight-keyOriginY));
        }];
        
    }
    self.moveH = moveH;
    if (!self.returnBtn) {
        UIButton * returnBtn = [[UIButton alloc]init];
        returnBtn.backgroundColor = RGBA(212, 216, 222, 1.0);
        [returnBtn setImage:[UIImage imageNamed:@"top_downKeyboard"] forState:UIControlStateNormal];
        [returnBtn addTarget:self action:@selector(top_clickReturnToHide) forControlEvents:UIControlEventTouchUpInside];
        returnBtn.layer.masksToBounds = YES;
        returnBtn.layer.cornerRadius = 3;
        self.returnBtn = returnBtn;
        [self.view addSubview:self.returnBtn];
    }
    self.returnBtn.frame = CGRectMake(TOPScreenWidth-55, keyOriginY-48, 53, 47);
    self.returnBtn.hidden = NO;
}

#pragma mark --键盘隐藏,文本框回到原来位置
- (void)keybaordhide:(NSNotification *)info{
    [UIView animateWithDuration:0.3 animations:^{
        [self.editView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_centerY).offset(-44);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
        }];
        [self.view layoutIfNeeded];
        self.returnBtn.hidden = YES;
        self.isDown = NO;
        self.editView.topRightBtn.selected = self.isDown;
        self.myView.textAgainCellH = Mid_H+10-88;
        self.myView.ConstantType = TOPCollectionConstantTypeAuto;
        [self.myView top_loadCurrentData];
        [self top_setupTipImgFream:Mid_H+10-88];
    }];
}

- (void)top_clickReturnToHide{
    [self.editView.textView resignFirstResponder];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --TOPPhotoShowChildImageViewDelegate
- (void)top_photoShowChildImageViewBackHomeVC{
    DocumentModel * model = self.dataArray[self.currentIndex];
    if ((![self.textString isEqualToString:[TOPDocumentHelper top_getTxtContent:model.ocrPath]])&&self.textString.length>0) {
        WS(weakSelf);
        [self.editView.textView resignFirstResponder];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_ocrtextagainvctip", @"")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [FIRAnalytics logEventWithName:@"TextAgain_photoShowChildImageViewBackHomeVC_OK" parameters:nil];
            [weakSelf top_backHomeVC];
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
            [FIRAnalytics logEventWithName:@"TextAgain_photoShowChildImageViewBackHomeVC_CANCEL" parameters:nil];
            [weakSelf.editView.textView becomeFirstResponder];
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [FIRAnalytics logEventWithName:@"TextAgain_backHomeVC" parameters:nil];
        [self top_backHomeVC];
    }
}
#pragma mark -- 返回时的逻辑处理
- (void)top_backHomeVC{
    [self.editView.textView resignFirstResponder];
    if (self.backType == TOPPhotoShowTextAgainVCBackTypePopVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if(self.backType == TOPPhotoShowTextAgainVCBackTypePopRoot){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if(self.backType == TOPPhotoShowTextAgainVCBackTypePopChild){
        for (UIViewController * vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[TOPHomeChildViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }else if(self.backType == TOPPhotoShowTextAgainVCBackTypePopFolder){
        NSMutableArray * vcArray = [NSMutableArray new];
        for (UIViewController * vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[TOPNextFolderViewController class]]) {
                [vcArray addObject:vc];
            }
        }
        
        TOPNextFolderViewController * nextVC = vcArray.lastObject;
        [self.navigationController popToViewController:nextVC animated:YES];
    }else if(self.backType == TOPPhotoShowTextAgainVCBackTypePopReEdit){
        NSMutableArray * vcArray = [NSMutableArray new];
        for (UIViewController * vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[TOPPhotoReEditVC class]]) {
                [vcArray addObject:vc];
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:TOP_TRPhotoReEditVCNotification object:self];
        TOPPhotoReEditVC * reEditVC = vcArray.lastObject;
        [self.navigationController popToViewController:reEditVC animated:YES];
    }else if(self.backType == TOPPhotoShowTextAgainVCBackTypePopPhotoShow){
        NSMutableArray * vcArray = [NSMutableArray new];
        for (UIViewController * vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[TOPPhotoShowViewController class]]) {
                [vcArray addObject:vc];
            }
        }
        
        TOPPhotoShowViewController * nextVC = vcArray.lastObject;
        [self.navigationController popToViewController:nextVC animated:YES];
    }else if(self.backType == TOPPhotoShowTextAgainVCBackTypeDismiss){
        if ([TOPScanerShare shared].isPush) {
            TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
            childVC.docModel = [TOPFileDataManager shareInstance].docModel;
            childVC.pathString = self.filePath;
            childVC.addType = @"add";
            childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
            childVC.hidesBottomBarWhenPushed = YES;
            [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
            [[TOPDocumentHelper top_getPushVC].navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
        }else{
            if (![self isBeingDismissed]) {
                [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}
#pragma mark -- TOPPhotoShowChildImageViewDelegate
- (void)top_photoShowChildImageViewSaveText:(NSInteger)index{
    [FIRAnalytics logEventWithName:@"TextAgain_photoShowChildImageViewSaveText" parameters:nil];
    DocumentModel * model = self.dataArray[self.currentIndex];
    NSString * saveString = [NSString new];
    if (self.textString.length>0) {
        saveString = self.textString;
    }else{
        saveString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
    }
    BOOL result= [saveString writeToFile:model.ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (result) {
        model.ocr = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
        [self top_backHomeVC];
    }
}

- (void)top_photoShowChildImageViewShareText:(NSInteger)index{
    [FIRAnalytics logEventWithName:@"showTextAgain_share" parameters:nil];
    [self.editView.textView resignFirstResponder];
    self.formatterType = TOPFormatterViewEnterTypeTextAgainShare;
    [self top_showExportView];
}

#pragma mark -- Translation
- (void)top_photoShowChildImageViewTranlation:(NSInteger)index{
    if (self.dataArray.count > self.currentIndex) {
        DocumentModel * currentModel = self.dataArray[self.currentIndex];
        NSMutableArray * tempArray = [NSMutableArray new];
        [tempArray addObject:currentModel];
        
        TOPPhotoShowTextTranslationVC * translationVC = [TOPPhotoShowTextTranslationVC new];
        translationVC.dataArray = tempArray;
        translationVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:translationVC animated:YES];
    }
}
- (void)top_photoShowChildImageViewOcrAgain:(NSInteger)index{
    if (self.dataArray.count>1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
        UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ocrocragainrecognizecurrentpage", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self top_ocrAgainSingle];
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ocrocragainrecognizeallpages", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self top_ocrAgainAll];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
        UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
        UIColor * canelColor = TOPAPPGreenColor;
        [cancelAction setValue:canelColor forKey:@"_titleTextColor"];
        [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
        [otherAction setValue:titleColor forKey:@"_titleTextColor"];
        [alertController addAction:archiveAction];
        [alertController addAction:otherAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        [self top_ocrAgainSingle];
    }
}

- (void)top_photoShowChildImageViewCopy:(NSInteger)index{
    if (self.dataArray.count>1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
        UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_copypage", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self top_exportTxtActionClipboard:NO];
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_copyallpages", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self top_exportTxtActionClipboard:YES];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
        UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
        UIColor * canelColor = TOPAPPGreenColor;
        [cancelAction setValue:canelColor forKey:@"_titleTextColor"];
        [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
        [otherAction setValue:titleColor forKey:@"_titleTextColor"];
        [alertController addAction:archiveAction];
        [alertController addAction:otherAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        [self top_exportTxtActionClipboard:NO];
    }
}

- (void)top_photoShowChildImageViewExport:(NSInteger)index{
    [FIRAnalytics logEventWithName:@"showTextAgain_export" parameters:nil];
    self.formatterType = TOPFormatterViewEnterTypeTextAgainExport;
    [self top_showExportView];
}

#pragma mark -- 滑动结束
- (void)top_photoShowChildImageViewCurrentLocation:(NSInteger)index{
    self.currentIndex = index;
    DocumentModel * model = self.dataArray[self.currentIndex];
    self.editView.model = model;
    
    [self top_setupPageFream];
    [self performSelector:@selector(top_pageLabHide) withObject:nil afterDelay:2];
    if (index == self.dataArray.count-1) {
        self.tipRimgV.hidden = YES;
    }else{
        self.tipRimgV.hidden = NO;
    }
    
    if (index == 0) {
        self.tipLimgV.hidden = YES;
    }else{
        self.tipLimgV.hidden = NO;
    }
}
#pragma mark -- 即将开始滑动时就进行数据保存
- (void)top_photoShowChildImageViewStartScrollow:(NSInteger)index{
    self.currentIndex = index;
    [self top_saveTextViewContent];
    
    [self top_setupPageFream];
    self.pageLab.hidden = NO;
}
#pragma mark -- 开始移动单个cell的图片
- (void)top_photoShowChildImageViewTextAgainScrollBeginShow{
    [self top_setupPageFream];
    self.pageLab.hidden = NO;
}
#pragma mark -- 移动单个cell上的的图片结束时
- (void)top_photoShowChildImageViewTextAgainScrollEndHide{
    [self top_setupPageFream];
    [self performSelector:@selector(top_pageLabHide) withObject:nil afterDelay:2];
}

- (void)top_pageLabHide{
    self.pageLab.hidden = YES;
}

#pragma mark -- 保存数据
- (void)top_saveTextViewContent{
    [FIRAnalytics logEventWithName:@"textAgain_saveTextViewContent" parameters:nil];
    DocumentModel * model = self.dataArray[self.currentIndex];
    NSLog(@"textString==%@",self.textString);
    if ((![self.textString isEqualToString:[TOPDocumentHelper top_getTxtContent:model.ocrPath]])&&self.textString.length>0) {
        BOOL result= [self.textString writeToFile:model.ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if (result) {
            self.textString = nil;
        }
    }
}
#pragma mark -- 识别单张
- (void)top_ocrAgainSingle{
    [FIRAnalytics logEventWithName:@"textAgain_ocrAgainSingle" parameters:nil];
    NSMutableArray * tempArray = [NSMutableArray new];
    if (self.currentIndex<self.dataArray.count) {
        [tempArray addObject:self.dataArray[self.currentIndex]];
    }
    WS(weakSelf);
    TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
    ocrVC.top_clickToReloadData = ^(NSInteger index) {
        weakSelf.currentIndex = index;
        DocumentModel * model = weakSelf.dataArray[index];
        weakSelf.textView.text = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
        weakSelf.myView.currentIndex = index;
        [weakSelf.myView top_loadCurrentData];
        weakSelf.editView.model = model;
        weakSelf.editView.netWorkState = [TOPScanerShare top_saveWlanFinish];
        [weakSelf top_getLanguageData];
    };
    ocrVC.currentIndex = 0;
    ocrVC.dataArray = tempArray;
    ocrVC.backType = self.backType;
    ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRAgain;
    ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishAlready;
    ocrVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:ocrVC animated:YES];
}

#pragma mark -- 识别多张
- (void)top_ocrAgainAll{
    WS(weakSelf);
    NSMutableArray * tempArray = [NSMutableArray new];
    [tempArray addObjectsFromArray:self.dataArray];
    TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
    ocrVC.top_clickToReloadData = ^(NSInteger index) {
        weakSelf.currentIndex = index;
        DocumentModel * model = weakSelf.dataArray[index];
        weakSelf.textView.text = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
        weakSelf.myView.currentIndex = index;
        [weakSelf.myView top_loadCurrentData];
        weakSelf.editView.model = model;
        weakSelf.editView.netWorkState = [TOPScanerShare top_saveWlanFinish];
        [weakSelf top_getLanguageData];
    };
    ocrVC.currentIndex = self.currentIndex;
    ocrVC.dataArray = tempArray;
    ocrVC.backType = self.backType;
    ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRAgain;
    ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishAlready;
    ocrVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:ocrVC animated:YES];
}

#pragma mark -- ExportViewAction
- (void)top_getSelectExportType:(BOOL)allPageSelect index:(NSInteger)row{
    NSNumber * num = [self top_exportArray][row];
    switch ([num integerValue]) {
        case TOPExportTypeTxt:
            [self top_exportTxtAction:allPageSelect];
            break;
        case TOPExportTypeText:
            [self top_exportTextAction:allPageSelect];
            break;
        case TOPExportTypeCopyToClipboard:
            [self top_exportTxtActionClipboard:allPageSelect];
            break;
        default:
            break;
    }
}

#pragma mark--分享txt文档
- (void)top_exportTxtAction:(BOOL)allPageSelect{
    [FIRAnalytics logEventWithName:@"textAgain_exportTxtAction" parameters:nil];
    NSString * homePath = [TOPDocumentHelper top_getTxtPathString];
    NSString * shareString = [NSString new];
    NSString * filePath = [NSString new];
    DocumentModel * model = self.dataArray[self.currentIndex];
    if (self.dataArray.count<=1||!allPageSelect) {
        if (self.textString.length>0) {
            shareString = self.textString;
        }else{
            shareString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
        }
        NSString * nameSuffix = [NSString new];
        if (!model.name) {
            if (self.currentIndex+1 < 10) {
                nameSuffix = [NSString stringWithFormat:@"0%@",@(self.currentIndex+1)];
            }else{
                nameSuffix = [NSString stringWithFormat:@"%@",@(self.currentIndex+1)];
            }
        }else{
            nameSuffix = model.name;
        }
        filePath = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.txt",model.fileName,nameSuffix]];
    }else{
        shareString = [self top_allOCRtogether];
        if (self.dataType == TOPOCRDataTypeSingleDocument) {
            filePath = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",model.fileName]];
        }else{
            filePath = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ and more.txt",model.fileName]];
        }
    }
    [shareString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSURL * shareURL = [NSURL fileURLWithPath:filePath];
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[shareURL] applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}

#pragma mark--分享字符串
- (void)top_exportTextAction:(BOOL)allPageSelect{
    [FIRAnalytics logEventWithName:@"textAgain_exportTextAction" parameters:nil];
    
    NSString * shareString = [NSString new];
    if (self.dataArray.count<=1||!allPageSelect) {
        DocumentModel * model = self.dataArray[self.currentIndex];
        if (self.textString.length>0) {
            shareString = self.textString;
        }else{
            shareString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
        }
    }else{
        shareString = [self top_allOCRtogether];
    }
    
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[shareString] applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}

#pragma mark -- 复制到粘贴板
- (void)top_exportTxtActionClipboard:(BOOL)allPageSelect{
    [FIRAnalytics logEventWithName:@"textAgain_exportTxtActionClipboard" parameters:nil];
    NSString * shareString = [NSString new];
    if (self.dataArray.count<=1||!allPageSelect) {
        DocumentModel * model = self.dataArray[self.currentIndex];
        if (self.textString.length>0) {
            shareString = self.textString;
        }else{
            shareString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
        }
    }else{
        shareString = [self top_allOCRtogether];
    }
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = shareString;
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 260)];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_ocrexportcopy", @"")];
    [SVProgressHUD dismissWithDelay:1.5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    });
}

- (NSString *)top_allOCRtogether{
    NSString * allString = [NSString new];
    for (DocumentModel * ocrModel in self.dataArray) {
        if ([self.dataArray indexOfObject:ocrModel] == self.currentIndex) {
            if (self.textString.length>0) {
                allString = [NSString stringWithFormat:@"%@Page %ld\nText recognition result\n%@\n\n\n",allString,[self.dataArray indexOfObject:ocrModel]+1,self.textString];
            }else{
                allString = [NSString stringWithFormat:@"%@Page %ld\nText recognition result\n%@\n\n\n",allString,[self.dataArray indexOfObject:ocrModel]+1,[TOPDocumentHelper top_getTxtContent:ocrModel.ocrPath]];
            }
        }else{
            allString = [NSString stringWithFormat:@"%@Page %ld\nText recognition result\n%@\n\n\n",allString,[self.dataArray indexOfObject:ocrModel]+1,[TOPDocumentHelper top_getTxtContent:ocrModel.ocrPath]];
        }
    }
    return allString;
}

@end
