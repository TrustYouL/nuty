#import <UIKit/UIKit.h>
#import "TOPCropEditModel.h"
#import "TopScanner-Swift.h"
#import "TOPMagnifierView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPBatchCell : UICollectionViewCell<CropViewDelegate>
@property (nonatomic ,strong)UIImageView * img;
@property (nonatomic ,strong)TOPCropEditModel * model;
@property (nonatomic,assign)TOPBatchCropType batchCropType;
@property (nonatomic ,strong)TOPCropView * cropView;
@property (nonatomic ,strong)TOPMagnifierView *magnifierView;
@property (nonatomic ,copy)void (^top_saveChangeData)(void);
@property (nonatomic ,copy)void (^top_saveAutomaticData)(NSArray * elementArray,TOPCropEditModel * model);
@end

NS_ASSUME_NONNULL_END
