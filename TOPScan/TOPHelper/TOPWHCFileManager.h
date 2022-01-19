#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TOPWHCFileManager : NSObject

#pragma mark - 沙盒目录相关
// 沙盒的主目录路径
+ (NSString *)top_homeDir;
// 沙盒中Documents的目录路径
+ (NSString *)top_documentsDir;
// 沙盒中Library的目录路径
+ (NSString *)top_libraryDir;
/// 沙盒中Application support目录 -- 建议用来存储除用户数据相关以外的所有文件 -- iTunes和iCloud备份时会备份该目录
+ (NSString *)top_appSupportDir;
// 沙盒中Libarary/Preferences的目录路径
+ (NSString *)top_preferencesDir;
// 沙盒中Library/Caches的目录路径
+ (NSString *)top_cachesDir;
// 沙盒中tmp的目录路径
+ (NSString *)top_tmpDir;

#pragma mark - 遍历文件夹
/**
 文件遍历
 
 @param path 目录的绝对路径
 @param deep 是否深遍历 (1. 浅遍历：返回当前目录下的所有文件和文件夹；
 2. 深遍历：返回当前目录下及子目录下的所有文件和文件夹)
 @return 遍历结果数组
 */
+ (NSArray *)top_listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;
// 遍历沙盒主目录
+ (NSArray *)top_listFilesInHomeDirectoryByDeep:(BOOL)deep;
// 遍历Documents目录
+ (NSArray *)top_listFilesInDocumentDirectoryByDeep:(BOOL)deep;
// 遍历Library目录
+ (NSArray *)top_listFilesInLibraryDirectoryByDeep:(BOOL)deep;
// 遍历Caches目录
+ (NSArray *)top_listFilisFileAtPathisFileAtPathesInCachesDirectoryByDeep:(BOOL)deep;
// 遍历tmp目录
+ (NSArray *)top_listFilesInTmpDirectoryByDeep:(BOOL)deep;

#pragma mark - 获取文件属性
// 根据key获取文件某个属性
+ (id)top_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key;
// 根据key获取文件某个属性(错误信息error)
+ (id)top_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;
// 获取文件属性集合
+ (NSDictionary *)top_attributesOfItemAtPath:(NSString *)path;
// 获取文件属性集合(错误信息error)
+ (NSDictionary *)top_attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 创建文件(夹)
// 创建文件夹
+ (BOOL)top_createDirectoryAtPath:(NSString *)path;
// 创建文件夹(错误信息error)
+ (BOOL)top_createDirectoryAtPath:(NSString *)path error:(NSError **)error;
// 创建文件
+ (BOOL)top_createFileAtPath:(NSString *)path;
// 创建文件(错误信息error)
+ (BOOL)top_createFileAtPath:(NSString *)path error:(NSError **)error;
// 创建文件，是否覆盖
+ (BOOL)top_createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite;
// 创建文件，是否覆盖(错误信息error)
+ (BOOL)top_createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error;
// 创建文件，文件内容
+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content;
// 创建文件，文件内容(错误信息error)
+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error;
// 创建文件，文件内容，是否覆盖
+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite;
// 创建文件，文件内容，是否覆盖(错误信息error)
+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error;
// 获取创建文件时间
+ (NSDate *)top_creationDateOfItemAtPath:(NSString *)path;
// 获取创建文件时间(错误信息error)
+ (NSDate *)top_creationDateOfItemAtPath:(NSString *)path error:(NSError **)error;
// 获取文件修改时间
+ (NSDate *)top_modificationDateOfItemAtPath:(NSString *)path;
// 获取文件修改时间(错误信息error)
+ (NSDate *)top_modificationDateOfItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 删除文件(夹)
// 删除文件
+ (BOOL)top_removeItemAtPath:(NSString *)path;
// 删除文件(错误信息error)
+ (BOOL)top_removeItemAtPath:(NSString *)path error:(NSError **)error;
// 清空Caches文件夹
+ (BOOL)top_clearCachesDirectory;
// 清空tmp文件夹
+ (BOOL)top_clearTmpDirectory;

