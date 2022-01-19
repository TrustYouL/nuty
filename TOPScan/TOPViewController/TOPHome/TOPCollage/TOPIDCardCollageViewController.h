#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPIDCardCollageViewController : TOPBaseViewController
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSArray *imagePathArr;
@property (nonatomic, strong) DocumentModel *docModel;
@property (assign, nonatomic) TOPEnterCameraType enterCameraType;
@property (nonatomic,strong)NSMutableArray * cameraArray;
@property (copy, nonatomic) void(^top_backBtnAction)(void);
@property (copy, nonatomic) void(^top_finishBtnAction)(void);

@end

NS_ASSUME_NONNULL_END
