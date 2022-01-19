#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSVPOCRShowView : UIView
@property (nonatomic ,copy)NSString * titleString;
@property (nonatomic ,copy)void(^top_clickAction)(void);
@end

NS_ASSUME_NONNULL_END
