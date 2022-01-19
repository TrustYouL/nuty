#import "TOPDBDataHandler.h"
#import "TOPDBService.h"
#import "TOPAPPFolder.h"
#import "TOPAppDocument.h"
#import "TOPImageFile.h"
#import "TOPDocTag.h"
@implementation TOPDBDataHandler

#pragma mark -- 注意：第一次升级到有数据库的版本才需要写入 检测数据库是否有数据，有的话不需要写入，否则需要写入
+(BOOL)top_hasDBData {
    NSInteger count = [TOPScanerShare top_theCountEnterApp];
    if (count == 1) {//新用户第一次进入没有数据 不需要走写入操作
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RealmDataKey"];
        return YES;
    }
    BOOL hasData = [[NSUserDefaults standardUserDefaults] boolForKey:@"RealmDataKey"];
    if (hasData) {
        return YES;
    }
    RLMResults<TOPAPPFolder *> *folders = [TOPAPPFolder allObjects];
    RLMResults<TOPAppDocument *> *documents = [TOPAppDocument allObjects];
    RLMResults<TOPDocTag *> *tags = [TOPDocTag allObjects];
    if (folders.count || tags.count || documents.count) {
        return YES;
    }
    return NO;
}

#pragma mark -- 写入数据
+ (void)top_loadingRealmDBData {
    [self top_createAppFoler];
    [self top_createDocTag];
}

#pragma mark -- 清空数据 需要重新写入
+ (void)top_emptyDBData {
    [TOPDBService top_clearRealmDB];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RealmDataKey"];
    return ;
}

//去重
+ (BOOL)dataArray:(NSMutableArray *)arr isContains:(id)obj {
    NSString *filePath = @"";
    if ([obj isKindOfClass:[NSString class]]) {
        filePath = obj;
    } else {
        TOPAppDocument *docObj = obj;
        filePath = docObj.filePath;
    }
    NSInteger eqCount = 0;//去重
    for (TOPAppDocument *tempDoc in arr) {
        if ([filePath compare:tempDoc.filePath] == NSOrderedSame) {
            eqCount ++;
        }
    }
    if (!eqCount) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -- 某个文件夹的数据同步 自检
+ (void)top_synchronizeDBDataWithFolder:(NSString *)folderId progress:(void (^)(CGFloat))progressBlock {
    NSMutableArray *invalidObjects = @[].mutableCopy;//本地没有文件，数据库还记录的数据
    NSMutableArray *missingObjects = @[].mutableCopy;//本地有文件，数据库没有记录的数据
    long gressValue = 0;
    long totalValue = [TOPDBQueryService top_totalFilesCountAtFolder:folderId] * 2;
    //同步文件夹数据
    RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_foldersAtFile:folderId];
    NSMutableArray *folderData = @[].mutableCopy;
    for (TOPAPPFolder *folderObj in folders) {//收集无效数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue*1.0/totalValue*1.0);
        }
        if ([folderObj.pathId containsString:@"null"]) {
            [invalidObjects addObject:folderObj];
            continue;
        }
        folderObj.filePath = [self top_folderPath:folderObj.pathId];
        if (![TOPWHCFileManager top_isExistsAtPath:folderObj.filePath] || [TOPDocumentHelper top_directoryHasJPG:folderObj.filePath]) {//无效路径的文件夹数据
            [invalidObjects addObject:folderObj];
            [FIRAnalytics logEventWithName:@"Folder_invalidFile" parameters:nil];
            if ([TOPDocumentHelper top_directoryHasJPG:folderObj.filePath]) {//需要移动文件保护用户的数据
                NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderObj.filePath error:nil];
                NSString *newFolderPath = [TOPDocumentHelper top_createDirectoryAtPath:folderObj.filePath];
                for (NSString *fileName in dirArray) {
                    if ([fileName containsString:@".DS_Store"] || [fileName containsString:TOP_TRTagsPathString] || [fileName containsString:TOP_TRTXTPathSuffixString] || [fileName containsString:TOP_TRDocPasswordPathString] || [TOPDocumentHelper top_isValidateJPG:fileName]) {
                        continue;
                    }
                    NSString *oldContentPath = [folderObj.filePath stringByAppendingPathComponent:fileName];
                    NSString *newContentPath = [newFolderPath stringByAppendingPathComponent:fileName];
                    [TOPWHCFileManager top_moveItemAtPath:oldContentPath toPath:newContentPath];
                }
            }
        }
        [folderData addObject:folderObj];
    }
    TOPAPPFolder *target = [TOPDBQueryService top_appFolderById:folderId];
    NSString *filePath = [self top_folderPath:target.pathId];
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * allFolderPaths = [TOPDocumentHelper top_getAllFoldersWithPath:filePath documentArray:documentArray];
    for (NSString *folderPath in allFolderPaths) {//收集缺失数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue);
        }
        NSArray *objs = [self top_hasRealmDBObj:folderData byFile:folderPath];
        if (!objs.count) {
            NSArray *fathers = [self top_hasRealmDBObj:folderData byFile:[TOPWHCFileManager top_directoryAtPath:folderPath]];//获取上层目录
            TOPAPPFolder *fatherFolder = fathers.count ? fathers.firstObject : nil;
            NSString *parentId = fatherFolder ? fatherFolder.pathId : @"000000";
            TOPAPPFolder *newFolder = [self top_buildRealmFolderWithParentId:parentId atPath:folderPath];
            [folderData addObject:newFolder];
            [missingObjects addObject:newFolder];
            [FIRAnalytics logEventWithName:@"Folder_missingData" parameters:nil];
        } else {
            for (int i = 0; i < objs.count; i ++) {
                if (!i) {
                    continue;
                }
                TOPAPPFolder *fld = objs[i];
                [invalidObjects addObject:fld];
            }
        }
    }
    //同步文档数据
    RLMResults<TOPAppDocument *> *documents = [TOPDBQueryService top_documentsAtFoler:folderId];
    NSMutableArray *docData = @[].mutableCopy;
    for (TOPAppDocument *docObj in documents) {//收集无效数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue*1.0/totalValue*1.0);
        }
        if ([docObj.pathId containsString:@"null"]) {
            [invalidObjects addObject:docObj];
            continue;
        }
        docObj.filePath = [self top_documentPath:docObj.pathId];
        if (![TOPWHCFileManager top_isExistsAtPath:docObj.filePath]) {//无效路径的文件夹数据
            [invalidObjects addObject:docObj];
            [invalidObjects addObjectsFromArray:[TOPDBService convertRLMArray:docObj.images]];
            [FIRAnalytics logEventWithName:@"Document_invalidFile" parameters:nil];
            continue;
        }
        BOOL isContains = [self dataArray:docData isContains:docObj];
        if (!isContains) {
            [docData addObject:docObj];
        } else {
            [invalidObjects addObject:docObj];
        }
    }
    
    NSMutableArray * documentArray1 = [NSMutableArray new];
    NSMutableArray * getArry1 = [TOPDocumentHelper top_getAllDocumentsWithPath:filePath documentArray:documentArray1];
    NSMutableArray * allDocumentPaths = @[].mutableCopy;
    [allDocumentPaths addObjectsFromArray:getArry1];
    for (NSString *folderPath in allDocumentPaths) {//收集缺失数据
        NSArray *objs = [self top_hasRealmDBObj:docData byFile:folderPath];
        if (!objs.count) {
            BOOL isContains = [self dataArray:docData isContains:folderPath];
            if (!isContains) {
                NSArray *fathers = [self top_hasRealmDBObj:folderData byFile:[TOPWHCFileManager top_directoryAtPath:folderPath]];//获取上层目录
                TOPAPPFolder *fatherFolder = fathers.count ? fathers.firstObject : nil;
                NSString *parentId = fatherFolder ? fatherFolder.pathId : @"000000";
                TOPAppDocument *newFolder = [self top_buildFullDocumetnWithParentId:parentId atPath:folderPath];
                [docData addObject:newFolder];
                [missingObjects addObject:newFolder];
                [FIRAnalytics logEventWithName:@"Document_missingData" parameters:nil];
            }
        } else {//同步图片数据 有效的文档数据
            for (int i = 0; i < objs.count; i ++) {
                if (!i) {
                    TOPAppDocument *doc = objs[0];
                    NSArray *picArr = [TOPDocumentHelper top_sortPicsAtPath:folderPath];
                    if (picArr) {
                        NSMutableArray *addImgArr = @[].mutableCopy;
                        for (TOPImageFile *imgObj in doc.images) {
                            gressValue ++;
                            if (progressBlock) {
                                progressBlock(gressValue*1.0/totalValue*1.0);
                            }
                            imgObj.filePath = [doc.filePath stringByAppendingPathComponent:imgObj.name];
                            if (![TOPWHCFileManager top_isExistsAtPath:imgObj.filePath] || ![doc.Id isEqualToString:imgObj.parentId]) {//收集无效图片数据
                                [invalidObjects addObject:imgObj];
                                [FIRAnalytics logEventWithName:@"Image_invalidFile" parameters:nil];
                            }
                        }
                        for (NSString *picPath in picArr) {
                            gressValue ++;
                            if (progressBlock) {
                                progressBlock(gressValue*1.0/totalValue*1.0);
                            }
                            RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:doc.Id withName:picPath];
                            if (!images.count) {//图片没有记录
                                [addImgArr addObject:picPath];
                                [FIRAnalytics logEventWithName:@"Image_missingData" parameters:nil];
                            } else {
                                for (int i = 0; i < images.count; i ++) {
                                    if (!i) {
                                        continue;
                                    }
                                    TOPImageFile *fld = images[i];
                                    [invalidObjects addObject:fld];
                                }
                            }
                        }
                        //有缺失图片需要写入
                        if (addImgArr.count) {
                            NSArray *imgFiles = [TOPDBDataHandler top_buildRealmImagesByFileNames:addImgArr withData:doc];
                            if (imgFiles.count && !doc.isInvalidated) {//修改前做判空
                                [TOPDBService top_transactionWithBlock:^{
                                    doc.utime = [NSDate date];
                                    [doc.images addObjects:imgFiles];
                                }];
                            }
                        }
                    } else {//无图片的文档需要删除
                        [TOPWHCFileManager top_removeItemAtPath:folderPath];
                        [invalidObjects addObject:doc];
                        [FIRAnalytics logEventWithName:@"Document_invalidFile" parameters:nil];
                    }
                    continue;
                }//重复数据 删除
                TOPAppDocument *invDoc = objs[i];
                [invalidObjects addObject:invDoc];
            }
        }
    }
    
    //同步标签数据
    RLMResults<TOPDocTag *> *tags = [TOPDBQueryService top_allTagsBySorted];
    NSMutableArray *tagsData = @[].mutableCopy;
    for (TOPDocTag *docObj in tags) {//收集无效数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue*1.0/totalValue*1.0);
        }
        if (![TOPWHCFileManager top_isExistsAtPath:docObj.filePath]) {//无效路径的文件夹数据
            [invalidObjects addObject:docObj];
            [FIRAnalytics logEventWithName:@"Tag_invalidFile" parameters:nil];
        }
        [tagsData addObject:docObj];
    }
    
    NSArray *tagArr = [TOPWHCFileManager top_listFilesInDirectoryAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString] deep:NO];
    for (NSString *tagName in tagArr) {
        TOPDocTag *docObj = [TOPDBQueryService top_docTagByName:tagName];
        if (!docObj) {//无记录
            TOPDocTag *addTag = [self top_buildRealmTagWithName:tagName];
            [missingObjects addObject:addTag];
            [FIRAnalytics logEventWithName:@"Tag_missingData" parameters:nil];
        }
    }
    //删除无效数据，写入缺失的数据
    [TOPDBService top_deleteObjects:invalidObjects saveObjects:missingObjects];
    if (gressValue < totalValue) {
        if (progressBlock) {
            progressBlock(1.0);
        }
    }
}

