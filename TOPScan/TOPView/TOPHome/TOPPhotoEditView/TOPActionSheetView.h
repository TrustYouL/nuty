#import <UIKit/UIKit.h>

@interface TOPActionSheetView : UIView
@property (nonatomic ,assign)NSInteger drawIndex;
- (instancetype)initWithTitleView:(UIView *)titleView
                       optionsArr:(NSArray *)optionsArr
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void(^)(void))cancelBlock
                      selectBlock:(void(^)(NSInteger index))selectBlock;

- (void)top_showView;
@end
