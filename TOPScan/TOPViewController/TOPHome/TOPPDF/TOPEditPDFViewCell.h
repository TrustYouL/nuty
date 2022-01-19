#import <UIKit/UIKit.h>

@class TOPEditPDFModel, StickerView;

NS_ASSUME_NONNULL_BEGIN

@interface TOPEditPDFViewCell : UICollectionViewCell
@property (nonatomic,copy) void(^top_beginReformBlock)(StickerView *dragView);

- (void)top_addStickerView:(StickerView *)sticker;
- (void)top_configCellWithData:(TOPEditPDFModel *)model;
- (void)top_showWaterMarkView;
- (void)top_hiddenWaterMarkView;

@end

NS_ASSUME_NONNULL_END