#pragma mark -- 数据同步 自检
+ (void)top_synchronizeRealmDBDataProgress:(void (^)(CGFloat))progressBlock {
    NSMutableArray *invalidObjects = @[].mutableCopy;//本地没有文件，数据库还记录的数据
    NSMutableArray *missingObjects = @[].mutableCopy;//本地有文件，数据库没有记录的数据
    long gressValue = 0;
    long totalValue = [TOPDBQueryService top_totalFilesCount] * 2;
    //同步文件夹数据
    RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_allFoldersBySorted];
    NSMutableArray *folderData = @[].mutableCopy;
    for (TOPAPPFolder *folderObj in folders) {//收集无效数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue*1.0/totalValue*1.0);
        }
        if ([folderObj.pathId containsString:@"null"]) {
            [invalidObjects addObject:folderObj];
            continue;
        }
        folderObj.filePath = [self top_folderPath:folderObj.pathId];
        if (![TOPWHCFileManager top_isExistsAtPath:folderObj.filePath] || [TOPDocumentHelper top_directoryHasJPG:folderObj.filePath]) {//无效路径的文件夹数据
            [invalidObjects addObject:folderObj];
            [FIRAnalytics logEventWithName:@"Folder_invalidFile" parameters:nil];
            if ([TOPDocumentHelper top_directoryHasJPG:folderObj.filePath]) {//需要移动文件保护用户的数据
                NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderObj.filePath error:nil];
                NSString *newFolderPath = [TOPDocumentHelper top_createDirectoryAtPath:folderObj.filePath];
                for (NSString *fileName in dirArray) {
                    if ([fileName containsString:@".DS_Store"] || [fileName containsString:TOP_TRTagsPathString] || [fileName containsString:TOP_TRTXTPathSuffixString] || [fileName containsString:TOP_TRDocPasswordPathString] || [TOPDocumentHelper top_isValidateJPG:fileName]) {
                        continue;
                    }
                    NSString *oldContentPath = [folderObj.filePath stringByAppendingPathComponent:fileName];
                    NSString *newContentPath = [newFolderPath stringByAppendingPathComponent:fileName];
                    [TOPWHCFileManager top_moveItemAtPath:oldContentPath toPath:newContentPath];
                }
            }
        }
        [folderData addObject:folderObj];
    }
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * allFolderPaths = [TOPDocumentHelper top_getAllFoldersWithPath:[TOPDocumentHelper top_getFoldersPathString] documentArray:documentArray];
    for (NSString *folderPath in allFolderPaths) {//收集缺失数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue);
        }
        NSArray *objs = [self top_hasRealmDBObj:folderData byFile:folderPath];
        if (!objs.count) {
            NSArray *fathers = [self top_hasRealmDBObj:folderData byFile:[TOPWHCFileManager top_directoryAtPath:folderPath]];//获取上层目录
            TOPAPPFolder *fatherFolder = fathers.count ? fathers.firstObject : nil;
            NSString *parentId = fatherFolder ? fatherFolder.pathId : @"000000";
            TOPAPPFolder *newFolder = [self top_buildRealmFolderWithParentId:parentId atPath:folderPath];
            [folderData addObject:newFolder];
            [missingObjects addObject:newFolder];
            [FIRAnalytics logEventWithName:@"Folder_missingData" parameters:nil];
        } else {
            for (int i = 0; i < objs.count; i ++) {
                if (!i) {
                    continue;
                }
                TOPAPPFolder *fld = objs[i];
                [invalidObjects addObject:fld];
            }
        }
    }
    //同步文档数据
    RLMResults<TOPAppDocument *> *documents = [TOPDBQueryService top_allDocumentsBySorted];
    NSMutableArray *docData = @[].mutableCopy;
    for (TOPAppDocument *docObj in documents) {//收集无效数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue*1.0/totalValue*1.0);
        }
        if ([docObj.pathId containsString:@"null"]) {
            [invalidObjects addObject:docObj];
            continue;
        }
        docObj.filePath = [self top_documentPath:docObj.pathId];
        if (![TOPWHCFileManager top_isExistsAtPath:docObj.filePath]) {//无效路径的文件夹数据
            [invalidObjects addObject:docObj];
            [invalidObjects addObjectsFromArray:[TOPDBService convertRLMArray:docObj.images]];
            [FIRAnalytics logEventWithName:@"Document_invalidFile" parameters:nil];
            continue;
        }
        BOOL isContains = [self dataArray:docData isContains:docObj];
        if (!isContains) {
            [docData addObject:docObj];
        } else {
            [invalidObjects addObject:docObj];
        }
    }
    
    NSMutableArray * documentArray1 = [NSMutableArray new];
    NSMutableArray * getArry1 = [TOPDocumentHelper top_getAllDocumentsWithPath:[TOPDocumentHelper top_getFoldersPathString] documentArray:documentArray1];
    NSMutableArray * documentArray2 = [NSMutableArray new];
    NSMutableArray * getArry2 = [TOPDocumentHelper top_getAllDocumentsWithPath:[TOPDocumentHelper top_getDocumentsPathString] documentArray:documentArray2];
    NSMutableArray * allDocumentPaths = @[].mutableCopy;
    [allDocumentPaths addObjectsFromArray:getArry1];
    [allDocumentPaths addObjectsFromArray:getArry2];
    for (NSString *folderPath in allDocumentPaths) {//收集缺失数据
        NSArray *objs = [self top_hasRealmDBObj:docData byFile:folderPath];
        if (!objs.count) {
            BOOL isContains = [self dataArray:docData isContains:folderPath];
            if (!isContains) {
                NSArray *fathers = [self top_hasRealmDBObj:folderData byFile:[TOPWHCFileManager top_directoryAtPath:folderPath]];//获取上层目录
                TOPAPPFolder *fatherFolder = fathers.count ? fathers.firstObject : nil;
                NSString *parentId = fatherFolder ? fatherFolder.pathId : @"000000";
                TOPAppDocument *newFolder = [self top_buildFullDocumetnWithParentId:parentId atPath:folderPath];
                [docData addObject:newFolder];
                [missingObjects addObject:newFolder];
                [FIRAnalytics logEventWithName:@"Document_missingData" parameters:nil];
            }
        } else {//同步图片数据 有效的文档数据
            for (int i = 0; i < objs.count; i ++) {
                if (!i) {
                    TOPAppDocument *doc = objs[0];
                    NSArray *picArr = [TOPDocumentHelper top_sortPicsAtPath:folderPath];
                    if (picArr) {
                        NSMutableArray *addImgArr = @[].mutableCopy;
                        for (TOPImageFile *imgObj in doc.images) {
                            gressValue ++;
                            if (progressBlock) {
                                progressBlock(gressValue*1.0/totalValue*1.0);
                            }
                            imgObj.filePath = [doc.filePath stringByAppendingPathComponent:imgObj.name];
                            if (![TOPWHCFileManager top_isExistsAtPath:imgObj.filePath] || ![doc.Id isEqualToString:imgObj.parentId]) {//收集无效图片数据
                                [invalidObjects addObject:imgObj];
                                [FIRAnalytics logEventWithName:@"Image_invalidFile" parameters:nil];
                            }
                        }
                        for (NSString *picPath in picArr) {
                            gressValue ++;
                            if (progressBlock) {
                                progressBlock(gressValue*1.0/totalValue*1.0);
                            }
                            RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:doc.Id withName:picPath];
                            if (!images.count) {//图片没有记录
                                [addImgArr addObject:picPath];
                                [FIRAnalytics logEventWithName:@"Image_missingData" parameters:nil];
                            } else {
                                for (int i = 0; i < images.count; i ++) {
                                    if (!i) {
                                        continue;
                                    }
                                    TOPImageFile *fld = images[i];
                                    [invalidObjects addObject:fld];
                                }
                            }
                        }
                        //有缺失图片需要写入
                        if (addImgArr.count) {
                            NSArray *imgFiles = [TOPDBDataHandler top_buildRealmImagesByFileNames:addImgArr withData:doc];
                            if (imgFiles.count && !doc.isInvalidated) {//修改前做判空
                                [TOPDBService top_transactionWithBlock:^{
                                    doc.utime = [NSDate date];
                                    [doc.images addObjects:imgFiles];
                                }];
                            }
                        }
                    } else {//无图片的文档需要删除
                        [TOPWHCFileManager top_removeItemAtPath:folderPath];
                        [invalidObjects addObject:doc];
                        [FIRAnalytics logEventWithName:@"Document_invalidFile" parameters:nil];
                    }
                    continue;
                }//重复数据 删除
                TOPAppDocument *invDoc = objs[i];
                [invalidObjects addObject:invDoc];
            }
        }
    }
    
    //同步标签数据
    RLMResults<TOPDocTag *> *tags = [TOPDBQueryService top_allTagsBySorted];
    NSMutableArray *tagsData = @[].mutableCopy;
    for (TOPDocTag *docObj in tags) {//收集无效数据
        gressValue ++;
        if (progressBlock) {
            progressBlock(gressValue*1.0/totalValue*1.0);
        }
        if (![TOPWHCFileManager top_isExistsAtPath:docObj.filePath]) {//无效路径的文件夹数据
            [invalidObjects addObject:docObj];
            [FIRAnalytics logEventWithName:@"Tag_invalidFile" parameters:nil];
        }
        [tagsData addObject:docObj];
    }
    
    NSArray *tagArr = [TOPWHCFileManager top_listFilesInDirectoryAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString] deep:NO];
    for (NSString *tagName in tagArr) {
        TOPDocTag *docObj = [TOPDBQueryService top_docTagByName:tagName];
        if (!docObj) {//无记录
            TOPDocTag *addTag = [self top_buildRealmTagWithName:tagName];
            [missingObjects addObject:addTag];
            [FIRAnalytics logEventWithName:@"Tag_missingData" parameters:nil];
        }
    }
    //删除无效数据，写入缺失的数据
    [TOPDBService top_deleteObjects:invalidObjects saveObjects:missingObjects];
    if (gressValue < totalValue) {
        if (progressBlock) {
            progressBlock(1.0);
        }
    }
}

