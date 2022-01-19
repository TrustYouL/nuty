#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GKPageControlStyle) {
    GKPageControlStyleSystem,       // 系统，默认类型
    GKPageControlStyleCycle,        // 圆形
    GKPageControlStyleRectangle,    // 长方形
    GKPageControlStyleSquare,       // 正方形
    GKPageControlStyleSizeDot       // 大小点
};

@interface GKPageControl : UIPageControl
@property (nonatomic, assign) GKPageControlStyle style;
@property (nonatomic, assign) CGFloat dotWidth;
@property (nonatomic, assign) CGFloat dotHeight;
@property (nonatomic, assign) CGFloat dotMargin;
@end

NS_ASSUME_NONNULL_END
