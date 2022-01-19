#import "TOPShareDownSizeView.h"
#import "TOPShareDownSizeCell.h"
#import "TOPShareCancelCell.h"
#define Space 10
#define DefaultSize (1024*1024)*10.0

@interface TOPShareDownSizeView()<UITableViewDelegate, UITableViewDataSource>
/** 头部视图 */
@property (nonatomic, strong) UIView *headView;

/** 背景蒙层 */
@property (nonatomic, strong) UIView *maskView;

/** 数组元素 */
@property (nonatomic, strong) NSArray *dataSource;

/** 取消文字 */
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, assign) BOOL isSVPShow;//当选择的文档包含folder时 进度条用SVP的
@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, copy) void(^selectBlock)(NSMutableArray * shareArray);
@property (nonatomic, assign) BOOL isFinish;//防止视图消失的时候走方法layoutSubviews时又调取了一次showView方法
@end
@implementation TOPShareDownSizeView
- (instancetype)initWithTitleView:(UIView *)titleView
                       optionsArr:(NSArray *)optionsArr
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void (^)(void))cancelBlock
                      selectBlock:(void (^)(NSMutableArray * shareArray))selectBlock
{
    
    
    if (self = [super init]) {
        
        self.dataSource = [NSArray array];
        self.headView = titleView;
        self.dataSource = optionsArr;
        self.cancelTitle = cancelTitle;
        self.cancelBlock = cancelBlock;
        self.selectBlock = selectBlock;
        self.isFinish = NO;

        [self top_createUI];
        
    }
    return self;
    
}

- (instancetype)initWithTitleView:(UIView *)titleView
                       optionsArr:(NSArray *)optionsArr
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void (^)(void))cancelBlock
                  selectItemBlock:(void (^)(CGFloat))selectItemBlock {
    if (self = [super init]) {
        self.dataSource = [NSArray array];
        self.headView = titleView;
        self.dataSource = optionsArr;
        self.cancelTitle = cancelTitle;
        self.cancelBlock = cancelBlock;
        self.chooseShareType = selectItemBlock;
        [self top_createUI];
        
    }
    return self;
}

- (void)top_createUI{
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.maskView];
    [self addSubview:self.tableView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    if (IS_IPAD) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.dataSource.count+1)+2*Space);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(Space);
            make.top.equalTo(self.mas_bottom);
            make.trailing.equalTo(self).offset(-Space);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.dataSource.count+1)+2*Space);
        }];
    }
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.tableHeaderView = self.headView;
        _tableView.separatorInset = UIEdgeInsetsMake(0, -50, 0, 0);
        _tableView.layer.cornerRadius = 10;
        
        [_tableView registerClass:[TOPShareDownSizeCell class] forCellReuseIdentifier:NSStringFromClass([TOPShareDownSizeCell class])];
        [_tableView registerClass:[TOPShareCancelCell class] forCellReuseIdentifier:NSStringFromClass([TOPShareCancelCell class])];
    }
    return _tableView;
}

- (UIView *)headView
{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(Space, 0, self.width-2*Space, 50)];
        _headView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _headView.frame.size.width, 30)];