#pragma mark -- 校验数据库是否记录本地文件数据 fileData 表数据 filePath：本地文件路径
+ (NSArray *)top_hasRealmDBObj:(NSArray *)fileData byFile:(NSString *)filePath {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"filePath = %@",filePath];
    NSArray *fileObjs = [fileData filteredArrayUsingPredicate:predicate];
    return fileObjs;//fileObjs.count == 0 数据库没有记录，需要写入
}

#pragma mark -- 恢复备份数据
+ (void)top_restoreFileData:(NSArray *)data {
    NSMutableArray *missingObjects = @[].mutableCopy;//本地有文件，数据库没有记录的数据
    //恢复文件夹数据
    RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_allFoldersBySorted];
    NSMutableArray *folderData = @[].mutableCopy;
    for (TOPAPPFolder *folderObj in folders) {
        folderObj.filePath = [self top_folderPath:folderObj.pathId];
        [folderData addObject:folderObj];
    }
    NSMutableArray *allFolderPaths = data[0];
    for (NSString *folderPath in allFolderPaths) {//收集缺失数据
        NSArray *fathers = [self top_hasRealmDBObj:folderData byFile:[TOPWHCFileManager top_directoryAtPath:folderPath]];//获取上层目录
        TOPAPPFolder *fatherFolder = fathers.count ? fathers.firstObject : nil;
        NSString *parentId = fatherFolder ? fatherFolder.pathId : @"000000";
        TOPAPPFolder *newFolder = [self top_buildRealmFolderWithParentId:parentId atPath:folderPath];
        [folderData addObject:newFolder];
        [missingObjects addObject:newFolder];
    }
    //文件夹内的文件数据
    NSMutableArray *temp = [missingObjects mutableCopy];
    for (TOPAPPFolder *folderModel in temp) {
        NSMutableArray *docArr = @[].mutableCopy;
        NSMutableArray *fdDocs = [self getAllDocumentsWithFoler:folderModel documentArray:docArr];
        [folderData addObjectsFromArray:fdDocs];
        [missingObjects addObjectsFromArray:fdDocs];
    }
    //恢复文档数据
    NSMutableArray *docPaths = data[1];
    for (NSString *folderPath in docPaths) {
        NSArray *docs = [self top_hasRealmDBObj:folderData byFile:folderPath];
        if (!docs.count) {
            NSArray *fathers = [self top_hasRealmDBObj:folderData byFile:[TOPWHCFileManager top_directoryAtPath:folderPath]];//获取上层目录
            TOPAPPFolder *fatherFolder = fathers.count ? fathers.firstObject : nil;
            NSString *parentId = fatherFolder ? fatherFolder.pathId : @"000000";
            TOPAppDocument *newFolder = [self top_buildFullDocumetnWithParentId:parentId atPath:folderPath];
            [missingObjects addObject:newFolder];
        }
    }
    
    //恢复标签数据
    NSMutableArray *tagData = data[2];
    for (NSString *tagName in tagData) {
        TOPDocTag *addTag = [self top_buildRealmTagWithName:tagName];
        [missingObjects addObject:addTag];
    }
    [TOPDBService top_saveAllObjects:missingObjects];
}

