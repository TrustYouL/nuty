#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoShowTextAgainVC : UIViewController
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) TOPPhotoShowTextAgainVCBackType backType;
@property (nonatomic, assign) TOPOCRDataType dataType;
@property (copy, nonatomic) NSString *filePath;
@end

NS_ASSUME_NONNULL_END
