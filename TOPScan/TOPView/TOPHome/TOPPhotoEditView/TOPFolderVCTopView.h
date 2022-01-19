#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFolderVCTopView : UIView
@property (nonatomic, copy) void(^top_DocumentHeadClickHandler)(NSInteger index,BOOL selected);
@property (nonatomic, copy) void(^top_clickTap)(void);

@property (nonatomic, copy) NSString * titleString;

- (void)top_setupUITopHAgain;
- (void)top_setupUITopHRestore;
- (void)top_refreshViewTypeBtn;
@end

NS_ASSUME_NONNULL_END