#pragma mark -- 从数据库获取 标签统计数据
+ (NSMutableArray *)top_buildTagListWithDB {
    NSString *path11 = [TOPDocumentHelper top_getFoldersPathString];
    NSLog(@"folerpath---%@",path11);
    RLMResults<TOPAppDocument *> *documents = [TOPAppDocument allObjects];
    TOPTagsListModel * listModel = [[TOPTagsListModel alloc] init];
    listModel.tagName = TOP_TRTagsAllDocesKey;
    listModel.tagNum = [NSString stringWithFormat:@"%ld",documents.count];
    listModel.docArray = [self top_buildHomeDataWithDB];
    
    RLMResults<TOPAppDocument *> *unGroupedDocuments = [TOPDBQueryService top_unGroupedDocumentsBySorted];
    TOPTagsListModel * unGroupedListModel = [[TOPTagsListModel alloc] init];
    unGroupedListModel.tagName = TOP_TRTagsUngroupedKey;
    unGroupedListModel.tagNum = [NSString stringWithFormat:@"%ld",unGroupedDocuments.count];
    unGroupedListModel.docArray = [self top_buildTagDocModleDataWithDB:unGroupedDocuments];
    
    RLMResults<TOPAppDocument *> *collectionDocuments = [TOPDBQueryService top_documentsByCollecting];
    TOPTagsListModel * collectionModel = [[TOPTagsListModel alloc] init];
    collectionModel.tagName = NSLocalizedString(@"topscan_childimportant", @"");
    collectionModel.tagNum = [NSString stringWithFormat:@"%ld",collectionDocuments.count];
    collectionModel.docArray = [self top_buildTagDocModleDataWithDB:collectionDocuments];
    
    NSMutableArray *tagManage = @[].mutableCopy;
    [tagManage addObject:listModel];
    if (collectionDocuments.count) {
        [tagManage addObject:collectionModel];
    }
    [tagManage addObject:unGroupedListModel];
    RLMResults<TOPDocTag *> *tags = [TOPDBQueryService top_allTagsBySorted];
    for (TOPDocTag *tagObj in tags) {
        RLMResults<TOPAppDocument *> *tagDocuments = [TOPDBQueryService top_documentsBySortedWithTag:tagObj.name];
        TOPTagsListModel * tagListModel = [[TOPTagsListModel alloc] init];
        tagListModel.tagName = tagObj.name;
        tagListModel.tagPath = tagObj.filePath;
        tagListModel.tagNum = [NSString stringWithFormat:@"%ld",tagDocuments.count];
        tagListModel.docArray = [self top_buildTagDocModleDataWithDB:tagDocuments];
        [tagManage addObject:tagListModel];
    }
    return tagManage;
}

