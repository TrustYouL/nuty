#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCellularView : UIView
@property (nonatomic ,strong)UIView * maskView;
@property (nonatomic ,strong)UIView * contentView;
@property (nonatomic ,copy)void(^top_settingBlock)(void);
@end

NS_ASSUME_NONNULL_END