#pragma mark - 复制文件(夹)
// 复制文件
+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath;
// 复制文件(错误信息error)
+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;
// 复制文件，是否覆盖
+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite;
// 复制文件，是否覆盖(错误信息error)
+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark - 移动文件(夹)
// 移动文件
+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath;
// 移动文件(错误信息error)
+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;
// 移动文件，是否覆盖
+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite;
// 移动文件，是否覆盖(错误信息error)
+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark - 根据URL获取文件名
// 根据文件路径获取文件名称，是否需要后缀
+ (NSString *)top_fileNameAtPath:(NSString *)path suffix:(BOOL)suffix;
// 获取文件所在的文件夹路径
+ (NSString *)top_directoryAtPath:(NSString *)path;
// 根据文件路径获取文件扩展类型
+ (NSString *)top_suffixAtPath:(NSString *)path;

#pragma mark - 判断文件(夹)是否存在
// 判断文件路径是否存在
+ (BOOL)top_isExistsAtPath:(NSString *)path;
// 判断路径是否为空(判空条件是文件大小为0，或者是文件夹下没有子文件)
+ (BOOL)top_isEmptyItemAtPath:(NSString *)path;
// 判断路径是否为空(错误信息error)
+ (BOOL)top_isEmptyItemAtPath:(NSString *)path error:(NSError **)error;
// 判断目录是否是文件夹
+ (BOOL)top_isDirectoryAtPath:(NSString *)path;
// 判断目录是否是文件夹(错误信息error)
+ (BOOL)top_isDirectoryAtPath:(NSString *)path error:(NSError **)error;
// 判断目录是否是文件
+ (BOOL)top_isFileAtPath:(NSString *)path;
// 判断目录是否是文件(错误信息error)
+ (BOOL)top_isFileAtPath:(NSString *)path error:(NSError **)error;
// 判断目录是否可以执行
+ (BOOL)top_isExecutableItemAtPath:(NSString *)path;
// 判断目录是否可读
+ (BOOL)top_isReadableItemAtPath:(NSString *)path;
// 判断目录是否可写
+ (BOOL)top_isWritableItemAtPath:(NSString *)path;

#pragma mark - 获取文件(夹)大小
// 获取目录大小
+ (NSNumber *)top_sizeOfItemAtPath:(NSString *)path;
// 获取目录大小(错误信息error)
+ (NSNumber *)top_sizeOfItemAtPath:(NSString *)path error:(NSError **)error;
// 获取文件大小
+ (NSNumber *)top_sizeOfFileAtPath:(NSString *)path;
// 获取文件大小(错误信息error)
+ (NSNumber *)top_sizeOfFileAtPath:(NSString *)path error:(NSError **)error;
// 获取文件夹大小
+ (NSNumber *)top_sizeOfDirectoryAtPath:(NSString *)path;
// 获取文件夹大小(错误信息error)
+ (NSNumber *)top_sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

// 获取目录大小，返回格式化后的数值
+ (NSString *)top_sizeFormattedOfItemAtPath:(NSString *)path;
// 获取目录大小，返回格式化后的数值(错误信息error)
+ (NSString *)top_sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error;
// 获取文件大小，返回格式化后的数值
+ (NSString *)top_sizeFormattedOfFileAtPath:(NSString *)path;
// 获取文件大小，返回格式化后的数值(错误信息error)
+ (NSString *)top_sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error;
// 获取文件夹大小，返回格式化后的数值
+ (NSString *)top_sizeFormattedOfDirectoryAtPath:(NSString *)path;
// 获取文件夹大小，返回格式化后的数值(错误信息error)
+ (NSString *)top_sizeFormattedOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 写入文件内容
// 写入文件内容
+ (BOOL)top_writeFileAtPath:(NSString *)path content:(NSObject *)content;
// 写入文件内容(错误信息error)
+ (BOOL)top_writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error;
@end

