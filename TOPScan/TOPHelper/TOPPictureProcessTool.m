#import "TOPPictureProcessTool.h"
#import <MobileCoreServices/MobileCoreServices.h>
#include "SSCubeMap.mm"
#import "TOPGPUImageCartoonFilter.h"
#import "TOPGPUImageWhiteBlackFilter.h"
#import "TOPOpenCVWrapper.h"
#import "UIImage+category.h"

@implementation TOPPictureProcessTool

+ (UIImage *)top_imageWithImage:(GPUImagePicture*)GpuPic withImg:(UIImage *)img withItem:(NSInteger)item{
    @autoreleasepool {
        UIImage * newimage = [UIImage new];
        GPUImagePicture * imageSource = GpuPic;
        if (item == TOPProcessTypeBW || item == TOPProcessTypeBW2) {
            img = img.fixOrientation;//这里根据图片的旋转属性会做一次真正的旋转，TOPProcessTypeBW，TOPProcessTypeBW2模式下输出图片时不需要再做旋转
            UIImage *noShardingImg = [TOPOpenCVWrapper top_getNoShardingImage:img];
            imageSource = [[GPUImagePicture alloc] initWithImage:noShardingImg];
        }
        //数据源
        if (item == TOPProcessTypeOriginal) {
            newimage = img;
            return newimage;
            
        }else if (item == TOPProcessTypeBW){
            GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
            [toneCurveFilter setRgbCompositeControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.50, 0.0)], [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]]];
            
            GPUImageLevelsFilter *levelsFilter = [[GPUImageLevelsFilter alloc] init];
            [levelsFilter setMin:0.40 gamma:0.50 max:0.65];
            
            NSMutableArray * filterArray = [NSMutableArray new];
            [filterArray addObject:toneCurveFilter];
            [filterArray addObject:levelsFilter];
            
            
            //组合滤镜
            GPUImageFilterPipeline * PipelineFilter = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filterArray input:imageSource output:nil];
            [levelsFilter useNextFrameForImageCapture];
            //开始渲染
            [imageSource processImage];
            newimage = [PipelineFilter currentFilteredFrame];
            [imageSource removeAllTargets];
            [PipelineFilter removeAllFilters];
            imageSource = nil;
            PipelineFilter = nil;
            
        }else if (item == TOPProcessTypeBW2){
            GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
            [toneCurveFilter setRgbCompositeControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.44, 0.0)], [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]]];
            
            GPUImageLevelsFilter *levelsFilter = [[GPUImageLevelsFilter alloc] init];
            [levelsFilter setMin:0.39 gamma:0.64 max:0.83];
            
            NSMutableArray * filterArray = [NSMutableArray new];
            [filterArray addObject:toneCurveFilter];
            [filterArray addObject:levelsFilter];
            //组合滤镜
            GPUImageFilterPipeline * PipelineFilter = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filterArray input:imageSource output:nil];
            [levelsFilter useNextFrameForImageCapture];
            //开始渲染
            [imageSource processImage];
            newimage = [PipelineFilter currentFilteredFrame];//currentFilteredFrameWithOrientation:img.imageOrientation];
            [imageSource removeAllTargets];
            [PipelineFilter removeAllFilters];
            imageSource = nil;
            
        }else if (item == TOPProcessTypeBW3){
            //这个应用阈值操作，其中基于场景的平均亮度连续地调整阈值。
            GPUImageAverageLuminanceThresholdFilter *ThreshFilter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
            ThreshFilter.thresholdMultiplier = 0.55;//这是平均亮度将被乘以的因子，以便达到要使用的最下限阈值
            
            NSMutableArray * filterArray = [NSMutableArray new];
            [filterArray addObject:ThreshFilter];
            //组合滤镜
            GPUImageFilterPipeline * PipelineFilter = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filterArray input:imageSource output:nil];
            [ThreshFilter useNextFrameForImageCapture];
            //开始渲染
            [imageSource processImage];
            newimage = [PipelineFilter currentFilteredFrameWithOrientation:img.imageOrientation];
            [imageSource removeAllTargets];
            [PipelineFilter removeAllFilters];
            imageSource = nil;
            PipelineFilter = nil;
        }else if (item == TOPProcessTypeGrayscale){
            //使用灰色滤镜
            GPUImageGrayscaleFilter *disFilter = [[GPUImageGrayscaleFilter alloc] init];
            //添加滤镜
            [imageSource addTarget:disFilter];
            [disFilter useNextFrameForImageCapture];
            //开始渲染
            [imageSource processImage];
            //获取渲染后的图片
            newimage = [disFilter imageFromCurrentFramebufferWithOrientation:img.imageOrientation];

            [imageSource removeAllTargets];
            [disFilter removeAllTargets];
            imageSource = nil;
            disFilter = nil;
            
        }else if (item == TOPProcessTypeMagicColor){
            //单色 根据每个像素的亮度将图像转换为单色版本
            GPUImageMonochromeFilter *disFilter = [[GPUImageMonochromeFilter alloc] init];
            [disFilter setColorRed:1.0 green:1.0 blue:1.0];
            //intensity 特定颜色替换正常图像颜色的程度（0.0 - 1.0，默认为1.0
            disFilter.intensity = 0.6;
            
            //亮度：调整亮度（-1.0 - 1.0，默认为0.0）
            GPUImageBrightnessFilter * brightFilter = [[GPUImageBrightnessFilter alloc]init];
            brightFilter.brightness = 0.1;
            
            GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc]init];
            saturationFilter.saturation = 2.0;
            
            //色彩增强 用于添加或删除雾度（类似于UV过滤器）    distance：应用的颜色的强度。-.3和.3之间的值最好。          斜率：颜色变化量。-.3和.3之间的值最好
            GPUImageHazeFilter * corlrBurnFilter = [[GPUImageHazeFilter alloc]init];
            corlrBurnFilter.distance = 0.3;
            corlrBurnFilter.slope = 0.1;
            
            NSMutableArray * filterArray = [NSMutableArray new];
            [filterArray addObject:disFilter];
            [filterArray addObject:brightFilter];
            [filterArray addObject:saturationFilter];
            [filterArray addObject:corlrBurnFilter];
            
            GPUImageFilterPipeline * PipelineFilter = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filterArray input:imageSource output:nil];
            [corlrBurnFilter useNextFrameForImageCapture];
            //开始渲染
            [imageSource processImage];
            newimage = [PipelineFilter currentFilteredFrameWithOrientation:img.imageOrientation];
            [imageSource removeAllTargets];
            [PipelineFilter removeAllFilters];
            imageSource = nil;
            PipelineFilter = nil;
        }else if (item == TOPProcessTypeMagicColor2){
            //单色 根据每个像素的亮度将图像转换为单色版本
            GPUImageMonochromeFilter *disFilter = [[GPUImageMonochromeFilter alloc] init];
            [disFilter setColorRed:1.0 green:1.0 blue:1.0];
            //intensity 特定颜色替换正常图像颜色的程度（0.0 - 1.0，默认为1.0
            disFilter.intensity = 0.6;
                    
            //亮度：调整亮度（-1.0 - 1.0，默认为0.0）
            GPUImageBrightnessFilter * brightFilter = [[GPUImageBrightnessFilter alloc]init];
            brightFilter.brightness = 0.3;
            
            TOPGPUImageCartoonFilter *cartoonFilter = [[TOPGPUImageCartoonFilter alloc] init];
            
            //色彩增强 用于添加或删除雾度（类似于UV过滤器）    distance：应用的颜色的强度。-.3和.3之间的值最好。          斜率：颜色变化量。-.3和.3之间的值最好
            GPUImageHazeFilter * corlrBurnFilter = [[GPUImageHazeFilter alloc]init];
            corlrBurnFilter.distance = 0.3;
            corlrBurnFilter.slope = 0.1;
            
            NSMutableArray * filterArray = [NSMutableArray new];
            [filterArray addObject:brightFilter];
            [filterArray addObject:disFilter];
            [filterArray addObject:cartoonFilter];
            [filterArray addObject:corlrBurnFilter];
            
            GPUImageFilterPipeline * PipelineFilter = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filterArray input:imageSource output:nil];
            [corlrBurnFilter useNextFrameForImageCapture];
            //开始渲染
            [imageSource processImage];
            newimage = [PipelineFilter currentFilteredFrameWithOrientation:img.imageOrientation];

            [imageSource removeAllTargets];
            [PipelineFilter removeAllFilters];
            imageSource = nil;
            PipelineFilter = nil;
        }
        else{
            //使用怀旧滤镜
            GPUImageSepiaFilter *disFilter = [[GPUImageSepiaFilter alloc] init];
            [imageSource addTarget:disFilter];
            [disFilter useNextFrameForImageCapture];
            //开始渲染
            [imageSource processImage];
            //获取渲染后的图片
            newimage = [disFilter imageFromCurrentFramebufferWithOrientation:img.imageOrientation];

            [imageSource removeAllTargets];
            [disFilter removeAllTargets];
            imageSource = nil;
            disFilter = nil;
        }
        return newimage;
    }
}

