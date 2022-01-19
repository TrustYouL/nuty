#define  FormatterView_Y 150
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#import "TOPSettingDocManagementVC.h"
#import "TOPSettingDocNameVC.h"
#import "TOPScanSettingCell.h"
#import "TOPScanSettingSaveCell.h"
#import "TOPScanSettingAutoCropCell.h"
#import "TOPNextSettingShowView.h"
#import "TOPUserDefinedSizeView.h"
#import "TOPSettingModel.h"
#import "TOPSettingFormatModel.h"
#import "TOPSwithBackTapTableViewCell.h"
#import "TOPAppSafeItemTableViewCell.h"

@interface TOPSettingDocManagementVC ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)TOPSettingFormatModel * formatModel;
@property (nonatomic ,strong)TOPNextSettingShowView * showFormatterView;
@property (nonatomic ,strong)TOPUserDefinedSizeView * userDefinedsizeView;
@property (nonatomic ,strong)TOPDocPasswordView * passwordView;
@property (nonatomic ,strong)UIView * coverView;
@property (nonatomic ,strong)NSMutableArray * docManagementArray;
@property (nonatomic ,strong)NSMutableArray *docSetArrays;
@property (nonatomic ,strong)NSMutableArray *pdfSetArrays;
@property (nonatomic ,strong)NSMutableArray *sectionArrays;
@property (nonatomic ,strong)NSMutableArray *sectionSubTitleArrays;
@property (nonatomic ,assign)BOOL isShowFailToast;

@end

