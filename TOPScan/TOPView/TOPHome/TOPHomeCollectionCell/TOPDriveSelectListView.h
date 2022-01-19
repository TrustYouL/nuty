#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDriveSelectListView : UIView
@property (strong, nonatomic) void(^selectDriveBlock)(NSString *selectItemName);


+(instancetype)top_creatXIB;
-(void)top_showXib;
-(void)top_closeXib;
@property (nonatomic,strong) NSMutableArray *driveDataArrays;
@end

NS_ASSUME_NONNULL_END
