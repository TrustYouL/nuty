#import "TOPCameraFilterView.h"
#import "TOPReEditCollectionViewCell.h"
#import "TOPDataTool.h"
@interface TOPCameraFilterView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray * filterShowArray;
@end
@implementation TOPCameraFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBA(0, 0, 0, 0.4);
        [self addSubview:self.filterCollectionView];
        [self top_loadFilterDefaultPic];
        if (IS_IPAD) {
            self.filterCollectionView.frame = CGRectMake((TOPScreenWidth-[TOPPictureProcessTool top_processTypeArray].count*90)/2, 0, [TOPPictureProcessTool top_processTypeArray].count*90, 100);
        }
    }
    return self;
}

- (NSMutableArray *)filterShowArray{
    if (!_filterShowArray) {
        _filterShowArray = [NSMutableArray new];
    }
    return _filterShowArray;
}

- (UICollectionView *)filterCollectionView{
    if (!_filterCollectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(80, 80);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _filterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0,TOPScreenWidth , 100) collectionViewLayout:layout];
        _filterCollectionView.dataSource = self;
        _filterCollectionView.delegate = self;
        _filterCollectionView.backgroundColor = [UIColor clearColor];
        _filterCollectionView.showsVerticalScrollIndicator = NO;
        _filterCollectionView.showsHorizontalScrollIndicator = NO;
        [_filterCollectionView registerClass:[TOPReEditCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class])];
    }
    return _filterCollectionView;
}

- (void)top_loadFilterDefaultPic{
    [TOPWHCFileManager top_removeItemAtPath:TOPBatchDefaultDraw_Path];
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
        NSInteger currentIndex = 0;
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
                    model.processType = processType;
                }
                
                if (processType == [TOPScanerShare top_defaultProcessType]) {
                    currentIndex = i;
                    model.isSelect = YES;
                }else{
                    model.isSelect = NO;
                }
                [weakSelf.filterShowArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.filterCollectionView reloadData];
            [weakSelf.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        });
    });
}

#pragma mark -- 取出保存filter的本地图片 需要对图片进行排序 保存到本地的图片是无序的
- (void)top_getFilterDefaultImg{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * compareArray = [TOPDocumentHelper top_sortPicsAtPath:TOPBatchDefaultDraw_Path];
        NSArray *processArray = [TOPPictureProcessTool top_processTypeArray];
        NSInteger currentIndex = 0;
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
                    model.processType = processType;
                }
                if (processType == [TOPScanerShare top_defaultProcessType]) {
                    currentIndex = i;
                    model.isSelect = YES;
                }else{
                    model.isSelect = NO;
                }
                [weakSelf.filterShowArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.filterCollectionView reloadData];
            [weakSelf.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            
        });
    });
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.filterShowArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPReEditCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class]) forIndexPath:indexPath];
    TOPReEditModel * model = self.filterShowArray[indexPath.item];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPReEditModel * model = self.filterShowArray[indexPath.item];
    for (TOPReEditModel * tempModel in self.filterShowArray) {
        if (tempModel == model) {
            tempModel.isSelect = YES;
        }else{
            tempModel.isSelect = NO;
        }
    }
    [self.filterCollectionView reloadData];
    
    if (self.top_sendProcessStateTip) {
        self.top_sendProcessStateTip(model,indexPath.item);
    }
}

@end
