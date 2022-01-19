#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSCameraViewController : UIViewController
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, copy) NSString *pathString;
@property (nonatomic, assign) TOPEnterCameraType fileType;
@property (nonatomic, assign) TOPHomeChildViewControllerBackType backType;
@property (nonatomic, copy)void(^top_sCamerDissmissToReloadData)(NSArray * assets);
@property (nonatomic, copy)void(^top_dismissAndReloadData)(void);
@property (nonatomic, strong) DocumentModel * sendModel;
@property (nonatomic, copy)NSString * imageName;
@end

NS_ASSUME_NONNULL_END