@implementation TOPSettingDocManagementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_loadData];
    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"topscan_settingdocmanagement", @"");
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor],
      NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)top_backHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1+self.sectionArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _docManagementArray.count;
    }else{
        NSString *sectionTitle = self.sectionArrays[section-1];
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword", @"")]) {
            return self.docSetArrays.count;
        }
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword", @"")]) {
            return self.pdfSetArrays.count;
        }
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPSettingModel * model = self.docManagementArray[indexPath.row];
        if (model.checkValue == TOPSettingCellTypeFirstKind) {
            TOPScanSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanSettingCell class]) forIndexPath:indexPath];
            cell.model = model;
            return cell;
        } else if(model.checkValue == TOPSettingCellTypeSecondKind) {
            TOPScanSettingSaveCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanSettingSaveCell class]) forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }else if(model.checkValue == TOPSettingCellTypeThirdKind){
            TOPScanSettingAutoCropCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanSettingAutoCropCell class]) forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }else{
            return nil;
        }
    }else{
        NSString *sectionTitle = self.sectionArrays[indexPath.section-1];
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword", @"")]) {
            NSString *swithName = self.docSetArrays[indexPath.row];
            if ([swithName isEqualToString:NSLocalizedString(@"topscan_turnoffpassword",@"")]) {
                TOPSwithBackTapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSaveCellIdentifier" forIndexPath:indexPath];
                cell.cellType = @"doc";
                cell.swithName = swithName;
                WS(weakSelf);
                cell.top_swichOpenOrCloseAppSafeBlock = ^(BOOL isOpen,NSString *currentItem) {//关闭开启文档密码
                    if (isOpen) {
                        [weakSelf top_clickToTurnOffPassword];
                    }else{
                        [weakSelf top_clickToTurnOnPassword];
                    }
                };
                return cell;
            }
            TOPAppSafeItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppSafeItemIdentifier" forIndexPath:indexPath];
            cell.titleLab.text = swithName;
            return cell;
        } else if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword", @"")]) {
            NSString *swithName = self.pdfSetArrays[indexPath.row];
            if ([swithName isEqualToString:NSLocalizedString(@"topscan_turnoffpassword",@"")]) {
                TOPSwithBackTapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSaveCellIdentifier" forIndexPath:indexPath];
                cell.cellType = @"pdf";
                cell.swithName = swithName;
                WS(weakSelf);
                cell.top_swichOpenOrCloseAppSafeBlock = ^(BOOL isOpen,NSString *currentItem) {//关闭开启pdf密码
                    if (isOpen) {
                        [weakSelf top_clickToTurnOffPDFPassword];
                    }else{
                        [weakSelf top_clickToTurnOnPDFPassword];
                    }

                };
                return cell;
            }
            TOPAppSafeItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppSafeItemIdentifier" forIndexPath:indexPath];
            cell.titleLab.text = swithName;
            return cell;
        }else{
            return nil;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 15)];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }else{
        NSString *sectionTitle = self.sectionArrays[section-1];
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword",@"")]||[sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword",@"")])  {
            UIView *sectionHeadView = [[UIView alloc] init];
            UILabel * titleLab = [UILabel new];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.textColor = UIColorFromRGB(0x777777);
            
            titleLab.textAlignment = NSTextAlignmentNatural;
            titleLab.text = sectionTitle;
            titleLab.frame = CGRectMake(15, 20, TOPScreenWidth-40, 20);
            [sectionHeadView addSubview:titleLab];
            
            UILabel * subTitleLab = [UILabel new];
            subTitleLab.font = [UIFont systemFontOfSize:11];
            subTitleLab.textColor = UIColorFromRGB(0x777777);
            subTitleLab.textAlignment = NSTextAlignmentNatural;
            subTitleLab.numberOfLines = 0;

            if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword",@"")]) {
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_clearFolderpasswordTap:)];
                tapGesture.numberOfTapsRequired = 5;
                [sectionHeadView addGestureRecognizer:tapGesture];
                
            }
            subTitleLab.text = self.sectionSubTitleArrays[section-1];
            CGFloat subHeight = [self top_headerHeight:self.sectionSubTitleArrays[section-1]]-55;

            subTitleLab.frame = CGRectMake(15, CGRectGetMaxY(titleLab.frame)+1, TOPScreenWidth-40, subHeight);
            [sectionHeadView addSubview:subTitleLab];
            sectionHeadView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF9F9F9)];
            return sectionHeadView;
        }
        else{
            UIView *sectionHeadView = [[UIView alloc] init];

            UILabel * titleLab = [UILabel new];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.textColor = UIColorFromRGB(0x777777);
            titleLab.textAlignment = NSTextAlignmentNatural;
            titleLab.text = NSLocalizedString(@"topscan_apppwd", @"");
            titleLab.frame = CGRectMake(15, 11, TOPScreenWidth-40, 20);
            [sectionHeadView addSubview:titleLab];
            sectionHeadView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF9F9F9)];
            return sectionHeadView;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15;
    }else{
        NSString *sectionTitle = self.sectionArrays[section-1];
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_appsecurity",@"")] || [sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword",@"")]||[sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword",@"")])  {
            NSString *sectionSubTitle = self.sectionSubTitleArrays[section-1];
            CGFloat subHeight = [self top_headerHeight:sectionSubTitle];
            return subHeight;
        }
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPSettingModel * model = self.docManagementArray[indexPath.row];
        return model.cellHeight;
    }else{
        return 58;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self top_didSelectedSettingDocAction:indexPath.row];
    }else{
        NSString *sectionTitle = self.sectionArrays[indexPath.section-1];
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword", @"")]) {
            NSString *swithName = self.docSetArrays[indexPath.row];
            if ([swithName isEqualToString:NSLocalizedString(@"topscan_changepassword", @"")]) {
                [self top_clickToChangePassword];
            }
        }
        
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword", @"")]) {
            NSString *swithName = self.pdfSetArrays[indexPath.row];
            if ([swithName isEqualToString:NSLocalizedString(@"topscan_changepassword", @"")]) {
                [self top_clickToChangePDFPassword];
            }
        }
    }
}
- (CGFloat)top_headerHeight:(NSString *)subTitle
{
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    CGSize size = [subTitle boundingRectWithSize:CGSizeMake(TOPScreenWidth-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
    return size.height+55;
}
#pragma mark - 连续点击5次
- (void)top_clearFolderpasswordTap:(UITapGestureRecognizer *)gesture {
    if ( [TOPScanerShare top_docPassword].length) {
        [self top_clearAppLockStatesAlert];
    }
}
#pragma mark -- 是否清除安全密码
- (void)top_clearAppLockStatesAlert{
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                   message:NSLocalizedString(@"topscan_clearapppsd" ,@"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
            [self top_clearLocalPassWord];

    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)top_clearLocalPassWord
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray  * docArray = [TOPDataModelHandler top_buildSearchDataAtPath:[TOPDocumentHelper top_appBoxDirectory]];
        for (DocumentModel * docModel in docArray) {
            if ([docModel.type isEqualToString:@"1"]) {
                NSString * docPasswordPath = docModel.docPasswordPath;
                if (docPasswordPath.length>0) {
                    [TOPWHCFileManager top_removeItemAtPath:docPasswordPath];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [TOPScanerShare top_writeDocPasswordSave:@""];
            self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
            [self.tableView reloadData];
        });
    });
}
#pragma mark -- 设置 DocManagement
- (void)top_didSelectedSettingDocAction:(NSInteger)index {
    TOPSettingModel *model = self.docManagementArray[index];
    TOPSettingVCAction actionType = model.settingAction;
    switch (actionType) {
        case TOPSettingVCActionDocManagementName:
            [self top_settingView_AddDocManagementView];
            break;
        case TOPSettingVCActionDocManagementFileSize:
            [self top_settingView_AddUserDefinedFileSizeView];
            break;
        case TOPSettingVCActionDocManagementAutoSave:
        case TOPSettingVCActionDocManagementSaveOriginalPic:
        case TOPSettingVCActionDocManagementCropImgAutomatic:
            [self top_settingView_SaveToGalleryModel:index];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        default:
            break;
    }
}
#pragma mark -- document默认名称
- (void)top_settingView_AddDocManagementView{
    TOPSettingDocNameVC * docNameVC = [TOPSettingDocNameVC new];
    docNameVC.top_backAction = ^(NSString * _Nonnull formatString) {
        if (formatString.length>0) {
            for (TOPSettingModel * docModel in self.docManagementArray) {
                if (docModel.settingAction == TOPSettingVCActionDocManagementName) {
                    docModel.myContent = [TOPDocumentHelper top_getCurrentFormatterTime:formatString];
                    [self.tableView reloadData];
                    break;
                }
            }
        }
    };
    docNameVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:docNameVC animated:YES];
}
#pragma mark -- 设置文件大小弹窗
- (void)top_settingView_AddUserDefinedFileSizeView{
    [FIRAnalytics logEventWithName:@"settingView_DefinedFileSizeView" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.userDefinedsizeView];
    [self.userDefinedsizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.userDefinedsizeView.alpha = 1;
    }];
}
#pragma mark -- 隐藏设置文件大小弹窗
- (void)top_hiddenUserDefinedFileSizeView {
    [UIView animateWithDuration:0.3 animations:^{
        self.userDefinedsizeView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.userDefinedsizeView removeFromSuperview];
        self.userDefinedsizeView = nil;
    }];
}
#pragma mark -- reload filesize cell
- (void)top_reloadFileSizeCell {
    for (TOPSettingModel * docModel in self.docManagementArray) {
        if (docModel.settingAction == TOPSettingVCActionDocManagementFileSize) {
            docModel.myContent = [NSString stringWithFormat:@"%@ %ld%%",NSLocalizedString(@"topscan_compressionration", @""),(long)[TOPScanerShare top_userDefinedFileSize]];
            [self.tableView reloadData];
            break;
        }
    }
}
#pragma mark -- 保存到Gallery文件夹的默认设置
- (void)top_settingView_SaveToGalleryModel:(NSInteger)index {
    [FIRAnalytics logEventWithName:@"top_settingView_SaveToGalleryModel" parameters:nil];
    TOPSettingModel *model = self.docManagementArray[index];
    TOPSettingVCAction actionType = model.settingAction;
    if (actionType == TOPSettingVCActionDocManagementAutoSave) {
        if ([TOPScanerShare top_saveToGallery] == TOPSettingSaveNO) {
            [TOPScanerShare top_writeSaveToGallery:TOPSettingSaveYES];
        }else{
            [TOPScanerShare top_writeSaveToGallery:TOPSettingSaveNO];
        }
    } else if (actionType == TOPSettingVCActionDocManagementSaveOriginalPic) {
        if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveNO) {
            [TOPScanerShare top_writeSaveOriginalImage:TOPSettingSaveYES];
        }else{
            [TOPScanerShare top_writeSaveOriginalImage:TOPSettingSaveNO];
        }
    }else if (actionType == TOPSettingVCActionDocManagementCropImgAutomatic){
        if ([TOPScanerShare top_saveBatchImage] == TOPSettingSaveNO) {
            [TOPScanerShare top_writeSaveBatchImage:TOPSettingSaveYES];
        }else{
            [TOPScanerShare top_writeSaveBatchImage:TOPSettingSaveNO];
        }
    }
}
- (void)top_settingView_ClickTap{
    [FIRAnalytics logEventWithName:@"settingView_ClickTap" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
        self.showFormatterView.frame = CGRectMake(0,TOPScreenHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-FormatterView_Y+10);
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        [self.showFormatterView removeFromSuperview];
        
        self.backView = nil;
        self.showFormatterView = nil;
    }];
}
- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_settingView_ClickTap)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}
#pragma mark -- lazy
#pragma mark -- 自定义文件大小弹窗
- (TOPUserDefinedSizeView *)userDefinedsizeView {
    __weak typeof(self) weakSelf = self;
    if (!_userDefinedsizeView) {
        _userDefinedsizeView = [[TOPUserDefinedSizeView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _userDefinedsizeView.percentValue = [TOPScanerShare top_userDefinedFileSize];
        _userDefinedsizeView.alpha = 0;
        _userDefinedsizeView.top_clickCancelBtnBlock = ^{
            [weakSelf top_hiddenUserDefinedFileSizeView];
        };
        _userDefinedsizeView.top_clickResultBtnBlock = ^(NSInteger percentVal) {
            [TOPScanerShare top_writeUserDefinedFileSizePercent:percentVal];
            [weakSelf top_reloadFileSizeCell];
            [weakSelf top_hiddenUserDefinedFileSizeView];
        };
    }
    return _userDefinedsizeView;
}

#pragma mark -- 文件名称弹窗
- (TOPNextSettingShowView *)showFormatterView{
    WS(weakSelf);
    if (!_showFormatterView) {
        _showFormatterView = [[TOPNextSettingShowView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-FormatterView_Y+10)];
        _showFormatterView.enterType = TOPFormatterViewEnterTypeSetting;
        _showFormatterView.top_clickToDismiss = ^{
            [weakSelf top_settingView_ClickTap];
        };
        
        _showFormatterView.top_clickCell = ^(NSString * _Nonnull formatString) {
            for (TOPSettingModel * docModel in weakSelf.docManagementArray) {
                if (docModel.settingAction == TOPSettingVCActionDocManagementName) {
                    docModel.myContent = [TOPDocumentHelper top_getCurrentFormatterTime:formatString];
                    [weakSelf.tableView reloadData];
                    [weakSelf top_settingView_ClickTap];
                    break;
                }
            }
        };
    }
    return _showFormatterView;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolderSingle_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType ,BOOL isShowFailToast) {
            weakSelf.isShowFailToast = isShowFailToast;
            [weakSelf top_passwordViewActionWithPassword:password WithType:actionType];
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf top_clickTapAction];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPHomeMoreFunctionUnLock:
            [self top_safe_SetTurnOffLock:password];
            break;
        case TOPHomeMoreFunctionSetLockFirst:
            [self top_safe_SetTurnOnLock:password];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self top_safe_SetChangeLock:password];
            break;
        case TOPHomeMoreFunctionPDFChangeLock:
            [self top_safe_SetChangePDFLock:password];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_safe_SetTurnOnPDFLock:password];
            break;
        default:
            break;
    }
}
#pragma mark -- 关闭doc密码功能
- (void)top_safe_SetTurnOffLock:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //所有的doc文档 清除里面的密码文件夹
            NSMutableArray  * docArray = [TOPDataModelHandler top_buildSearchDataAtPath:[TOPDocumentHelper top_appBoxDirectory]];
            for (DocumentModel * docModel in docArray) {
                if ([docModel.type isEqualToString:@"1"]) {
                    NSString * docPasswordPath = docModel.docPasswordPath;
                    if (docPasswordPath.length>0) {
                        [TOPWHCFileManager top_removeItemAtPath:docPasswordPath];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //清空本地保存的密码
                [TOPScanerShare top_writeDocPasswordSave:@""];
                self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
                [self.tableView reloadData];
            });
        });
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 开启doc密码功能
- (void)top_safe_SetTurnOnLock:(NSString *)password{
    [self top_clickTapAction];
    self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_colletiondocpasswordtitle", @"") stringByAppendingString:@":"],password]];
    [TOPScanerShare top_writeDocPasswordSave:password];
    [self.tableView reloadData];
}