//        titleLabel.text = @"请选择类型";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_headView addSubview:titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height-0.5, _headView.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor grayColor];
        [_headView addSubview:lineView];
    }
    return _headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPShareDownSizeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPShareDownSizeCell class]) forIndexPath:indexPath];
        cell.row = indexPath.row;
        cell.dataSourceArray = [self.dataSource mutableCopy];
        if (indexPath.row == 0) {
            cell.numberLab.text = self.numberStr;
        }else if (indexPath.row == 1 ){
            cell.numberLab.text = [NSString stringWithFormat:@"70%%(%@ %@)",NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:(self.totalNum * 0.7)]];
        }else if (indexPath.row == 2 ){
            cell.numberLab.text = [NSString stringWithFormat:@"50%%(%@ %@)",NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:(self.totalNum * 0.5)]];
        }else if (indexPath.row == 3 ){
            NSInteger percentVal = [TOPScanerShare top_userDefinedFileSize];
            cell.numberLab.text = [NSString stringWithFormat:@"%ld%%(%@ %@)",(long)percentVal,NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:(self.totalNum * percentVal / 100.0)]];
        }
        return cell;
    }else{
        TOPShareCancelCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPShareCancelCell class]) forIndexPath:indexPath];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.dataSource.count : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(Space, 10, IPAD_CELLW-2*Space, Space)];
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return Space;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rate = 1.0;
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    if (freeSize<_totalNum/1024.0/1024.0+5) {//判定手机存储空间大小够不够
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
        [self top_dismissView];
        return;
    }
 
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            rate = 1.0;
            [FIRAnalytics logEventWithName:@"shareOriginalSize" parameters:nil];
        } else if (indexPath.row == 1){
            rate = 0.7;
            [FIRAnalytics logEventWithName:@"shareMediumSize" parameters:nil];

        }else if (indexPath.row == 2){
            rate = 0.5;
            [FIRAnalytics logEventWithName:@"shareSmallSize" parameters:nil];

        }else if (indexPath.row == 3){
            rate = [TOPScanerShare top_userDefinedFileSize]/100.0;
            [FIRAnalytics logEventWithName:@"shareUserDefinedSize" parameters:nil];
        }
        if (self.chooseShareType) {
            self.chooseShareType(rate);
        } else {
            if (rate == 1.0) {
                if (self.pdfPath !=nil) {//pdf已经存在 直接传递数据
                    [self top_pdfIsThereAction];
                }else{
                    [self top_processShowType];
                    [self top_originalSizeShare];//pdf不存在 需要生成
                }
            } else {
                [self top_processShowType];
                [self top_MediumSizeShare:rate];
            }
        }

        [self top_dismissView];
    }else{
        self.cancelBlock();
        [self top_dismissView];
    }
}

#pragma mark -- pdf已经存在了
- (void)top_pdfIsThereAction{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * shareArray = [NSMutableArray new];
        NSURL * file = [NSURL fileURLWithPath:self.pdfPath];
        if (file) {
            [shareArray addObject:file];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (self.selectBlock) {
                self.selectBlock(shareArray);
            };
        });
    });
}

- (void)top_processShowType{
    if (self.compressType == 0) {//合成pdf
        if (!self.isSVPShow) {//不包含folder类文件夹
            if (self.totalNum>DefaultSize) {//文件大小大于10M的情况
                if (self.dataArray.count>1) {
                    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(1-%@)",NSLocalizedString(@"topscan_processingdoc", @""),@(self.dataArray.count)]];
                }else{
                    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingdoc", @"")]];
                }
            }else{//文件大小小于10M的情况
                [SVProgressHUD show];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            }
        }else{
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        }
    }else{//图片处理提示
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.isFinish) {
        [self top_showView];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self top_dismissView];
}

- (void)top_showView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-(self.tableView.rowHeight*(self.dataSource.count+1)+2*Space+TOPBottomSafeHeight));
        }];
        self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.tableView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.isFinish = YES;
    }];
}

