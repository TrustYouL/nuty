#import <Foundation/Foundation.h>
#import "TOPSaveElementModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPCameraBatchModel : NSObject
@property (nonatomic ,assign)NSInteger cellType;//0表示图片类型的cell 1表示最后添加图片的cell
@property (nonatomic ,copy)NSString * PicName;
@property (nonatomic ,assign)BOOL isSelect;//是否需要重新渲染 也是渲染完成的标记 no的时候不需要重新渲染说明已经渲染完成 yes时表示需要重新渲染说明没有渲染完成
@property (nonatomic ,assign)BOOL isFirstEnter;//是否是第一次处理数据
@property (nonatomic ,assign)NSInteger processType;
@property (nonatomic ,strong)UIImage * rotationImg;
@property (nonatomic ,strong)UIImage * showImg;
@property (nonatomic ,copy)NSString * filterDicKey;
@property (nonatomic ,strong)NSMutableDictionary * filterSaveDic;
@property (nonatomic ,strong)NSMutableArray * autoEndPoinArray;//裁剪框的四个点的坐标 没有处理的原始数据(自动识别)
@property (nonatomic ,strong)NSMutableArray * notAutoEndPoinArray;//裁剪框的四个点的坐标 没有处理的原始数据(没有自动识别)
@property (nonatomic ,strong)NSMutableArray * endPoinArray;//保存最后一次裁剪的四点坐标
@property (nonatomic ,strong)TOPSaveElementModel * elementModel;
@property (nonatomic ,assign)BOOL isFinishCrop;//图片是否默认裁剪操作（图片没有做过裁剪操作 这种情况如果图片裁剪区域不是原图区域无论有没有做过手势移动或者按钮点击 最后点击完成按钮时都要做裁剪处理）
@property (nonatomic ,assign)CGFloat brightnessValue;//亮度
@property (nonatomic ,assign)CGFloat staturationValue;//饱和度
@property (nonatomic ,assign)CGFloat contrastValue;//对比度
@property (nonatomic ,copy)NSString * imgPath;//图片路径
@property (nonatomic ,copy)NSString * originalImgPath;//源图路径
@property (nonatomic ,assign) CGRect cropImgViewRect;//裁剪图的容器frame

@property (nonatomic ,copy)NSString * cropPath;
@property (nonatomic ,copy)NSString * adjustPicPath;

@end

NS_ASSUME_NONNULL_END
