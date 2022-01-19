#define AddFolder_W 310
#define AddFolder_H 190
#import "TOPFunctionColletionListVC.h"
#import "TOPFunctionColletionListCell.h"
#import "TOPListFolderTableViewCell.h"
#import "TOPListTableViewTagsCell.h"
#import "TOPListTableViewCell.h"
#import "TOPShowLongImageViewController.h"
#import "TOPHomeChildBatchViewController.h"
#import "TOPSetTagViewController.h"
#import "TOPEditPDFViewController.h"
#import "TOPHomeChildViewController.h"
#import "TOPDocPasswordView.h"
#import "TOPTextField.h"
@interface TOPFunctionColletionListVC ()<UITableViewDelegate,UITableViewDataSource,UIDocumentPickerDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong)UIView * coverView;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray * allFileArray;
@property (nonatomic, strong)DocumentModel * selectDocModel;
@property (nonatomic, strong)TOPDocPasswordView * passwordView;
@property (nonatomic, assign)BOOL isShowFailToast;
@end

@implementation TOPFunctionColletionListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [TOPScanerShare shared].isRefresh = NO;
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    self.title = self.selectModel.titleString;
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_setupUI];
    [self top_loadData];
}

- (void)top_setupUI{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 40)];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 250, 40)];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(153, 153, 153, 1.0)];
    titleLab.textAlignment = NSTextAlignmentNatural;
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.text = NSLocalizedString(@"topscan_colletionfunctiontitle", @"");
    
    [self.view addSubview:headerView];
    [headerView addSubview:titleLab];
    [self.view addSubview:self.tableView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView).offset(15);
        make.top.bottom.equalTo(headerView);
        make.width.mas_equalTo(250);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(headerView.mas_bottom);
    }];
}

#pragma mark -- 刷新列表数据
- (void)top_loadData{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    if (self.folderPath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TOPAPPFolder *appfld = [TOPDBQueryService top_appFolderById:self.docModel.docId];
            appfld.filePath = self.folderPath;
            NSMutableArray *dataArray = [TOPDBDataHandler top_buildFolderSecondaryDataWithDB:appfld];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                self.allFileArray = dataArray;
                [self.tableView reloadData];
                [TOPScanerShare shared].isRefresh = NO;
            });
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *dataArray = [TOPDBDataHandler top_buildHomeDataWithDB];//[TOPDataModelHandler buildHomeData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                self.allFileArray = dataArray;
                [self.tableView reloadData];
                [TOPScanerShare shared].isRefresh = NO;
            });
        });
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    if ([TOPScanerShare shared].isRefresh) {
        [self top_loadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    if (self.passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
        [self top_clickTapAction];
    }
}
#pragma mark -- 隐藏视图
- (void)top_clickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self.passwordView removeFromSuperview];
        [self.coverView removeFromSuperview];
        self.passwordView = nil;
        self.coverView = nil;
    }];
}
- (void)top_backHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allFileArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        TOPFunctionColletionListCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPFunctionColletionListCell class]) forIndexPath:indexPath];
        cell.folderPath = self.folderPath;
        cell.lineView.hidden = YES;
        return cell;
    }else{
        DocumentModel *model = self.allFileArray[indexPath.row-1];
        if ([model.type isEqualToString:@"0"]) {
            TOPListFolderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListFolderTableViewCell class]) forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }else{
            if (model.tagsArray.count>0) {
                TOPListTableViewTagsCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewTagsCell class]) forIndexPath:indexPath];
                cell.model = model;
                return cell;
            }else{
                TOPListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewCell class]) forIndexPath:indexPath];
                cell.model = model;
                return cell;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if (self.folderPath.length == 0) {
            return 60;
        }else{
            return 0;
        }
    }else{
        DocumentModel *model = self.allFileArray[indexPath.row-1];
        if ([model.type isEqualToString:@"0"]) {
            return 50;
        }else{
            return 110;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        self.selectDocModel = nil;
        [self top_clickCellAndJupIcloud];
    }else{
        DocumentModel *model = self.allFileArray[indexPath.row-1];
        self.selectDocModel = model;
        [self top_clickCellAndPushVC];
    }
}

