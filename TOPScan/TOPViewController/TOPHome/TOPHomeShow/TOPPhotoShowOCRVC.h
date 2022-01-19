#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoShowOCRVC : UIViewController
@property (copy, nonatomic) NSString *filePath;
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic, strong) DocumentModel *docModel;
@property (nonatomic, strong) NSMutableArray * imagePathArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy)void(^top_clickToReloadData)(NSInteger index);
@property (nonatomic, assign) TOPPhotoShowOCRVCAgainType ocrAgain;
@property (nonatomic, assign) TOPPhotoShowTextAgainVCBackType backType;
@property (nonatomic, assign) TOPPhotoShowOCRVCAgainFinishType finishType;
@property (nonatomic, assign) TOPEnterShowOCRVCType enterType;
@property (nonatomic, assign) TOPOCRDataType dataType;
@property (nonatomic, copy)NSString * countString;
@end

NS_ASSUME_NONNULL_END
