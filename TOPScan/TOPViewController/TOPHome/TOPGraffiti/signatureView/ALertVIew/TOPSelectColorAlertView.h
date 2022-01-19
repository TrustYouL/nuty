#import <UIKit/UIKit.h>

@interface TOPSelectColorAlertView : UIView
@property (strong, nonatomic) void(^saveColorSelectBlock)(UIColor *currentColor);
@property (nonatomic,assign) NSInteger jumpType;
+(instancetype)top_creatXIB;
-(void)top_showXib;
-(void)top_closeXib;
@end
