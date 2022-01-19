#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger,RestoreClickStyle) {
    RestoreClickStyleDelete = 0,
    RestoreClickStyleRestore=1
};

NS_ASSUME_NONNULL_BEGIN

@interface TOPReStoreItemTableViewCell : UITableViewCell
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIButton * reStoreButton;
@property (nonatomic ,strong)UIButton * deleteButton;
@property (nonatomic ,strong)GTLRDrive_File *driveFile;
@property (nonatomic ,strong)BOXItem *boxDriveFile;
@property (nonatomic ,strong)ODItem *oneDriveFile;
@property (nonatomic ,strong)DBFILESMetadata *dropBoxFile;
@property (nonatomic,copy) void(^top_didItemClick)(RestoreClickStyle clickStyle,GTLRDrive_File *driveFile);
@property (nonatomic,copy) void(^top_didDropBoxItemClick)(RestoreClickStyle clickStyle,DBFILESMetadata *dropBoxFile);
@property (nonatomic,copy) void(^top_didBoxDriveItemClick)(RestoreClickStyle clickStyle,BOXItem *boxItemFile);
@property (nonatomic,copy) void(^top_didOneBoxDriveItemClick)(RestoreClickStyle clickStyle,ODItem *odItemFile);

@end

NS_ASSUME_NONNULL_END