#pragma mark -- 根据设置的最高清尺寸裁出作为源图片文件 -- 1000万像素
+ (UIImage *)top_fetchOriginalImageWithData:(NSData *)data {
    UIImage *originalImg = [UIImage imageWithData:data];
    CGFloat fixelW = CGImageGetWidth(originalImg.CGImage);
    CGFloat fixelH = CGImageGetHeight(originalImg.CGImage);
    CGFloat imagePiexl = fixelW * fixelH;
    if (imagePiexl > TOP_TRSSMaxPiexl) {//图片过大需要压缩
        float rate = imagePiexl / TOP_TRSSMaxPiexl;
        float scale = sqrtf(rate);
        CGFloat maxPixeSize = MAX(fixelW, fixelH);
        CGFloat settingSize = maxPixeSize / scale;
        originalImg = [self top_scaleImageWithData:data withSize:CGSizeMake(settingSize, settingSize)];
    }
    if (originalImg.imageOrientation != UIImageOrientationUp) {//校正图片方向，统一向上
        CGFloat maxPixeSize = MAX(fixelW, fixelH);
        originalImg = [self top_scaleImageWithData:data withSize:CGSizeMake(maxPixeSize, maxPixeSize)];
    }
    return originalImg;
}

+ (UIImage *)top_fetchOriginalImageWithData:(NSData *)data withSize:(CGFloat)imgSize{
    UIImage *originalImg = [UIImage imageWithData:data];
    CGFloat fixelW = CGImageGetWidth(originalImg.CGImage);
    CGFloat fixelH = CGImageGetHeight(originalImg.CGImage);
    CGFloat imagePiexl = fixelW * fixelH;
    if (imagePiexl > TOP_TRSSMaxPiexl) {//图片过大需要压缩
        float rate = imagePiexl / TOP_TRSSMaxPiexl;
        float scale = sqrtf(rate);
        CGFloat maxPixeSize = MAX(fixelW, fixelH);
        CGFloat settingSize = maxPixeSize / scale;
        originalImg = [self top_scaleImageWithData:data withSize:CGSizeMake(settingSize, settingSize)];
    }
    if (originalImg.imageOrientation != UIImageOrientationUp) {//校正图片方向，统一向上
        CGFloat maxPixeSize = MAX(fixelW, fixelH);
        originalImg = [self top_scaleImageWithData:data withSize:CGSizeMake(maxPixeSize, maxPixeSize)];
    }
    return originalImg;
}

