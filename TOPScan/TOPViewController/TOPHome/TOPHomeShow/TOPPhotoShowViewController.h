#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface TOPPhotoShowViewController : TOPBaseChildViewController 
@property (nonatomic, copy) NSString *pathString;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray *imageFrames;
@property (nonatomic, assign) NSInteger enterType;
@property (nonatomic, copy) void(^top_DismissBlock)(DocumentModel * sendModel);
@property (nonatomic, copy) void(^top_DeleteAllData)(void);
@end

NS_ASSUME_NONNULL_END
