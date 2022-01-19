#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPShareFileModel;
@interface TOPShareFileView : UIView

- (instancetype)initWithItemArray:(NSArray *)items doneTitle:(NSString *)doneTitle cancelBlock:(void (^)(void))cancelBlock selectBlock:(void (^)(TOPShareFileModel *))selectBlock;

- (void)top_updateSubViewsLayout;

@end

NS_ASSUME_NONNULL_END
