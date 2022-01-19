#import "TOPBinEditDataHandler.h"
#import "TOPBinQueryHandler.h"
#import "TOPBinDataHandler.h"
#import "TOPBinHelper.h"
#import "TOPBinFolder.h"
#import "TOPBinDocument.h"
#import "TOPBinImage.h"

@implementation TOPBinEditDataHandler

#pragma mark -- 增加文件夹 path: 文件夹路径 parentId：文件夹id
+ (void)top_addFolderAtFile:(NSString *)path WithParentId:(NSString *)parentId {
    //文件夹的id使用原folder.Id 和parentId也不变
    //只改变第一层folder的parentId为“000000”
    TOPAPPFolder *folderObj = [TOPDBQueryService top_appFolderById:parentId];
    RLMResults<TOPBinFolder *> *bins = [TOPBinFolder objectsWhere:@"delParentId = %@",folderObj.pathId];
    if (bins.count) {
        [TOPDBService top_removeAllObjects:bins];
    }
    TOPBinFolder *binFolder = [TOPBinDataHandler top_buildBinFolderWithParentId:parentId atPath:path];
    binFolder.delParentId = folderObj.pathId;
    NSMutableArray *addData = @[].mutableCopy;
    [addData addObject:binFolder];
    //folderObj 次级目录
    RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_foldersAtFile:folderObj.Id];
    for (TOPAPPFolder *obj in folders) {
        NSString *pathId = [obj.pathId stringByReplacingOccurrencesOfString:folderObj.pathId withString:binFolder.pathId];
        TOPBinFolder *folderModel = [self top_copyFolder:obj withPathId:pathId];
        [addData addObject:folderModel];
    }
    
    //folderObj 次级文档
    RLMResults<TOPAppDocument *> *documents = [TOPDBQueryService top_documentsAtFoler:folderObj.Id];
    for (TOPAppDocument *obj in documents) {
        NSString *pathId = [obj.pathId stringByReplacingOccurrencesOfString:folderObj.pathId withString:binFolder.pathId];
        TOPBinDocument *documentModel = [self top_copyDocument:obj withPathId:pathId];
        //图片
        NSMutableArray *imgArr = @[].mutableCopy;
        imgArr = [self top_copyImages:obj withPathId:pathId];
        if (imgArr.count) {
            [documentModel.images addObjects:imgArr];
        }
        [addData addObject:documentModel];
    }
    [TOPDBService top_saveAllObjects:addData];
}

#pragma mark -- 新建文档 parentId: image.pathId 图片路径id path： 文档路径
+ (void)top_saddBinDocWithParentId:(NSString *)parentId atPath:(NSString *)path {
    TOPBinDocument *documentModel = [TOPBinDataHandler top_buildFullBinDocWithParentId:parentId atPath:path];
    NSString *docId = [parentId stringByDeletingLastPathComponent];
    docId = [docId lastPathComponent];
    TOPAppDocument *docObj = [TOPDBQueryService top_appDocumentById:docId];
    documentModel.ctime = docObj.ctime;
    documentModel.utime = docObj.utime;
    [TOPDBService top_saveObject:documentModel];
}

#pragma mark -- 重置新建文档的创建和修改时间--保持删除前后一致
+ (void)top_setBinDocTime:(NSString *)binDocId withDocId:(NSString *)docId {
    TOPAppDocument *docObj = [TOPDBQueryService top_appDocumentById:docId];
    TOPBinDocument *binDoc = [TOPBinQueryHandler top_appDocumentById:binDocId];
    [TOPDBService top_transactionWithBlock:^{
        binDoc.ctime = docObj.ctime;
        binDoc.utime = docObj.utime;
    }];
}

#pragma mark -- 增加图片  fileNames:  图片名集合   path： 文档路径Id
+ (void)top_addBinImageAtDocument:(NSArray *)fileNames WithId:(NSString *)docId {
    RLMResults<TOPBinDocument *> *appDocs = [TOPBinDocument objectsWhere:@"delParentId = %@", docId];
    if (appDocs.count) {
        TOPBinDocument *appDoc = appDocs[0];
        NSMutableArray *imgArr = [TOPBinDataHandler top_buildRealmImagesByFileNames:fileNames withData:appDoc];
        if (imgArr.count) {
            [TOPDBService top_transactionWithBlock:^{
                [appDoc.images addObjects:imgArr];
            }];
        }
    }
}

