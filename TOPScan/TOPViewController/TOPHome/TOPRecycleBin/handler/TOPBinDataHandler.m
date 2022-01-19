#import "TOPBinDataHandler.h"
#import "TOPBinHelper.h"
#import "TOPBinFolder.h"
#import "TOPBinDocument.h"
#import "TOPBinImage.h"

@implementation TOPBinDataHandler

#pragma mark -- 检测过期文件 -- 目前设置90天
+ (void)top_checkExpiredFile {
    NSInteger days = [TOPScanerShare top_saveBinFileTime];
    CGFloat expiration = days * 24 * 3600.0;
    
    RLMResults<TOPBinImage *> *images = [TOPBinImage allObjects];
    NSMutableArray *expiredFiles = @[].mutableCopy;
    for (TOPBinImage *obj in images) {
        CGFloat sinceNow = fabs(obj.delTime.timeIntervalSinceNow);
        if (sinceNow > expiration) {
            [expiredFiles addObject:obj];
            NSString *docPath = [self top_binDocumentPath:[obj.pathId stringByDeletingLastPathComponent]];
            NSString *imgPath = [docPath stringByAppendingPathComponent:obj.fileName];
            [TOPWHCFileManager top_removeItemAtPath:imgPath];
        }
    }
    [TOPDBService top_removeAllObjects:expiredFiles];
    [expiredFiles removeAllObjects];
    
    RLMResults<TOPBinDocument *> *documents = [TOPBinQueryHandler top_allDocumentsBySorted];
    for (TOPBinDocument *obj in documents) {
        CGFloat sinceNow = fabs(obj.delTime.timeIntervalSinceNow);
        if (sinceNow > expiration) {
            RLMResults<TOPBinImage *> *images = [TOPBinQueryHandler top_imageFilesByParentId:obj.Id];
            if (!images.count) {
                [expiredFiles addObject:obj];
                NSString *docPath = [self top_binDocumentPath:obj.pathId];
                [TOPWHCFileManager top_removeItemAtPath:docPath];
            }
        }
    }
    [TOPDBService top_removeAllObjects:expiredFiles];
    [expiredFiles removeAllObjects];
    
    RLMResults<TOPBinFolder *> *folders = [TOPBinQueryHandler top_allFoldersBySorted];
    for (TOPBinFolder *obj in folders) {
        CGFloat sinceNow = fabs(obj.delTime.timeIntervalSinceNow);
        if (sinceNow > expiration) {
            RLMResults<TOPBinDocument *> *docs = [TOPBinQueryHandler top_documentsAtFoler:obj.Id];
            if (!docs.count) {
                [expiredFiles addObject:obj];
                NSString *docPath = [self top_binFolderPath:obj.pathId];
                [TOPWHCFileManager top_removeItemAtPath:docPath];
            }
        }
    }
    [TOPDBService top_removeAllObjects:expiredFiles];
}

#pragma mark -- 从数据库获取首页数据
+ (NSMutableArray *)top_buildBinHomeDataWithDB {
    NSMutableArray *dataArray = [self top_buildBinFolerDataWithParentId:@"000000"];
    return dataArray;
}

#pragma mark -- 从数据库获取Folder次级界面数据
+ (NSMutableArray *)top_buildBinFolderDataWithDB:(TOPBinFolder *)fldModel {
    NSMutableArray *dataArr = [self top_buildBinFolerDataWithParentId:fldModel.Id];
    return dataArr;
}

#pragma mark -- 从数据库获取子目录文件夹数据-根据父id
+ (NSMutableArray *)top_buildBinFolerDataWithParentId:(NSString *)parentId {
    NSMutableArray *folderArr = @[].mutableCopy;
    NSMutableArray *docArr = @[].mutableCopy;
    //folder 文件夹
    RLMResults<TOPBinFolder *> *folders = [TOPBinQueryHandler top_foldersByParentId:parentId];
    for (TOPBinFolder *folderObj in folders) {
        folderObj.filePath = [self top_binFolderPath:folderObj.pathId];
        DocumentModel *dtModel = [self top_buildFolderModelWithData:folderObj];
        if (dtModel) {
            [folderArr addObject:dtModel];
        }
    }
    //document 文档
    RLMResults<TOPBinDocument *> *documents = [TOPBinQueryHandler top_documentsByParentId:parentId];
    for (TOPBinDocument *docObj in documents) {
        docObj.filePath = [self top_binDocumentPath:docObj.pathId];
        DocumentModel *dtModel = [self top_buildDocumentModelWithData:docObj];
        if (dtModel) {
            [docArr addObject:dtModel];
        }
    }
    
    NSMutableArray *dataArray = @[].mutableCopy;
    [dataArray addObjectsFromArray:folderArr];
    [dataArray addObjectsFromArray:docArr];
    
    return dataArray;
}

