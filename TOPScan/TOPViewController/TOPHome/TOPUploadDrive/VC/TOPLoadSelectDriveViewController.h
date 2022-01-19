#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPLoadSelectDriveViewController : TOPBaseChildViewController
@property (nonatomic, assign) TOPDriveOpenStyleType openDrivetype;
@property (nonatomic, assign) TOPDownloadFileToDriveAddPathType downloadFileType;
@property (nonatomic, copy) NSString  *docId;
@property (nonatomic, copy) NSString  *downloadFileSavePath;
@property (nonatomic, strong) NSMutableArray *uploadDatas;
@property (nonatomic, assign) BOOL isSingleUpload;
@end

NS_ASSUME_NONNULL_END
