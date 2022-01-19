#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingFormatModel : NSObject<NSCoding>
@property (nonatomic ,copy)NSString * iconImg;
@property (nonatomic ,copy)NSString * formatString;
@property (nonatomic ,copy)NSString * timeStyle;
@property (nonatomic ,assign)CGFloat pixValue;
@property (nonatomic ,assign)NSInteger processType;
@property (nonatomic ,assign)BOOL isSelect;
@property (nonatomic, assign) BOOL showVip;//是否显示vip
@end

NS_ASSUME_NONNULL_END