#pragma mark -- 带标签的文档数据模型
+ (NSMutableArray *)top_buildTagDocModleDataWithDB:(RLMResults<TOPAppDocument *> *)docModels {
    NSMutableArray *tagDocs = @[].mutableCopy;
    for (TOPAppDocument *docObj in docModels) {
        docObj.filePath = [self top_documentPath:docObj.pathId];
        DocumentModel *model = [self top_buildDocumentModelWithData:docObj];
        if (model) {
            [tagDocs addObject:model];
        }
    }
    return tagDocs;
}

#pragma mark -- 从数据库获取 最后一个浏览文档数据
+ (DocumentModel *)top_buildLastDocDataWithDB {
    RLMResults<TOPAppDocument *> * documents = [TOPDBQueryService top_allDocumentsByRecent];
    if (documents.count) {
        TOPAppDocument *docObj = documents.firstObject;
        docObj.filePath = [self top_documentPath:docObj.pathId];
        DocumentModel *model = [self top_buildDocumentModelWithData:docObj];
        return model;
    }
    return nil;
}

#pragma mark -- 从数据库获取 最近浏览文档数据
+ (NSMutableArray *)top_buildRecentDocDataWithDB {
    const NSUInteger limit = 50;//只显示50条数据
    RLMResults<TOPAppDocument *> * documents = [TOPDBQueryService top_allDocumentsByRecent];
    NSMutableArray *tagDocs = @[].mutableCopy;
    for (TOPAppDocument *docObj in documents) {
        if (tagDocs.count >= limit) {
            break;
        }
        docObj.filePath = [self top_documentPath:docObj.pathId];
        DocumentModel *model = [self top_buildDocumentModelWithData:docObj];
        if (model) {
            [tagDocs addObject:model];
        }
    }
    return tagDocs;
}

#pragma mark -- 从数据库获取首页数据
+ (NSMutableArray *)top_buildHomeDataWithDB {
    NSMutableArray *dataArray = [self top_buildFolerDataWithParentId:@"000000"];
    return dataArray;
}

#pragma mark -- 从数据库获取Folder次级界面数据
+ (NSMutableArray *)top_buildFolderSecondaryDataWithDB:(TOPAPPFolder *)fldModel {
    NSMutableArray *dataArr = [self top_buildFolerDataWithParentId:fldModel.Id];
    return dataArr;
}

#pragma mark -- 从数据库获取子目录文件夹数据-根据父id
+ (NSMutableArray *)top_buildFolerDataWithParentId:(NSString *)parentId {
    NSMutableArray *folderArr = @[].mutableCopy;
    NSMutableArray *docArr = @[].mutableCopy;

    //folder 文件夹
    RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_foldersByParentId:parentId];
    for (TOPAPPFolder *folderObj in folders) {//拼接的路径id，拆分后挨个查询，拼接成完整路径
        folderObj.filePath = [self top_folderPath:folderObj.pathId];
        DocumentModel *dtModel = [self top_buildFolderModelWithData:folderObj];
        if (dtModel) {
            [folderArr addObject:dtModel];
        }
    }

    //document 文档
    RLMResults<TOPAppDocument *> *documents = [TOPDBQueryService top_documentsByParentId:parentId];
    for (TOPAppDocument *docObj in documents) {//拼接的路径id，拆分后挨个查询，拼接成完整路径
        docObj.filePath = [self top_documentPath:docObj.pathId];
        DocumentModel *dtModel = [self top_buildDocumentModelWithData:docObj];
        if (dtModel) {
            [docArr addObject:dtModel];
        }
    }

    NSMutableArray *dataArray = @[].mutableCopy;
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 1) {//文件夹排前文档排后
        [dataArray addObjectsFromArray:folderArr];
        [dataArray addObjectsFromArray:docArr];
    }else{
        [dataArray addObjectsFromArray:docArr];
        [dataArray addObjectsFromArray:folderArr];
    }
    
    return dataArray;
}