#pragma mark -- 更改doc密码功能
- (void)top_safe_SetChangeLock:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        [self top_addPasswordView];
        self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 开启PDF密码功能
- (void)top_safe_SetTurnOnPDFLock:(NSString *)password{
    [self top_clickTapAction];
    self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"],password]];
    [TOPScanerShare top_writePDFPassword:password];
    [self.tableView reloadData];
}

#pragma mark -- 更改PDF密码功能
- (void)top_safe_SetChangePDFLock:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_pdfPassword]]) {
        [self top_clickTapAction];
        [self top_addPasswordView];
        self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
    }else{
        [self top_writePasswordFail];
    }
}
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}
- (void)top_clickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self.passwordView removeFromSuperview];
        [self.coverView removeFromSuperview];
        self.passwordView = nil;
        self.coverView = nil;
    }];
}

#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    if (self.passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            if (self.passwordView.actionType == TOPHomeMoreFunctionSetLockFirst || self.passwordView.actionType == TOPHomeMoreFunctionPDFPassword) {
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
            }else{
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolderSingle_H, AddFolder_W, AddFolderSingle_H);
            }
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
        [self top_clickTapAction];
    }
}

#pragma mark -- 关闭doc密码视图
- (void)top_clickToTurnOffPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionUnLock;
}

