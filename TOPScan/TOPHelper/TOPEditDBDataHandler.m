#import "TOPEditDBDataHandler.h"
#import "TOPDBService.h"
#import "TOPAPPFolder.h"
#import "TOPAppDocument.h"
#import "TOPImageFile.h"
#import "TOPDocTag.h"
#import "TOPDBDataHandler.h"
#import "TOPBinDocument.h"

@implementation TOPEditDBDataHandler
#warning 增、删、改操作需要更新文件的修改时间字段

#pragma mark -- 增加文件夹
+ (TOPAPPFolder *)top_addFolderAtFile:(NSString *)path WithParentId:(NSString *)folderId {
    NSString *parentId = folderId;
    if (![parentId isEqualToString:@"000000"]) {//区分是首页的文档，还是folder下的文档
        TOPAPPFolder *appFolder = [TOPDBQueryService top_appFolderById:folderId];
        parentId = appFolder.pathId;
    }
    TOPAPPFolder *appFolder = [TOPDBDataHandler top_buildRealmFolderWithParentId:parentId atPath:path];
    [TOPDBService top_saveObject:appFolder];
    return appFolder;
}

#pragma mark -- 删除文件夹
+ (void)top_deleteFolderWithId:(NSString *)docId {
    //该目录下的文件夹
    RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_foldersAtFile:docId];
    [TOPDBService top_removeAllObjects:folders];
    //该目录下的文档
    RLMResults<TOPAppDocument *> *docs = [TOPDBQueryService top_documentsAtFoler:docId];
    [TOPDBService top_removeAllObjects:docs];
    
    TOPAPPFolder *appFolder = [TOPDBQueryService top_appFolderById:docId];
    [TOPDBService top_removeObject:appFolder];
}

#pragma mark -- 修改文件夹名称
+ (void)top_editFolderName:(NSString *)name withId:(NSString *)docId {
    TOPAPPFolder *appFolder = [TOPDBQueryService top_appFolderById:docId];
    [TOPDBService top_transactionWithBlock:^{
        appFolder.utime = [NSDate date];
        appFolder.name = name;
    }];
}
#pragma mark -- 增加文档
+ (TOPAppDocument *)top_addDocumentAtFolder:(NSString *)path WithParentId:(NSString *)folderId {
    NSString *parentId = folderId;
    if (![parentId isEqualToString:@"000000"]) {//区分是首页的文档，还是folder下的文档
        TOPAPPFolder *appFolder = [TOPDBQueryService top_appFolderById:folderId];
        parentId = appFolder.pathId;
        [TOPDBService top_transactionWithBlock:^{
            appFolder.utime = [NSDate date];
        }];
    }
    TOPAppDocument *appDoc = [TOPDBDataHandler top_buildFullDocumetnWithParentId:parentId atPath:path];
    [TOPDBService top_saveObject:appDoc];
    return appDoc;
}

#pragma mark -- 重置新建文档的创建和修改时间--保持从回收站还原前后一致
+ (void)top_setDocTime:(NSString *)docId withBinDocId:(NSString *)binDocId {
    TOPAppDocument *docObj = [TOPDBQueryService top_appDocumentById:docId];
    TOPBinDocument *binDoc = [TOPBinQueryHandler top_appDocumentById:binDocId];
    [TOPDBService top_transactionWithBlock:^{
        docObj.ctime = binDoc.ctime;
        docObj.utime = binDoc.utime;
    }];
}

#pragma mark -- 删除文档
+ (void)top_deleteDocumentWithId:(NSString *)docId {
    RLMResults<TOPImageFile *> * images = [TOPDBQueryService top_imageFilesByParentId:docId];
    [TOPDBService top_removeAllObjects:images];
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    [TOPDBService top_removeObject:appDoc];
}

