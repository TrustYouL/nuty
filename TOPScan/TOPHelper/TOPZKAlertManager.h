#import <UIKit/UIKit.h>

typedef void(^ZKAlertHandler)(BOOL isCancel);

@interface ZKAlert : NSObject
@property (nonatomic, readonly) NSInteger priority;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *message;
@property (nonatomic, readonly, copy) ZKAlertHandler handler;
@property (nonatomic) CGFloat delay;
@property (nonatomic, copy) dispatch_block_t didDismiss;
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     priority:(NSInteger)priority
                      handler:(ZKAlertHandler)handler NS_DESIGNATED_INITIALIZER;

+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                      priority:(NSInteger)priority
                       handler:(ZKAlertHandler)handler;
- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_BEGIN

@interface TOPZKAlertManager : NSObject
+ (instancetype)shareManager;
- (void)top_addAlert:(ZKAlert *)alert;
- (void)top_addAlerts:(NSArray<ZKAlert *> *)alerts;
- (void)top_showAlerts;

@end

NS_ASSUME_NONNULL_END
