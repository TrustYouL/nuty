#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPConnectorView : UIView
@property (nonatomic, copy) NSString *peerId;

- (instancetype)initWithTitle:(NSString *)title role:(BOOL)sender cancelBlock:(void (^)(void))cancelBlock completeBlock:(void (^)(void))completeBlock;

- (void)top_dismissView;

@end

NS_ASSUME_NONNULL_END
