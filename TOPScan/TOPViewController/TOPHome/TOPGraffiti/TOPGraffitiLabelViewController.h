#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPGraffitiLabelViewController : UIViewController

@property (nonatomic,assign) BOOL noCreateFile;
@property (nonatomic,copy) NSString *imagePath;
@property (nonatomic,copy) void(^top_saveEditedImgBlick)(void);

@end

NS_ASSUME_NONNULL_END
