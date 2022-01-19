#import "TOPOpenCVWrapper.h"
#undef NO
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import<opencv2/stitching.hpp>
#import <GPUImage/GPUImage.h>
#include <iostream>

using namespace std;
using namespace cv;
@implementation TOPOpenCVWrapper
+(NSMutableArray *) top_getLargestSquarePoints: (UIImage *) image : (CGSize) size :(BOOL)isAutomatic{
    if (!image.size.width) {//出现用户传入的图片为空的情况--目前没有复现，先做判空处理
        return nil;
    }
    if (!size.width) {
        return nil;
    }
    cv::Mat imageMat;
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    imageMat = cvMat;
    cv::resize(imageMat, imageMat, cvSize(size.width, size.height));
    std::vector<std::vector<cv::Point> >rectangle;
    std::vector<cv::Point> largestRectangle;
    
    top_getRectangles(imageMat, rectangle);
    top_getlargestRectangle(rectangle, largestRectangle);
    //识别功能 现在先不要 屏蔽掉 后面用到再打开
    if (isAutomatic) {
        if (largestRectangle.size() == 4)
        {
            NSMutableArray *points = @[].mutableCopy;
            for (int i = 0; i < largestRectangle.size(); i ++) {//坐标点校验 大于0 且不大于视图的宽度/高度
                CGFloat potx = fmax((CGFloat)largestRectangle[i].x, 0);
                potx = fminf(potx, size.width);
                
                CGFloat poty = fmax((CGFloat)largestRectangle[i].y, 0);
                poty = fminf(poty, size.height);
                
                [points addObject:[NSValue valueWithCGPoint:(CGPoint){potx, poty}]];
            }
            
            CGPoint min = [points[0] CGPointValue];
            CGPoint max = min;
            for (NSValue *value in points) {
                CGPoint point = [value CGPointValue];
                min.x = fminf(point.x, min.x);
                min.y = fminf(point.y, min.y);
                max.x = fmaxf(point.x, max.x);
                max.y = fmaxf(point.y, max.y);
            }
            
            CGPoint center = {
                0.5f * (min.x + max.x),
                0.5f * (min.y + max.y),
            };
            
            NSNumber *(^angleFromPoint)(id) = ^(NSValue *value){
                CGPoint point = [value CGPointValue];
                CGFloat theta = atan2f(point.y - center.y, point.x - center.x);
                CGFloat angle = fmodf(M_PI - M_PI_4 + theta, 2 * M_PI);
                return @(angle);
            };
            
            NSArray *sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [angleFromPoint(a) compare:angleFromPoint(b)];
            }];
            
            NSMutableArray *squarePoints = [[NSMutableArray alloc] init];
            for (NSValue *value in sortedPoints) {
                [squarePoints addObject:value];
            }
            imageMat.release();
            
            return squarePoints;
        }
        else{
            imageMat.release();
            return nil;
        }
    }else{
        imageMat.release();
        return nil;
    }
    return nil;
}

void top_getRectangles(cv::Mat& image, std::vector<std::vector<cv::Point> >&rectangles) {
    cv::Mat blurred(image);
    cv::cvtColor(blurred, blurred, cv::COLOR_BGR2GRAY);
    GaussianBlur(image, blurred, cvSize(11,11), 0);
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point> > contours;
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            if (l == 0)
            {
                Canny(gray0, gray,  5, 150, 5);
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 1000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        rectangles.push_back(approx);
                }
            }
        }
    }
}

void top_getlargestRectangle(const std::vector<std::vector<cv::Point> >& rectangles, std::vector<cv::Point>& largestRectangle)
{
    if (!rectangles.size())
    {
        return;
    }
    
    double maxArea = 0;
    int index = 0;
    
    for (size_t i = 0; i < rectangles.size(); i++)
    {
        std::vector<cv::Point> approx = rectangles[i];//存放四个角坐标的数组
        if (!approx.size()) {//判空防闪退
            return;
        }
        cv::Rect rectangle = boundingRect(cv::Mat(approx));
        double area = rectangle.width * rectangle.height;
                
        if (maxArea < area)
        {
            maxArea = area;
            index = (int)i;
        }
    }
    largestRectangle = rectangles[index];
}


double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}


