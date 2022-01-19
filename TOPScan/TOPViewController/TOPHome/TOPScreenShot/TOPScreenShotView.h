#import <UIKit/UIKit.h>
#import "TOPShareTypeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPScreenShotView : UIView
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)UIImage * showImage;
@property (nonatomic ,copy)void (^top_functionBlock)(NSInteger index);
@end

NS_ASSUME_NONNULL_END
