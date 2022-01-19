#import <UIKit/UIKit.h>

@interface TOPSelectEraserAlertView : UIView
@property (strong, nonatomic) void(^saveLineWidthSelectBlock)(NSInteger currentLineWidth);
@property (nonatomic,assign) NSInteger jumpType;
+(instancetype)top_creatXIB;
-(void)top_showXib;
-(void)top_closeXib;
@end
