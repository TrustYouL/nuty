#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)
#define CropView_Y 45
#define CropView_X 15
#import "TOPBatchCell.h"

@implementation TOPBatchCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        [self.contentView addSubview:self.cropView];
    }
    return self;
}
- (TOPCropView*)cropView{
    if (!_cropView){
        _cropView  = [[TOPCropView alloc]initWithFrame:CGRectMake(CropView_X, CropView_Y , TOPScreenWidth-30, ((TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)*(TOPScreenWidth-30))/TOPScreenWidth)];
        _cropView.cropViewDelegate = self;
        _cropView.touchRange = IS_IPAD ? 100 : 60;
    }
    return _cropView;
}

-(TOPMagnifierView *)magnifierView{
    if (! _magnifierView) {
        _magnifierView = [[TOPMagnifierView alloc]init];
        _magnifierView.magnifyView = self.cropView;
    }
    return _magnifierView;
}
- (void)setBatchCropType:(TOPBatchCropType)batchCropType{
    _batchCropType = batchCropType;
}
- (void)setModel:(TOPCropEditModel *)model{
    _model = model;
    __block UIImage * sendImg = [UIImage new];
    UIImage * originalImg = [UIImage imageWithContentsOfFile:model.originalPath];
    self.cropView.originalImage = originalImg;
    
    UIImage * showImg = [UIImage imageWithContentsOfFile:model.showPath];
    if (!showImg) {
        CGSize cropSize = _cropView.size;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (originalImg.size.width>0&&originalImg.size.height>0) {
                NSData *imgData = [NSData dataWithContentsOfFile:model.originalPath];
                UIImage * img =  [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:cropSize];
                if (img.size.width>0) {
                    [TOPDocumentHelper top_saveImage:img atPath:model.showPath];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                sendImg = [UIImage imageWithContentsOfFile:model.showPath];
                if (sendImg.size.width>0) {
                    [self top_creatShowUI:sendImg currentModel:model];
                }
            });
        });
    }else{
        [self top_creatShowUI:showImg currentModel:model];
    }
}

- (void)top_creatShowUI:(UIImage *)sendImg currentModel:(TOPCropEditModel *)model{
    self.cropView.defaultPoints = model.showEndPoinArray.mutableCopy;
    [self.cropView setUpImageWithImage:sendImg isAutomatic:model.isAutomatic];
}
#pragma mark--CropViewDelegate
- (void)panChangePoint:(CGPoint)point{
    //设置放大镜位置
    [self magnifierPosition:point];
    //显示放大镜
    [self.magnifierView makeKeyAndVisible];
}

- (void)panChangePointEnd{
    self.magnifierView.hidden = YES;
    _model.isChangeType = NO;
    _model.isChange = YES;
    if (self.top_saveChangeData) {
        self.top_saveChangeData();
    }
}

-(void)magnifierPosition:(CGPoint )position
{
    CGPoint sendPoint = position;//CGPointMake(position.x+CropView_X, position.y+TOPNavBarAndStatusBarHeight+CropView_Y);
    self.magnifierView.pointTomagnify = sendPoint;
}

- (BOOL)top_compareArray:(NSMutableArray *)array1 withArray:(NSMutableArray *)array2{
    NSSet * set1 = [NSSet setWithArray:[array1 copy]];
    NSSet * set2 = [NSSet setWithArray:[array2 copy]];
    if ([set1 isEqualToSet:set2]) {
        return NO;
    }
    return YES;
}
@end