- (void)top_dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        self.maskView.alpha = 0;
        [self.tableView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
#pragma mark -- document下所有图片集合 并排序
- (NSArray *)top_documentAllPicPath:(NSString *)path{
    //Documents文件夹下的文件夹里的图片名称集合 及路径下的图片名称集合
    NSArray * documentArray = [TOPDocumentHelper top_getJPEGFile:path];
    NSArray * compareArray = [documentArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString * str1 = obj1;
        NSString * str2 = obj2;
        NSString * compareStr1 = [[str1 componentsSeparatedByString:@".jpg"][0] substringFromIndex:14];
        NSString * compareStr2 = [[str2 componentsSeparatedByString:@".jpg"][0] substringFromIndex:14];
        if ([compareStr1 integerValue]>[compareStr2 integerValue]) {
            if ([TOPScanerShare top_childViewByType] == 1) {
                return NSOrderedDescending;
            }else{
                return NSOrderedAscending;
            }
        }else if([compareStr1 integerValue]<[compareStr2 integerValue]){
            if ([TOPScanerShare top_childViewByType] == 1) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }else{
            return NSOrderedSame;
        }
    }];
    return compareArray;
}
#pragma mark -- folder文件夹下所有图片的集合
- (NSMutableArray *)top_folderOriginalpdfShare:(DocumentModel*)model index:(NSInteger)index{
    NSMutableArray * tempArray = [NSMutableArray new];

    NSMutableArray * documentArray = [NSMutableArray new];
    //folder下的Documents文件夹中的所有文件夹的路径，图片都是存放在documents文件夹中的文件夹里的
    NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
    //遍历出文件夹路径
    for (int j = 0; j<getArry.count; j++) {
        NSString * documentPath = getArry[j];
        DocumentModel * folderUnderModel = [DocumentModel new];
        folderUnderModel.name = [documentPath componentsSeparatedByString:@"/"].lastObject;
        NSArray * compareArray = [self top_documentAllPicPath:documentPath];

        NSMutableArray * imgArray = [NSMutableArray new];
        for (int i = 0; i<compareArray.count; i++) {
            NSString * picName = compareArray[i];
            //拼接成图片路径 文件夹路径+图片名称=图片路径
            NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
            UIImage * img = [UIImage imageWithContentsOfFile:picPath];
            if (img) {

                [imgArray addObject:img];
            }
        }
        folderUnderModel.docArray = [imgArray copy];
        [tempArray addObject:folderUnderModel];
    }
    return tempArray;
}
#pragma mark -- document文件夹下图片集合
- (NSMutableArray *)top_documentOriginalpdfShare:(DocumentModel*)model index:(NSInteger)index{
    DocumentModel * folderUnderModel = [DocumentModel new];
    folderUnderModel.name = model.name;
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * imgArray = [NSMutableArray new];
    NSArray * compareArray = [self top_documentAllPicPath:model.path];
    for (int i = 0; i<compareArray.count; i++) {
        NSString * pcStr = compareArray[i];
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
        UIImage * img = [UIImage imageWithContentsOfFile:fullPath];
        if (img) {
            [imgArray addObject:img];
            if (!self.isSVPShow) {
                if (self.totalNum>DefaultSize) {
                    if (self.dataArray.count>1) {
                        [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(compareArray.count*10.0) withStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_processingdoc", @""),@(index+1),@(self.dataArray.count)]];
                    }else{
                        [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(compareArray.count*10.0) withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingdoc", @"")]];
                    }
                }
            }
        }
    }
    folderUnderModel.docArray = [imgArray copy];
    [tempArray addObject:folderUnderModel];
    return tempArray;
}
#pragma mark -- childVC控制器图片pdf分享路径
- (NSString *)top_childOriginalpdfShare:(NSMutableArray *)array{
    //内部的pdf分享
    NSMutableArray * imgArray = [NSMutableArray new];
    NSMutableArray * selectArray = [NSMutableArray new];
    NSString * pdfName = [NSString new];
    for (int i = 0; i<array.count; i++) {
        DocumentModel * model = array[i];
        if (model.selectStatus) {
            //每个文件夹的图片集合
            UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
            if (img) {
                [imgArray addObject:img];
                if (self.totalNum>DefaultSize) {
                    [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(array.count*10.0) withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingdoc", @"")]];
                }
            }
            [selectArray addObject:model];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.totalNum>DefaultSize) {
            [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        }
    });
    
    if (selectArray.count == 1) {
        DocumentModel * model = selectArray[0];
        pdfName = [NSString stringWithFormat:@"%@_%@",model.fileName,model.name];
    }
    if (selectArray.count>1){
        DocumentModel * model = selectArray[0];
        pdfName = [NSString stringWithFormat:@"%@",model.fileName];
    }
    //合成pdf图片
    NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:pdfName progress:^(CGFloat myProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.totalNum>DefaultSize) {
                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
            }
        });
    }];
    return path;
}