#pragma mark -- 点击cell跳转到其他界面
- (void)top_clickCellAndPushVC{
    if ([self.selectDocModel.type isEqualToString:@"0"]) {
        TOPFunctionColletionListVC * listVC = [TOPFunctionColletionListVC new];
        listVC.folderPath = self.selectDocModel.path;
        listVC.selectModel = self.selectModel;
        listVC.docModel = self.selectDocModel;
        listVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listVC animated:YES];
    }else{
        [self top_judgeClickDocPasswordState];
    }
}

#pragma mark -- 点击cell跳转到icloud
- (void)top_clickCellAndJupIcloud{
    [FIRAnalytics logEventWithName:@"FunctionList_pdfToLongPictureIcloud" parameters:nil];
    NSArray *documentTypes = @[@"com.adobe.pdf"];
    [self top_getIcouldView:documentTypes];
}

#pragma mark -- 点击doc文档时有无密码的判断
- (void)top_judgeClickDocPasswordState{
    NSString * passwordPath = self.selectDocModel.docPasswordPath;
    if (passwordPath.length>0) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [keyWindow addSubview:self.passwordView];
        self.passwordView.actionType = TOPMenuItemsFunctionPushVC;
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(keyWindow);
        }];
    }else{
        [self top_icloudFinishAndPushWithPath:self.selectDocModel.path];
    }
}

#pragma mark -- 密码匹配
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    [FIRAnalytics logEventWithName:@"home_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        [self top_icloudFinishAndPushWithPath:self.selectDocModel.path];
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 密码不正确的提示
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}

#pragma mark -- 显示icloud界面
- (void)top_getIcouldView:(NSArray *)typeArray{
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:typeArray inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark -- UIDocumentPickerDelegate
#pragma mark- iCloud Drive
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(nonnull NSArray<NSURL *> *)urls {
    WS(weakSelf);
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init]; NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            if (error) {
                NSLog(@"读取错误error == %@",error);
            }else {
                NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
                if ([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"]) {
                    CGPDFDocumentRef fromPDFDoc = CGPDFDocumentCreateWithURL((CFURLRef)newURL);
                    if (fromPDFDoc == NULL) {
                        NSLog(@"can't open '%@'", newURL); CFRelease((__bridge CFURLRef)newURL);
                    }else{
                        NSString * sendName = [NSString new];
                        if ([fileName hasSuffix:@".pdf"]) {
                            sendName = [[fileName componentsSeparatedByString:@".pdf"] firstObject];
                        }else{
                            sendName = [[fileName componentsSeparatedByString:@".PDF"] firstObject];
                        }
                        [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_decryption", @"") alertMessage:@"pdf" fileName:sendName];
                    }
                }
                NSString * lowString = fileName.lowercaseString;
                if ([lowString hasSuffix:@".jpg"] || [lowString hasSuffix:@".png"]|| [lowString hasSuffix:@".jpeg"]) {
                    UIImage *photo = [UIImage imageWithData:fileData];
                    if (photo) {
                        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
                        [weakSelf top_writeImageDataToDocument:photo withIndex:0 withPath:endPath];
                        [weakSelf top_icloudFinishAndPushWithPath:endPath];
                    }
                }
            }
        }];
    }
}

