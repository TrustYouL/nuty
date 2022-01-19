#import "TOPActionExtensionHandler.h"

@implementation TOPActionExtensionHandler
#define ShareAppGroup @"group.tongsoft.simple.scanner"

+ (void)top_parsingDataSuccess:(void (^)(NSMutableArray * _Nonnull, NSString * _Nonnull))success {
    NSString *docFile = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL * groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
        NSError * error;
        NSArray * folderList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[groupURL path] error:&error];

        NSMutableArray * dataArray = [NSMutableArray array];
        int i = 0;
        for (NSString  * tempstr in folderList) {
            if ([tempstr.lowercaseString hasSuffix:@".jpg"] || [tempstr.lowercaseString hasSuffix:@".png"] || [tempstr.lowercaseString hasSuffix:@".jpeg"]) {
                NSString * newFilePath = [[groupURL path] stringByAppendingPathComponent:tempstr];
                NSString *imgName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                NSString *boxFilePath = [docFile stringByAppendingPathComponent:imgName];
                [TOPWHCFileManager top_moveItemAtPath:newFilePath toPath:boxFilePath];
                [dataArray addObject:imgName];
                i ++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            success(dataArray, docFile);
        });
    });
}

+ (void)top_parsingDataBuildModelsSuccess:(void (^)(NSMutableArray * _Nonnull, NSString * _Nonnull))success {
    NSString *docFile = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL * groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
        NSError * error;
        NSArray * folderList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[groupURL path] error:&error];

        NSMutableArray * dataArray = [NSMutableArray array];
        int i = 0;
        for (NSString  * tempstr in folderList) {
            if ([tempstr.lowercaseString hasSuffix:@".jpg"] || [tempstr.lowercaseString hasSuffix:@".png"] || [tempstr.lowercaseString hasSuffix:@".jpeg"]) {
                NSString * newFilePath = [[groupURL path] stringByAppendingPathComponent:tempstr];
                NSString *imgName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                NSString *boxFilePath = [docFile stringByAppendingPathComponent:imgName];
                [TOPWHCFileManager top_moveItemAtPath:newFilePath toPath:boxFilePath];
                i ++;
            }
        }
        dataArray = [TOPDataModelHandler top_buildDocumentSecondaryDataAtPath:docFile];
        [TOPDBDataHandler top_addNewDocModel:docFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            success(dataArray, docFile);
        });
    });
}

@end
