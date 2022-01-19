#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBatchEditModel : NSObject
@property (nonatomic ,copy)NSString * originalPath;
@property (nonatomic ,copy)NSString * defaultPath;//旋转，渲染的模版图
@property (nonatomic ,copy)NSString * movePath;//document的路径
@property (nonatomic ,copy)NSString * imgPath;//展示的效果图
@property (nonatomic ,copy)NSString * coverImgPath;//展示的缩略图
@property (nonatomic ,copy)NSString * photoName;//带后缀的图片名称
@property (nonatomic ,copy)NSString * indexString;//下标字符串
@property (nonatomic ,assign)NSInteger index;//下标
@property (nonatomic ,assign)NSInteger processType;//渲染类型
@property (nonatomic ,assign)BOOL isChange;//是否做过旋转，渲染等操作
@property (nonatomic ,assign)BOOL selectStatus;//选中状态
@property (nonatomic ,assign)BOOL isShow;
@property (nonatomic ,strong)NSMutableArray * endPoinArray;//裁剪框的四个点的坐标 没有处理的原始数据
@property (nonatomic ,strong)NSMutableArray * cropImagePointArray;//裁剪图四个点的坐标 直接用于图片裁剪不需要再转换
@property (nonatomic ,assign) CGSize cropImageSize;//裁剪后的图片大小
@property (nonatomic ,assign) CGRect cropImgViewRect;//裁剪图的容器frame
@property (nonatomic ,strong)NSMutableArray * autoEndPoinArray;//裁剪框的四个点的坐标 没有处理的原始数据(自动识别)
@property (nonatomic, copy) NSString *docId;//目录id 数据库记录

@end

NS_ASSUME_NONNULL_END
