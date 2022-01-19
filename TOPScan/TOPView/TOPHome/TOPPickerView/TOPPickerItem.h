#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPickerItem : UIView

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, assign)CGSize originalSize;

@property (nonatomic, assign)BOOL selected;

@property (nonatomic, copy) void(^PickerItemSelectBlock)(NSInteger index);
- (void)changeSizeOfItem;
- (void)backSizeOfItem;
@end

NS_ASSUME_NONNULL_END
