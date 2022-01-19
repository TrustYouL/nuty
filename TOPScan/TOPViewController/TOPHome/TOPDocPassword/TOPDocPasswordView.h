#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPTextField;
@interface TOPDocPasswordView : UIView

@property (nonatomic, strong)TOPTextField * tField;
@property (nonatomic, strong)TOPTextField * againField;
@property (nonatomic ,assign)NSInteger actionType;//功能类型
@property (nonatomic ,copy) void (^top_sendPassword)(NSString * password,NSInteger actionType,BOOL isShowFailToast);
@property (nonatomic ,copy) void (^top_clickToHide)(void);
@property (nonatomic ,copy) void (^top_clickToHelp)(void);

- (void)top_beginEditing;
- (void)top_hiddenkeyboard;
@end

NS_ASSUME_NONNULL_END
