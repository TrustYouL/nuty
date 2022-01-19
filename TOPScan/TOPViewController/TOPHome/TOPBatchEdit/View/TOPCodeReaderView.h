#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCodeReaderView : UIView
@property (nonatomic ,copy)void(^codeReaderFinish)(NSString * resultAsString);
@property (nonatomic ,strong)NSTimer * timer;
- (void)startRun;
- (void)stopRun;
- (void)animationAction;
- (void)toggleTorch;
- (void)toggleTorchClose;
@end

NS_ASSUME_NONNULL_END
