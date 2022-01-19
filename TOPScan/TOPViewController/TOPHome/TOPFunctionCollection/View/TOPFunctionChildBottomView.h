#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFunctionChildBottomView : UIView
@property (nonatomic,strong)UIButton * myBtn;
@property (nonatomic,copy)void(^top_clickBtnBlock)(void);
@end

NS_ASSUME_NONNULL_END
