#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPChildMoreView : UIView
@property (copy, nonatomic) NSArray *menuItems;
- (instancetype)initWithTitleView:(UIView *)titleView
                      optionsArr:(NSArray *)optionsArr
                      iconArr:(NSArray *)iconArr
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void(^)(void))cancelBlock
                      selectBlock:(void(^)(NSInteger index))selectBlock;

@property (copy, nonatomic) NSArray *headMenuItems;
@property (assign, nonatomic) BOOL showHeadMenu;
@property (nonatomic ,strong)DocumentModel * docModel;
@property (nonatomic,copy) void(^top_selectedHeadMenuBlock)(NSInteger item);
- (void)top_updateWithNewData;

@end

NS_ASSUME_NONNULL_END