#pragma mark -- 修改文档名称
+ (void)top_editDocumentName:(NSString *)name withId:(NSString *)docId {
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    [TOPDBService top_transactionWithBlock:^{
        appDoc.utime = [NSDate date];
        appDoc.name = name;
    }];
}
#pragma mark -- 修改文档加载耗时
+ (void)top_editDocumentCostTime:(int)costTime withId:(NSString *)docId {
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    [TOPDBService top_transactionWithBlock:^{
        appDoc.costTime = costTime;
    }];
}

#pragma mark -- 修改文档浏览时间
+ (void)top_editDocumentReadingTimeWithId:(NSString *)docId {
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    [TOPDBService top_transactionWithBlock:^{
        appDoc.rtime = [NSDate date];
    }];
}
#pragma mark -- 修改文档收藏状态
+ (void)top_editDocumentCollectionState:(NSInteger)state withId:(NSString *)docId{
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    [TOPDBService top_transactionWithBlock:^{
        appDoc.collectionState = state;
    }];
}
#pragma mark -- 写入文档提醒的数据
+ (void)top_editDocumentNoticeModel:(TOPDocNoticeModel *)noticeModel{
    TOPAppDocument * appDoc = [TOPDBQueryService top_appDocumentById:noticeModel.noticeID];
    [TOPDBService top_transactionWithBlock:^{
        appDoc.remindTime = noticeModel.noticeDate;
        appDoc.remindTitle = noticeModel.noticeTitle;
        appDoc.remindNote = noticeModel.noticeBody;
        appDoc.docNoticeLock = noticeModel.noticeState;
    }];
}
#pragma mark -- 修改文档路径：移动
+ (void)top_editDocumentPath:(NSString *)name withParentId:(NSString *)parentId withId:(NSString *)docId {
    NSString *pathId = parentId;
    TOPAPPFolder *appFolder = [TOPDBQueryService top_appFolderById:parentId];
    if (![parentId isEqualToString:@"000000"]) {
        pathId = appFolder.pathId;
    }
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    // warn： 通过parentId查询的集合，不可以修改对象的parentId，一旦修改集合会删除该对象
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:docId];
    [TOPDBService top_transactionWithBlock:^{
        if (appFolder) {
            appFolder.utime = [NSDate date];
        }
        appDoc.utime = [NSDate date];
        appDoc.name = name;
        appDoc.parentId = parentId;
        appDoc.pathId = [NSString stringWithFormat:@"%@/%@",pathId, appDoc.Id];
        for (TOPImageFile *imgFile in images) {
            imgFile.pathId = [NSString stringWithFormat:@"%@/%@",appDoc.pathId, imgFile.Id];
        }
    }];
}

#pragma mark -- 拷贝文档
+ (TOPAppDocument *)top_copyDocument:(NSString *)docId atFolder:(NSString *)path WithParentId:(NSString *)folderId {
    NSString *parentId = folderId;
    if (![parentId isEqualToString:@"000000"]) {//区分是首页的文档，还是folder下的文档
        TOPAPPFolder *appFolder = [TOPDBQueryService top_appFolderById:folderId];
        parentId = appFolder.pathId;
        [TOPDBService top_transactionWithBlock:^{
            appFolder.utime = [NSDate date];
        }];
    }
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    TOPAppDocument *copyDoc = [[TOPAppDocument alloc] initWithValue:appDoc];
    copyDoc.Id = [[NSUUID UUID] UUIDString];
    copyDoc.parentId = folderId;
    copyDoc.name = [TOPWHCFileManager top_fileNameAtPath:path suffix:YES];
    copyDoc.pathId = [NSString stringWithFormat:@"%@/%@",parentId,copyDoc.Id];
    copyDoc.utime = [NSDate date];
    [TOPDBService top_transactionWithBlock:^{//这是一个新文档，图片数据也要生成一份新的
        NSMutableArray *temp = @[].mutableCopy;
        for (TOPImageFile *imgFile in copyDoc.images) {
            TOPImageFile *copyImg = [[TOPImageFile alloc] initWithValue:imgFile];
            copyImg.Id = [[NSUUID UUID] UUIDString];
            copyImg.parentId = copyDoc.Id;
            copyImg.pathId = [NSString stringWithFormat:@"%@/%@",copyDoc.pathId, copyImg.Id];
            copyImg.utime = [NSDate date];
            [temp addObject:copyImg];
        }
        [copyDoc.images removeAllObjects];
        [copyDoc.images addObjects:temp];
    }];
    [TOPDBService top_saveObject:copyDoc];
    return appDoc;
}
#pragma mark -- 更新文档图片的排序
+ (void)top_updateDocumentImagesSortWithIds:(NSArray *)Ids byDoc:(NSString *)docPath {
    NSArray *imageNames = [TOPDocumentHelper top_sortPicsAtPath:docPath];
    NSMutableArray *images = [TOPDBQueryService top_imageFilesOrderByImageIds:Ids];
    if (images.count && imageNames.count) {
        [TOPDBService top_transactionWithBlock:^{
            for (int i = 0; i < images.count; i++) {
                if (i < imageNames.count) {
                    NSString *imgName = imageNames[i];
                    TOPImageFile *imageFile = images[i];
                    imageFile.fileName = imgName;
                }
            }
            TOPImageFile *subImg = images.firstObject;
            TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:subImg.parentId];
            appDoc.utime = [NSDate date];
            [appDoc.images removeAllObjects];
            [appDoc.images addObjects:images];
        }];
    }
}