#pragma mark -- folder文件夹下所有图片URL的集合
- (NSMutableArray *)top_folderOriginalImgShare:(DocumentModel*)model index:(NSInteger)index{
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * tempArray = [NSMutableArray new];
    //folder下的Documents文件夹中的所有文件夹的路径，图片都是存放在documents文件夹中的文件夹里的
    NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
    //遍历出文件夹路径
    for (NSString * documentPath in getArry) {
        NSArray * compareArray = [self top_documentAllPicPath:documentPath];
        for (int i = 0; i<compareArray.count; i++) {
            NSString * picName = compareArray[i];
            //拼接成图片路径 文件夹路径+图片名称=图片路径
            NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
            NSURL * file = [NSURL fileURLWithPath:picPath];
            if (file) {
                [tempArray addObject:file];
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }
        }
    }
    return tempArray;
}

#pragma mark -- document文件夹下图片URL集合
- (NSMutableArray *)top_documentOriginalImgShare:(DocumentModel*)model index:(NSInteger)index{
    NSArray * compareArray = [self top_documentAllPicPath:model.path];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<compareArray.count; i++) {
        NSString * pcStr = compareArray[i];
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
        NSURL * file = [NSURL fileURLWithPath:fullPath];
        if (file) {
            [tempArray addObject:file];
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }
    }
    return tempArray;
}

#pragma mark -- 分享时原图生成pdf分享和原图分享
- (void)top_originalSizeShare{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * shareArray = [NSMutableArray new];
        //pdf分享
        if (weakSelf.compressType == 0) {
            //先清空pdf文件夹里的内容
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            //folder文件夹界面的分享功能
            if (weakSelf.dataArray.count>0) {
                //一个文件夹合成一张pdf图 多个文件夹合成多张pdf图片
                NSMutableArray * allTempArray = [NSMutableArray new];//存放每个文档图片数组的数组 里面存放的是图片数组
                for (int i = 0; i<weakSelf.dataArray.count; i++) {
                    DocumentModel * model = weakSelf.dataArray[i];
                    //每个文件夹的图片集合
                    NSMutableArray * imgArray = [NSMutableArray new];
                    //在folder文件夹下 获取图片
                    if ([model.type isEqualToString:@"0"]) {

                        imgArray = [weakSelf top_folderOriginalpdfShare:model index:i];
                        [allTempArray addObjectsFromArray:imgArray];
                    }
                    
                    //是documents文件夹 直接就能获取
                    if ([model.type isEqualToString:@"1"]) {
                        imgArray = [weakSelf top_documentOriginalpdfShare:model index:i];
                        [allTempArray addObjectsFromArray:imgArray];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!weakSelf.isSVPShow) {
                        if (weakSelf.totalNum>DefaultSize) {
                            if (allTempArray.count>1) {
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@... (1-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.dataArray.count)]];
                            }else{
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                            }
                        }
                    }
                });
                
               //通过图片数组来生成pdf
                for (int j = 0; j<allTempArray.count; j++) {
                    if (j<allTempArray.count) {
                        DocumentModel * model = allTempArray[j];
                        NSMutableArray * imgArray = [model.docArray mutableCopy];
                        //合成pdf图片
                        NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:model.name progress:^(CGFloat myProgress) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!weakSelf.isSVPShow) {
                                    if (weakSelf.totalNum>DefaultSize) {
                                        if (allTempArray.count>1) {
                                            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@... (%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(j +1),@(weakSelf.dataArray.count)]];
                                        }else{
                                            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                                        }
                                    }
                                }
                            });
                        }];
                        NSURL * file = [NSURL fileURLWithPath:path];
                        if (file) {
                            [shareArray addObject:file];
                        }
                    }
                }
            }
            
            if (weakSelf.childArray.count>0) {
                NSString * path = [self top_childOriginalpdfShare:weakSelf.childArray];
                NSURL * file = [NSURL fileURLWithPath:path];
                if (file) {
                    [shareArray addObject:file];
                }
            }

        }else{
            [TOPWHCFileManager top_removeItemAtPath:TOPCompress_Path];
            if (weakSelf.dataArray.count>0) {
                shareArray =  [weakSelf top_HomeVCShare:1.0];
            }
            if (weakSelf.childArray.count>0) {
                shareArray =  [weakSelf top_childVCShare:1.0];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD dismiss];
            if (self.selectBlock) {
                self.selectBlock(shareArray);
            };
        });
    });
}

