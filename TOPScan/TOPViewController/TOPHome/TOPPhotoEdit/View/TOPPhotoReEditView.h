#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoReEditView : UIView
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic ,strong)void(^top_clickBtnBlock)(NSInteger tag);
- (instancetype)initWithFrame:(CGRect)frame iconArray:(NSArray *)iconArray titleArray:(NSArray *)titleArray;
@end

NS_ASSUME_NONNULL_END
