#import <UIKit/UIKit.h>
@interface TOPDownProgressAlertView : UIView
@property (strong, nonatomic) void(^closeViewBlock)(void);
@property (nonatomic,assign) NSInteger downTotalCount;
@property (nonatomic,assign) NSInteger currentIndexCount;
@property (nonatomic,assign) float progressFloat;
@property (nonatomic,copy) NSString *titleName;
@property (nonatomic,strong) NSProgress *progress;

+(instancetype)top_creatXIB;
-(void)top_showXib;
-(void)top_closeXib;
-(void)top_hideProgress;
@end
