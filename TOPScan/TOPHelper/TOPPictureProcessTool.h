
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TOPPictureProcessTool : NSObject
/// 利用GPUImage 滤镜处理图片
+ (UIImage *)top_imageWithImage:(GPUImagePicture*)GpuPic withImg:(UIImage *)img withItem:(NSInteger)item;
+ (UIImage *)top_scaleImageWithData:(NSData *)data withSize:(CGSize)size;
+ (UIImage *)top_fetchOriginalImageWithData:(NSData *)data;
+ (UIImage *)top_fetchOriginalImageWithData:(NSData *)data withSize:(CGFloat)imgSize;
+ (void)top_resizeOriginalImage:(NSData *)data atPath:(NSString *)path;
+ (UIImage *)top_waterMarkWithImage:(UIImage *)backgroundImage andWaterImage:(UIImage *)waterImage withRect:(CGRect)rect;
+ (UIImage *)top_imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image;
+ (UIImage *)top_removeWhiteColorWithImage:(UIImage *)image;
+ (UIImage *)top_rotationScaleImageWithImageView:(UIImageView *)subImageView;
+ (UIImage *)top_mergedImages:(NSArray *)imagesArray;
+ (UIImage*)top_imageWithColor:(UIColor*)color;
+ (NSArray *)top_processTypeArray;
+ (NSArray *)top_processTitles;
@end

NS_ASSUME_NONNULL_END