#pragma mark -- 缩略图 -- 使用Image i/o 避免在改变图片大小的过程中产生临时的bitmap(栅格图)，就能够在很大程度上减少内存的占有
+ (UIImage *)top_scaleImageWithData:(NSData *)data withSize:(CGSize)size {
    CGFloat maxPixeSize = MAX(size.width, size.height);
    if (maxPixeSize < TOPScreenHeight) {
        CGFloat scale = [UIScreen mainScreen].scale;
        maxPixeSize = maxPixeSize * scale;
    }
    //读取图像源
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    NSDictionary *options = @{(__bridge id)kCGImageSourceCreateThumbnailWithTransform:(__bridge id)kCFBooleanTrue,
                              (__bridge id)kCGImageSourceCreateThumbnailFromImageAlways:(__bridge id)kCFBooleanTrue,
                              (__bridge id)kCGImageSourceThumbnailMaxPixelSize:[NSNumber numberWithFloat:maxPixeSize]};
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(sourceRef);
    CGImageRelease(imageRef);
    
    return resultImage;
    
}

#pragma mark -- 控制源图大小到1200W像素内，保存在本地文件减少内存消耗
+ (void)top_resizeOriginalImage:(NSData *)data atPath:(NSString *)path {
    UIImage *originalImg = [UIImage imageWithData:data];
    CGFloat fixelW = CGImageGetWidth(originalImg.CGImage);
    CGFloat fixelH = CGImageGetHeight(originalImg.CGImage);
    CGFloat imagePiexl = fixelW * fixelH;
    if (imagePiexl > TOP_TRSSMaxPiexl) {//图片过大需要压缩
        float rate = imagePiexl / TOP_TRSSMaxPiexl;
        float scale = sqrtf(rate);
        CGFloat maxPixeSize = MAX(fixelW, fixelH);
        CGFloat settingSize = maxPixeSize / scale;
        
        //读取图像源
        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        NSDictionary *options = @{(__bridge id)kCGImageSourceCreateThumbnailWithTransform:(__bridge id)kCFBooleanTrue,
                                  (__bridge id)kCGImageSourceCreateThumbnailFromImageAlways:(__bridge id)kCFBooleanTrue,
                                  (__bridge id)kCGImageSourceThumbnailMaxPixelSize:[NSNumber numberWithFloat:settingSize]};
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
        
        CGImageWriteToFile(imageRef, path);//存储后的文件会变大:1M -> 2M
        
        CFRelease(sourceRef);
        CGImageRelease(imageRef);
    } else {
        [data writeToFile:path atomically:YES];
    }
}