#pragma mark -- 从数据库获取文档详情数据
+ (NSMutableArray *)top_buildBinDocumentDataWithDB:(TOPBinDocument *)docModel {
    NSMutableArray *dataArr = @[].mutableCopy;
    NSArray *images = [TOPBinQueryHandler top_sortImageFilesByParentId:docModel.Id];
    for (int i = 0; i < images.count; i ++) {
        TOPBinImage *imgObj = images[i];
        imgObj.filePath = [docModel.filePath stringByAppendingPathComponent:imgObj.fileName];
        DocumentModel *dtModel = [self top_buildImageModelWithData:imgObj];
        if (dtModel) {
            if (i + 1 < 10) {
                dtModel.name = [NSString stringWithFormat:@"0%d",i + 1];
            }else{
                dtModel.name = [NSString stringWithFormat:@"%d",i + 1];
            }
            [dataArr addObject:dtModel];
        }
    }
    return dataArr;
}

#pragma mark -- 首页 回收站还原新增Document模型
+ (DocumentModel *)top_restoreNewDocModel:(NSString *)endPath withDelParentId:(NSString *)delParentId {
    TOPBinImage *img = [TOPBinQueryHandler top_imageFileById:delParentId];
    TOPAppDocument *doc = [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:@"000000"];
    [TOPDBService top_transactionWithBlock:^{
        doc.storeParentId = img.delParentId;
    }];
    DocumentModel *model = [TOPDBDataHandler top_buildDocumentModelWithData:doc];
    return model;
}


#pragma mark -- 回收站是否新建文档
+ (BOOL)top_needCreateBinDocument:(NSString *)docId {
    TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:docId];
    TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:imgFile.parentId];
    RLMResults<TOPBinImage *> *images = [TOPBinImage objectsWhere:@"delParentId = %@", doc.pathId];
    if (images.count) {               
        return NO;
    }
    return YES;
}

#pragma mark -- 从回收站还原的文档是否新建文档--不需要的话做合并
+ (BOOL)top_needNewDocument:(NSString *)docId {
    TOPBinDocument *doc = [TOPBinQueryHandler top_appDocumentById:docId];
    RLMResults<TOPAppDocument *> *docs = [TOPAppDocument objectsWhere:@"pathId = %@ OR storeParentId = %@", doc.delParentId, doc.delParentId];
    if (docs.count) {
        return NO;
    }
    return YES;
}

#pragma mark -- 构造回收站Folder模型 parentId:(删除前)上级目录的pathId
+ (TOPBinFolder *)top_buildBinFolderWithParentId:(NSString *)parentId atPath:(NSString *)docPath {
    NSString *fdStr = [TOPWHCFileManager top_fileNameAtPath:docPath suffix:YES];
    TOPBinFolder *folderModel = [[TOPBinFolder alloc] init];
    folderModel.Id = parentId;
    folderModel.parentId = @"000000";
    folderModel.name = fdStr;
    folderModel.pathId = [NSString stringWithFormat:@"%@/%@",folderModel.parentId, folderModel.Id];
    folderModel.ctime = [TOPDocumentHelper top_createTimeOfFile:docPath];
    folderModel.utime = [TOPDocumentHelper top_updateTimeOfFile:docPath];
    folderModel.delTime = [NSDate date];
    folderModel.filePath = docPath;
    return folderModel;
}

#pragma mark -- 构造完整的文档数据对象
+ (TOPBinDocument *)top_buildFullBinDocWithParentId:(NSString *)parentId atPath:(NSString *)path {
    TOPBinDocument *documentModel = [self top_buildBinDocWithParentId:@"000000" atPath:path];
    documentModel.delParentId = [parentId stringByDeletingLastPathComponent];
    //图片
    NSMutableArray *imgArr = @[].mutableCopy;
    imgArr = [self top_buildRealmImagesWithData:documentModel];
    if (imgArr.count) {
        [documentModel.images addObjects:imgArr];
    }
    return documentModel;
}

