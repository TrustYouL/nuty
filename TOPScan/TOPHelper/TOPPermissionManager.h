#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TOPPermissionManager : NSObject
/// 过滤广告
+ (BOOL)top_enableByAdvertising;
/// 云识别OCR
+ (BOOL)top_enableByOCROnline;
/// 拼图保存
+ (BOOL)top_enableByCollageSave;
/// PDF水印
+ (BOOL)top_enableByPDFWaterMark;
/// PDF签名
+ (BOOL)top_enableByPDFSignature;
/// PDF页码
+ (BOOL)top_enableByPDFPageNO;
/// PDF密码
+ (BOOL)top_enableByPDFPassword;
/// EmailMySelf
+ (BOOL)top_enableByEmailMySelf;
/// 图片签名
+ (BOOL)top_enableByImageSign;
/// 图片涂鸦
+ (BOOL)top_enableByImageGraffiti;
/// 高质量图片
+ (BOOL)top_enableByImageHigh;
/// 超高质量图片
+ (BOOL)top_enableByImageSuperHigh;
/// -- 创建文件夹
+ (BOOL)top_enableByCreateFolder;
/// -- 上传文件
+ (BOOL)top_enableByUploadFile;
@end

NS_ASSUME_NONNULL_END