#pragma mark -- 从数据库获取文档详情数据
+ (NSMutableArray *)top_buildDocumentDataWithDB:(TOPAppDocument *)docModel {
    NSMutableArray *dataArr = @[].mutableCopy;
    NSArray *images = [TOPDBQueryService top_sortImageFilesByParentId:docModel.Id];
    for (int i = 0; i < images.count; i ++) {
        TOPImageFile *imgObj = images[i];
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
    //根据名字再进行一次排序 这里是满足底部的sorty by功能
    NSMutableArray *sortDocs = [[TOPDataModelHandler top_imageSortWithData:dataArr] mutableCopy];
    return sortDocs;
}

#pragma mark -- 从数据库获取所有标签数据
+ (NSMutableArray *)top_buildAllTagsDataWithDB {
    NSMutableArray *dataArr = @[].mutableCopy;
    RLMResults<TOPDocTag *> *tags = [TOPDBQueryService top_allTagsBySorted];
    for (TOPDocTag *tagObj in tags) {
        TOPTagsModel * tagModel = [TOPDataModelHandler top_buildDocumentBottomTOPTagsModelWithPath:tagObj.filePath];
        [dataArr addObject:tagModel];
    }
    return dataArr;
}

#pragma mark -- 排序规则
+ (NSDictionary *)sortRule {
    NSInteger type = [TOPScanerShare top_sortType];
    NSString *sortKey = @"ctime";
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

#pragma mark -- 文件夹 根据pathId获取完整路径
+ (NSString *)top_folderPath:(NSString *)pathId {
    NSArray *pathIds = [pathId componentsSeparatedByString:@"/"];
    NSString *fldPath = [TOPDocumentHelper top_getFoldersPathString];
    for (NSString *pathId in pathIds) {
        if ([pathId isEqualToString:@"000000"]) {//000000代表根目录固定不变
            continue;
        }
        TOPAPPFolder *folderModel = [TOPDBQueryService top_appFolderById:pathId];
        fldPath = [fldPath stringByAppendingPathComponent:folderModel.name];
    }
    return fldPath;
}

#pragma mark -- 文档 根据pathId获取完整路径 ***特别注意在文件夹下的文档路径拼接 需要先拼接文件夹路径最后拼接文档名称
+ (NSString *)top_documentPath:(NSString *)pathId {
    NSString *documentPath = [TOPDocumentHelper top_getDocumentsPathString];
    NSArray *pathIds = [pathId componentsSeparatedByString:@"/"];
    if (pathIds.count < 2) {//防止闪退保护，正常情况不会出现
        return documentPath;
    }
    TOPAppDocument *docModel = [TOPDBQueryService top_appDocumentById:pathIds.lastObject];
    if (pathIds.count == 2) {//首页文档
        documentPath = [documentPath stringByAppendingPathComponent:docModel.name];
    } else {//文件夹下的文档 先拼接上级目录的路径，再拼接当前文档的名称
        NSString *fatherPathId = [TOPWHCFileManager top_directoryAtPath:pathId];
        NSString *fatherPath = [self top_folderPath:fatherPathId];
        documentPath = [fatherPath stringByAppendingPathComponent:docModel.name];
    }
    return documentPath;
}


#pragma mark -- 首页文件夹 数据库数据写入
+ (void)top_createAppFoler {
    RLMResults<TOPAPPFolder *> *folders = [TOPAPPFolder allObjects];
    if (folders.count) {
        return;
    }
    //Folders路径下的文件夹
    NSArray *blFdArray = [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getFoldersPathString]];
    
    NSMutableArray *temp = @[].mutableCopy;
    NSString *path = [TOPDocumentHelper top_getFoldersPathString];
    for (NSString *fdStr in blFdArray) {
        NSString *fldPath = [path stringByAppendingPathComponent:fdStr];
        NSString *parentId = @"000000"; //首页foler的父id 固定‘000000’
        TOPAPPFolder *folderModel = [self top_buildRealmFolderWithParentId:parentId atPath:fldPath];
        [temp addObject:folderModel];
    }
    [TOPDBService top_saveAllObjects:temp];
    [self createTOPAppDocument];
    [self createNextFoler:temp];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RealmDataKey"];
}

#pragma mark -- 次级文件夹 数据库数据写入
+ (void)createNextFoler:(NSArray *)folders {
    NSMutableArray *temp = @[].mutableCopy;
    for (TOPAPPFolder *folderModel in folders) {
        NSMutableArray *docArr = @[].mutableCopy;
        NSMutableArray *fdDocs = [self getAllDocumentsWithFoler:folderModel documentArray:docArr];
        [temp addObjectsFromArray:fdDocs];
    }
    [TOPDBService top_saveAllObjects:temp];
}

#pragma mark -- 获取沙盒Documents目录下的所有文档(Document-存放图片的文件夹) 递归遍历
+ (NSMutableArray *)getAllDocumentsWithFoler:(TOPAPPFolder *)appFoler documentArray:(NSMutableArray*)documentArray {
    TOPAPPFolder *folerObj = appFoler;
    NSString *path = folerObj.filePath;
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {//目录(文件夹)
            NSArray * dirArray = [TOPDocumentHelper top_sortContentOfDirectoryAtPath:path];
            if (!dirArray.count) {//没有子目录 则是Folder
                if ([[folerObj.pathId componentsSeparatedByString:@"/"] count] > 2) {
                    [documentArray addObject:folerObj];
                }
            } else {
                BOOL hasDoc = NO;
                for (NSString *fileName in dirArray) {
                    if ([fileName containsString:@".DS_Store"]) {
                        continue;
                    }
                    if ([TOPDocumentHelper top_isValidateJPG:fileName]) {//判断是否为jpg 有图片 则是Doc
                        //构造文档模型
                        NSString *parentId = [folerObj.pathId stringByDeletingLastPathComponent];
                        TOPAppDocument *documentModel = [self top_buildFullDocumetnWithParentId:parentId atPath:path];
                        [documentArray addObject:documentModel];
                        break;
                    } else {// 不是图片 则是Folder
                        //递归遍历该文件下所有的子目录
                        if ([[folerObj.pathId componentsSeparatedByString:@"/"] count] > 2) {
                            if (!hasDoc) {//确保遍历子目录过程中只计算一次
                                [documentArray addObject:folerObj];
                                hasDoc = YES;
                            }
                        }
                        NSString * documentPath = [path stringByAppendingPathComponent:fileName];
                        TOPAPPFolder *folderModel = [self top_buildRealmFolderWithParentId:folerObj.pathId atPath:documentPath];
                        [self getAllDocumentsWithFoler:folderModel documentArray:documentArray];
                    }
                }
            }
        } else {//文件
            return documentArray;
        }
    }
    return documentArray;
}

#pragma mark -- 首页文档 数据库数据写入
+ (void)createTOPAppDocument {
    RLMResults<TOPAppDocument *> *documents = [TOPAppDocument allObjects];
    if (documents.count) {
        return;
    }
    //获取Documents/Documents里面的文档
    NSArray *blDtArray = [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getDocumentsPathString]];
    
    NSMutableArray * tempArray = @[].mutableCopy;
    NSString *path = [TOPDocumentHelper top_getDocumentsPathString];
    for (NSString *fdStr in blDtArray) {
        NSString *docPath = [path stringByAppendingPathComponent:fdStr];
        NSString *parentId = @"000000"; //首页document的父id 固定‘000000’
        TOPAppDocument *documentModel = [self top_buildFullDocumetnWithParentId:parentId atPath:docPath];
        [tempArray addObject:documentModel];
    }
    [TOPDBService top_saveAllObjects:tempArray];
}

+ (TOPAppDocument *)top_buildFullDocumetnWithParentId:(NSString *)parentId atPath:(NSString *)docPath {
    TOPAppDocument *documentModel = [self top_buildRealmDocumentWithParentId:parentId atPath:docPath];
    //图片
    NSMutableArray *imgArr = @[].mutableCopy;
    imgArr = [self top_buildRealmImagesWithData:documentModel];
    if (imgArr.count) {
        [documentModel.images addObjects:imgArr];
    }
    //标签
    documentModel.tags = [self tagsAtDocument:documentModel.filePath];
    return documentModel;
}

#pragma mark -- 获取文档的标签
+ (NSString *)tagsAtDocument:(NSString *)filePath {
    NSString *tagStr = @"";
    NSString * tempTagsPath = [TOPDocumentHelper top_getTagsPathString:filePath];
    if (tempTagsPath.length>0) {
        //获取Tags文件夹下的标签文件夹的名称
        NSArray *tagsArray = [TOPDocumentHelper top_getCurrentFileAndPath:tempTagsPath];
        //判断Tags文件夹下有没有数据 没有就删除掉
        if (!tagsArray.count) {
            [TOPWHCFileManager top_removeItemAtPath:tempTagsPath];
        } else {
            for (NSString *dtStr in tagsArray) {
                //拼接tags文件夹下的标签文件夹名称
                tagStr = [tagStr stringByAppendingFormat:@"%@/",dtStr];
            }
        }
    }
    return tagStr;
}

#pragma mark -- 统计标签 数据库数据写入
+ (void)top_createDocTag {
    RLMResults<TOPDocTag *> *tags = [TOPDocTag allObjects];
    if (tags.count) {
        return;
    }
    
    //获取根目录下Tags文件夹的路径
    NSString * homeTagsPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    //获取homeTagsPath下的文件夹名称
    NSArray * homeTagsPathArray = [TOPDocumentHelper top_getCurrentFileAndPath:homeTagsPath];
    NSMutableArray *temp = @[].mutableCopy;
    for (NSString *fdStr in homeTagsPathArray) {
        TOPDocTag *docTag = [self top_buildRealmTagWithName:fdStr];
        [temp addObject:docTag];
    }
    [TOPDBService top_saveAllObjects:temp];
    
}

