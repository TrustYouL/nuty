#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPUploadFileDriveCollectionVC : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, assign) TOPDriveOpenStyleType openDrivetype;
@property (nonatomic, assign) TOPDownloadFileToDriveAddPathType downloadFileType;
@property (nonatomic, copy) NSString  *docId;
@property (nonatomic, copy) NSString  *downloadFileSavePath;
@property (nonatomic, strong) NSMutableArray *uploadDatas;
@property (nonatomic, assign) BOOL isSingleUpload;

@property (nonatomic, strong)  NSMutableArray *boxItems;
@property (nonatomic, strong) BOXContentClient *contentClient;
@property (nonatomic, strong) NSArray<GTLRDrive_File *> *googleitems;
@property (nonatomic, strong)  BOXItem *boxCurrentItem;
- (void)top_loadChildren;
- (TOPUploadFileDriveCollectionVC *)collectionViewWithItem:(BOXItem *)item;
///- Google
@property (nonatomic, assign) TOPDownLoadDataStyle uploadDriveStyle;
@property (strong, nonatomic) GTLRDriveService *googleDriveService;
@property (nonatomic, strong) GTLRDrive_File *googleCurrentItem;
- (TOPUploadFileDriveCollectionVC *)collectionViewWithGoogleItem:(GTLRDrive_File *)item;
///- DropBox
@property NSMutableArray *dropBoxItems;
@property (nonatomic, strong) DBUserClient *dropBoxContentClient;
@property (nonatomic, strong) DBFILESMetadata *dropBoxCurrentItem;
- (TOPUploadFileDriveCollectionVC *)collectionViewWithDropBoxItem:(DBFILESMetadata *)item;
/// -OneDrive
@property (strong, nonatomic) NSMutableDictionary *oneDriveItems;
@property NSMutableArray *itemsLookup;
@property (strong, nonatomic) ODClient *oneDriveClient;
@property (strong, nonatomic) ODItem *oneDrivecurrentItem;
- (void)top_loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests;
- (TOPUploadFileDriveCollectionVC *)collectionViewWithOneDriveItem:(ODItem *)item;
@property (nonatomic, assign) TOPUpLoadToDriveFileType fileType;
@end

NS_ASSUME_NONNULL_END
