#import "TOPWHCFileManager.h"

@implementation TOPWHCFileManager
#pragma mark - 沙盒目录相关
+ (NSString *)top_homeDir {
    return NSHomeDirectory();
}

+ (NSString *)top_documentsDir {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)top_libraryDir {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)top_appSupportDir {
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];;
}

+ (NSString *)top_preferencesDir {
    NSString *libraryDir = [self top_libraryDir];
    return [libraryDir stringByAppendingPathComponent:@"Preferences"];
}

+ (NSString *)top_cachesDir {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)top_tmpDir {
    return NSTemporaryDirectory();
}
#pragma mark - 遍历文件夹
+ (NSArray *)top_listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *listArr;
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (deep) {
        // 深遍历
        NSArray *deepArr = [manager subpathsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = deepArr;
        }else {
            listArr = nil;
        }
    }else {
        // 浅遍历
        NSArray *shallowArr = [manager contentsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = shallowArr;
        }else {
            listArr = nil;
        }
    }
    return listArr;
}

+ (NSArray *)top_listFilesInHomeDirectoryByDeep:(BOOL)deep {
    return [self top_listFilesInDirectoryAtPath:[self top_homeDir] deep:deep];
}

+ (NSArray *)top_listFilesInLibraryDirectoryByDeep:(BOOL)deep {
    return [self top_listFilesInDirectoryAtPath:[self top_libraryDir] deep:deep];
}

+ (NSArray *)top_listFilesInDocumentDirectoryByDeep:(BOOL)deep {
    return [self top_listFilesInDirectoryAtPath:[self top_documentsDir] deep:deep];
}

+ (NSArray *)top_listFilesInTmpDirectoryByDeep:(BOOL)deep {
    return [self top_listFilesInDirectoryAtPath:[self top_tmpDir] deep:deep];
}

+ (NSArray *)top_listFilesInCachesDirectoryByDeep:(BOOL)deep {
    return [self top_listFilesInDirectoryAtPath:[self top_cachesDir] deep:deep];
}

#pragma mark - 获取文件属性
+ (id)top_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key {
    return [[self top_attributesOfItemAtPath:path] objectForKey:key];
}

+ (id)top_attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError *__autoreleasing *)error {
    return [[self top_attributesOfItemAtPath:path error:error] objectForKey:key];
}

+ (NSDictionary *)top_attributesOfItemAtPath:(NSString *)path {
    return [self top_attributesOfItemAtPath:path error:nil];
}

+ (NSDictionary *)top_attributesOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
}

#pragma mark - 创建文件(夹)
+ (BOOL)top_createDirectoryAtPath:(NSString *)path {
    return [self top_createDirectoryAtPath:path error:nil];
}

+ (BOOL)top_createDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    return isSuccess;
}

+ (BOOL)top_createFileAtPath:(NSString *)path {
    return [self top_createFileAtPath:path content:nil overwrite:YES error:nil];
}

+ (BOOL)top_createFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [self top_createFileAtPath:path content:nil overwrite:YES error:error];
}

+ (BOOL)top_createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite {
    return [self top_createFileAtPath:path content:nil overwrite:overwrite error:nil];
}

+ (BOOL)top_createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    return [self top_createFileAtPath:path content:nil overwrite:overwrite error:error];
}

+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content {
    return [self top_createFileAtPath:path content:content overwrite:YES error:nil];
}

+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    return [self top_createFileAtPath:path content:content overwrite:YES error:error];
}

+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite {
    return [self top_createFileAtPath:path content:content overwrite:overwrite error:nil];
}
+ (BOOL)top_createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 如果文件夹路径不存在，那么先创建文件夹
    NSString *directoryPath = [self top_directoryAtPath:path];
    if (![self top_isExistsAtPath:directoryPath]) {
        // 创建文件夹
        if (![self top_createDirectoryAtPath:directoryPath error:error]) {
            return NO;
        }
    }
    // 如果文件存在，并不想覆盖，那么直接返回YES。
    if (!overwrite) {
        if ([self top_isExistsAtPath:path]) {
            return YES;
        }
    }
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    if (content) {
        [self top_writeFileAtPath:path content:content error:error];
    }
    return isSuccess;
}

+ (NSDate *)top_creationDateOfItemAtPath:(NSString *)path {
    return [self top_creationDateOfItemAtPath:path error:nil];
}
//获取文件创建的时间
+ (NSDate *)top_creationDateOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return (NSDate *)[self top_attributeOfItemAtPath:path forKey:NSFileCreationDate error:error];
}

+ (NSDate *)top_modificationDateOfItemAtPath:(NSString *)path {
    return [self top_modificationDateOfItemAtPath:path error:nil];
}
//获取文件修改的时间
+ (NSDate *)top_modificationDateOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return (NSDate *)[self top_attributeOfItemAtPath:path forKey:NSFileModificationDate error:error];
}