#pragma mark -- 构造完整的文档数据对象
+ (TOPBinDocument *)top_buildBinDocWithParentId:(NSString *)parentId atPath:(NSString *)docPath {
    NSString *fdStr = [TOPWHCFileManager top_fileNameAtPath:docPath suffix:YES];
    TOPBinDocument *documentModel = [[TOPBinDocument alloc] init];
    documentModel.Id = [[NSUUID UUID] UUIDString];
    documentModel.parentId = [parentId isEqualToString:@"000000"] ? parentId : [[parentId componentsSeparatedByString:@"/"] lastObject];
    documentModel.name = fdStr;
    documentModel.pathId = [NSString stringWithFormat:@"%@/%@",parentId, documentModel.Id];
    documentModel.filePath = docPath;
    documentModel.ctime = [TOPDocumentHelper top_createTimeOfFile:docPath];
    documentModel.utime = [TOPDocumentHelper top_updateTimeOfFile:docPath];
    documentModel.rtime = [TOPDocumentHelper top_updateTimeOfFile:docPath];
    documentModel.delTime = [NSDate date];
    documentModel.isDelete = NO;
    documentModel.docNoticeLock = NO;
    return documentModel;
}

#pragma mark -- 构造回收站Image模型
+ (NSMutableArray *)top_buildRealmImagesWithData:(TOPBinDocument *)appDoc {
    if (!appDoc.filePath.length) {
        appDoc.filePath = [TOPBinDataHandler top_binDocumentPath:appDoc.pathId];
    }
    NSMutableArray * sortDtArray = @[].mutableCopy;
    NSString *docPath = appDoc.filePath;
    NSArray *imageArr = [TOPDocumentHelper top_sortPicsAtPath:docPath];
    for (NSString *pic in imageArr) {
        NSString *imgPath = [docPath stringByAppendingPathComponent:pic];
        TOPBinImage *imgModel = [[TOPBinImage alloc] init];
        imgModel.Id = [[NSUUID UUID] UUIDString];
        imgModel.fileName = pic;
        imgModel.parentId = appDoc.Id;
        imgModel.pathId = [NSString stringWithFormat:@"%@/%@",appDoc.pathId, imgModel.Id];
        imgModel.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:imgPath] longValue];
        imgModel.fileShowName = pic;
        imgModel.ctime = [TOPDocumentHelper top_createTimeOfFile:imgPath];
        imgModel.utime = [TOPDocumentHelper top_updateTimeOfFile:imgPath];
        imgModel.delTime = [NSDate date];
        imgModel.isDelete = NO;
        imgModel.isUpload = NO;
        imgModel.isUploadSuccess = NO;
        imgModel.delParentId = appDoc.delParentId;
        [sortDtArray addObject:imgModel];
    }

    return sortDtArray;
}

#pragma mark -- 根据图片名称构造Bin Image模型
+ (NSMutableArray *)top_buildRealmImagesByFileNames:(NSArray *)fileNames withData:(TOPBinDocument *)appDoc {
    if (!appDoc.filePath.length) {
        appDoc.filePath = [TOPBinDataHandler top_binDocumentPath:appDoc.pathId];
    }
    NSMutableArray * sortDtArray = @[].mutableCopy;
    NSString *docPath = appDoc.filePath;
    for (NSString *pic in fileNames) {
        if (![TOPDocumentHelper top_isCoverJPG:pic]) {//校验图片名称是否合规
            continue;
        }
        NSString *imgPath = [docPath stringByAppendingPathComponent:pic];
        TOPBinImage *imgModel = [[TOPBinImage alloc] init];
        imgModel.Id = [[NSUUID UUID] UUIDString];
        imgModel.fileName = pic;
        imgModel.parentId = appDoc.Id;
        imgModel.pathId = [NSString stringWithFormat:@"%@/%@",appDoc.pathId, imgModel.Id];
        imgModel.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:imgPath] longValue];
        imgModel.fileShowName = pic;
        imgModel.ctime = [TOPDocumentHelper top_createTimeOfFile:imgPath];
        imgModel.utime = [TOPDocumentHelper top_updateTimeOfFile:imgPath];
        imgModel.delTime = [NSDate date];
        imgModel.isDelete = NO;
        imgModel.isUpload = NO;
        imgModel.isUploadSuccess = NO;
        imgModel.delParentId = appDoc.delParentId;
        [sortDtArray addObject:imgModel];
    }
    return sortDtArray;
}