void CGImageWriteToFile(CGImageRef image, NSString *path) {
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
    }
}

#pragma mark -- 绘制水印图片
+ (UIImage *)top_waterMarkWithImage:(UIImage *)backgroundImage andWaterImage:(UIImage *)waterImage withRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 1.0);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [waterImage drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -- 设置图片透明度
+ (UIImage *)top_imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -- 获取imageView 旋转和缩放后的image图片对象
+ (UIImage *)top_rotationScaleImageWithImageView:(UIImageView *)subImageView {
    //使用绘制的方法得到旋转之后的图片
    double rotationZ = [[subImageView.layer valueForKeyPath:@"transform.rotation.z"] doubleValue];
    
    float currentScale = [[subImageView.layer valueForKeyPath:@"transform.scale"] floatValue];
    if (rotationZ == 0 && currentScale == 1) {//未旋转、未缩放
        return subImageView.image;
    }
    CGSize scaleSIze = CGSizeMake( subImageView.image.size.width*currentScale,  subImageView.image.size.height*currentScale);
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,scaleSIze.width,scaleSIze.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(rotationZ);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    UIGraphicsBeginImageContext(rotatedSize);
    
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/ 2,rotatedSize.height / 2);
    CGContextRotateCTM(bitmap,rotationZ);
    CGContextScaleCTM(bitmap,1, -1);
    CGContextDrawImage(bitmap, CGRectMake(-(scaleSIze.width)/ 2, -(scaleSIze.height) / 2, scaleSIze.width, scaleSIze.height), [subImageView.image CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -- 多张图片合成一张
+ (UIImage *)top_mergedImages:(NSArray *)imagesArray {
    CGFloat longImageWidth = [UIScreen mainScreen].scale > 2 ? 1100 : 900;
    CGFloat maxWidth    = 0;//
    CGFloat totalHeight = 0;
    //计算图片的高度
    NSMutableArray *temp = @[].mutableCopy;
    for (UIImage *image in imagesArray) {
        totalHeight += image.size.height;
        CGFloat width = image.size.width;
        [temp addObject:@(width)];
    }
    maxWidth = [[temp valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat scale = longImageWidth / maxWidth;
    if (scale > 1) {
        scale = 1;
    }
    maxWidth = maxWidth * scale;
    totalHeight = totalHeight * scale;
    //绘图上下文
    UIGraphicsBeginImageContext(CGSizeMake(maxWidth, totalHeight));
    
    totalHeight = 0;
    for (UIImage *image in imagesArray) {
        CGFloat imageWidth  = image.size.width * scale;
        CGFloat imageHeight = image.size.height * scale;
        CGFloat pointX = (maxWidth - imageWidth)/2.0;
        [image drawInRect:CGRectMake(pointX, totalHeight, imageWidth, imageHeight)];
        totalHeight += imageHeight;
    }     //生成图片
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //释放上下文
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

+ (UIImage*)top_imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    // 开始画图的上下文
    UIGraphicsBeginImageContext(rect.size);
    // 设置背景颜色
    [color set];
    // 设置填充区域
    UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
    // 返回UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -- 渲染模式
+ (NSArray *)top_processTypeArray{
    NSArray * tempArray = @[@(TOPProcessTypeOriginal),@(TOPProcessTypeMagicColor),@(TOPProcessTypeMagicColor2),@(TOPProcessTypeBW),@(TOPProcessTypeBW2),@(TOPProcessTypeBW3),@(TOPProcessTypeGrayscale),@(TOPProcessTypeNostalgic)];
    return tempArray;
}

#pragma mark -- 渲染模式对应标题
+ (NSArray *)top_processTitles {
    NSArray * tempArray = @[NSLocalizedString(@"topscan_original", @""),NSLocalizedString(@"topscan_magiccolor", @""),NSLocalizedString(@"topscan_magiccolor2", @""),NSLocalizedString(@"topscan_blackwhite", @""),NSLocalizedString(@"topscan_blackwhite2", @""),NSLocalizedString(@"topscan_blackwhite3", @""),NSLocalizedString(@"topscan_grayscale", @""),NSLocalizedString(@"topscan_nostalgic", @"")];
    return tempArray;
}

#pragma mark -- 抠图：去除图中白色背景
+ (UIImage *)top_removeWhiteColorWithImage:(UIImage *)image {
    return [self removeColorWithMinHueAngle:360 maxHueAngle:360 image:image];
}

#pragma mark -- 抠图：去除图中指定范围的颜色
+ (UIImage *)removeColorWithMaxR:(float)maxR minR:(float)minR maxG:(float)maxG minG:(float)minG maxB:(float)maxB minB:(float)minB image:(UIImage *)image {
    const CGFloat myMaskingColors[6] = {minR, maxR,  minG, maxG, minB, maxB};
    CGImageRef sourceImage = image.CGImage;
    CGImageAlphaInfo info = CGImageGetAlphaInfo(sourceImage);
    if (info != kCGImageAlphaNone) {
        NSData *buffer = UIImagePNGRepresentation(image);
        UIImage *newImage = [UIImage imageWithData:buffer];
        sourceImage = newImage.CGImage;
    }

    CGImageRef masked = CGImageCreateWithMaskingColors(sourceImage, myMaskingColors);
    UIImage *retImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return retImage;
}

+ (UIImage *)removeColorWithMinHueAngle:(float)minHueAngle maxHueAngle:(float)maxHueAngle image:(UIImage *)originalImage{
//    CIImage *image = [CIImage imageWithCGImage:originalImage.CGImage];
    NSData * imgData = UIImageJPEGRepresentation(originalImage, TOP_TRPicScale);
    if (imgData) {
        CIImage * image = [CIImage imageWithData:imgData];
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *renderBgImage = [self outputImageWithOriginalCIImage:image minHueAngle:minHueAngle maxHueAngle:maxHueAngle];
        CGImageRef renderImg = [context createCGImage:renderBgImage fromRect:image.extent];
        UIImage *renderImage = [UIImage imageWithCGImage:renderImg];
        return renderImage;
    }else{
        return nil;
    }
}

+ (CIImage *)outputImageWithOriginalCIImage:(CIImage *)originalImage minHueAngle:(float)minHueAngle maxHueAngle:(float)maxHueAngle{
    
    struct CubeMap map = createCubeMap(minHueAngle, maxHueAngle);
    const unsigned int size = 64;
    // Create memory with the cube data
    NSData *data = [NSData dataWithBytesNoCopy:map.data
                                        length:map.length
                                  freeWhenDone:YES];
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:@(size) forKey:@"inputCubeDimension"];
    // Set data for cube
    [colorCube setValue:data forKey:@"inputCubeData"];
    
    [colorCube setValue:originalImage forKey:kCIInputImageKey];
    CIImage *result = [colorCube valueForKey:kCIOutputImageKey];
    
    return result;
}
@end