#pragma mark -- folder下的压缩图片
- (NSMutableArray *)top_folderMediumpdfShare:(DocumentModel*)model mediumsize:(CGFloat)max index:(NSInteger)index{
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
    //遍历出文件夹路径
    for (NSString * documentPath in getArry) {
        DocumentModel * folderUnderModel = [DocumentModel new];
        folderUnderModel.name = [documentPath componentsSeparatedByString:@"/"].lastObject;
        NSArray * compareArray = [self top_documentAllPicPath:documentPath];
        NSMutableArray * imgArray = [NSMutableArray new];
        for (int i = 0; i<compareArray.count; i++) {
            NSString * picName = compareArray[i];
            NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
            NSString * compressFile = [NSString new];
            if (compareArray.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:picPath maxCompression:max];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:picPath maxCompression:max];
            }
            if (compressFile.length) {
                if ([UIImage imageWithContentsOfFile:compressFile]) {
                    [imgArray addObject:[UIImage imageWithContentsOfFile:compressFile]];
                }
            }
        }
        folderUnderModel.docArray = [imgArray copy];
        [tempArray addObject:folderUnderModel];
    }
    return tempArray;
}

#pragma mark -- document下的压缩图片
- (NSMutableArray *)top_documentMediumpdfShare:(DocumentModel*)model mediumsize:(CGFloat)max index:(NSInteger)index{
    DocumentModel * folderUnderModel = [DocumentModel new];
    folderUnderModel.name = model.name;
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * imgArray = [NSMutableArray new];
    NSArray * compareArray = [self top_documentAllPicPath:model.path];
    for (int i = 0; i<compareArray.count; i++) {
        @autoreleasepool {
            NSString * pcStr = compareArray[i];
            NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
            NSString * compressFile = [NSString new];
            if (compareArray.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:fullPath maxCompression:max];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:fullPath maxCompression:max];
            }
            if (compressFile.length) {
                if ([UIImage imageWithContentsOfFile:compressFile]) {
                    [imgArray addObject:[UIImage imageWithContentsOfFile:compressFile]];
                    if (!self.isSVPShow) {
                        if (self.totalNum>DefaultSize) {
                            if (self.dataArray.count>1) {
                                [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(compareArray.count*10.0) withStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_processingdoc", @""),@(index+1),@(self.dataArray.count)]];
                            }else{
                                [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(compareArray.count*10.0) withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingdoc", @"")]];
                            }
                        }
                    }
                }
            }
        }
    }
    folderUnderModel.docArray = [imgArray copy];
    [tempArray addObject:folderUnderModel];
    return tempArray;
}
#pragma mark -- childVC控制器压缩图片pdf分享路径
- (NSString *)top_childMediumpdfShare:(NSMutableArray *)array mediumSize:(CGFloat)max{
    //内部的pdf分享 即docunment下的pdf分享
    NSMutableArray * imgArray = [NSMutableArray new];
    NSMutableArray * selectArray = [NSMutableArray new];
    NSString * pdfName = [NSString new];
    for (int i = 0; i<array.count; i++) {
        DocumentModel * model = array[i];
        if (model.selectStatus) {
            NSString * compressFile = [NSString new];
            if (array.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:model.imagePath maxCompression:max];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:model.imagePath maxCompression:max];
            }
            
            if (compressFile.length) {
                if ([UIImage imageWithContentsOfFile:compressFile]) {
                    [imgArray addObject:[UIImage imageWithContentsOfFile:compressFile]];
                    if (self.totalNum>DefaultSize) {
                        [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(array.count*10.0) withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingdoc", @"")]];
                    }
                }
            }
            [selectArray addObject:model];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.totalNum>DefaultSize) {
            [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        }
    });
    
    if (selectArray.count == 1) {
        DocumentModel * model = selectArray[0];
        pdfName = [NSString stringWithFormat:@"%@_%@",model.fileName,model.name];
    }
    
    if (selectArray.count>1){
        DocumentModel * model = selectArray[0];
        pdfName = [NSString stringWithFormat:@"%@",model.fileName];
    }
    
    NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:pdfName progress:^(CGFloat myProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.totalNum>DefaultSize) {
                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
            }
        });
    }];
    return path;
}

