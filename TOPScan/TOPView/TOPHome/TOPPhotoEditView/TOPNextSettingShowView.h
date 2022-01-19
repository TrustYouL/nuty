#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPNextSettingShowView : UIView
@property (nonatomic ,strong) NSArray * dataArray;
@property (nonatomic ,assign) TOPFormatterViewEnterType enterType;
@property (nonatomic ,copy)void(^top_clickToDismiss)(void);
@property (nonatomic ,copy)void(^top_clickCell)(NSString * formatString);
@property (nonatomic ,copy)void(^top_selectedJPGQualityBlock)(NSString * keyString,NSInteger row);
@property (nonatomic ,copy)void(^top_selectedProcessBlock)(void);
@property (nonatomic ,copy)void(^top_permissionAlertBlock)(void);
@property (nonatomic ,copy)void(^top_imgMoreBlock)(NSDictionary * dic);

@property (nonatomic ,copy)NSArray * filterArray;
@end

NS_ASSUME_NONNULL_END