#pragma mark - 删除文件(夹)
+ (BOOL)top_removeItemAtPath:(NSString *)path {
    if ([self top_isExistsAtPath:path]) {
        return [self top_removeItemAtPath:path error:nil];
    }
    return NO;
}

+ (BOOL)top_removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

#pragma mark 清空Cashes文件夹
+ (BOOL)top_clearCachesDirectory {
    NSArray *subFiles = [self top_listFilesInCachesDirectoryByDeep:NO];
    BOOL isSuccess = YES;
    
    for (NSString *file in subFiles) {
        NSString *absolutePath = [[self top_cachesDir] stringByAppendingPathComponent:file];
        isSuccess &= [self top_removeItemAtPath:absolutePath];
    }
    return isSuccess;
}
#pragma mark 清空temp文件夹
+ (BOOL)top_clearTmpDirectory {
    NSArray *subFiles = [self top_listFilesInTmpDirectoryByDeep:NO];
    BOOL isSuccess = YES;
    
    for (NSString *file in subFiles) {
        NSString *absolutePath = [[self top_tmpDir] stringByAppendingPathComponent:file];
        isSuccess &= [self top_removeItemAtPath:absolutePath];
    }
    return isSuccess;
}

#pragma mark - 复制文件
+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    return [self top_copyItemAtPath:path toPath:toPath overwrite:NO error:nil];
}

+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError *__autoreleasing *)error {
    return [self top_copyItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite {
    return [self top_copyItemAtPath:path toPath:toPath overwrite:overwrite error:nil];
}
#pragma mark - 复制文件
+ (BOOL)top_copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self top_isExistsAtPath:path]) {
        if (DEBUG) {
            [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        }
        return NO;
    }
    //获得目标文件的上级目录
    NSString *toDirPath = [self top_directoryAtPath:toPath];
    if (![self top_isExistsAtPath:toDirPath]) {
        // 创建复制路径
        if (![self top_createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 如果覆盖，那么先删掉原文件
    if (overwrite) {
        if ([self top_isExistsAtPath:toPath]) {
            [self top_removeItemAtPath:toPath error:error];
        }
    }
    // 复制文件，如果不覆盖且文件已存在则会复制失败
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}

#pragma mark - 移动文件(夹)
+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    return [self top_moveItemAtPath:path toPath:toPath overwrite:NO error:nil];
}

+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError *__autoreleasing *)error {
    return [self top_moveItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite {
    return [self top_moveItemAtPath:path toPath:toPath overwrite:overwrite error:nil];
}
#pragma mark - 移动文件(夹)
+ (BOOL)top_moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self top_isExistsAtPath:path]) {
        if (DEBUG) {
            [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
            return NO;
        }
    }
    //获得目标文件的上级目录
    NSString *toDirPath = [self top_directoryAtPath:toPath];
    if (![self top_isExistsAtPath:toDirPath]) {
        // 创建移动路径
        if (![self top_createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 判断目标路径文件是否存在
    if ([self top_isExistsAtPath:toPath]) {
        //如果覆盖，删除目标路径文件
        if (overwrite) {
            //删掉目标路径文件
            [self top_removeItemAtPath:toPath error:error];
        }else {
            //删掉被移动文件
            [self top_removeItemAtPath:path error:error];
            return YES;
        }
    }
    
    // 移动文件，当要移动到的文件路径文件存在，会移动失败
    BOOL isSuccess = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}

#pragma mark - 根据URL获取文件名
+ (NSString *)top_fileNameAtPath:(NSString *)path suffix:(BOOL)suffix {
    NSString *fileName = [path lastPathComponent];
    if (!suffix) {
        fileName = [fileName stringByDeletingPathExtension];
    }
    return fileName;
}

+ (NSString *)top_directoryAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
}

+ (NSString *)top_suffixAtPath:(NSString *)path {
    return [path pathExtension];
}

#pragma mark - 判断文件(夹)是否存在
+ (BOOL)top_isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)top_isEmptyItemAtPath:(NSString *)path {
    return [self top_isEmptyItemAtPath:path error:nil];
}
#pragma mark - 判断文件(夹)是否为空
+ (BOOL)top_isEmptyItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self top_isFileAtPath:path error:error] &&
            [[self top_sizeOfItemAtPath:path error:error] intValue] == 0) ||
    ([self top_isDirectoryAtPath:path error:error] &&
     [[self top_listFilesInDirectoryAtPath:path deep:NO] count] == 0);
}

+ (BOOL)top_isDirectoryAtPath:(NSString *)path {
    return [self top_isDirectoryAtPath:path error:nil];
}

