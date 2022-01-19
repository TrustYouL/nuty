#import <UIKit/UIKit.h>

@class GKCycleScrollViewCell;

typedef void(^cellClickBlock)(NSInteger index);
@interface GKCycleScrollViewCell : UIView
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UIView        *coverView;
@property (nonatomic, copy) cellClickBlock  didCellClick;

- (void)setupCellFrame:(CGRect)frame;

@end