#pragma mark -- 构造数据库Folder模型 parentId:上级目录的pathId
+ (TOPAPPFolder *)top_buildRealmFolderWithParentId:(NSString *)parentId atPath:(NSString *)docPath {
    NSString *fdStr = [TOPWHCFileManager top_fileNameAtPath:docPath suffix:YES];
    TOPAPPFolder *folderModel = [[TOPAPPFolder alloc] init];
    folderModel.Id = [[NSUUID UUID] UUIDString];
    folderModel.parentId = [parentId isEqualToString:@"000000"] ? parentId : [[parentId componentsSeparatedByString:@"/"] lastObject];
    folderModel.name = fdStr;
    folderModel.pathId = [NSString stringWithFormat:@"%@/%@",parentId, folderModel.Id];
    folderModel.ctime = [self top_createTimeOfFile:docPath];
    folderModel.utime = [self top_updateTimeOfFile:docPath];
    folderModel.filePath = docPath;
    folderModel.isDelete = NO;
    return folderModel;
}

#pragma mark -- 构造数据库Doc模型 parentId：上级目录的pathId
+ (TOPAppDocument *)top_buildRealmDocumentWithParentId:(NSString *)parentId atPath:(NSString *)docPath {
    NSString *fdStr = [TOPWHCFileManager top_fileNameAtPath:docPath suffix:YES];
    TOPAppDocument *documentModel = [[TOPAppDocument alloc] init];
    documentModel.Id = [[NSUUID UUID] UUIDString];
    documentModel.parentId = [parentId isEqualToString:@"000000"] ? parentId : [[parentId componentsSeparatedByString:@"/"] lastObject];
    documentModel.name = fdStr;
    documentModel.pathId = [NSString stringWithFormat:@"%@/%@",parentId, documentModel.Id];
    documentModel.filePath = docPath;
    documentModel.ctime = [self top_createTimeOfFile:docPath];
    documentModel.utime = [self top_updateTimeOfFile:docPath];
    documentModel.rtime = [self top_updateTimeOfFile:docPath];
    documentModel.isDelete = NO;
    documentModel.docNoticeLock = NO;
    return documentModel;
}

#pragma mark -- 构造数据库Image模型
+ (NSMutableArray *)top_buildRealmImagesWithData:(TOPAppDocument *)appDoc {
    NSMutableArray * sortDtArray = @[].mutableCopy;
    NSString *docPath = appDoc.filePath;
    NSArray *imageArr = [TOPDocumentHelper top_sortPicsAtPath:docPath];
    for (NSString *pic in imageArr) {
        NSString *imgPath = [docPath stringByAppendingPathComponent:pic];
        TOPImageFile *imgModel = [[TOPImageFile alloc] init];
        imgModel.Id = [[NSUUID UUID] UUIDString];
        imgModel.fileName = pic;
        imgModel.parentId = appDoc.Id;
        imgModel.pathId = [NSString stringWithFormat:@"%@/%@",appDoc.pathId, imgModel.Id];
        imgModel.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:imgPath] longValue];
        imgModel.fileShowName = pic;
        imgModel.ctime = [self top_createTimeOfFile:imgPath];
        imgModel.utime = [self top_updateTimeOfFile:imgPath];
        imgModel.isDelete = NO;
        imgModel.isUpload = NO;
        imgModel.isUploadSuccess = NO;
        [sortDtArray addObject:imgModel];
    }

    return sortDtArray;
}

#pragma mark -- 根据图片名称构造数据库Image模型
+ (NSMutableArray *)top_buildRealmImagesByFileNames:(NSArray *)fileNames withData:(TOPAppDocument *)appDoc {
    NSMutableArray * sortDtArray = @[].mutableCopy;
    NSString *docPath = appDoc.filePath;
    for (NSString *pic in fileNames) {
        if (![TOPDocumentHelper top_isCoverJPG:pic]) {//校验图片名称是否合规
            continue;
        }
        NSString *imgPath = [docPath stringByAppendingPathComponent:pic];
        TOPImageFile *imgModel = [[TOPImageFile alloc] init];
        imgModel.Id = [[NSUUID UUID] UUIDString];
        imgModel.fileName = pic;
        imgModel.parentId = appDoc.Id;
        imgModel.pathId = [NSString stringWithFormat:@"%@/%@",appDoc.pathId, imgModel.Id];
        imgModel.fileLength = [[TOPWHCFileManager top_sizeOfFileAtPath:imgPath] longValue];
        imgModel.fileShowName = pic;
        imgModel.ctime = [self top_createTimeOfFile:imgPath];
        imgModel.utime = [self top_updateTimeOfFile:imgPath];
        imgModel.isDelete = NO;
        imgModel.isUpload = NO;
        imgModel.isUploadSuccess = NO;
        [sortDtArray addObject:imgModel];
    }
    return sortDtArray;
}

#pragma mark -- 构造数据库Tag模型
+ (TOPDocTag *)top_buildRealmTagWithName:(NSString *)tagName {
    NSString * homeTagsPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    TOPDocTag *docTag = [[TOPDocTag alloc] init];
    docTag.Id = [[NSUUID UUID] UUIDString];
    docTag.name = tagName;
    NSString *docTagFilePath = [homeTagsPath stringByAppendingPathComponent:tagName];
    docTag.ctime = [self top_createTimeOfFile:docTagFilePath];
    docTag.utime = [self top_updateTimeOfFile:docTagFilePath];
    return docTag;
}
+ (NSMutableArray *)top_buildRealmTagsWithData:(TOPAppDocument *)appDoc {
    NSMutableArray * sortDtArray = @[].mutableCopy;
    NSString * tempTagsPath = [TOPDocumentHelper top_getTagsPathString:appDoc.filePath];
    if (tempTagsPath.length>0) {
        //获取Tags文件夹下的标签文件夹的名称
        NSArray *tagsArray = [TOPDocumentHelper top_getCurrentFileAndPath:tempTagsPath];
        //判断Tags文件夹下有没有数据 没有就删除掉
        if (!tagsArray.count) {
            [TOPWHCFileManager top_removeItemAtPath:tempTagsPath];
            return nil;
        }
        for (NSString *dtStr in tagsArray) {
            //拼接tags文件夹下的标签文件夹的路径
            TOPDocTag *docTag = [[TOPDocTag alloc] init];
            docTag.Id = [[NSUUID UUID] UUIDString];
            docTag.name = dtStr;
            NSString *docTagFilePath = [tempTagsPath stringByAppendingPathComponent:dtStr];
            docTag.ctime = [self top_createTimeOfFile:docTagFilePath];
            docTag.utime = [self top_updateTimeOfFile:docTagFilePath];
            [sortDtArray addObject:docTag];
        }
    }
    return sortDtArray;
}

