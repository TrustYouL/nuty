#import <UIKit/UIKit.h>

@class TOPCollageModel, StickerView;
NS_ASSUME_NONNULL_BEGIN

@interface TOPCollageViewCell : UICollectionViewCell
@property (strong, nonatomic) TOPCollageModel *collageModel;
@property (nonatomic, assign) BOOL idCardModel;
@property (nonatomic,copy) void(^top_beginDragBlock)(StickerView *dragView);
@property (nonatomic,copy) void(^top_beginMovingBlock)(StickerView *dragView, CGPoint target);
- (void)top_addStickerView:(StickerView *)sticker;
- (void)top_showWaterMarkView;
- (void)top_hiddenWaterMarkView;
@end

NS_ASSUME_NONNULL_END
