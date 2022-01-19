#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPColorMenuView : UIView
@property (strong, nonatomic) UIColor *currentColor;
@property (copy, nonatomic) NSArray *colorsArray;

@property (nonatomic, copy) void(^didSelectedItemBlock)(UIColor *textColor);

@end

NS_ASSUME_NONNULL_END