- (void)top_dealWithPDF:(CGPDFDocumentRef)fromPDFDoc withPath:(NSURL *)newURL alertTitle:(NSString *)title alertMessage:(NSString *)message fileName:(NSString *)fileName{
    if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {
        WS(weakSelf);
        if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {
            TOPSCAlertController *alert = [TOPSCAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alert) weakAlert = alert;
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                __strong typeof(weakAlert) strongAlert = weakAlert;

                UITextField *  textField=   strongAlert.textFields.firstObject;
                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (textField.text != NULL && CGPDFDocumentUnlockWithPassword (fromPDFDoc, [textField.text UTF8String])) {
                    [weakSelf top_pushSendControllerMothodWithPassword:textField.text withPath:fromPDFDoc fileName:fileName];
                }else{
                    [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_error", @"") alertMessage:NSLocalizedString(@"topscan_pdferror", @"") fileName:fileName];
                }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                return;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"topscan_placeholderpassword", @"");
            }];
            [alert addAction:cancelAction];
            
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{
        [self top_pushSendControllerMothodWithPassword:nil withPath:fromPDFDoc fileName:fileName];
    }
}
 
#pragma mark -- 倒入pdf的处理
- (void)top_pushSendControllerMothodWithPassword:(NSString *)passwordStr withPath:(CGPDFDocumentRef)fromPDFDoc fileName:(NSString *)fileName{
    NSString * endPath = [NSString new];
    if (fileName.length>0) {
        NSString *filePath = [[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:fileName];
        endPath = [TOPDocumentHelper top_createDirectoryAtPath:filePath];
    }else{
        endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    }
    WS(weakSelf);
    [[TOPProgressStripeView shareInstance]top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    [TOPDocumentHelper top_getUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:passwordStr docPath:endPath  progress:^(CGFloat progressString) {
        //拆分成pdf的进度条
        [[TOPProgressStripeView shareInstance]top_showProgress:progressString withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    } success:^(id  _Nonnull responseObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [weakSelf top_icloudFinishAndPushWithPath:endPath];
        });
    }];
}

#pragma mark -- icloud图片写入doc文件夹
- (void)top_writeImageDataToDocument:(UIImage *)image withIndex:(NSInteger)index withPath:(NSString *)endPath{
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [endPath stringByAppendingPathComponent:imgName];
    NSString *oriEndPath = [endPath stringByAppendingPathComponent:oriName];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:fileEndPath atomically:YES];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
}

#pragma mark -- icloud处理完成之后的跳转
- (void)top_icloudFinishAndPushWithPath:(NSString *)endPath{
    switch (self.selectModel.functionType) {
        case TopFunctionTypePDFToLongPicture:
            [FIRAnalytics logEventWithName:@"FunctionList_pdfToLongPicture" parameters:nil];
            [self top_pdfExportToLongPictureWithPath:endPath];
            break;
        case TopFunctionTypePDFPassword:
            [FIRAnalytics logEventWithName:@"FunctionList_pdfSetPassword" parameters:nil];
            [self top_pdfSetPasswordWithPath:endPath];
            break;
        case TopFunctionTypeBatchEdit:
            [FIRAnalytics logEventWithName:@"FunctionList_batchEditAction" parameters:nil];
            [self top_batchEditActionWithPath:endPath];
            break;
        case TopFunctionTypePDFAddWatermark:
            [FIRAnalytics logEventWithName:@"FunctionList_pdfAddWatermark" parameters:nil];
            [self top_pdfAddWatermarkWithPath:endPath];
            break;
        case TopFunctionTypePDFExtract:
            [FIRAnalytics logEventWithName:@"FunctionList_pdfExtract" parameters:nil];
            [self top_pdfExtractWithPath:endPath];
            break;
        case TopFunctionTypeSetTags:
            [FIRAnalytics logEventWithName:@"FunctionList_documnentSetTags" parameters:nil];
            [self top_documnentSetTagsWithPath:endPath];
            break;
        case TopFunctionTypePDFSignature:
            [FIRAnalytics logEventWithName:@"FunctionList_pdfSignatureAction" parameters:nil];
            [self top_pdfSignatureActionWithPath:endPath];
            break;
        case TopFunctionTypeDocPassword:
            [FIRAnalytics logEventWithName:@"FunctionList_documentSetPassword" parameters:nil];
            [self top_documentSetPasswordWithPath:endPath];
            break;
        case TopFunctionTypePDFPageAdjustment:
            [FIRAnalytics logEventWithName:@"FunctionList_PDFPageAdjustment" parameters:nil];
            [self top_pdfPageAdjustment:endPath];
            break;
        case TopFunctionTypeImageToPDF:
            [FIRAnalytics logEventWithName:@"FunctionList_ImageToPDF" parameters:nil];
            [self top_imageToPDF:endPath];
            break;
        case TopFunctionTypeOCR:
            [FIRAnalytics logEventWithName:@"FunctionList_OCR" parameters:nil];
            [self top_functionToOCR:endPath];
            break;
        default:
            break;
    }
}

