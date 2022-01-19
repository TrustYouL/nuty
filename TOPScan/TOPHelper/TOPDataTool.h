#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TOPDataTool : NSObject
+(NSDictionary *)top_pictureProcessDatawithImg:(UIImage *)img currentItem:(NSInteger)item;
+(NSDictionary *)top_pictureProcessDatawithImgPath:(NSString *)path currentItem:(NSInteger)item;
+(NSMutableArray *)top_pictureProcessData:(UIImage *)imag;
+(UIImage *)top_pictureProcessData:(GPUImagePicture *)GpuPic withImg:(UIImage *)img withItem:(NSInteger)item;
@end

NS_ASSUME_NONNULL_END
