#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)

#import "TOPScameraBatchCell.h"
#import "TOPDataTool.h"
#import "TOPOpenCVWrapper.h"
#import "TOPSaveElementModel.h"
@implementation TOPScameraBatchCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        WS(weakSelf);
        _zoomView = [[TOPPhotoEditScrollView alloc]init];
        _zoomView.userInteractionEnabled = YES;
        _zoomView.layer.cornerRadius = 3;
        _zoomView.layer.shadowColor = [UIColor blackColor].CGColor;
        _zoomView.layer.shadowOffset = CGSizeMake(0, 0);
        _zoomView.layer.shadowOpacity = 0.5;
        _zoomView.clipsToBounds = NO;
        _zoomView.photoZoomScale = ^(CGFloat zoomScale) {
            [weakSelf top_judgeZoomScale:zoomScale];
        };
        
        [self.contentView addSubview:_zoomView];
        _picH = ((TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)*(TOPScreenWidth-30))/TOPScreenWidth;
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    [_zoomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(30);
        make.trailing.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.contentView).offset(110);
        make.bottom.equalTo(self.contentView).offset(-110);
    }];
}

- (void)setModel:(TOPCameraBatchModel *)model{
    _model = model;
    if (!model.isFirstEnter) {//不是第一次加载数据
        [self top_notFirstLoadData:model];
    }else{
        @autoreleasepool {
            NSString * originalPicPath = [TOPCamerPic_Path stringByAppendingPathComponent:model.PicName];
            UIImage * originImage = [UIImage imageWithContentsOfFile:originalPicPath];
            
            NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:model.PicName];
            UIImage * filterImage = [UIImage imageWithContentsOfFile:filterPicPath];
            if (filterImage) {
                _zoomView.mainImage = filterImage;
                model.isFirstEnter = NO;
            }else{
                _zoomView.mainImage = originImage;
            }
        }
    }
}
- (void)top_notFirstLoadData:(TOPCameraBatchModel *)model{
    @autoreleasepool {
        NSString * cameraBatchImagePath = model.PicName;
        NSString * originalPicPath = [NSString new];
        originalPicPath = [TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:cameraBatchImagePath];

        NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:cameraBatchImagePath];

        UIImage * originImage = [UIImage imageWithContentsOfFile:originalPicPath];
        UIImage * filterImage = [UIImage imageWithContentsOfFile:filterPicPath];
        model.showImg = filterImage;
        if (model.showImg) {
            _zoomView.mainImage = model.showImg;
        }else{
            if (originImage) {
                _zoomView.mainImage = originImage;
            }else{
                NSString * originalPicPath = [TOPCamerPic_Path stringByAppendingPathComponent:cameraBatchImagePath];
                _zoomView.mainImage = [UIImage imageWithContentsOfFile:originalPicPath];
            }
        }
        
        if (model.isSelect) {
            [self top_filterCurrentImage];
        }
    }
}

- (void)top_filterCurrentImage{
    @autoreleasepool {
        WS(weakSelf);
        NSString * cameraBatchImagePath = _model.PicName;
        NSString * originalPicPath = [NSString new];
        originalPicPath = [TOPCameraBatchCropDraw_Path stringByAppendingPathComponent:cameraBatchImagePath];

        NSString * filterPicPath = [TOPCameraBatchDefaultDraw_Path stringByAppendingPathComponent:cameraBatchImagePath];
        NSString * adjustPicPath = [TOPCameraBatchAdjustDraw_Path stringByAppendingPathComponent:cameraBatchImagePath];
        UIImage * originImage = [UIImage imageWithContentsOfFile:originalPicPath];
        NSLog(@"originalPicPath==%@ originImage==%@",originalPicPath,originImage);

        if (originImage) {
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:originImage];
                //开始渲染
                UIImage *image = [TOPDataTool top_pictureProcessData:imageSource withImg:originImage withItem:weakSelf.model.processType];
                //完成后清除渲染的缓存
                [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
                [TOPDocumentHelper top_saveImage:image atPath:filterPicPath];
                [TOPDocumentHelper top_saveImage:image atPath:adjustPicPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (self.top_changAdjustModelImg) {
                        self.top_changAdjustModelImg();
                    }
                    if (image) {
                        weakSelf.zoomView.mainImage = image;
                    }else{
                        weakSelf.zoomView.mainImage = originImage;
                    }
                    weakSelf.model.isSelect = NO;
                });
            });
        }
    }
}
- (void)top_judgeZoomScale:(CGFloat)zoomScale{
    if (self.top_sendZoomScale) {
        self.top_sendZoomScale(zoomScale);
    }
}
@end