#pragma mark -- 更新文档标签
+ (void)top_updateDocumentTags:(NSDictionary *)data byDocIds:(NSArray *)docIds {
    RLMResults<TOPAppDocument *> *appDocs = [TOPAppDocument objectsWhere:@"Id IN %@", docIds];
    [TOPDBService top_batchUpdateObjects:appDocs data:data];
}

#pragma mark -- 增加图片
+ (void)top_addImageFileAtDocument:(NSArray *)fileNames WithId:(NSString *)docId {
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    appDoc.filePath = [TOPDBDataHandler top_documentPath:appDoc.pathId];
    NSMutableArray *imgArr = [TOPDBDataHandler top_buildRealmImagesByFileNames:fileNames withData:appDoc];
    if (imgArr.count) {
        [TOPDBService top_transactionWithBlock:^{
            appDoc.utime = [NSDate date];
            [appDoc.images addObjects:imgArr];
        }];
    }
}

#pragma mark -- 增加来自回收站的图片，文档时间不做修改
+ (void)top_addBinImageFileAtDocument:(NSArray *)fileNames WithId:(NSString *)docId {
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    appDoc.filePath = [TOPDBDataHandler top_documentPath:appDoc.pathId];
    NSMutableArray *imgArr = [TOPDBDataHandler top_buildRealmImagesByFileNames:fileNames withData:appDoc];
    if (imgArr.count) {
        [TOPDBService top_transactionWithBlock:^{
            [appDoc.images addObjects:imgArr];
        }];
    }
}

#pragma mark -- 删除图片
+ (void)top_deleteImagesWithIds:(NSArray *)imageIds {
    RLMResults<TOPImageFile *> * images = [TOPDBQueryService top_imageFilesWithImageIds:imageIds];
    if (images.count) {
        TOPImageFile *imageFile = images.firstObject;
        TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:imageFile.parentId];
        if (appDoc.images.count == images.count) {//删除全部图片的同时也要删除文档
            [TOPDBService top_removeObject:appDoc];
        } else {
            [TOPDBService top_transactionWithBlock:^{
                appDoc.utime = [NSDate date];
            }];
        }
        [TOPDBService top_removeAllObjects:images];
    }
}

#pragma mark -- 更新图片
+ (void)top_updateImageWithId:(NSString *)imageId {
    TOPImageFile *image = [TOPDBQueryService top_imageFileById:imageId];
    TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:image.parentId];
    image.filePath = [[TOPDBDataHandler top_documentPath:doc.pathId] stringByAppendingPathComponent:image.fileName];
    [TOPDBService top_transactionWithBlock:^{
        image.utime = [NSDate date];
        image.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:image.filePath] longValue];
    }];
}

