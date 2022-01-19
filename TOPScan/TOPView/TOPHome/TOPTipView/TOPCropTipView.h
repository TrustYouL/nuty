#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCropTipView : UIView
@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^okBlock)(void);
- (instancetype)initWithTipMessage:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
