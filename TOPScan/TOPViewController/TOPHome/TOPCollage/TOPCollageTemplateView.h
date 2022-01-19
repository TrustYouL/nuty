#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCollageTemplateView : UIView

@property (copy, nonatomic) NSArray *templateItems;
@property (nonatomic,copy) void(^top_selectedHeadMenuBlock)(NSInteger item);
@end

NS_ASSUME_NONNULL_END
