

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPImageFile : RLMObject

/**
 *  ID
 */
@property NSString *Id;
/**
 *  父id  上级目录的id
 */
@property NSString *parentId;
/**
 *  文件夹路径id 上级目录的pathId + Id
 */
@property NSString *pathId;
/**
 *  文件夹路径 **不存数据库 设置忽略属性
 */
@property NSString *filePath;
/**
 *  图片名 01，02，03 **不存数据库 设置忽略属性
 */
@property NSString *name;
/**
 *  文件大小
 */
@property long fileLength;
/**
 *  文件名字 自动生成
 */
@property NSString *fileName;
/**
 *  图片排序索引 截取根据图片名后缀
 */
@property (readonly) NSString *picIndex;
/**
 *  文件展示名字 实际显示用户可自定义
 */
@property NSString *fileShowName;
/**
 *  driveId
 */
@property NSString *driveId;
/**
 *  boxid
 */
@property NSString *boxId;
/**
 * dropboxId
 */
@property NSString *dropBoxId;
/**
 * onedriveId
 */
@property NSString *oneDriveId;
/**
 * onenoteId
 */
@property NSString *oneNoteId;
/**
 * envrnoteId
 */
@property NSString *envrNoteId;
/**
 * upload time
 */
@property NSString *uploadTime;
/**
 *  创建时间
 */
@property NSDate *ctime;
/**
 *  更新时间
 */
@property NSDate *utime;
/**
 *  是否被删除
 */
@property BOOL isDelete;
/**
 *  是否上传成功
 */
@property BOOL isUploadSuccess;
/**
 *  是否上传
 */
@property BOOL isUpload;
/**
 *  竖屏裁剪点
 */
@property NSData *portraitPoints;
/**
 *  横屏裁剪点
 */
@property NSData *landscapePoints;
/**
 *  竖屏自动裁剪点
 */
@property NSData *atuoPortraitPoints;
/**
 *  横屏自动裁剪点
 */
@property NSData *autoLandscapePoints;
/**
 *  图片朝向  上 0 、下 1、 左 2、 右 3
 */
@property int orientation;
@property int filterMode;

@end

NS_ASSUME_NONNULL_END
RLM_COLLECTION_TYPE(TOPImageFile)
