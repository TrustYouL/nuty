

#import <UIKit/UIKit.h>
@interface TOPYYForgotPasswordAlertView : UIView

@property (strong, nonatomic) void(^sendTextForgotPasswordBlock)(NSString *tempName);


+(instancetype)top_creatXIB;
-(void)top_showXib;
-(void)top_closeXib;
-(void)top_showXibSupview:(UIView *)supView;

@property (nonatomic,copy)NSString *customTitleStr;


@end
