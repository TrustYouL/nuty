#import <Foundation/Foundation.h>
#import "TOPSaveElementModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPDataModelHandler : NSObject
/// 构造主界面数据
+ (NSMutableArray *)top_buildHomeData;
///对模型数据排序 dataArray排序的模型数组
///type=yes是首页数据 type=no不是首页
///path界面路径
+ (NSMutableArray *)top_loadDataSortAgain:(NSMutableArray *)dataArray withType:(BOOL)type withPath:(NSString *)path;
///doc类文档和folder类文档的前后排序 dataArray排序的模型数组
+ (NSMutableArray *)top_docFolerBeforeAndAfter:(NSMutableArray *)dataArray;
/// Folder次级界面数据
/// @param path 当前目录
+ (NSMutableArray *)top_buildFolderSecondaryDataAtPath:(NSString *)path;
/// Document次级界面数据
/// @param path 当前目录
+ (NSMutableArray *)top_buildDocumentSecondaryDataAtPath:(NSString *)path;
///搜索界面数据
+ (NSMutableArray *)top_buildSearchDataAtPath:(NSString *)path;
/// 根据设置条件排序(tags标签) 这个针对的是tags标签 tags标签是按创建时间的顺序排列
+ (NSMutableArray *)top_sortTagsFileData:(NSArray *)blFdArray atPath:(NSString *)path;
#pragma mark -- Folder数据模型下Document的数据 -- Folders目录下 folderPath:文件路径
///@param folderPath Folder文件夹路径
+ (NSArray *)top_getFolderBottomDocumentWithPath:(NSString *)folderPath;
/// -- 生成一张中等大小的缩率图用作展示存放在一个临时文件备用
+ (void)top_createMidCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath;
/// 生成一张缩率图用作展示存放在一个临时文件备用
/// @param imagePath 源图片
/// @param coverImagePath 缩略图路径
+ (void)top_createCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath;
+ (void)top_getCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath complete:(nonnull void (^)(NSString * imgPath))complete;
+ (void)top_updateCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath;
///构造Folder数据模型
+ (DocumentModel *)top_buildFolderTargetModelWithPath:(NSString *)filePath;
///@param dtStr doc文件夹的路径
+ (DocumentModel *)top_buildDocumentTargetModelWithPath:(NSString *)dtStr;
/// 选中的图片
/// @param selectFiles 选中的文件 <DocumentModel>
+ (NSArray *)top_selectedImageArray:(NSArray *)selectFiles;
///根据路径创建model
///@param dtStr 图片名
///@param path 图片所在文件夹路径
+ (DocumentModel *)top_buildImageModelWithName:(NSString *)dtStr atPath:(NSString *)path;
+ (BOOL)top_documentIsThereAnyData:(NSString *)path;
///获取document文件夹下Tags文件夹的数据
+ (NSArray *)top_getDocumentTagsArrayWithPath:(NSString *)dtStr;
///获取标签列表数据
+ (NSMutableArray *)top_getTagsListData;
///获取所有doc文件夹数据
+ (NSMutableArray *)top_getDocArray:(NSMutableArray *)buildArray;
///获取标签管理页面的数据 数据是需要排列的
+ (NSMutableArray *)top_getTagsListManagerData;
///创建没有标签的数据模型
+ (TOPTagsListModel *)top_ungrouperListModelWithDocArray:(NSMutableArray * )docArray;
///根据标签文件夹路径创建标签模型
+ (TOPTagsModel *)top_buildDocumentBottomTOPTagsModelWithPath:(NSString *)dtStr;
///管理界面对tag重新排序
+ (NSMutableArray *)top_tagsManagerListSort:(NSMutableArray *)tagsArray;
#pragma mark -- 根据名字再进行一次排序 这里是满足底部的sorty by功能
+ (NSArray *)top_imageSortWithData:(NSArray *)data;
///image展示的图片
///fatherWidth默认设置展示图片的宽
///fatherHeight默认设置展示图片的高
+ (CGRect)top_adaptiveBGImage:(UIImage *)image fatherW:(CGFloat)fatherWidth fatherH:(CGFloat)fatherHeight;
///图片自动裁剪时需要保存的坐标数据
+ (TOPSaveElementModel *)top_getBatchSavePointData:(NSArray *)pointArray imgPath:(NSString *)originalPath imgRect:(CGRect)imgRect;
+ (TOPSaveElementModel *)top_getBatchSavePointData:(NSArray *)pointArray img:(UIImage *)originalImg imgRect:(CGRect)imgRect;
/// -- 坐标点转换 准备存入数据库
+ (NSMutableArray *)top_pointsFromModel:(TOPSaveElementModel *)elementModel;
/// -- 校验手动裁剪坐标和自动裁剪坐标是否相同
+ (BOOL)top_pointEqual:(NSString *)imageId;
/// -- 校验两组坐标是否相同
+ (BOOL)top_comparePointsIsEqual:(NSArray *)points withOtherPoints:(NSArray *)autoPoints;
/// -- valuePoint 类型坐标点数据比较 相同返回no， 否则yes
+ (BOOL)top_compareArray:(NSMutableArray *)array1 withArray:(NSMutableArray *)array2;
/// 读取功能权限配置文件
+ (NSDictionary *)top_readPermissionJsonFile;
+ (NSString *)top_permissionKey:(TOPPermissionType)type;
/// 写入权限的配置文件
+ (void)top_configPermissionJsonFile;
@end

NS_ASSUME_NONNULL_END
