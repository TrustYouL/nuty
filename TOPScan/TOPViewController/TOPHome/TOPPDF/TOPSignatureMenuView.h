#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSignatureMenuView : UIView
@property (nonatomic,copy) void(^top_clickAddBtnBlock)(void);
@property (nonatomic,copy) void(^top_selectSignatureBlock)(NSString *imgPath);
@property (nonatomic, weak) UIViewController *superVC;

- (void)top_configContentData;

@end

NS_ASSUME_NONNULL_END
