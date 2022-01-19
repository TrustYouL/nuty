#import "TOPImageBrowsingView.h"

@interface TOPImageBrowsingView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *mainImageView;

@end

@implementation TOPImageBrowsingView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self top_setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self top_setup];
    }
    return self;
}
- (void)top_setup{
    self.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.2];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.maximumZoomScale = [UIScreen mainScreen].scale * 3;
    self.minimumZoomScale = 1;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
    self.layer.masksToBounds = YES;
    self.bounces = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.mainImageView];
}

- (void)setMainImage:(UIImage *)mainImage {
    _mainImage = mainImage;
    if (_mainImage) {
        CGRect imgRect = [self top_adaptiveImageFrame:_mainImage];
        self.mainImageView.image = _mainImage;
        self.mainImageView.frame = imgRect;
    }
}

- (void)top_resetHighImage:(UIImage *)image {
    _mainImage = image;
    self.mainImageView.image = _mainImage;
}

#pragma mark -- 根据图片大小进行适配--保持原图比例
- (CGRect)top_adaptiveImageFrame:(UIImage *)image {
    CGFloat fatherWidth = TOPScreenWidth;
    CGFloat fatherHeight = TOPScreenHeight-TOPNavBarAndStatusBarHeight;
    CGFloat imgWidth  = 0;
    CGFloat imgHeight = 0;
    if  (image.size.width/image.size.height >= fatherWidth/fatherHeight) {
        imgWidth = fatherWidth;
        imgHeight = imgWidth / image.size.width * image.size.height;
    } else {
        imgHeight = fatherHeight;
        imgWidth = imgHeight / image.size.height * image.size.width;
    }
    CGFloat imgX = (fatherWidth - imgWidth)/2;
    CGFloat imgY = (fatherHeight - imgHeight)/2;
    CGRect rect = CGRectMake(imgX, imgY, imgWidth, imgHeight);
    return rect;
}

#pragma mark -- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (!self.mainImageView.image) {
        return;
    }
    if (self.highDefinition) {
        if (self.browsingDelegate && [self.browsingDelegate respondsToSelector:@selector(top_imageBrowsingShowDidScrollZoom)]) {
            [self.browsingDelegate top_imageBrowsingShowDidScrollZoom];
        }
        self.highDefinition = NO;
    }
    CGFloat centerX = scrollView.center.x, centerY = scrollView.center.y;
    centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : centerX;
    centerY = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : centerY;
    [self.mainImageView setCenter:CGPointMake(centerX, centerY)];
}

#pragma mark - lazy
- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] init];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        _mainImageView.userInteractionEnabled = YES;
    }
    return _mainImageView;
}


@end
