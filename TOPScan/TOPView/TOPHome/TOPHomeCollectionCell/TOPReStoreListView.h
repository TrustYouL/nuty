#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPReStoreListView : UIView
@property (strong, nonatomic) void(^saveSelectBlock)(NSString *selectItemName);
@property (assign, nonatomic)  TOPDownLoadDataStyle showStyle;
+(instancetype)top_creatXIB;
-(void)top_showXib;
-(void)top_closeXib;
@property (nonatomic,strong) NSMutableArray<GTLRDrive_File *> *driveGoogleDataArrays;
@property (nonatomic,strong) NSMutableArray<DBFILESMetadata *> *dropBoxDataArrays;
@property (nonatomic,strong) NSMutableArray<BOXItem *> *boxDataArrays;
@property (nonatomic,strong) NSMutableArray<ODItem *> *oneDriveDataArrays;
@end

NS_ASSUME_NONNULL_END
