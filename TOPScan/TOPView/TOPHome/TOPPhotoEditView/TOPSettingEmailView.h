#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingEmailView : UIView
@property (nonatomic ,copy)void(^top_clickToDismiss)(void);
@property (nonatomic ,copy)void(^top_keyboardToChangeFream)(void);
@property (nonatomic ,copy)void(^top_returnToOriginalFream)(void);
@property (nonatomic ,assign)BOOL isKeyBoardShow;//视图弹出就弹出键盘
@end

NS_ASSUME_NONNULL_END
