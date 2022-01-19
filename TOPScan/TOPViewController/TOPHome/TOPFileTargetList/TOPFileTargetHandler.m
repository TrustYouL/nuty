#import "TOPFileTargetHandler.h"
#import "TOPFileTargetModel.h"
#import "TOPAPPFolder.h"
#import "TOPAppDocument.h"

static NSString *TRAllDocIdentifier = @"All Doc";

@implementation TOPFileTargetHandler
#pragma mark -- 可移动/复制到的目标文件目录
- (NSArray *)top_getFileArrayWithType:(TOPFileTargetType)type {
    NSMutableArray *temp = [@[] mutableCopy];
    if (type == TOPFileTargetTypeFolder) {
        if (self.fileHandleType == TOPFileHandleTypeCopy || ![self top_isAllDocPath]) {
            TOPFileTargetModel *allDocModel = [self top_buildFolderTargetModelWithPath:[TOPDocumentHelper top_getDocumentsPathString]];
            allDocModel.docId = @"000000";
            allDocModel.targetFileName = NSLocalizedString(@"topscan_tagsalldocs", @"");
            allDocModel.isAllDoc = YES;
            [temp addObject:allDocModel];
        }
        NSMutableArray *folders = [TOPDBQueryService top_allFoldersByFatherDirectorySorted];
        for (TOPAPPFolder *folderObj in folders) {
            NSString *folderPath = [TOPDBDataHandler top_folderPath:folderObj.pathId];
            TOPFileTargetModel *dtModel = [self top_buildFolderTargetModelWithPath:folderPath];
            dtModel.docId = folderObj.Id;
            if (self.fileHandleType == TOPFileHandleTypeMove &&  dtModel.isCurrentFile) {
                continue;
            }
            [temp addObject:dtModel];
        }
    } else {
        BOOL folderAtTop = [TOPScanerShare top_homeFolderTopOrBottom] == 1 ? YES : NO;
        RLMResults<TOPAppDocument *> *documents = [TOPDBQueryService top_allDocumentsAtFoler];
        for (TOPAppDocument *docObj in documents) {
            NSString *folderPath = [TOPDBDataHandler top_documentPath:docObj.pathId];
            RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:docObj.Id];
            if (!images.count || ![TOPWHCFileManager top_isExistsAtPath:folderPath]) {
                [TOPWHCFileManager top_removeItemAtPath:folderPath];
                continue;
            }
            TOPFileTargetModel *dtModel = [self top_buildDocumentTargetModelWithPath:folderPath forFile:NO];
            dtModel.docId = docObj.Id;
            if (self.fileHandleType == TOPFileHandleTypeMove &&  dtModel.isCurrentFile) {
                continue;
            }
            [temp addObject:dtModel];
        }
        
        RLMResults<TOPAppDocument *> *docs = [TOPDBQueryService top_homeDocumentsBySorted];
        NSMutableArray *tempDocs = @[].mutableCopy;
        for (TOPAppDocument *docObj in docs) {
            NSString *docPath = [TOPDBDataHandler top_documentPath:docObj.pathId];
            RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:docObj.Id];
            if (!images.count || ![TOPWHCFileManager top_isExistsAtPath:docPath]) {
                [TOPWHCFileManager top_removeItemAtPath:docPath];
                continue;
            }
            TOPFileTargetModel *dtModel = [self top_buildDocumentTargetModelWithPath:docPath forFile:YES];
            dtModel.docId = docObj.Id;
            if (self.fileHandleType == TOPFileHandleTypeMove &&  dtModel.isCurrentFile) {
                continue;
            }
            [tempDocs addObject:dtModel];
        }
        
        if (folderAtTop) {
            [temp addObjectsFromArray:tempDocs];
        } else {
            [tempDocs addObjectsFromArray:temp];
            return tempDocs;
        }
    }
    return temp;
}