#pragma mark -- 收集所有的文件数据 -- 传输数据
+ (NSMutableDictionary *)top_fileDataAll {
    RLMResults<TOPAPPFolder *> *folders = [TOPAPPFolder allObjects];
    RLMResults<TOPAppDocument *> *documents = [TOPAppDocument allObjects];
    NSMutableDictionary *dic = @{}.mutableCopy;
    for (TOPAPPFolder *folder in folders) {
        folder.filePath = [self top_folderPath:folder.pathId];
        [dic setValue:folder.name forKey:folder.filePath];
    }
    for (TOPAppDocument *doc in documents) {
        doc.filePath = [self top_documentPath:doc.pathId];
        [dic setValue:doc.name forKey:doc.filePath];
        RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:doc.Id];
        for (TOPImageFile *img in images) {
            @autoreleasepool {
                img.filePath = [doc.filePath stringByAppendingPathComponent:img.fileName];
                NSData *imgData = [NSData dataWithContentsOfFile:img.filePath];
                [dic setValue:imgData forKey:img.filePath];
            }
        }
    }
    return dic;
}

#pragma mark -- 首页 新增Document模型
+ (DocumentModel *)top_addNewDocModel:(NSString *)endPath {
    TOPAppDocument *doc = [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:@"000000"];
    DocumentModel *model = [self top_buildDocumentModelWithData:doc];
    return model;
}

#pragma mark -- 构造文件夹Folder模型
+ (DocumentModel *)top_buildFolderModelWithData:(TOPAPPFolder *)appFld {
    if (![TOPWHCFileManager top_isExistsAtPath:appFld.filePath] || [TOPDocumentHelper top_directoryHasJPG:appFld.filePath]) {
//        [TOPDBService removeObject:appFld]; 放在自检中完成，降低了操作无效数据的风险
        return nil;
    }
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    dtModel.name = appFld.name;
    dtModel.path = appFld.filePath;
    dtModel.docId = appFld.Id;
    dtModel.createDate = [TOPAppTools timeStringFromDate:appFld.utime];
    dtModel.type = @"0";
    dtModel.isFile = NO;
    RLMResults<TOPAppDocument *> *docArr = [TOPDBQueryService top_documentsAtFoler:appFld.Id];
    dtModel.number = [NSString stringWithFormat:@"%ld", docArr.count];
    return dtModel;
}

#pragma mark -- 构造文档Doc模型
+ (DocumentModel *)top_buildDocumentModelWithData:(TOPAppDocument *)appDoc {
    //document下的文件夹若是空的就删除掉
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:appDoc.Id];
    if (!images.count || ![TOPWHCFileManager top_isExistsAtPath:appDoc.filePath]) {
//        [TOPDBService removeObject:appDoc];
        [TOPWHCFileManager top_removeItemAtPath:appDoc.filePath];
        return nil;
    }
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    dtModel.collectionstate = appDoc.collectionState;
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
    TOPImageFile *imgFile = appDoc.images.firstObject;
    NSString *imageName = imgFile.fileName;
    dtModel.imagePath = [dtModel.path stringByAppendingPathComponent:imageName];
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[dtModel.path stringByReplacingOccurrencesOfString:@"/" withString:@""],imageName];
    dtModel.coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    dtModel.gaussianBlurPath = [TOPDocumentHelper top_gaussianBlurImgFileString:coverName];
    dtModel.tagsPath = [TOPDocumentHelper top_getTagsPathString:dtModel.path];
    dtModel.tagsArray = [TOPDataModelHandler top_getDocumentTagsArrayWithPath:dtModel.path];
    dtModel.docPasswordPath = [TOPDocumentHelper top_getDocPasswordPathString:dtModel.path];
    dtModel.midCoverImgPath = [TOPDocumentHelper top_coverImageFile:[NSString stringWithFormat:@"mid_%@",coverName]];
    dtModel.picArray = [self top_getDocPicArray:dtModel];
    return dtModel;
}
#pragma mark -- 创建Image数据模型数组 数组中最多有4个数据
+ (NSArray *)top_getDocPicArray:(DocumentModel *)dtModel{
    TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:dtModel.docId];
    appDoc.filePath = dtModel.path;
    NSArray *images = [TOPDBQueryService top_sortImageFilesByParentId:appDoc.Id];
    
    NSMutableArray * tempArray = [NSMutableArray new];
    NSInteger dataCount = 0;
    if (images.count>4) {
        dataCount = 4;
    }else{
        dataCount = images.count;
    }
    for (int i = 0; i < dataCount; i ++) {
        TOPImageFile *imgObj = images[i];
        imgObj.filePath = [appDoc.filePath stringByAppendingPathComponent:imgObj.fileName];
        DocumentModel *dtModel = [self top_buildImageModelWithData:imgObj];
        if (dtModel) {
            if (i + 1 < 10) {
                dtModel.name = [NSString stringWithFormat:@"0%d",i + 1];
            }else{
                dtModel.name = [NSString stringWithFormat:@"%d",i + 1];
            }
            [tempArray addObject:dtModel];
        }
    }
    //根据名字再进行一次排序 这里是满足底部的sorty by功能
    NSMutableArray *sortDocs = [[TOPDataModelHandler top_imageSortWithData:tempArray] mutableCopy];
    return sortDocs;
}
#pragma mark -- 构造Image数据模型
+ (DocumentModel *)top_buildImageModelWithData:(TOPImageFile *)imgFile {
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
    dtModel.createDate = [TOPAppTools timeStringFromDate:imgFile.utime];
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
    dtModel.gaussianBlurPath = [TOPDocumentHelper top_gaussianBlurImgFileString:coverName];
    return dtModel;
}

#pragma mark -- 图片 计算文件大小
+ (long)top_sumImagesFileSize:(NSArray *)imgIds {
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesWithImageIds:imgIds];
    long sumSize = [[images sumOfProperty:@"fileLength"] longValue];
    return sumSize;
}

#pragma mark -- 文档 计算文件大小
+ (long)top_sumDocumentsFileSize:(NSArray *)docIds {
    long sumSize = 0;
    for (NSString *docId in docIds) {
        TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:docId];
        long docSize = [[doc.images sumOfProperty:@"fileLength"] longValue];
        sumSize += docSize;
    }
    return sumSize;
}

#pragma mark -- 文件夹 计算文件大小
+ (long)top_sumFoldersFileSize:(NSArray *)folderIds {
    long sumSize = 0;
    for (NSString *docId in folderIds) {
        TOPAPPFolder *fld = [TOPDBQueryService top_appFolderById:docId];
        RLMResults<TOPAppDocument *> *documents = [TOPDBQueryService top_documentsAtFoler:fld.Id];
        for (TOPAppDocument *docObj in documents) {
            long docSize = [[docObj.images sumOfProperty:@"fileLength"] longValue];
            sumSize += docSize;
        }
    }
    return sumSize;
}

#pragma mark -- 文件创建时间
+ (NSDate *)top_createTimeOfFile:(NSString *)path {
    NSDate *date = [TOPWHCFileManager top_creationDateOfItemAtPath:path];
    return date;
}

#pragma mark -- 文件修改时间
+ (NSDate *)top_updateTimeOfFile:(NSString *)path {
    NSDate *date = [TOPWHCFileManager top_modificationDateOfItemAtPath:path];
    return date;
}

@end