#pragma mark -- pdf转长图
- (void)top_pdfExportToLongPictureWithPath:(NSString *)endPath{
    WS(weakSelf);
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DocumentModel * model = [DocumentModel new];
        if (self.selectDocModel) {
            model = self.selectDocModel;
        }else{
            model = [TOPDataModelHandler top_buildDocumentTargetModelWithPath:endPath];
        }
        NSArray * tempArray = @[model];
        NSArray *imgArray = [TOPDataModelHandler top_selectedImageArray:tempArray];
        UIImage *resultImg = [TOPPictureProcessTool top_mergedImages:imgArray];
        NSString *showPath = [TOPDocumentHelper top_longImageFileString];
        [TOPDocumentHelper top_saveImage:resultImg atPath:showPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            TOPShowLongImageViewController * longImgVC = [TOPShowLongImageViewController new];
            longImgVC.showPath = showPath;
            longImgVC.pathString = [TOPDocumentHelper top_getDocumentsPathString];
            longImgVC.hidesBottomBarWhenPushed = YES;
            longImgVC.top_bankAndReloadData = ^{
                if (!weakSelf.selectDocModel) {
                    [weakSelf top_loadData];
                }
            };
            longImgVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:longImgVC animated:YES];
        });
    });
}

#pragma mark -- 批量处理
- (void)top_batchEditActionWithPath:(NSString *)endPath{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:self.selectDocModel.docId];
        appDoc.filePath = endPath;
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildDocumentDataWithDB:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            TOPHomeChildBatchViewController * batchVC = [TOPHomeChildBatchViewController new];
            batchVC.dataArray = dataArray;
            batchVC.isAllData = YES;
            batchVC.childVCPath = endPath;
            batchVC.isCollectionBox = YES;
            if (!self.selectDocModel) {
                batchVC.addType = @"add";
            }
            batchVC.top_dataChangeAndLoadData = ^{
                [weakSelf top_loadData];
            };
            batchVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:batchVC animated:YES];
        });
    });
}

#pragma mark -- 文档设置标签
- (void)top_documnentSetTagsWithPath:(NSString *)endPath{
    WS(weakSelf);
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableArray * selectArray = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DocumentModel * model = [DocumentModel new];
        if (self.selectDocModel) {
            model = self.selectDocModel;
        }else{
            model = [TOPDataModelHandler top_buildDocumentTargetModelWithPath:endPath];
        }
        [selectArray addObject:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            TOPSetTagViewController * tagVC = [[TOPSetTagViewController alloc]init];
            tagVC.dataArray = selectArray;
            tagVC.top_saveFinishAction = ^{
                [weakSelf top_loadData];
            };
            tagVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:tagVC animated:YES];
        });
    });
}
#pragma mark -- doc文档设置密码
- (void)top_documentSetPasswordWithPath:(NSString *)endPath{
    [self top_pushChildVCWithPath:endPath];
}
#pragma mark -- pdf设置密码
- (void)top_pdfSetPasswordWithPath:(NSString *)endPath{
    [self top_pushPDFEditVCWithPath:endPath];
}

#pragma mark -- pdf加水印
- (void)top_pdfAddWatermarkWithPath:(NSString *)endPath{
    [self top_pushPDFEditVCWithPath:endPath];
}

