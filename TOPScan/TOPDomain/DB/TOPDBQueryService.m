
#import "TOPDBQueryService.h"
#import "TOPDBService.h"
#import "TOPAPPFolder.h"
#import "TOPAppDocument.h"
#import "TOPImageFile.h"
#import "TOPDocTag.h"

@implementation TOPDBQueryService

#pragma mark -- 总文件个数
+ (long)top_totalFilesCount {
    RLMResults<TOPAPPFolder *> *folders = [TOPAPPFolder allObjects];
    RLMResults<TOPAppDocument *> *docs = [TOPAppDocument allObjects];
    RLMResults<TOPImageFile *> *images = [TOPImageFile allObjects];
    RLMResults<TOPDocTag *> *tags = [TOPDocTag allObjects];
    long totalCount = folders.count + docs.count + images.count + tags.count;
    return totalCount;
}

#pragma mark -- 某个文件夹下的总文件个数
+ (long)top_totalFilesCountAtFolder:(NSString *)folderId {
    TOPAPPFolder *target = [self top_appFolderById:folderId];
    RLMResults<TOPAPPFolder *> *folders = [self top_foldersAtFile:folderId];
    RLMResults<TOPAppDocument *> *docs = [self top_documentsAtFoler:folderId];
    RLMResults<TOPImageFile *> *images = [self top_imagesAtPath:target.pathId];
    RLMResults<TOPDocTag *> *tags = [TOPDocTag allObjects];
    long totalCount = folders.count + docs.count + images.count + tags.count;
    return totalCount;
}

#pragma mark -- TOPAPPFolder 查询
+ (TOPAPPFolder *)top_appFolderById:(NSString *)Id {
    TOPAPPFolder *target = [TOPAPPFolder objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 查询所有的文件夹 默认排序
+ (RLMResults<TOPAPPFolder *> *)top_allFoldersBySorted {
    RLMResults<TOPAPPFolder *> *folders = [self top_sortResults:[TOPAPPFolder allObjects]];
    return folders;
}

#pragma mark -- 查询所有的文件夹 根据第一级目录排序：用于复制、移动的文件夹数据
+ (NSMutableArray *)top_allFoldersByFatherDirectorySorted {
    NSMutableArray *allData = @[].mutableCopy;
    NSMutableArray *folders = [self foldersByDocId:@"000000" data:allData];
    return folders;
}

//先加第一层的第一个文件及其所有子文件，后加第二个文件及其所有 -- 类推 01, 01/101, 02, 02/102
+ (NSMutableArray *)foldersByDocId:(NSString *)docId data:(NSMutableArray *)allData {
    if ([docId isEqualToString:@"000000"]) {
        RLMResults<TOPAPPFolder *> *folders = [self top_foldersByParentId:docId];
        if (folders.count) {
            for (TOPAPPFolder *obj in folders) {
                [self foldersByDocId:obj.Id data:allData];
            }
        } else {
            return allData;
        }
    } else {
        TOPAPPFolder *folder = [self top_appFolderById:docId];
        if (folder) {
            [allData addObject:folder];
            RLMResults<TOPAPPFolder *> *folders = [self top_foldersByParentId:folder.Id];
            if (folders.count) {
                for (TOPAPPFolder *obj in folders) {
                    [self foldersByDocId:obj.Id data:allData];
                }
            } else {
                return allData;
            }
        } else {
            return allData;
        }
    }
    return allData;
}

#pragma mark -- 查询所有的文件夹 根据目录排序
+ (NSMutableArray *)top_allFoldersByDirectorySorted {
    NSMutableArray *allData = @[].mutableCopy;
    NSMutableArray *folders = [self top_foldersByParentId:@"000000" data:allData];
    return folders;
}


//先加第一层全部，后加第一层文件的子文件 -- 类推 01, 02, 01/101, 02/102
+ (NSMutableArray *)top_foldersByParentId:(NSString *)parentId data:(NSMutableArray *)allData {
    RLMResults<TOPAPPFolder *> *folders = [self top_foldersByParentId:parentId];
    if (folders.count) {
        [allData addObjectsFromArray:[TOPDBService convertToArray:folders]];
    } else {
        return allData;
    }
    for (TOPAPPFolder *folderObj in folders) {
        [self top_foldersByParentId:folderObj.Id data:allData];
    }
    return allData;
}

#pragma mark -- 根据父id(文件夹上级目录id)查询folders 默认排序
+ (RLMResults<TOPAPPFolder *> *)top_foldersByParentId:(NSString *)parentId {
    RLMResults<TOPAPPFolder *> *folders = [self top_sortResults:[TOPAPPFolder objectsWhere:@"parentId = %@",parentId]];
    return folders;
}

#pragma mark -- 查询首页的文件夹 默认排序
+ (RLMResults<TOPAPPFolder *> *)top_homeFoldersBySorted {
    RLMResults<TOPAPPFolder *> *folders = [self top_foldersByParentId:@"000000"];
    return folders;
}

#pragma mark -- 查询某个文件夹下的所有folder 可用于计数
+ (RLMResults<TOPAPPFolder *> *)top_foldersAtFile:(NSString *)folderId {
    RLMResults<TOPAPPFolder *> *folders = [TOPAPPFolder objectsWhere:@"pathId CONTAINS %@ AND Id != %@", folderId, folderId];
    return folders;
}

#pragma mark -- TOPAppDocument 查询
+ (TOPAppDocument *)top_appDocumentById:(NSString *)Id {
    TOPAppDocument *target = [TOPAppDocument objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 查询所有的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsBySorted {
    RLMResults<TOPAppDocument *> *documents = [self top_sortResults:[TOPAppDocument allObjects]];
    return documents;
}

#pragma mark -- 查询所有的文档 制定排序类型进行排序
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsBySortedWithSortType:(NSInteger)sortType {
    RLMResults<TOPAppDocument *> *documents = [self top_sortResults:[TOPAppDocument allObjects] withSortType:sortType];
    return documents;
}

#pragma mark -- 查询所有的文档 浏览时间排序
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsByRecent {
    RLMResults<TOPAppDocument *> *documents = [[TOPAppDocument allObjects] sortedResultsUsingKeyPath:@"rtime" ascending:NO];
    return documents;
}

#pragma mark -- 根据父id(文档上级目录id)查询documents 默认排序
+ (RLMResults<TOPAppDocument *> *)top_documentsByParentId:(NSString *)parentId {
    RLMResults<TOPAppDocument *> *documents = [self top_sortResults:[TOPAppDocument objectsWhere:@"parentId = %@",parentId]];
    return documents;
}


#pragma mark -- 查询首页的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_homeDocumentsBySorted {
    RLMResults<TOPAppDocument *> *documents = [self top_documentsByParentId:@"000000"];
    return documents;
}

#pragma mark -- 查询没有标签的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_unGroupedDocumentsBySorted {
    RLMResults<TOPAppDocument *> *documents = [self top_sortResults:[TOPAppDocument objectsWhere:@"tags = ''"]];
    return documents;
}
#pragma mark -- 查询已经被收藏的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_documentsByCollecting{
    RLMResults<TOPAppDocument *> *documents = [self top_sortResults:[TOPAppDocument objectsWhere:@"collectionState = 1"]];
    return documents;
}
#pragma mark -- 查询带标签的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_documentsBySortedWithTag:(NSString *)tagName {
    NSString *name = [NSString stringWithFormat:@"%@/",tagName];// TOPAppDocument tags是用'/'加后缀拼接而成
    RLMResults<TOPAppDocument *> *documents = [self top_sortResults:[TOPAppDocument objectsWhere:@"tags CONTAINS %@", name]];
    return documents;
}

