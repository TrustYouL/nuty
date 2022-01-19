#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingModel : NSObject
@property (nonatomic ,copy) NSString * myTitle;//标题
@property (nonatomic ,copy) NSString * myContent;//描述
@property (nonatomic ,assign) TOPSettingCellType checkValue;//是否有checkbox yes：有
@property (nonatomic ,assign) TOPSettingVCAction settingAction;
@property (nonatomic ,assign) CGFloat cellHeight;//cell高度

@end

NS_ASSUME_NONNULL_END