#pragma mark -- pdf添加签名
- (void)top_pdfSignatureActionWithPath:(NSString *)endPath{
    [self top_pushPDFEditVCWithPath:endPath];
}

#pragma mark -- 提取文档
- (void)top_pdfExtractWithPath:(NSString *)endPath{
    [self top_pushChildVCWithPath:endPath];
}
#pragma mark -- pdf Page Adjustment
- (void)top_pdfPageAdjustment:(NSString *)endPath{
    [TOPScanerShare top_writepdfPageAdjustmentBottomViewShow:YES];
    [self top_pushChildVCWithPath:endPath];
}
#pragma mark -- image To PDF
- (void)top_imageToPDF:(NSString *)endPath{
    
}
#pragma mark -- OCR
- (void)top_functionToOCR:(NSString *)endPath{
    
}
#pragma mark -- 跳转到pdfEdit界面
- (void)top_pushPDFEditVCWithPath:(NSString *)endPath{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentByPath:endPath];
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildDocumentDataWithDB:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
            pdfVC.docModel = self.selectDocModel;
            pdfVC.filePath = endPath;
            pdfVC.imagePathArr = [self top_selectImages:dataArray];
            if (!self.selectDocModel) {
                pdfVC.backRefresh = YES;
            }
            pdfVC.selectModel = self.selectModel;
            pdfVC.top_backBtnAction = ^{
                [weakSelf top_loadData];
            };
            pdfVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:pdfVC animated:YES];
        });
    });
}

#pragma mark -- 跳转到childVC界面
- (void)top_pushChildVCWithPath:(NSString *)endPath{
    WS(weakSelf);
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    if (self.selectDocModel) {
        childVC.docModel = self.selectDocModel;
    } else {
        childVC.docModel = [TOPDBDataHandler top_addNewDocModel:endPath];
    }
    childVC.pathString = endPath;
    if (self.folderPath) {
        childVC.upperPathString = self.folderPath;
    }else{
        childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    }
    if (!self.selectDocModel) {
        childVC.backRefresh = YES;
        childVC.addType = @"add";
        childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    }
    childVC.selectBoxModel = self.selectModel;
    childVC.top_backBtnAction = ^{
        [weakSelf top_loadData];
    };
    childVC.top_pdfExtractAction = ^(NSString * _Nonnull endPath, NSString * _Nonnull upperPathString) {
        TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:weakSelf.selectDocModel.docId];
        TOPAppDocument *newDoc = [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:doc.parentId];
        DocumentModel *model = [TOPDBDataHandler top_buildDocumentModelWithData:newDoc];
        TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
        childVC.docModel = model;
        childVC.pathString = endPath;
        childVC.upperPathString = upperPathString;
        childVC.addType = @"add";
        childVC.backType = TOPHomeChildViewControllerBackTypePopCollList;
        childVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:childVC animated:NO];
    };
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}
#pragma mark -- 图片模型的图片名称
- (NSArray *)top_selectImages:(NSMutableArray *)picModelArray{
    NSMutableArray *imgs = @[].mutableCopy;
    for (DocumentModel *model in picModelArray) {
        [imgs addObject:model.photoName];
    }
    return [NSArray arrayWithArray:imgs];
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
#pragma mark -- lazy
- (NSMutableArray *)allFileArray{
    if (!_allFileArray) {
        _allFileArray = [NSMutableArray new];
    }
    return _allFileArray;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-40) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPFunctionColletionListCell class] forCellReuseIdentifier:NSStringFromClass([TOPFunctionColletionListCell class])];
        [_tableView registerClass:[TOPListFolderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListFolderTableViewCell class])];
        [_tableView registerClass:[TOPListTableViewTagsCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewTagsCell class])];
        [_tableView registerClass:[TOPListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewCell class])];
    }
    return _tableView;
}

#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType,BOOL isShowFailToast) {
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

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

@end