#pragma mark -- 还原
#pragma mark -- 还原文件夹
+ (void)top_restoreFolderWithId:(NSString *)docId {
    [self top_deleteFolderWithId:docId];
}
#pragma mark -- 还原文件夹
+ (void)top_restoreDocumentWithId:(NSString *)docId {
    [self top_deleteDocumentWithId:docId];
}
#pragma mark -- 还原文件夹
+ (void)top_restoreImagesWithIds:(NSArray *)docIds {
    //还原完成
    [self top_deleteImagesWithIds:docIds];
}

#pragma mark -- 删除
#pragma mark -- 删除文件夹
+ (void)top_deleteFolderWithId:(NSString *)docId {
    //该目录下的文件夹
    RLMResults<TOPBinFolder *> *folders = [TOPBinQueryHandler top_foldersAtFile:docId];
    [TOPDBService top_removeAllObjects:folders];
    //该目录下的文档
    RLMResults<TOPBinDocument *> *docs = [TOPBinQueryHandler top_documentsAtFoler:docId];
    for (TOPBinDocument *docModel in docs) {
        [self top_deleteDocumentWithId:docModel.Id];
    }
    
    TOPBinFolder *appFolder = [TOPBinQueryHandler top_appFolderById:docId];
    [TOPDBService top_removeObject:appFolder];
}

#pragma mark -- 删除文档
+ (void)top_deleteDocumentWithId:(NSString *)docId {
    RLMResults<TOPBinImage *> * images = [TOPBinQueryHandler top_imageFilesByParentId:docId];
    [TOPDBService top_removeAllObjects:images];
    TOPBinDocument *appDoc = [TOPBinQueryHandler top_appDocumentById:docId];
    [TOPDBService top_removeObject:appDoc];
}

#pragma mark -- 删除图片
+ (void)top_deleteImagesWithIds:(NSArray *)docIds {
    RLMResults<TOPBinImage *> * images = [TOPBinQueryHandler top_imageFilesWithImageIds:docIds];
    if (images.count) {
        TOPBinImage *imageFile = images.firstObject;
        TOPBinDocument *appDoc = [TOPBinQueryHandler top_appDocumentById:imageFile.parentId];
        if (appDoc.images.count == images.count) {
            [TOPDBService top_removeObject:appDoc];
        } else {
            [TOPDBService top_transactionWithBlock:^{
                appDoc.utime = [NSDate date];
            }];
        }
        [TOPDBService top_removeAllObjects:images];
    }
}


#pragma mark -- 适用于删除整个文件夹的数据构造
+ (TOPBinFolder *)top_copyFolder:(TOPAPPFolder *)obj withPathId:(NSString *)pathId {
    TOPBinFolder *folderModel = [[TOPBinFolder alloc] init];
    folderModel.Id = obj.Id;
    folderModel.parentId = obj.parentId;
    folderModel.name = obj.name;
    folderModel.pathId = pathId;
    folderModel.ctime = obj.ctime;
    folderModel.utime = obj.utime;
    folderModel.delTime = [NSDate date];
    folderModel.delParentId = obj.pathId;
    return  folderModel;
}

+ (TOPBinDocument *)top_copyDocument:(TOPAppDocument *)obj withPathId:(NSString *)pathId {
    TOPBinDocument *documentModel = [[TOPBinDocument alloc] init];
    documentModel.Id = obj.Id;
    documentModel.parentId = obj.parentId;
    documentModel.name = obj.name;
    documentModel.pathId = pathId;
    documentModel.ctime = obj.ctime;
    documentModel.utime = obj.utime;
    documentModel.rtime = obj.rtime;
    documentModel.delTime = [NSDate date];
    documentModel.isDelete = NO;
    documentModel.docNoticeLock = NO;
    documentModel.delParentId = obj.pathId;
    return documentModel;
}

+ (NSMutableArray *)top_copyImages:(TOPAppDocument *)obj withPathId:(NSString *)pathId {
    NSMutableArray * sortDtArray = @[].mutableCopy;
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:obj.Id];
    for (TOPImageFile *img in images) {
        TOPBinImage *imgModel = [[TOPBinImage alloc] init];
        imgModel.Id = img.Id;
        imgModel.fileName = img.fileName;
        imgModel.parentId = img.parentId;
        imgModel.pathId = [NSString stringWithFormat:@"%@/%@",pathId, imgModel.Id];
        imgModel.fileLength = img.fileLength;
        imgModel.fileShowName = img.fileShowName;
        imgModel.ctime = img.ctime;
        imgModel.utime = img.utime;
        imgModel.delTime = [NSDate date];
        imgModel.isDelete = NO;
        imgModel.isUpload = NO;
        imgModel.isUploadSuccess = NO;
        imgModel.delParentId = obj.pathId;
        [sortDtArray addObject:imgModel];
    }
    return sortDtArray;
}

@end
