#import "TOPPhotoEditScrollView.h"
@interface TOPPhotoEditScrollView()<UIScrollViewDelegate>
@property (nonatomic,assign) CGPoint currPont;

@end


@implementation TOPPhotoEditScrollView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup{
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.maximumZoomScale = 3;
    self.minimumZoomScale = 1;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.mainImageView];

    _currPont = CGPointZero;
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapSingleSponse:)];
    tapSingle.numberOfTapsRequired = 1;
    tapSingle.delaysTouchesEnded = NO;
    [self.mainImageView addGestureRecognizer:tapSingle];

    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapDoubleSponse:)];
    tapDouble.numberOfTapsRequired = 2;
    [self.mainImageView addGestureRecognizer:tapDouble];
     [tapSingle requireGestureRecognizerToFail:tapDouble];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.zooming || self.zoomScale != 1.0 || self.zoomBouncing) {
        return;
    }
    if (_mainImage.size.width>0&&_mainImage.size.height>0) {
        CGRect imgRect = [self top_getImageViewFrame];
        self.mainImageView.frame = imgRect;
        if (CGRectGetHeight(imgRect) > CGRectGetHeight(self.frame)) {
            [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(imgRect))];
        }else{
            [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        }
    }
}
- (void)setMainImage:(UIImage *)mainImage{
    if (mainImage.size.width>0&&mainImage.size.height>0) {
        _mainImage = mainImage;
        self.mainImageView.image = _mainImage;
        [self setContentOffset:CGPointMake(0, 0)];
        [self setNeedsLayout];
    }
}
- (CGRect)top_getImageViewFrame{
    if (_mainImage.size.width>0&&_mainImage.size.height>0) {
        UIImage *imageTy = _mainImage;
        float imgWidth = 0;
        float imgHeight = 0;
        CGFloat fatherWidth = self.frame.size.width;
        CGFloat fatherHeight = CGRectGetHeight(self.frame);
        if  (imageTy.size.width/imageTy.size.height >= fatherWidth/fatherHeight) {
            imgWidth = fatherWidth;
            imgHeight = imgWidth / imageTy.size.width * imageTy.size.height;
        } else {
            imgHeight = fatherHeight;
            imgWidth = imgHeight / imageTy.size.height * imageTy.size.width;
        }
        return CGRectMake((fatherWidth-imgWidth)/2, (fatherHeight-imgHeight)/2, imgWidth, imgHeight);
    }else{
        return self.frame;
    }
}
- (void)top_zoomingOffset:(CGPoint)location{
    CGFloat lo_x = location.x * self.zoomScale;
    CGFloat lo_y = location.y * self.zoomScale;
    
    CGFloat off_x;
    CGFloat off_y;
    ///off_x
    if (lo_x < CGRectGetWidth(self.frame)/2) {
        off_x = 0;
    }
    else if (lo_x > self.contentSize.width - CGRectGetWidth(self.frame)/2){
        off_x = self.contentSize.width - CGRectGetWidth(self.frame);
    }
    else{
        off_x = lo_x - CGRectGetWidth(self.frame)/2;
    }
    ///off_y
    if (lo_y < CGRectGetHeight(self.frame)/2) {
        off_y = 0;
    }
    else if (lo_y > self.contentSize.height - CGRectGetHeight(self.frame)/2){
        if (self.contentSize.height <= CGRectGetHeight(self.frame)) {
            off_y = 0;
        }
        else{
            off_y = self.contentSize.height - CGRectGetHeight(self.frame);
        }
    }
    else{
        off_y = lo_y - CGRectGetHeight(self.frame)/2;
    }
    [self setContentOffset:CGPointMake(off_x, off_y)];
}
#pragma mark - 重置图片
- (void)resetImageViewState{
    self.zoomScale = 1;
    _mainImage = nil;;
    self.mainImageView.image = nil;
}
#pragma mark - 变量
- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [UIImageView new];
        _mainImageView.image = nil;
        _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        _mainImageView.userInteractionEnabled = YES;

    }
    return _mainImageView;
}
#pragma mark - 单击
- (void)top_tapSingleSponse:(UITapGestureRecognizer *)singleTap{
    if (!self.mainImageView.image) {
        return;
    }
    if (self.photoClickSingleHandler) {
        self.photoClickSingleHandler();
    }
}
#pragma mark - 双击
- (void)top_tapDoubleSponse:(UITapGestureRecognizer *)doubleTap{
    if (!self.mainImageView.image) {
        return;
    }
    CGPoint point = [doubleTap locationInView:self.mainImageView];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomScale = 2.0;
            [self top_zoomingOffset:point];
        }];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomScale = 1;
        } completion:^(BOOL finished) {
            [self setContentOffset:self->_currPont animated:YES];
        }];
    }
    if (self.photoClickZoomHandler) {
        self.photoClickZoomHandler();
    }
    
    if (self.photoZoomScale) {
        self.photoZoomScale(self.zoomScale);
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    if (self.photoClickZoomHandler) {
        self.photoClickZoomHandler();
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (!self.mainImageView.image) {
        return;
    }
    
    CGRect imageViewFrame = self.mainImageView.frame;
    CGFloat width = imageViewFrame.size.width,
    height = imageViewFrame.size.height,
    sHeight = scrollView.bounds.size.height,
    sWidth = scrollView.bounds.size.width;
    if (height > sHeight) {
        imageViewFrame.origin.y = 0;
    } else {
        imageViewFrame.origin.y = (sHeight - height) / 2.0;
    }
    if (width > sWidth) {
        imageViewFrame.origin.x = 0;
    } else {
        imageViewFrame.origin.x = (sWidth - width) / 2.0;
    }
    self.mainImageView.frame = imageViewFrame;
    if (self.photoZoomScale) {
        self.photoZoomScale(self.zoomScale);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isZooming || self.zoomScale != 1) {
        return;
    }
    _currPont = scrollView.contentOffset;
    if (self.photoDidEndDecelerating) {
        self.photoDidEndDecelerating();
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.photoWillBeginDragging) {
        self.photoWillBeginDragging();
    }
}

@end