#pragma mark -- folder下压缩图片URL集合
- (NSMutableArray *)top_folderMediumImgShare:(DocumentModel*)model mediumSize:(CGFloat)max{
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
    //遍历出文件夹路径
    for (NSString * documentPath in getArry) {
        NSArray * compareArray = [self top_documentAllPicPath:documentPath];
        for (NSString * picName in compareArray) {
            NSString * nameIndex = [NSString stringWithFormat:@"%ld",[compareArray indexOfObject:picName]+1];
            NSString * docName = [documentPath componentsSeparatedByString:@"/"].lastObject;
            NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];
            NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
            NSString * compressFile = [NSString new];
            if (compareArray.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:picPath savePath:savePath maxCompression:max];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:picPath savePath:savePath maxCompression:max];
            }
            if (compressFile.length) {
                NSURL * file = [NSURL fileURLWithPath:compressFile];
                [tempArray addObject:file];
            }
        }
    }
    return tempArray;
}
#pragma mark -- document下压缩图片URL集合
- (NSMutableArray *)top_documentMediumImgShare:(DocumentModel*)model mediumSize:(CGFloat)max{
    NSArray * compareArray = [self top_documentAllPicPath:model.path];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (NSString * pcStr in compareArray) {
        NSString * nameIndex = [NSString stringWithFormat:@"%ld",[compareArray indexOfObject:pcStr]+1];
        NSString * docName = [model.path componentsSeparatedByString:@"/"].lastObject;
        NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];//保存压缩后的图片路的径最后一部分
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];//原图片的路径
        NSString * compressFile = [NSString new];
        if (compareArray.count > 5) {
            compressFile = [TOPDocumentHelper top_saveCompressPDFImage:fullPath savePath:savePath maxCompression:max];
        }else{
            compressFile = [TOPDocumentHelper top_saveCompressImage:fullPath savePath:savePath maxCompression:max];
        }
        if (compressFile.length) {
            NSURL * file = [NSURL fileURLWithPath:compressFile];
            [tempArray addObject:file];
        }
    }
    return tempArray;
}

#pragma mark -- 压缩图的pdf和图片分享 --- 这部分业务代码不应该放在视图中处理(违背了MVC设计模式)，后期优化时转移至vc中
- (void)top_MediumSizeShare:(CGFloat)max{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT , 0), ^{
        NSMutableArray * shareArray = [NSMutableArray new];
        if (weakSelf.compressType == 0) {
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            [TOPWHCFileManager top_removeItemAtPath:TOPCompress_Path];
            if (weakSelf.dataArray.count>0) {
                shareArray =  [weakSelf top_HomeVCPDFShare:max];
            }
            if (weakSelf.childArray.count>0) {
                shareArray =  [weakSelf top_childVCPDFShare:max];
            }
        }else{
            [TOPWHCFileManager top_removeItemAtPath:TOPCompress_Path];
            if (weakSelf.dataArray.count>0) {
                shareArray =  [weakSelf top_HomeVCShare:max];
            }
            if (weakSelf.childArray.count>0) {
                shareArray =  [weakSelf top_childVCShare:max];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD dismiss];
            if (self.selectBlock) {
                self.selectBlock(shareArray);
            }
        });
    });
}

