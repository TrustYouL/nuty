#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPFileTargetModel;
@interface TOPFileTargetListViewController : UIViewController
@property (assign, nonatomic) TOPFileHandleType fileHandleType;
@property (assign, nonatomic) TOPFileTargetType fileTargetType;
@property (copy, nonatomic) NSString *currentFilePath;
@property (nonatomic, copy) void(^top_callBackFilePathBlock)(NSString *path);
@property (nonatomic, copy) void(^top_clickCancelBlock)(void);

@end

NS_ASSUME_NONNULL_END
