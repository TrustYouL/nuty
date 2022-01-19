#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPUserDefinedSizeView : UIView
@property (assign, nonatomic) NSInteger percentValue;
@property (assign, nonatomic) CGFloat fileSize;
@property (nonatomic,copy) void(^top_clickResultBtnBlock)(NSInteger percentVal);
@property (nonatomic,copy) void(^top_clickCancelBtnBlock)(void);
@end

NS_ASSUME_NONNULL_END