+ (BOOL)top_isDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self top_attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+ (BOOL)top_isFileAtPath:(NSString *)path {
    return [self top_isFileAtPath:path error:nil];
}

+ (BOOL)top_isFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self top_attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}

+ (BOOL)top_isExecutableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isExecutableFileAtPath:path];
}

+ (BOOL)top_isReadableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}
+ (BOOL)top_isWritableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isWritableFileAtPath:path];
}

#pragma mark - 获取文件(夹)大小
+ (NSNumber *)top_sizeOfItemAtPath:(NSString *)path {
    return [self top_sizeOfItemAtPath:path error:nil];
}

+ (NSNumber *)top_sizeOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return (NSNumber *)[self top_attributeOfItemAtPath:path forKey:NSFileSize error:error];
}

+ (NSNumber *)top_sizeOfFileAtPath:(NSString *)path {
    return [self top_sizeOfFileAtPath:path error:nil];
}

+ (NSNumber *)top_sizeOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    if ([self top_isFileAtPath:path error:error]) {
        return [self top_sizeOfItemAtPath:path error:error];
    }
    return nil;
}

+ (NSNumber *)top_sizeOfDirectoryAtPath:(NSString *)path {
    return [self top_sizeOfDirectoryAtPath:path error:nil];
}
#pragma mark 获取文件夹的大小
+ (NSNumber *)top_sizeOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    if ([self top_isDirectoryAtPath:path error:error]) {
        //深遍历文件夹
        NSArray *subPaths = [self top_listFilesInDirectoryAtPath:path deep:YES];
        NSEnumerator *contentsEnumurator = [subPaths objectEnumerator];
        
        NSString *file;
        unsigned long long int folderSize = 0;
        
        while (file = [contentsEnumurator nextObject]) {
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
            folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
        }
        return [NSNumber numberWithUnsignedLongLong:folderSize];
    }
    return nil;
}

+ (NSString *)top_sizeFormattedOfItemAtPath:(NSString *)path {
    return [self top_sizeFormattedOfItemAtPath:path error:nil];
}

+ (NSString *)top_sizeFormattedOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self top_sizeOfItemAtPath:path error:error];
    if (size) {
        return [self top_sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)top_sizeFormattedOfFileAtPath:(NSString *)path {
    return [self top_sizeFormattedOfFileAtPath:path error:nil];
}

+ (NSString *)top_sizeFormattedOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self top_sizeOfFileAtPath:path error:error];
    if (size) {
        return [self top_sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)top_sizeFormattedOfDirectoryAtPath:(NSString *)path {
    return [self top_sizeFormattedOfDirectoryAtPath:path error:nil];
}

+ (NSString *)top_sizeFormattedOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self top_sizeOfDirectoryAtPath:path error:error];
    if (size) {
        return [self top_sizeFormatted:size];
    }
    return nil;
}

#pragma mark - 写入文件内容
+ (BOOL)top_writeFileAtPath:(NSString *)path content:(NSObject *)content {
    return [self top_writeFileAtPath:path content:content error:nil];
}
#pragma mark 写入文件内容
+ (BOOL)top_writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    //判断文件内容是否为空
    if (!content) {
        if (DEBUG) {
            [NSException raise:@"非法的文件内容" format:@"文件内容不能为nil"];
        }
        return NO;
    }
    //判断文件(夹)是否存在
    if ([self top_isExistsAtPath:path]) {
        if ([content isKindOfClass:[NSMutableArray class]]) {//文件内容为可变数组
            [(NSMutableArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSArray class]]) {//文件内容为不可变数组
            [(NSArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableData class]]) {//文件内容为可变NSMutableData
            [(NSMutableData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSData class]]) {//文件内容为NSData
            [(NSData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableDictionary class]]) {//文件内容为可变字典
            [(NSMutableDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSDictionary class]]) {//文件内容为不可变字典
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSJSONSerialization class]]) {//文件内容为JSON类型
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableString class]]) {//文件内容为可变字符串
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSString class]]) {//文件内容为不可变字符串
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[UIImage class]]) {//文件内容为图片
            [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
        }else if ([content conformsToProtocol:@protocol(NSCoding)]) {//文件归档
            [NSKeyedArchiver archiveRootObject:content toFile:path];
        }else {
            if (DEBUG) {
                [NSException raise:@"非法的文件内容" format:@"文件类型%@异常，无法被处理。", NSStringFromClass([content class])];
            }
            return NO;
        }
    }else {
        return NO;
    }
    return YES;
}

#pragma mark - private methods
+ (BOOL)isNotError:(NSError **)error {
    return ((error == nil) || ((*error) == nil));
}

#pragma mark 将文件大小格式化为字节
+(NSString *)top_sizeFormatted:(NSNumber *)size {
    return [NSByteCountFormatter stringFromByteCount:[size unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
}

@end
