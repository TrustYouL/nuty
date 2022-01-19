#import "TOPCollageModel.h"
#import "StickerView.h"

@implementation SSCollagePic
- (instancetype)initWithImage:(UIImage *)img imgRect:(CGRect)imgRect {
    self = [super init];
    if (self) {
        self.img = img;
        self.picRect = imgRect;
    }
    return self;
}

@end

@implementation TOPCollageModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.picArr = @[].mutableCopy;
        self.stickerArr = @[].mutableCopy;
        self.imageScale = 6.0;
    }
    return self;
}

- (void)setBgImgView:(UIImageView *)bgImgView {
    _bgImgView = bgImgView;
    _bgImageRect = CGRectMake(0, 0, CGRectGetWidth(_bgImgView.bounds) * self.imageScale, CGRectGetHeight(_bgImgView.bounds) * self.imageScale);
}

- (void)top_convertRectBuildPicModel {
    if (self.picArr.count && self.stickerArr.count) {
        [self.picArr removeAllObjects];
    }
    for (StickerView *selectedSticker in self.stickerArr) {
        UIImageView *subImageView = [selectedSticker viewWithTag:1234];
        UIImage *subImage = [TOPPictureProcessTool top_rotationScaleImageWithImageView:subImageView];
        CGRect subViewRect = [self top_smallImageViewFrame:selectedSticker];
        SSCollagePic *picModel = [[SSCollagePic alloc] initWithImage:subImage imgRect:subViewRect];
        [self.picArr addObject:picModel];
    }
}

#pragma mark -- 签名在底图中的frame 根据底图的缩放比例
- (CGRect)top_smallImageViewFrame:(StickerView *)sticker {
    UIImageView *subImageView = [sticker viewWithTag:1234];
    CGFloat subViewWidth = CGRectGetWidth(subImageView.frame);
    CGFloat subViewHeight = CGRectGetHeight(subImageView.frame);
    CGFloat scale = self.imageScale;
    CGPoint centerPoint = [self.bgImgView convertPoint:subImageView.center fromView:sticker];
    CGRect newRect = CGRectMake((centerPoint.x - subViewWidth/2)*scale, (centerPoint.y - subViewHeight/2)*scale, subViewWidth *scale, subViewHeight *scale);
    return newRect;
}

@end
