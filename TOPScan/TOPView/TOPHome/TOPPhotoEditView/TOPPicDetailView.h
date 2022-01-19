#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPicDetailView : UIView
@property (nonatomic ,copy)NSString * imgPath;
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)dataArray;
@end

NS_ASSUME_NONNULL_END