#pragma mark -- 文件夹 根据pathId获取完整路径
+ (NSString *)top_binFolderPath:(NSString *)pathId {
    NSArray *pathIds = [pathId componentsSeparatedByString:@"/"];
    NSString *fldPath = [TOPBinHelper top_getBinFoldersPathString];
    for (NSString *pathId in pathIds) {
        if ([pathId isEqualToString:@"000000"]) {//000000代表根目录固定不变
            continue;
        }
        TOPBinFolder *folderModel = [TOPBinQueryHandler top_appFolderById:pathId];
        fldPath = [fldPath stringByAppendingPathComponent:folderModel.name];
    }
    return fldPath;
}

#pragma mark -- 文档 根据pathId获取完整路径 ***特别注意在文件夹下的文档路径拼接 需要先拼接文件夹路径最后拼接文档名称
+ (NSString *)top_binDocumentPath:(NSString *)pathId {
    NSString *documentPath = [TOPBinHelper top_getBinDocumentsPathString];
    NSArray *pathIds = [pathId componentsSeparatedByString:@"/"];
    if (pathIds.count < 2) {//防止闪退保护，正常情况不会出现
        return documentPath;
    }
    TOPBinDocument *docModel = [TOPBinQueryHandler top_appDocumentById:pathIds.lastObject];
    if (pathIds.count == 2) {//首页文档
        documentPath = [documentPath stringByAppendingPathComponent:docModel.name];
    } else {//文件夹下的文档 先拼接上级目录的路径，再拼接当前文档的名称
        NSString *fatherPathId = [TOPWHCFileManager top_directoryAtPath:pathId];
        NSString *fatherPath = [self top_binFolderPath:fatherPathId];
        documentPath = [fatherPath stringByAppendingPathComponent:docModel.name];
    }
    return documentPath;
}

#pragma mark -- folder 还原后的路径
+ (NSString *)top_restoreFolderPath:(NSString *)docId {
    NSString *fldPath = @"";
    TOPBinFolder *folderModel = [TOPBinQueryHandler top_appFolderById:docId];
    NSString *parentId = [folderModel.delParentId stringByDeletingLastPathComponent];
    if ([parentId isEqualToString:@"000000"]) {
        fldPath = [[TOPDocumentHelper top_getFoldersPathString] stringByAppendingPathComponent:folderModel.name];
    } else {
        parentId = [parentId lastPathComponent];
        TOPAPPFolder *folderObj = [TOPDBQueryService top_appFolderById:parentId];
        if (folderObj) {
            fldPath = [TOPDBDataHandler top_folderPath:folderObj.pathId];
            fldPath = [fldPath stringByAppendingPathComponent:folderModel.name];
        } else {//原父目录不存在了 统一放置在首页
            fldPath = [[TOPDocumentHelper top_getFoldersPathString] stringByAppendingPathComponent:folderModel.name];
        }
    }
    fldPath = [TOPDocumentHelper top_createDirectoryAtPath:fldPath];
    return fldPath;
}

