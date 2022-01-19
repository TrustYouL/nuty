#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, WMDragDirection) {
    WMDragDirectionAny,          /**< 任意方向 */
    WMDragDirectionHorizontal,   /**< 水平方向 */
    WMDragDirectionVertical,     /**< 垂直方向 */
};

@interface TOPWMDragView : UIView
@property (nonatomic,assign) BOOL dragEnable;
@property (nonatomic,assign) CGRect freeRect;
@property (nonatomic,assign) WMDragDirection dragDirection;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,assign) BOOL isKeepBounds;
@property (nonatomic,copy) void(^clickDragViewBlock)(TOPWMDragView *dragView);
@property (nonatomic,copy) void(^top_beginDragBlock)(TOPWMDragView *dragView);
@property (nonatomic,copy) void(^duringDragBlock)(TOPWMDragView *dragView);
@property (nonatomic,copy) void(^endDragBlock)(TOPWMDragView *dragView);
@end


