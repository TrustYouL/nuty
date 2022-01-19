#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPDFSignatureViewController : UIViewController
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSArray *imagePathArr;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (nonatomic,copy) void(^top_savePDFSignatureBlock)(NSMutableArray *arr);

@end

NS_ASSUME_NONNULL_END
