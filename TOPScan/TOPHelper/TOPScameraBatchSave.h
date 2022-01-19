#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPScameraBatchSave : NSObject
@property (nonatomic ,strong)NSMutableArray * images;
@property (nonatomic ,strong)NSMutableDictionary * saveShowDic;
@property (nonatomic ,assign)BOOL backType;//yes表示返回相机的方式是点击cancel按钮 no表示返回相机的方式是点击添加图片的按钮
@property (nonatomic ,assign)NSInteger currentIndex;//backType=yes时记录的当前位置
+ (instancetype)save;
@end

NS_ASSUME_NONNULL_END
