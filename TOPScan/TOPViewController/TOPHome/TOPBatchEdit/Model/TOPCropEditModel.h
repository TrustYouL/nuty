#import <Foundation/Foundation.h>
#import "TOPSaveElementModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPCropEditModel : NSObject
@property(nonatomic ,assign)NSInteger index;//在数组中的位置
@property(nonatomic ,copy)NSString * picName;//图片名称
@property(nonatomic ,copy)NSString * originalPath;//源图
@property(nonatomic ,copy)NSString * imgPath;//展示的效果图
@property(nonatomic ,copy)NSString * cropImgPath;//拍照用到的模版图
@property(nonatomic ,copy)NSString * adjustPicPath;//调节模版图的路径（入口是相机时用到）
@property(nonatomic ,copy)NSString * coverImgPath;//展示的缩略图
@property(nonatomic ,copy)NSString * showPath;//展示的大图
@property(nonatomic ,assign)NSInteger processType;//渲染类型
@property(nonatomic ,assign)BOOL isChangeType;//是手势的操作NO 还是视图底部按钮自动切换的操作Yes
@property(nonatomic ,assign)BOOL isChange;//是否做过操作
@property(nonatomic ,assign)BOOL isAutomatic;
@property(nonatomic ,strong)TOPSaveElementModel * elementModel;
@property(nonatomic ,strong)NSMutableArray * showEndPoinArray;//最后一次操作的四点坐标(用于试图的展示，点击all按钮和右上方按钮会重新赋值)
@property(nonatomic ,strong)NSMutableArray * endPoinArray;//最后一次操作的四点坐标（用于最后保存的逻辑判断依据, 裁剪完成点击保存按钮会重新赋值）
@property(nonatomic ,strong)NSMutableArray * autoEndPoinArray;//裁剪框的四个点的坐标 没有处理的原始数据(自动识别)
@property(nonatomic ,strong)NSMutableArray * notAutoEndPoinArray;//裁剪框的四个点的坐标 没有处理的原始数据(没有自动识别)
@property(nonatomic ,copy) NSArray  *leftCropBtnStates;//按钮有几种状态：full，fit，auto，如果裁剪坐标和自动裁剪坐标相同，则显示full，auto--默认显示fit的裁剪点，对应按钮是auto
@property(nonatomic ,assign) TOPCropBtnState cropState;
@property(nonatomic ,assign) BOOL isNotAutoEndPoint;//最后保存的坐标是否和图片四个顶点坐标相等 YES相等 NO不想等
@end

NS_ASSUME_NONNULL_END