#pragma mark -- 构造Folder数据模型 -- Folders目录下
- (TOPFileTargetModel *)top_buildFolderTargetModelWithPath:(NSString *)folderPath {
    NSString *fatherPaht = [NSString stringWithFormat:@"%@/",[TOPDocumentHelper top_getFoldersPathString]];
    TOPFileTargetModel *dtModel = [[TOPFileTargetModel alloc] init];
    dtModel.path = folderPath;
    dtModel.name = [TOPWHCFileManager top_fileNameAtPath:dtModel.path suffix:YES];
    dtModel.createDate = [TOPDocumentHelper top_getModifyTimeString:dtModel.path];
    dtModel.isFile = NO;
    dtModel.targetFileName = [dtModel.path stringByReplacingOccurrencesOfString:fatherPaht withString:@""];
    dtModel.fatherPath = [TOPWHCFileManager top_directoryAtPath:dtModel.path];
    dtModel.isCurrentFile = [dtModel.path isEqualToString:self.currentFilePath];
    return dtModel;
}

#pragma mark -- 判断当前目录是否为首页目录
- (BOOL)top_isAllDocPath {
    NSString *allDocPath = [TOPDocumentHelper top_getDocumentsPathString];
    if ([self.currentFilePath isEqualToString:allDocPath]) {//在首页
        return YES;
    }
    return NO;
}

#pragma mark -- 构造Document数据模型 -- Documents和Folders两个目录下， isFile == Yes 为 Documents，否则为Folders
- (TOPFileTargetModel *)top_buildDocumentTargetModelWithPath:(NSString *)path forFile:(BOOL)isFile {
    NSString *fatherPaht = isFile ? [NSString stringWithFormat:@"%@/",[TOPDocumentHelper top_getDocumentsPathString]] : [NSString stringWithFormat:@"%@/",[TOPDocumentHelper top_getFoldersPathString]];
    TOPFileTargetModel *dtModel = [[TOPFileTargetModel alloc] init];
    dtModel.path = path;
    dtModel.name = [TOPWHCFileManager top_fileNameAtPath:dtModel.path suffix:YES];
    dtModel.createDate = [TOPDocumentHelper top_getModifyTimeString:dtModel.path];
    dtModel.isFile = isFile;
    dtModel.targetFileName = [dtModel.path stringByReplacingOccurrencesOfString:fatherPaht withString:@""];
    dtModel.fatherPath = [TOPWHCFileManager top_directoryAtPath:dtModel.path];
    NSArray *imgArr = [TOPDocumentHelper top_sortPicsAtPath:dtModel.path];
    dtModel.imagePath = [dtModel.path stringByAppendingPathComponent:imgArr.firstObject];
    dtModel.isCurrentFile = [dtModel.path isEqualToString:self.currentFilePath];
    dtModel.number = [NSString stringWithFormat:@"%ld",imgArr.count];
    NSString *imageName = imgArr.firstObject;
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[dtModel.path stringByReplacingOccurrencesOfString:@"/" withString:@""],imageName];
    dtModel.coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    dtModel.tagsPath = [TOPDocumentHelper top_getTagsPathString:path];
    dtModel.tagsArray = [TOPDataModelHandler top_getDocumentTagsArrayWithPath:path];
    dtModel.gaussianBlurPath = [TOPDocumentHelper top_gaussianBlurImgFileString:coverName];
    dtModel.docPasswordPath = [TOPDocumentHelper top_getDocPasswordPathString:dtModel.path];
    
    return dtModel;
}

#pragma mark -- 当前所有的文件夹(Folder)
- (NSArray *)allFolders {
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_getAllFoldersWithPath:[TOPDocumentHelper top_getFoldersPathString] documentArray:documentArray];
    return getArry;
}

#pragma mark -- Documents所有的文档(Document)
- (NSArray *)allDocsAtDocuments {
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_getAllDocumentsWithPath:[TOPDocumentHelper top_getDocumentsPathString] documentArray:documentArray];
    return getArry;
}

#pragma mark -- Folders所有的文档(Document)
- (NSArray *)allDocsAtFolders {
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_getAllDocumentsWithPath:[TOPDocumentHelper top_getFoldersPathString] documentArray:documentArray];
    return getArry;
}

#pragma mark -- 当前所有的文档(Document)
- (NSArray *)allDocuments {
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_getAllDocumentsWithPath:[TOPDocumentHelper top_appBoxDirectory] documentArray:documentArray];
    return getArry;
}
@end