#pragma mark -- document 还原后的路径
+ (NSString *)top_restoreDocumentPath:(NSString *)docId {
    NSString *fldPath = @"";
    TOPBinDocument *folderModel = [TOPBinQueryHandler top_appDocumentById:docId];
    
    NSString *parentId = [folderModel.delParentId stringByDeletingLastPathComponent];
    RLMResults<TOPAPPFolder *> *folders = [TOPAPPFolder objectsWhere:@"pathId = %@",parentId];
    if (!folders.count) {//源文档父目录不存在 --则在首页新建文档
        parentId = @"000000";
    }
    if ([parentId isEqualToString:@"000000"]) {
        fldPath = [[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:folderModel.name];
    } else {
        parentId = [parentId lastPathComponent];
        TOPAPPFolder *folderObj = [TOPDBQueryService top_appFolderById:parentId];
        if (folderObj) {
            fldPath = [TOPDBDataHandler top_folderPath:folderObj.pathId];
            fldPath = [fldPath stringByAppendingPathComponent:folderModel.name];
        } else {//原父目录不存在了 统一放置在首页
            fldPath = [[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:folderModel.name];
        }
    }
    fldPath = [TOPDocumentHelper top_createDirectoryAtPath:fldPath];
    return fldPath;
}

#pragma mark -- image 还原后的父级目录
+ (NSString *)top_restoreImageParentPath:(NSString *)docId {
    NSString *fldPath = @"";
    TOPBinImage *folderModel = [TOPBinQueryHandler top_imageFileById:docId];
    RLMResults<TOPAppDocument *> *docs = [TOPAppDocument objectsWhere:@"pathId = %@ OR storeParentId = %@", folderModel.delParentId,folderModel.delParentId];
    if (docs.count) {//父级目录存在
        TOPAppDocument *doc = docs[0];
        fldPath = [TOPDBDataHandler top_documentPath:doc.pathId];
        if (![TOPWHCFileManager top_isExistsAtPath:fldPath]) {
            [TOPWHCFileManager top_createDirectoryAtPath:fldPath];
        }
    } else {//父级目录不存在
        TOPBinDocument *docModel = [TOPBinQueryHandler top_appDocumentById:folderModel.parentId];
        fldPath = [TOPDocumentHelper top_createDirectoryAtPath:[[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:docModel.name]];
    }
    return fldPath;
}

#pragma mark -- image 还原后的文档Id
+ (NSString *)top_restoreImageParentId:(NSString *)docId {
    TOPBinImage *folderModel = [TOPBinQueryHandler top_imageFileById:docId];
    RLMResults<TOPAppDocument *> *docs = [TOPAppDocument objectsWhere:@"pathId = %@ OR storeParentId = %@", folderModel.delParentId,folderModel.delParentId];
    if (docs.count) {
        TOPAppDocument *doc = docs[0];
        return doc.Id;
    }
    return nil;
}

#pragma mark -- document父级目录id
+ (NSString *)top_documentParentId:(NSString *)docId {
    TOPBinDocument *folderModel = [TOPBinQueryHandler top_appDocumentById:docId];
    NSString *parentId = [folderModel.delParentId stringByDeletingLastPathComponent];
    parentId = [parentId lastPathComponent];
    return parentId;
}

#pragma mark -- image父级目录id
+ (NSString *)top_imageParentId:(NSString *)docId {
    NSString *parentId = [self top_restoreImageParentId:docId];
//    TOPBinImage *folderModel = [TOPBinQueryHandler top_imageFileById:docId];
//    NSString *parentId = [folderModel.delParentId lastPathComponent];
    return parentId;
}

#pragma mark -- 构造文件夹Folder模型
+ (DocumentModel *)top_buildFolderModelWithData:(TOPBinFolder *)appFld {
    if (![TOPWHCFileManager top_isExistsAtPath:appFld.filePath] || [TOPDocumentHelper top_directoryHasJPG:appFld.filePath]) {
        return nil;
    }
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    dtModel.name = appFld.name;
    dtModel.path = appFld.filePath;
    dtModel.docId = appFld.Id;
    dtModel.createDate = [TOPAppTools timeStringFromDate:appFld.utime];
    dtModel.type = @"0";
    dtModel.isFile = NO;
    RLMResults<TOPBinDocument *> *docArr = [TOPBinQueryHandler top_documentsAtFoler:appFld.Id];
    dtModel.number = [NSString stringWithFormat:@"%ld", docArr.count];
    return dtModel;
}

#pragma mark -- 构造文档Doc模型
+ (DocumentModel *)top_buildDocumentModelWithData:(TOPBinDocument *)appDoc {
    //document下的文件夹若是空的就删除掉
    RLMResults<TOPBinImage *> *images = [TOPBinQueryHandler top_imageFilesByParentId:appDoc.Id];
    if (!images.count || ![TOPWHCFileManager top_isExistsAtPath:appDoc.filePath]) {
        [TOPWHCFileManager top_removeItemAtPath:appDoc.filePath];
        return nil;
    }
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    dtModel.path = appDoc.filePath;
    dtModel.docId = appDoc.Id;
    dtModel.name = appDoc.name;
    dtModel.docNoticeLock = appDoc.docNoticeLock;
    dtModel.remindTime = appDoc.remindTime;
    dtModel.remindTitle = appDoc.remindTitle;
    dtModel.remindNote = appDoc.remindNote;
    dtModel.createDate = [TOPAppTools timeStringFromDate:appDoc.utime];
    dtModel.type = @"1";
    dtModel.isFile = NO;
    dtModel.number = [NSString stringWithFormat:@"%ld", [appDoc.images count]];
    TOPBinImage *imgFile = appDoc.images.firstObject;
    NSString *imageName = imgFile.fileName;
    dtModel.imagePath = [dtModel.path stringByAppendingPathComponent:imageName];
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[dtModel.path stringByReplacingOccurrencesOfString:@"/" withString:@""],imageName];
    dtModel.coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    dtModel.gaussianBlurPath = [TOPDocumentHelper top_gaussianBlurImgFileString:coverName];
    dtModel.tagsPath = [TOPDocumentHelper top_getTagsPathString:dtModel.path];
    dtModel.tagsArray = [TOPDataModelHandler top_getDocumentTagsArrayWithPath:dtModel.path];
    dtModel.docPasswordPath = [TOPDocumentHelper top_getDocPasswordPathString:dtModel.path];
    return dtModel;
}

#pragma mark -- 构造Image数据模型
+ (DocumentModel *)top_buildImageModelWithData:(TOPBinImage *)imgFile {
    //判断图片是否存在 同时判断图片的名称是否合规 判断图片大小
    if (![TOPWHCFileManager top_isExistsAtPath:imgFile.filePath] || ![TOPDocumentHelper top_isCoverJPG:imgFile.fileName] || (imgFile.fileLength <= 0)) {
        return nil;
    }
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    dtModel.docId = imgFile.Id;
    NSString *fullStr = imgFile.filePath;
    dtModel.movePath =[TOPWHCFileManager top_directoryAtPath:imgFile.filePath];//文件夹路径
    dtModel.fileName = [TOPWHCFileManager top_fileNameAtPath:dtModel.movePath suffix:YES];
    dtModel.path = fullStr;//图片路径
    dtModel.createDate = [TOPAppTools timeStringFromDate:imgFile.utime];//修改时间
    dtModel.picCreateDate = [TOPAppTools timeStringFromDate:imgFile.ctime];//创建时间
    dtModel.isFile = YES;
    dtModel.chooseStatus = NO;
    dtModel.type = @"1";
    CGFloat fileLength = imgFile.fileLength > 0 ? imgFile.fileLength : [[TOPWHCFileManager top_sizeOfFileAtPath:imgFile.filePath] floatValue];
    dtModel.number = [TOPDocumentHelper top_memorySizeStr:fileLength];
    dtModel.photoIndex = [TOPWHCFileManager top_fileNameAtPath:fullStr suffix:NO];
    dtModel.photoName = [TOPWHCFileManager top_fileNameAtPath:fullStr suffix:YES];
    dtModel.notePath = [TOPDocumentHelper top_getTxtPath:dtModel.movePath imgName:dtModel.photoIndex txtType:TOPRSimpleScanNoteString];
    dtModel.note = [TOPDocumentHelper top_getTxtContent:dtModel.notePath];
    dtModel.ocrPath = [TOPDocumentHelper top_getTxtPath:dtModel.movePath imgName:dtModel.photoIndex txtType:@""];
    dtModel.ocr = [TOPDocumentHelper top_getTxtContent:dtModel.ocrPath];
    if (dtModel.photoIndex.length > 14) {
        dtModel.numberIndex = [dtModel.photoIndex substringFromIndex:14];
    }
    dtModel.selectStatus = NO;
    dtModel.imagePath = fullStr;
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[dtModel.movePath stringByReplacingOccurrencesOfString:@"/" withString:@""],dtModel.photoName];
    dtModel.coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    return dtModel;
}

#pragma mark -- 图片 计算所有文件大小
+ (long)top_sumAllBinFileSize {
    RLMResults<TOPBinImage *> *images = [TOPBinImage allObjects];
    long sumSize = [[images sumOfProperty:@"fileLength"] longValue];
    return sumSize;
}

#pragma mark -- 图片 计算文件大小
+ (long)top_sumBinImagesFileSize:(NSArray *)imgIds {
    RLMResults<TOPBinImage *> *images = [TOPBinQueryHandler top_imageFilesWithImageIds:imgIds];
    long sumSize = [[images sumOfProperty:@"fileLength"] longValue];
    return sumSize;
}

#pragma mark -- 文档 计算文件大小
+ (long)top_sumBinDocumentsFileSize:(NSArray *)docIds {
    long sumSize = 0;
    for (NSString *docId in docIds) {
        TOPBinDocument *doc = [TOPBinQueryHandler top_appDocumentById:docId];
        long docSize = [[doc.images sumOfProperty:@"fileLength"] longValue];
        sumSize += docSize;
    }
    return sumSize;
}

#pragma mark -- 文件夹 计算文件大小
+ (long)top_sumBinFoldersFileSize:(NSArray *)folderIds {
    long sumSize = 0;
    for (NSString *docId in folderIds) {
        TOPBinFolder *fld = [TOPBinQueryHandler top_appFolderById:docId];
        RLMResults<TOPBinDocument *> *documents = [TOPBinQueryHandler top_documentsAtFoler:fld.Id];
        for (TOPBinDocument *docObj in documents) {
            long docSize = [[docObj.images sumOfProperty:@"fileLength"] longValue];
            sumSize += docSize;
        }
    }
    return sumSize;
}

@end
