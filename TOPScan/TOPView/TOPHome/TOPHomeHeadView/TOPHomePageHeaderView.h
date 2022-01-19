#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPHomePageHeaderView : UIView
@property (nonatomic, copy) void(^top_DocumentHeadClickHandler)(NSInteger index,BOOL selected);
- (void)top_setupUI;
- (void)top_changeChildHideState:(NSString*)titleString;
@end

NS_ASSUME_NONNULL_END
