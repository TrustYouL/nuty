#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShareTypeView : UIView
@property (nonatomic ,copy)NSString * numberStr;
- (instancetype)initWithTitleView:(UIView *)titleView
                      titleArray:(NSArray *)titleArray
                      picArray:(NSArray *)picArray
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void(^)(void))cancelBlock
                      selectBlock:(void(^)(NSInteger row ,NSString * totalSize))selectBlock;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *backView;
@property (strong, nonatomic) NSArray * selectArray;
@property (assign, nonatomic) BOOL showSectionHeader;
@property (assign, nonatomic) CGFloat totalSizeNum;
@property (assign, nonatomic) TOPPopUpBounceViewType popType;
@end

NS_ASSUME_NONNULL_END
