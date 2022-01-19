#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSaveElementModel : NSObject
@property (nonatomic ,assign)CGFloat saveW;
@property (nonatomic ,assign)CGFloat saveH;
@property (nonatomic ,strong)UIImage * originalImage;
@property (nonatomic ,copy)NSString * originalPath;
@property (nonatomic ,copy)NSArray * pointArray;//裁剪框的四个点的坐标 处理过的数据
@end

NS_ASSUME_NONNULL_END
