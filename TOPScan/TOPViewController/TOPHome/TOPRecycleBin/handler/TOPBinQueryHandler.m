#import "TOPBinQueryHandler.h"
#import "TOPBinFolder.h"
#import "TOPBinDocument.h"
#import "TOPBinImage.h"

@implementation TOPBinQueryHandler

#pragma mark -- TOPBinFolder 查询
+ (TOPBinFolder *)top_appFolderById:(NSString *)Id {
    TOPBinFolder *target = [TOPBinFolder objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 查询所有的文件夹 默认排序
+ (RLMResults<TOPBinFolder *> *)top_allFoldersBySorted {
    RLMResults<TOPBinFolder *> *folders = [self sortResults:[TOPBinFolder allObjects]];
    return folders;
}

#pragma mark -- 根据父id(文件夹上级目录id)查询folders 默认排序
+ (RLMResults<TOPBinFolder *> *)top_foldersByParentId:(NSString *)parentId {
    RLMResults<TOPBinFolder *> *folders = [self sortResults:[TOPBinFolder objectsWhere:@"parentId = %@",parentId]];
    return folders;
}

#pragma mark -- 查询某个文件夹下的所有folder 可用于计数
+ (RLMResults<TOPBinFolder *> *)top_foldersAtFile:(NSString *)folderId {
    RLMResults<TOPBinFolder *> *folders = [TOPBinFolder objectsWhere:@"pathId CONTAINS %@ AND Id != %@", folderId, folderId];
    return folders;
}


#pragma mark -- TOPBinDocument 查询
+ (TOPBinDocument *)top_appDocumentById:(NSString *)Id {
    TOPBinDocument *target = [TOPBinDocument objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 查询所有的文档 默认排序
+ (RLMResults<TOPBinDocument *> *)top_allDocumentsBySorted {
    RLMResults<TOPBinDocument *> *documents = [self sortResults:[TOPBinDocument allObjects]];
    return documents;
}

#pragma mark -- 根据父id(文件夹上级目录id)查询folders 默认排序
+ (RLMResults<TOPBinDocument *> *)top_documentsByParentId:(NSString *)parentId {
    RLMResults<TOPBinDocument *> *folders = [self sortResults:[TOPBinDocument objectsWhere:@"parentId = %@",parentId]];
    return folders;
}

#pragma mark -- 查询某个文件夹下的所有文档
+ (RLMResults<TOPBinDocument *> *)top_documentsAtFoler:(NSString *)folderId {
    RLMResults<TOPBinDocument *> *documents = [TOPBinDocument objectsWhere:@"pathId CONTAINS %@", folderId];
    return documents;
}

#pragma mark -- TOPBinImage 查询
+ (TOPBinImage *)top_imageFileById:(NSString *)Id {
    TOPBinImage *target = [TOPBinImage objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 根据父id(图片上级目录id)查询images
+ (RLMResults<TOPBinImage *> *)top_imageFilesByParentId:(NSString *)parentId {
    RLMResults<TOPBinImage *> *images = [TOPBinImage objectsWhere:@"parentId = %@",parentId];
    return images;
}

#pragma mark -- 根据父id(图片上级目录id)查询images 并排序
+ (NSArray *)top_sortImageFilesByParentId:(NSString *)parentId {
    RLMResults<TOPBinImage *> *images = [TOPBinImage objectsWhere:@"parentId = %@",parentId];
    NSArray *imageArr = [TOPDBService convertToArray:images];
    NSArray *sortArray = [imageArr sortedArrayUsingComparator:^NSComparisonResult(TOPBinImage *file1, TOPBinImage *file2) {
        NSString *sortNO1 = file1.picIndex;
        NSString *sortNO2 = file2.picIndex;
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return sortArray;
}

#pragma mark -- 根据ids查询images 查询结果和ids的顺序并不同
+ (RLMResults<TOPBinImage *> *)top_imageFilesWithImageIds:(NSArray *)imgIds {
    RLMResults<TOPBinImage *> *images = [TOPBinImage objectsWhere:@"Id IN %@", imgIds];
    return images;
}


#pragma mark -- 对查询结果进行排序
+ (RLMResults *)sortResults:(RLMResults *)results {
    NSString *sortKey = @"delTime";
    BOOL asceding = NO;
    RLMResults *res = [results sortedResultsUsingKeyPath:sortKey ascending:asceding];
    return res;
}

#pragma mark -- 排序规则
+ (NSDictionary *)sortRule {
    NSInteger type = [TOPScanerShare top_sortType];
    NSString *sortKey = @"utime";
    BOOL asceding = YES;
    switch (type) {
        case FolderDocumentCreateDescending:
            sortKey = @"ctime";
            asceding = NO;
            break;
        case FolderDocumentCreateAscending:
            sortKey = @"ctime";
            asceding = YES;
            break;
        case FolderDocumentUpdateDescending:
            sortKey = @"utime";
            asceding = NO;
            break;
        case FolderDocumentUpdateAscending:
            sortKey = @"utime";
            asceding = YES;
            break;
        case FolderDocumentFileNameAToZ:
            sortKey = @"name";
            asceding = YES;
            break;
        case FolderDocumentFileNameZToA:
            sortKey = @"name";
            asceding = NO;
            break;
            
        default:
            break;
    }
    return @{@"sortKey":sortKey, @"asceding":@(asceding)};
}

@end
