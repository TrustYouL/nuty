#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPNewFolderInDriveViewController : TOPBaseChildViewController
@property (nonatomic, assign) TOPDownLoadDataStyle uploadDriveStyle;
@property (nonatomic, strong) BOXItem *boxCurrentItem;
@property (nonatomic, strong) BOXContentClient *boxContentClient;
@property (nonatomic, strong) DBUserClient *dropBoxContentClient;
@property (nonatomic, strong) DBFILESMetadata *dropBoxCurrentItem;
@property (strong, nonatomic) ODClient *oneDriveClient;
@property (strong, nonatomic) ODItem *oneDrivecurrentItem;
@property (strong, nonatomic) GTLRDriveService *googleDriveService;
//google
@property (nonatomic, strong) GTLRDrive_File *currentGoogleFileDrive;
@property (nonatomic,copy) void(^top_reloadCreatNewFolderWithListBlock)(void);
@end

NS_ASSUME_NONNULL_END
