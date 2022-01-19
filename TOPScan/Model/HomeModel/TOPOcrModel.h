#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPOcrModel : NSObject
@property (nonatomic ,assign)NSInteger index;
@property (nonatomic ,copy)NSString * imgPath;
@property (nonatomic ,copy)NSString * photoName;
@property (nonatomic ,copy)NSString * movePath;
@property (nonatomic ,copy)NSString * photoIndex;
@property (nonatomic ,copy)NSString * ocrPath;
@property (nonatomic ,copy)NSString * ocr;

//ocr识别用到
@property (nonatomic, assign) BOOL isChange;//是否裁剪过
@property (nonatomic, assign) CGRect ocrRect;//裁剪的坐标
@end

NS_ASSUME_NONNULL_END
