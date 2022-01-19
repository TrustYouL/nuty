#import <UIKit/UIKit.h>

@interface TOPMagnifierView : UIWindow
//放大框
@property(nonatomic,strong)UIView * magnifyView;
//触摸点
@property(nonatomic)CGPoint pointTomagnify;
@end
