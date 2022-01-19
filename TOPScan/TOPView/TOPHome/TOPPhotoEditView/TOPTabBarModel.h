#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTabBarModel : NSObject
@property (nonatomic, assign) BOOL isSelected;//是否选中
@property (nonatomic, assign) BOOL showVip;//是否显示vip
@property (nonatomic, assign) NSInteger functionType;//按钮对应的功能
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *icon_high;//高亮

@end

NS_ASSUME_NONNULL_END
