#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TOPAlertActionStyle) {
    TOPAlertActionStyleDefault = 0,
    TOPAlertActionStyleCancel,
    TOPAlertActionStyleDestructive
} API_AVAILABLE(ios(9.0));


UIKIT_EXTERN API_AVAILABLE(ios(9.0)) @interface TOPAlertAction : NSObject
+ (instancetype)actionWithTitle:(nullable NSString *)title style:(TOPAlertActionStyle)style handler:(void (^ __nullable)(TOPAlertAction *action))handler;
+ (instancetype)actionWithCustomView:(UIView *)customView style:(TOPAlertActionStyle)style handler:(void (^ __nullable)(TOPAlertAction *action))handler;
@property (nullable, nonatomic, readonly) NSString *title;
@property (nullable, nonatomic, readonly) UIView *customView;
@property (nonatomic, readonly) TOPAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, readonly) void (^handler)(TOPAlertAction *action);

@end

NS_ASSUME_NONNULL_END