#pragma mark -- 开启doc密码视图
- (void)top_clickToTurnOnPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
}

#pragma mark --修改doc密码视图
- (void)top_clickToChangePassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionSetLock;
}

#pragma mark -- 关闭pdf密码
- (void)top_clickToTurnOffPDFPassword{
    [TOPScanerShare top_writePDFPassword:@""];
    self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
    [self.tableView reloadData];
}

#pragma mark -- 开启pdf密码视图
- (void)top_clickToTurnOnPDFPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
}

#pragma mark --修改pdf密码视图
- (void)top_clickToChangePDFPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionPDFChangeLock;

}
- (void)top_addPasswordView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [keyWindow addSubview:self.passwordView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
#pragma mark -- Send feedback
- (void)top_settingView_SendFeedback{
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
                                                                       message:NSLocalizedString(@"topscan_bindcontent", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
          
        }];
        [alert addAction:okAction];

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    MFMailComposeViewController * mailCompose = [[MFMailComposeViewController alloc]init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setSubject:NSLocalizedString(@"topscan_passwordhelpsubject", @"")];
    NSArray * toRecipients = [NSArray arrayWithObjects:SimplescannerEmail,nil];
    [mailCompose setToRecipients:toRecipients];
    
    NSString *emailBody = [NSString stringWithFormat:@"Model:%@\n %@\n App:%@",[TOPAppTools deviceVersion],[TOPAppTools SystemVersion],[TOPAppTools getAppVersion]];


    [mailCompose setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailCompose animated:YES completion:^{
           
    }];
}
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString * msg ;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"取消发送邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"保存邮件成功";
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
            msg = @"保存或者发送邮件失败";
            break;
        default:
            msg = @"66666";
            break;
    }
    NSLog(@"msg===%@",msg);
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPScanSettingCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanSettingCell class])];
        [_tableView registerClass:[TOPScanSettingSaveCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanSettingSaveCell class])];
        [_tableView registerClass:[TOPScanSettingAutoCropCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanSettingAutoCropCell class])];
        
        [self.tableView registerClass:[TOPAppSafeItemTableViewCell class] forCellReuseIdentifier:@"AppSafeItemIdentifier"];
        [self.tableView registerNib:[UINib nibWithNibName:@"TOPSwithBackTapTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingSaveCellIdentifier"];
    }
    return _tableView;
}

