#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, FXShowAdvertisingStyle) {
    FXShowAdvertisingStyleDefault = 0,//默认新增
    FXShowAdvertisingStyleRewarded = 1 //视频
    
};
@interface TOPSelectLineWithAlertView : UIView
@property (strong, nonatomic) void(^saveLineWidthSelectBlock)(NSInteger currentLineWidth);
@property (nonatomic,assign) NSInteger jumpType;
+(instancetype)top_creatXIB;
-(void)top_showXib;
-(void)top_closeXib;
@end