#pragma mark -- 计数某个文件夹下的所有文档个数
+ (RLMResults<TOPAppDocument *> *)top_documentsAtFoler:(NSString *)folderId {
    RLMResults<TOPAppDocument *> *documents = [TOPAppDocument objectsWhere:@"pathId CONTAINS %@", folderId];
    return documents;
}

#pragma mark -- 计数所有文件夹下的所有文档个数 父id != '000000'
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsAtFoler {
    RLMResults<TOPAppDocument *> *documents = [self top_sortResults:[TOPAppDocument objectsWhere:@"parentId != '000000'"]];
    return documents;
}

#pragma mark -- TOPAppDocument 根据路径查询 **仅限首页文档**
+ (TOPAppDocument *)top_appDocumentByPath:(NSString *)path {
    NSString *docName = [TOPWHCFileManager top_fileNameAtPath:path suffix:YES];
    RLMResults<TOPAppDocument *> *documents = [TOPAppDocument objectsWhere:@"parentId == '000000' AND name == %@",docName];
    if (documents.count) {
        TOPAppDocument *document = documents.firstObject;
        document.filePath = path;
        return document;
    }
    return nil;
}

#pragma mark -- ImageFile 查询
+ (TOPImageFile *)top_imageFileById:(NSString *)Id {
    TOPImageFile *target = [TOPImageFile objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 根据父id(图片上级目录id)查询images
+ (RLMResults<TOPImageFile *> *)top_imageFilesByParentId:(NSString *)parentId {
    RLMResults<TOPImageFile *> *images = [TOPImageFile objectsWhere:@"parentId = %@",parentId];
    return images;
}

#pragma mark -- 根据父id(图片上级目录id)查询images 并排序
+ (NSArray *)top_sortImageFilesByParentId:(NSString *)parentId {
    //***目前废弃 picIndex字段增加了接口维护成本 改为只读，每次通过get方法重新获取
//    RLMResults<TOPImageFile *> *images = [[TOPImageFile objectsWhere:@"parentId = %@",parentId] sortedResultsUsingKeyPath:@"picIndex" ascending:YES];
    RLMResults<TOPImageFile *> *images = [TOPImageFile objectsWhere:@"parentId = %@",parentId];
    NSArray *imageArr = [TOPDBService convertToArray:images];
    NSArray *sortArray = [imageArr sortedArrayUsingComparator:^NSComparisonResult(TOPImageFile *file1, TOPImageFile *file2) {
        NSString *sortNO1 = file1.picIndex;
        NSString *sortNO2 = file2.picIndex;
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return sortArray;
}



#pragma mark -- 根据图片名称和父id(图片上级目录id)查询images
+ (RLMResults<TOPImageFile *> *)top_imageFilesByParentId:(NSString *)parentId withName:(NSString *)name {
    RLMResults<TOPImageFile *> *images = [TOPImageFile objectsWhere:@"parentId = %@ AND fileName = %@",parentId, name];
    return images;
}

#pragma mark -- 根据ids查询images 查询结果和ids的顺序并不同
+ (RLMResults<TOPImageFile *> *)top_imageFilesWithImageIds:(NSArray *)imgIds {
    RLMResults<TOPImageFile *> *images = [TOPImageFile objectsWhere:@"Id IN %@", imgIds];
    return images;
}

#pragma mark -- 根据ids查询images 且保持ids的顺序
+ (NSMutableArray *)top_imageFilesOrderByImageIds:(NSArray *)imgIds {
    NSMutableArray *temp = @[].mutableCopy;
    for (NSString *imgId in imgIds) {
        TOPImageFile *target = [self top_imageFileById:imgId];
        if (target) {
            [temp addObject:target];
        }
    }
    return temp;
}

#pragma mark -- 计数某个目录下的所有图片个数
+ (RLMResults<TOPImageFile *> *)top_imagesAtPath:(NSString *)pathId {
    RLMResults<TOPImageFile *> *images = [TOPImageFile objectsWhere:@"pathId CONTAINS %@", pathId];
    return images;
}

#pragma mark -- DocTag 查询
+ (TOPDocTag *)top_docTagById:(NSString *)Id {
    TOPDocTag *target = [TOPDocTag objectForPrimaryKey:Id];
    return target;
}

#pragma mark --  查询所有TOPDocTag
+ (RLMResults<TOPDocTag *> *)top_allTagsBySorted {
    RLMResults<TOPDocTag *> *tags = [self top_sortResults:[TOPDocTag allObjects]];
    return tags;
}

#pragma mark --  TOPDocTag 根据标签名称查询
+ (TOPDocTag *)top_docTagByName:(NSString *)name {
    RLMResults<TOPDocTag *> *tags = [self top_sortResults:[TOPDocTag objectsWhere:@"name == %@",name]];
    if (tags.count) {
        return tags.firstObject;
    }
    return nil;
}

#pragma mark -- 对查询结果进行排序 默认排序类型排序
+ (RLMResults *)top_sortResults:(RLMResults *)results {
    NSString *sortKey = [self top_sortRule][@"sortKey"];
    BOOL asceding = [[self top_sortRule][@"asceding"] boolValue];
    RLMResults *res = [results sortedResultsUsingKeyPath:sortKey ascending:asceding];
    return res;
}
#pragma mark -- 对查询结果进行制定排序类型排序
+ (RLMResults *)top_sortResults:(RLMResults *)results withSortType:(NSInteger)sortType{
    NSString *sortKey = [self top_top_sortRuleWithSortType:sortType][@"sortKey"];
    BOOL asceding = [[self top_top_sortRuleWithSortType:sortType][@"asceding"] boolValue];
    RLMResults *res = [results sortedResultsUsingKeyPath:sortKey ascending:asceding];
    return res;
}
#pragma mark -- 指定排序规则
+ (NSDictionary *)top_top_sortRuleWithSortType:(NSInteger)sortType {
    NSString *sortKey = @"utime";
    BOOL asceding = YES;
    switch (sortType) {
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
#pragma mark -- 默认排序规则
+ (NSDictionary *)top_sortRule {
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
- (NSInteger)sortType{
    NSInteger sortType = [TOPScanerShare top_sortType];
    if ([TOPScanerShare top_theCountEnterApp]>1) {//老用户
        
    }
    return sortType;
}
@end