- (NSMutableArray *)docManagementArray{
    if (!_docManagementArray) {
        _docManagementArray = [NSMutableArray new];
    }
    return _docManagementArray;
}

- (void)top_loadData{
    self.formatModel = [TOPSettingFormatModel new];
    self.formatModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingFormatter_Path];
    NSDictionary *dic1 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCActionDocManagementName),
                           @"title":NSLocalizedString(@"topscan_documentname", @""),
                           @"content":[TOPDocumentHelper top_getCurrentFormatterTime:self.formatModel.formatString]};
    NSDictionary *dic2 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCActionDocManagementFileSize),
                           @"title":NSLocalizedString(@"topscan_userdefinedsize", @""),
                           @"content":[NSString stringWithFormat:@"%@ %ld%%",NSLocalizedString(@"topscan_compressionration", @""),(long)[TOPScanerShare top_userDefinedFileSize]]};
    NSDictionary *dic3 = @{@"checkValue":@(TOPSettingCellTypeSecondKind),
                           @"settingAction":@(TOPSettingVCActionDocManagementAutoSave),
                           @"title":NSLocalizedString(@"topscan_autosavetogallery", @""),
                           @"content":NSLocalizedString(@"topscan_savetogallerytip", @"")};
    NSDictionary *dic4 = @{@"checkValue":@(TOPSettingCellTypeSecondKind),
                           @"settingAction":@(TOPSettingVCActionDocManagementSaveOriginalPic),
                           @"title":NSLocalizedString(@"topscan_saveoriginalimage", @""),
                          @"content":NSLocalizedString(@"topscan_saveoriginalimagetip", @"")};
    NSDictionary *dic5 = @{@"checkValue":@(TOPSettingCellTypeThirdKind),
                           @"settingAction":@(TOPSettingVCActionDocManagementCropImgAutomatic),
                           @"title":NSLocalizedString(@"topscan_cropautomatic", @""),
                           @"content":NSLocalizedString(@"topscan_cropautomatictip", @"")};
    NSArray *docSettingObjs = @[dic1,
                                dic2,
                                dic3,
                                dic4,
                                dic5];
    for (NSDictionary *dic in docSettingObjs) {
        TOPSettingModel * docModel = [self top_buildSettingModel:dic];
        [self.docManagementArray addObject:docModel];
    }
    
    BOOL isAppSafeState = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    NSInteger currentType = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
    if (isAppSafeState &&currentType==TOPAppSetSafeUnlockTypePwd) {
        self.sectionArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_docaccesspassword", @""),NSLocalizedString(@"topscan_pdfpassword", @"")]];
        self.sectionSubTitleArrays =  [NSMutableArray arrayWithArray:@[ NSLocalizedString(@"topscan_docheadingtitle", @""),NSLocalizedString(@"topscan_pdfheadingtitle", @"")]];
    }else{
        self.sectionArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_docaccesspassword", @""),NSLocalizedString(@"topscan_pdfpassword", @"")]];
        self.sectionSubTitleArrays =  [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_docheadingtitle", @""),NSLocalizedString(@"topscan_pdfheadingtitle", @"")]];
    }
    
    if ([TOPScanerShare top_docPassword].length>0) {
        self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    }else{
        self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
    }
    if ([TOPScanerShare top_pdfPassword].length>0) {
        self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    }else{
        self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
    }
}

- (TOPSettingModel *)top_buildSettingModel:(NSDictionary *)dic {
    TOPSettingModel * docModel = [[TOPSettingModel alloc] init];
    docModel.myTitle = dic[@"title"];
    docModel.myContent = dic[@"content"];
    docModel.checkValue = [dic[@"checkValue"] integerValue];
    docModel.settingAction = [dic[@"settingAction"] integerValue];
    return docModel;
}

- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

@end
