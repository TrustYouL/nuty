#import <UIKit/UIKit.h>
#import "TOPSCScreenshotView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPQuestionImgCell : UITableViewCell
@property (nonatomic ,strong)TOPSCScreenshotView * screenshotView;
@property (nonatomic ,strong)NSMutableArray * imagesArray;
@property (nonatomic ,copy)void(^top_addScreenshotImg)(void);
@property (nonatomic ,copy)void(^top_showScreenshotImg)(NSInteger currentIndex);
@property (nonatomic ,copy)void(^top_deleteCurrentPic)(NSString * picName);
@property (nonatomic ,assign)BOOL reloadType;
@end

NS_ASSUME_NONNULL_END