- (NSMutableArray *)top_HomeVCPDFShare:(CGFloat)max {
    NSMutableArray *shareArray = @[].mutableCopy;
    NSMutableArray * allTempArray = [NSMutableArray new];
    for (int i = 0; i<self.dataArray.count; i++) {
        DocumentModel * model = self.dataArray[i];
        NSMutableArray * imgArray = [NSMutableArray new];
        if ([model.type isEqualToString:@"0"]) {
            imgArray = [self top_folderMediumpdfShare:model mediumsize:max index:i];
            [allTempArray addObjectsFromArray:imgArray];
        }
        
        if ([model.type isEqualToString:@"1"]) {
            imgArray = [self top_documentMediumpdfShare:model mediumsize:max index:i];
            [allTempArray addObjectsFromArray:imgArray];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isSVPShow) {
            if (self.totalNum>DefaultSize) {
                if (allTempArray.count>1) {
                    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@... (1-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(self.dataArray.count)]];
                }else{
                    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                }
            }
        }
    });
    
     for (int j = 0; j<allTempArray.count; j++) {
         if (j<allTempArray.count) {
             DocumentModel * model = allTempArray[j];
             NSMutableArray * imgArray = [model.docArray mutableCopy];
             //合成pdf图片
             NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:model.name progress:^(CGFloat myProgress) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (!self.isSVPShow) {
                         if (self.totalNum>DefaultSize) {
                             if (allTempArray.count>1) {
                                 [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@... (%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(j +1),@(self.dataArray.count)]];
                             }else{
                                 [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                             }
                         }
                     }
                 });
             }];
             NSURL * file = [NSURL fileURLWithPath:path];
             if (file) {
                 [shareArray addObject:file];
             }
         }
     }
    return shareArray;
}

- (NSMutableArray *)top_childVCPDFShare:(CGFloat)max {
    NSMutableArray *shareArray = @[].mutableCopy;
    NSString * path = [self top_childMediumpdfShare:self.childArray mediumSize:max];
    NSURL * file = [NSURL fileURLWithPath:path];
    if (file) {
        [shareArray addObject:file];
    }
    return shareArray;
}

- (NSMutableArray *)top_HomeVCShare:(CGFloat)max {
    NSMutableArray *shareArray = @[].mutableCopy;
    for (DocumentModel * model in self.dataArray) {
        if (model.selectStatus) {
            //在folder文件夹下 获取图片
            if ([model.type isEqualToString:@"0"]) {
                [shareArray addObjectsFromArray:[self top_folderMediumImgShare:model mediumSize:max]];
            }
            
            if ([model.type isEqualToString:@"1"]) {
                [shareArray addObjectsFromArray:[self top_documentMediumImgShare:model mediumSize:max]];
            }
        }
    }
    return shareArray;
}

- (NSMutableArray *)top_childVCShare:(CGFloat)max {
    NSMutableArray *shareArray = @[].mutableCopy;
    for (DocumentModel * model in self.childArray) {
        if (model.selectStatus) {
            NSString * nameIndex = [NSString stringWithFormat:@"%ld",[self.childArray indexOfObject:model]+1];
            NSArray * pathArray = [model.path componentsSeparatedByString:@"/"];
            NSString * docName = [NSString new];
            if (pathArray.count>0) {
                docName = pathArray[pathArray.count-2];
            }
            NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];
            NSString * compressFile = [NSString new];
            if (self.childArray.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:model.imagePath savePath:savePath maxCompression:max];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:model.imagePath savePath:savePath maxCompression:max];
            }
            if (compressFile.length) {
                NSURL * file = [NSURL fileURLWithPath:compressFile];
                [shareArray addObject:file];
            }
        }
    }
    return shareArray;
}

- (void)setNumberStr:(NSString *)numberStr{
    _numberStr = numberStr;
    [self.tableView reloadData];
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    self.isSVPShow = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocumentModel * model in dataArray) {
            if ([model.type isEqualToString:@"0"]) {
                self.isSVPShow = YES;
            }
        }
    });
}
- (void)setChildArray:(NSMutableArray *)childArray{
    _childArray = childArray;
}

- (void)setCompressType:(NSInteger)compressType{
    _compressType = compressType;
}

@end