#pragma mark -- 批量更新图片
+ (void)top_updateImagesWithIds:(NSArray *)imageIds {
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesWithImageIds:imageIds];
    if (images.count) {
        TOPImageFile *obj = images.firstObject;
        TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:obj.parentId];
        NSString *docPath = [TOPDBDataHandler top_documentPath:doc.pathId];
        [TOPDBService top_transactionWithBlock:^{
            for (TOPImageFile *image in images) {
                image.filePath = [docPath stringByAppendingPathComponent:image.fileName];
                image.utime = [NSDate date];
                image.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:image.filePath] longValue];
            }
        }];
    }
}

#pragma mark -- 更新图片 裁剪、渲染、朝向
+ (void)top_updateImageWithHandler:(NSDictionary *)handler byId:(NSString *)imageId {
    int orientation = [handler[@"orientation"] intValue];
    int filter = [handler[@"filter"] intValue];
    NSArray *points = handler[@"points"];
    NSData *data = points.count == 5 ? [NSJSONSerialization dataWithJSONObject:points options:NSJSONWritingPrettyPrinted error:nil] : nil;
    
    NSArray *autoPoints = handler[@"autoPoints"];
    NSData *autoData = autoPoints.count == 5 ? [NSJSONSerialization dataWithJSONObject:autoPoints options:NSJSONWritingPrettyPrinted error:nil] : nil;
    
    UIDeviceOrientation faceOr = [[UIDevice currentDevice] orientation];
    TOPImageFile *image = [TOPDBQueryService top_imageFileById:imageId];
    TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:image.parentId];
    image.filePath = [[TOPDBDataHandler top_documentPath:doc.pathId] stringByAppendingPathComponent:image.fileName];
    [TOPDBService top_transactionWithBlock:^{
        image.utime = [NSDate date];
        image.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:image.filePath] longValue];
        image.orientation = orientation;
        image.filterMode = filter;
        if (faceOr == UIDeviceOrientationLandscapeLeft || faceOr == UIDeviceOrientationLandscapeRight) {
            image.landscapePoints = data;
            image.autoLandscapePoints = autoData;
        } else {
            image.portraitPoints = data;
            image.atuoPortraitPoints = autoData;
        }
    }];
}


#pragma mark -- 生成新图片：根据原图片和新图名称
+ (void)top_createImageById:(NSString *)imageId WithName:(NSString *)imageName {
    TOPImageFile *image = [TOPDBQueryService top_imageFileById:imageId];
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:image.parentId];
    TOPImageFile *newImg = [[TOPImageFile alloc] initWithValue:image];
    newImg.Id = [[NSUUID UUID] UUIDString];
    newImg.pathId = [NSString stringWithFormat:@"%@/%@",appDoc.pathId, newImg.Id];
    newImg.fileName = imageName;
    newImg.utime = [NSDate date];
    newImg.ctime = [NSDate date];
    [TOPDBService top_transactionWithBlock:^{
        [appDoc.images addObject:newImg];
    }];
}

#pragma mark -- 更新图片 根据图片名称和上级目录
+ (void)top_updateImageWithName:(NSString *)imageName atDoc:(NSString *)docId {
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:docId withName:imageName];
    if (images.count) {
        TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:docId];
        TOPImageFile *image = images.firstObject;
        image.filePath = [[TOPDBDataHandler top_documentPath:doc.pathId] stringByAppendingPathComponent:image.fileName];
        [TOPDBService top_transactionWithBlock:^{
            image.utime = [NSDate date];
            image.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:image.filePath] longValue];
        }];
    }
}

#pragma mark -- 批量修改图片路径：移动 文档的所有图片
+ (void)top_batchEditImagePathWithId:(NSString *)docId toNewDoc:(NSString *)newDocId withImageNames:(NSArray *)imageNames {
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:docId];
    TOPAppDocument *newAppDoc = [TOPDBQueryService top_appDocumentById:newDocId];
    [TOPDBService top_transactionWithBlock:^{
        newAppDoc.utime = [NSDate date];
        for (int i = 0; i < appDoc.images.count; i ++) {
            TOPImageFile *imgFile = appDoc.images[i];
            imgFile.parentId = newDocId;
            imgFile.pathId = [NSString stringWithFormat:@"%@/%@",newAppDoc.pathId, imgFile.Id];
            if (i < imageNames.count) {
                imgFile.fileName = imageNames[i];
            }
            imgFile.utime = [NSDate date];
        }
        [newAppDoc.images addObjects:appDoc.images];
    }];
    [TOPDBService top_removeObject:appDoc];
}

