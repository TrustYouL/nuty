#import "TOPBinHelper.h"

@implementation TOPBinHelper
#pragma mark -- 回收站根目录
+ (NSString*)top_binBoxDirectory {
    NSString *simpleScanbin = [[TOPWHCFileManager top_appSupportDir] stringByAppendingPathComponent:TOPRAppBinString];
    if (![TOPWHCFileManager top_isExistsAtPath:simpleScanbin]) {
        [TOPWHCFileManager top_createDirectoryAtPath:simpleScanbin];
    }
    return simpleScanbin;
}

#pragma mark -- 属于binBox路径拼接
+ (NSString*)top_getBinFilePathString:(NSString*)str {
    NSString *simpleScanbin = [self top_binBoxDirectory];
    NSString * rarFilePath = [simpleScanbin stringByAppendingPathComponent:str];
    
    return rarFilePath;
}

#pragma mark -- Folders路径
+ (NSString *)top_getBinFoldersPathString {
    NSString * rarFilePath = [self top_getBinFilePathString:TOP_TRFoldersString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- Documents路径
+ (NSString *)top_getBinDocumentsPathString {
    NSString * rarFilePath = [self top_getBinFilePathString:TOP_TRDocumentsString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 文件删除后存入回收站的路径
+ (NSString *)top_binFileWithDeleteFolderPath:(NSString *)path isDoc:(BOOL)isDoc {
    NSString *fileName = [TOPWHCFileManager top_fileNameAtPath:path suffix:YES];
    NSString *directory = isDoc ? [TOPBinHelper top_getBinDocumentsPathString] : [TOPBinHelper top_getBinFoldersPathString];
    NSString *newPath = [directory stringByAppendingPathComponent:fileName];
    newPath = [TOPDocumentHelper top_createDirectoryAtPath:newPath];
    return newPath;
}

#pragma mark -- 图片删除后存入回收站的路径
+ (NSString *)top_binImageWithDeleteFilePath:(NSString *)path isNewDoc:(BOOL)isNewDoc {
    NSString *docPath = [TOPWHCFileManager top_directoryAtPath:path];
    NSString *directory = [self docDirectoryAtPath:docPath];
    if (isNewDoc) {
        directory = [TOPDocumentHelper top_createDirectoryAtPath:directory];
    } else {
        if (![TOPWHCFileManager top_isExistsAtPath:directory]) {//没有目录文件则在首页新建一个
            [TOPWHCFileManager top_createDirectoryAtPath:directory];
        }
    }
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:([TOPDocumentHelper top_maxImageNumIndexAtPath:directory])],TOP_TRJPGPathSuffixString];
    return [directory stringByAppendingPathComponent:fileName];
}

#pragma mark -- 设置父级目录
+ (NSString *)docDirectoryAtPath:(NSString *)path {
    NSString *fileName = [TOPWHCFileManager top_fileNameAtPath:path suffix:YES];
    NSString *directory = [[TOPBinHelper top_getBinDocumentsPathString] stringByAppendingPathComponent:fileName];
    return directory;
}

#pragma mark -- Folder移动到回收站
+ (NSString *)top_moveFolderToBin:(NSString *)docPath {
    NSString *binPath = [self top_binFileWithDeleteFolderPath:docPath isDoc:NO];
    [TOPDocumentHelper top_moveFileItemsAtPath:docPath toNewFileAtPath:binPath];
    return binPath;
}

#pragma mark -- Document移动到回收站
+ (NSString *) top_moveDocumentToBin:(NSString *)docPath {
    NSString *binPath = [self top_binFileWithDeleteFolderPath:docPath isDoc:YES];
    [TOPDocumentHelper top_moveFileItemsAtPath:docPath toNewFileAtPath:binPath];
    return binPath;
}

#pragma mark -- Document移动到回收站 带进度
+ (NSString *) top_moveDocumentToBin:(NSString *)docPath progress:(void (^)(CGFloat moveProgressValue))moveProgressBlock {
    NSString *binPath = [self top_binFileWithDeleteFolderPath:docPath isDoc:YES];
    [TOPDocumentHelper top_moveFileItemsAtPath:docPath toNewFileAtPath:binPath progress:^(CGFloat moveProgressValue) {
        if (moveProgressBlock) {
            moveProgressBlock(moveProgressValue);
        }
    }];
    return binPath;
}

#pragma mark -- 将单个图片移动到回收站
+ (NSString *)top_moveImageToBin:(NSString *)imgPath atNewDoc:(BOOL)newDoc {
    if (![TOPWHCFileManager top_isExistsAtPath:imgPath]) {
        return @"";
    }
    NSString *path = [self top_binImageWithDeleteFilePath:imgPath isNewDoc:newDoc];
    [self moveImage:imgPath toargetFile:path];
    return path;
}

#pragma mark -- 将文件夹还原
+ (NSString *)top_restoreFolder:(NSString *)docPath atPath:(NSString *)path {
    [TOPDocumentHelper top_moveFileItemsAtPath:docPath toNewFileAtPath:path];
    return docPath;
}

#pragma mark -- 将文档还原
+ (NSString *)top_restoreDocument:(NSString *)docPath atPath:(NSString *)path {
    [TOPDocumentHelper top_moveFileItemsAtPath:docPath toNewFileAtPath:path];
    return path;
}

#pragma mark -- 将图片还原到文档中
+ (NSString *)top_restoreImage:(NSString *)imgPath atPath:(NSString *)docPath {
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:([TOPDocumentHelper top_maxImageNumIndexAtPath:docPath])],TOP_TRJPGPathSuffixString];
    NSString *imgFile = [docPath stringByAppendingPathComponent:fileName];
    [self moveImage:imgPath toargetFile:imgFile];
    return imgFile;
}


+ (void)moveImage:(NSString *)imgPath toargetFile:(NSString *)path {
    NSString *docPath = [TOPWHCFileManager top_directoryAtPath:path];
    NSString *originalContentFilePath = [TOPDocumentHelper top_originalImage:imgPath];
    NSString *notePath = [TOPDocumentHelper top_originalNote:imgPath];
    NSString *ocrPath = [TOPDocumentHelper top_originalOcr:imgPath];
    
    NSString *fileName  = [TOPWHCFileManager top_fileNameAtPath:path suffix:NO];
    NSString *noteName  = [NSString stringWithFormat:@"%@%@%@",TOPRSimpleScanNoteString,fileName,TOP_TRTXTPathSuffixString];
    NSString *ocrName = [NSString stringWithFormat:@"%@%@",fileName,TOP_TRTXTPathSuffixString];
    
    NSString *newOriginalContentPath = [TOPDocumentHelper top_originalImage:path];
    NSString *noteContentPath = [docPath stringByAppendingPathComponent:noteName];
    NSString *ocrContentPath = [docPath stringByAppendingPathComponent:ocrName];

    [TOPWHCFileManager top_moveItemAtPath:imgPath toPath:path];
    if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
        [TOPWHCFileManager top_moveItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
    }
    if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
        [TOPWHCFileManager top_moveItemAtPath:notePath toPath:noteContentPath];
    }
    if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
        [TOPWHCFileManager top_moveItemAtPath:ocrPath toPath:ocrContentPath];
    }
}

@end
