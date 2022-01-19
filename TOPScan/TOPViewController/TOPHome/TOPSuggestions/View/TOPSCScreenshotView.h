#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSCScreenshotView : UIView
@property (nonatomic, strong)NSMutableArray * imagesArray;
@property (nonatomic ,assign)BOOL reloadType;
@property (nonatomic, copy)void(^top_addScreenshotImg)(void);
@property (nonatomic, copy)void(^top_showScreenshotImg)(NSInteger currentIndex);
@property (nonatomic ,copy)void(^top_deleteCurrentPic)(NSString * picName);
@end 

NS_ASSUME_NONNULL_END
