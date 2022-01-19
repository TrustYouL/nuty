#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSignatureLineWithCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *lineWithView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineWithConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;

@property (nonatomic,assign) NSInteger lineWidth;

@end

NS_ASSUME_NONNULL_END