#pragma mark -- 批量移动图片 文档的部分图片 修改parentId、pathId、fileName
+ (void)top_batchMoveImageWithIds:(NSArray *)imageIds withImageNames:(NSArray *)imageNames toNewDoc:(NSString *)newDocId {
    RLMResults<TOPImageFile *> * images = [TOPDBQueryService top_imageFilesWithImageIds:imageIds];
    [self top_batchCopyImageWithIds:imageIds withImageNames:imageNames toNewDoc:newDocId];
    [TOPDBService top_removeAllObjects:images];
}

#pragma mark -- 批量复制图片 修改parentId、pathId、fileName
+ (void)top_batchCopyImageWithIds:(NSArray *)imageIds withImageNames:(NSArray *)imageNames toNewDoc:(NSString *)newDocId {
//    RLMResults<TOPImageFile *> * images = [TOPDBQueryService top_imageFilesWithImageIds:imageIds];
    NSMutableArray *images = [TOPDBQueryService top_imageFilesOrderByImageIds:imageIds];
    TOPAppDocument *newAppDoc = [TOPDBQueryService top_appDocumentById:newDocId];
    NSMutableArray *newImages = @[].mutableCopy;
    [TOPDBService top_transactionWithBlock:^{
        newAppDoc.utime = [NSDate date];
        for (int i = 0; i < imageNames.count; i ++) {
            if (i < images.count) {
                TOPImageFile *imgFile = images[i];
                TOPImageFile *copyImg = [[TOPImageFile alloc] initWithValue:imgFile];
                copyImg.Id = [[NSUUID UUID] UUIDString];
                copyImg.parentId = newDocId;
                copyImg.pathId = [NSString stringWithFormat:@"%@/%@",newAppDoc.pathId, copyImg.Id];
                copyImg.fileName = imageNames[i];
                copyImg.utime = [NSDate date];
                [newImages addObject:copyImg];
            }
        }
        [newAppDoc.images addObjects:newImages];
    }];
}

#pragma mark -- 新增标签
+ (void)top_createTags:(NSArray *)tags {
    NSMutableArray *docTags = @[].mutableCopy;
    for (NSString *tag in tags) {
        TOPDocTag *docTag = [TOPDBDataHandler top_buildRealmTagWithName:tag];
        [docTags addObject:docTag];
    }
    [TOPDBService top_saveAllObjects:docTags];
}

#pragma mark -- 删除标签
+ (void)top_deleteTag:(NSString *)tag {
    TOPDocTag *docTag = [TOPDBQueryService top_docTagByName:tag];
    if (docTag) {
        [TOPDBService top_removeObject:docTag];
        RLMResults<TOPAppDocument *> *appDocs = [TOPDBQueryService top_documentsBySortedWithTag:tag];
        NSString *name = [NSString stringWithFormat:@"%@/",tag];
        [TOPDBService top_transactionWithBlock:^{
            for (TOPAppDocument *object in appDocs) {
                NSString *oldTags = object.tags;
                object.tags = [oldTags stringByReplacingOccurrencesOfString:name withString:@""];
            }
        }];
    }
}

#pragma mark -- 更新标签
+ (void)top_updateTag:(NSString *)tag withNewName:(NSString *)name {
    TOPDocTag *tagObj = [TOPDBQueryService top_docTagByName:tag];
    TOPDocTag *newObj = [TOPDBDataHandler top_buildRealmTagWithName:name];
    [TOPDBService top_deleteObjects:@[tagObj] saveObjects:@[newObj]];
}

@end
