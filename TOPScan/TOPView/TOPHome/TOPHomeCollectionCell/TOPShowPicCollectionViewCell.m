#import "TOPShowPicCollectionViewCell.h"
@implementation TOPShowPicCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        WS(weakSelf);
        _zoomView = [[TOPPhotoEditScrollView alloc]init];
        _zoomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _zoomView.userInteractionEnabled = YES;
        _zoomView.photoClickSingleHandler = ^{
            [weakSelf top_currentItemAction];
        };
        
        _zoomView.photoClickZoomHandler = ^{
            [weakSelf top_currentZoomAction];
        };
        
        _zoomView.photoWillBeginDragging = ^{
            if (weakSelf.top_scrollBeginShow) {
                weakSelf.top_scrollBeginShow();
            }
        };
        
        _zoomView.photoDidEndDecelerating = ^{
            if (weakSelf.top_scrollEndHide) {
                weakSelf.top_scrollEndHide();
            }
        };
        _zoomView.photoZoomScale = ^(CGFloat zoomScale) {
            [weakSelf top_judgeZoomScale:zoomScale];
        };
        [self.contentView addSubview:_zoomView];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    [_zoomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentView);
    }];
}

- (void)setModel:(DocumentModel *)model{
    _model = model;
    _zoomView.zoomScale = 1.0;
    _zoomView.mainImage = [UIImage imageWithContentsOfFile:model.imagePath];
}

- (void)setCameraImagePath:(NSString *)cameraImagePath{
    NSString * picPath = [TOPCamerPic_Path stringByAppendingPathComponent:cameraImagePath];
    _zoomView.zoomScale = 1.0;
    _zoomView.mainImage = [UIImage imageWithContentsOfFile:picPath];
}

- (void)top_judgeZoomScale:(CGFloat)zoomScale{
    if (self.top_sendZoomScale) {
        self.top_sendZoomScale(zoomScale);
    }
}
- (void)top_currentItemAction{
    if (self.top_clickItem) {
        self.top_clickItem();
    }
}

- (void)top_currentZoomAction{
    if (self.top_clickZoom) {
        self.top_clickZoom();
    }
}

@end