+(UIImage *) top_getTransformedImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (CGPoint [4]) corners : (CGSize) size {
    
    cv::Mat imageMat;
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(origImage.CGImage);
    CGFloat cols = size.width;
    CGFloat rows = size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), origImage.CGImage);
    CGContextRelease(contextRef);
    
    contextRef = nil;
    imageMat = cvMat;
    cv::Mat newImageMat = cv::Mat( cvSize(newWidth,newHeight), CV_8UC4);
    cv::Point2f src[4], dst[4];
    src[0].x = corners[0].x;
    src[0].y = corners[0].y;
    src[1].x = corners[1].x;
    src[1].y = corners[1].y;
    src[2].x = corners[2].x;
    src[2].y = corners[2].y;
    src[3].x = corners[3].x;
    src[3].y = corners[3].y;
    
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = newWidth;
    dst[1].y = 0;
    dst[2].x = newWidth;
    dst[2].y = newHeight;
    dst[3].x = 0;
    dst[3].y = newHeight;
    
    cv::warpPerspective(imageMat, newImageMat, cv::getPerspectiveTransform(src, dst), cvSize(newWidth, newHeight));
    NSData *data = [NSData dataWithBytes:newImageMat.data length:newImageMat.elemSize() * newImageMat.total()];
    CGColorSpaceRef colorSpace2;
    if (newImageMat.elemSize() == 1) {
        colorSpace2 = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace2 = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGFloat width = newImageMat.cols;
    CGFloat height = newImageMat.rows;
    
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        8 * newImageMat.elemSize(),
                                        newImageMat.step[0],
                                        colorSpace2,
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace2);
    
    cvMat.release();
    imageMat.release();
    newImageMat.release();
    return image;
}

+(UIImage *) top_getTransformedObjectImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (NSArray *) corners : (CGSize) size {
    if (size.width <= 0 || size.height <= 0) {
        return origImage;
    }
    
    cv::Mat imageMat;
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(origImage.CGImage);
    CGFloat cols = size.width;
    CGFloat rows = size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), origImage.CGImage);
    CGContextRelease(contextRef);
    contextRef = nil;
    imageMat = cvMat;
    cv::Mat newImageMat = cv::Mat( cvSize(newWidth,newHeight), CV_8UC4);
    cv::Point2f src[4], dst[4];
    for (int i = 0; i < corners.count; i ++) {
        NSValue * value = [corners objectAtIndex:i];
        src[i].x = value.CGPointValue.x;
        src[i].y = value.CGPointValue.y;
    }
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = newWidth;
    dst[1].y = 0;
    dst[2].x = newWidth;
    dst[2].y = newHeight;
    dst[3].x = 0;
    dst[3].y = newHeight;
    
    cv::warpPerspective(imageMat, newImageMat, cv::getPerspectiveTransform(src, dst), cvSize(newWidth, newHeight));
    NSData *data = [NSData dataWithBytes:newImageMat.data length:newImageMat.elemSize() * newImageMat.total()];
    CGColorSpaceRef colorSpace2;
    if (newImageMat.elemSize() == 1) {
        colorSpace2 = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace2 = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGFloat width = newImageMat.cols;
    CGFloat height = newImageMat.rows;
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        8 * newImageMat.elemSize(),
                                        newImageMat.step[0],
                                        colorSpace2,
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace2);
    
    
    cvMat.release();
    imageMat.release();
    newImageMat.release();
    return image;
}

+ (cv::Mat)top_cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    return cvMat;
}

+ (UIImage *)top_getNoShardingImage:(UIImage *)origImage {
    UIImage *image = origImage;
    cv::Mat imageMat = [self top_cvMatFromUIImage:image];

    Mat src = top_handleImageMain(imageMat);
    UIImage *newImage = [self top_UIImageFromCVMat:src];
    return newImage;
}

Mat top_handleImageMain(Mat image) {
    Mat src = image;
    Mat gray;
    cvtColor(src, gray, COLOR_BGR2GRAY);
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(3, 3));
    int iteration = 9;
    Mat dilateMat;
    morphologyEx(gray, dilateMat, MORPH_DILATE, element, cv::Point(-1, -1), iteration);
    Mat erodeMat;
    morphologyEx(dilateMat, erodeMat, MORPH_ERODE, element, cv::Point(-1, -1), iteration);
    Mat calcMat = ~(erodeMat - gray);
    return calcMat;
}

+ (UIImage *)top_UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
