#import "TOPShareFileDataHandler.h"
#import "TOPShareFileModel.h"

@implementation TOPShareFileDataHandler

#pragma mark -- 首页和nextFolder界面的分享数据
+ (NSMutableArray *)top_fetchShareFileData:(NSArray *)fileArray {
    NSMutableArray *data = @[].mutableCopy;
    if (fileArray.count) {
        CGFloat totalSize = [TOPDocumentHelper top_calculateSelectFilesSize:fileArray];
        NSArray *icons = [self imageArr];
        NSArray *titles = [self titleItems];
        NSArray *types = [self typeItems];
        for (int i = 0; i < 4; i ++) {
            TOPShareFileModel *model = [[TOPShareFileModel alloc] init];
            model.isSelected = !i;
            model.showSize = i < 2 ? YES : NO;
            model.fileSize = totalSize;
            model.icon = icons[i];
            model.title = titles[i];
            model.fileType = [types[i] integerValue];
            model.isZip = NO;
            if (i == 0 && [self pdfCount:fileArray] > 1) {//pdf
                model.sectionData = [self pdfFileFormat:icons[i]];
            } else if (i == 1 && [self imageCount:fileArray] > 9) {//jpg
                model.sectionData = [self imageFileFormat:icons[i]];
            }
            
            [data addObject:model];
        }
    }
    return data;
}

#pragma mark -- homeChild界面的分享数据
+ (NSMutableArray *)top_fetchShareImageData:(NSArray *)fileArray {
    NSMutableArray *data = @[].mutableCopy;
    if (fileArray.count) {
        CGFloat totalSize = [TOPDocumentHelper top_calculateSelectImagesSize:fileArray];
        NSMutableArray *imgs = @[].mutableCopy;
        for (DocumentModel * model in fileArray) {
            if (model.selectStatus) {
                [imgs addObject:model];
            }
        }
        NSArray *icons = [self imageArr];
        NSArray *titles = [self titleItems];
        NSArray *types = [self typeItems];
        for (int i = 0; i < 4; i ++) {
            TOPShareFileModel *model = [[TOPShareFileModel alloc] init];
            model.isSelected = !i;
            model.showSize = i < 2 ? YES : NO;
            model.fileSize = totalSize;
            model.icon = icons[i];
            model.title = titles[i];
            model.fileType = [types[i] integerValue];
            model.isZip = NO;
            if (i == 1 && imgs.count > 9) {
                model.sectionData = [self imageFileFormat:icons[i]];
            }
            [data addObject:model];
        }
    }
    return data;
}

#pragma mark -- 计算转成PDF的个数
+ (NSInteger)pdfCount:(NSArray *)fileArray {
    NSInteger fileCount = 0;
    for (DocumentModel * model in fileArray) {
        if (model.selectStatus) {
            if ([model.type isEqualToString:@"1"]) {//documents
                fileCount ++;
            } else {
                fileCount += [model.number integerValue];
            }
        }
        
    }
    return fileCount;
}

#pragma mark -- 计算image的个数
+ (NSInteger)imageCount:(NSArray *)fileArray {
    NSInteger fileCount = 0;
    for (DocumentModel * model in fileArray) {
        if (model.selectStatus) {
            if ([model.type isEqualToString:@"1"]) {//documents
                TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:model.docId];
                RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imagesAtPath:doc.pathId];
                fileCount += images.count;
            } else {
                TOPAPPFolder *folder = [TOPDBQueryService top_appFolderById:model.docId];
                RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imagesAtPath:folder.pathId];
                fileCount += images.count;
            }
        }
        
    }
    return fileCount;
}

#pragma mark -- 选中分享pdf的次级数据
+ (NSMutableArray *)pdfFileFormat:(NSString *)icon {
    TOPShareFileModel *model = [self subSectionModel];
    model.isSelected = YES;
    model.icon = icon;
    model.title = NSLocalizedString(@"topscan_sharepdfformat", @"");
    TOPShareFileModel *model2 = [self subSectionModel];
    model2.isSelected = NO;
    model2.icon = @"top_ShareZIP";
    model2.title = NSLocalizedString(@"topscan_sharezipformat", @"");
    model2.zipItem = YES;
    return @[model, model2].mutableCopy;
}

#pragma mark -- 选中分享image的次级数据
+ (NSMutableArray *)imageFileFormat:(NSString *)icon {
    TOPShareFileModel *model = [self subSectionModel];
    model.isSelected = YES;
    model.icon = icon;
    model.title = NSLocalizedString(@"topscan_sharejpgformat", @"");
    TOPShareFileModel *model2 = [self subSectionModel];
    model2.isSelected = NO;
    model2.icon = @"top_ShareZIP";
    model2.title = NSLocalizedString(@"topscan_sharezipformat", @"");
    model2.zipItem = YES;
    return @[model, model2].mutableCopy;
}

#pragma mark -- 次级数据模型
+ (TOPShareFileModel *)subSectionModel {
    TOPShareFileModel *model = [[TOPShareFileModel alloc] init];
    model.showSize = NO;
    model.zipItem = NO;
    model.sectionData = @[].mutableCopy;
    return model;
}

+ (NSArray *)imageArr {
    NSArray *icons = @[@"top_SharePDF",@"top_ShareJPG",@"top_ShareLongJPG",@"top_ShareTXT"];
    return icons;
}

+ (NSArray *)titleItems {
    NSArray *titles = @[
        NSLocalizedString(@"topscan_pdffile", @""),
        NSLocalizedString(@"topscan_image_jpg", @""),
        NSLocalizedString(@"topscan_longimage_jpg", @""),
        NSLocalizedString(@"topscan_txt", @"")];
    return titles;
}

+ (NSArray *)typeItems {
    NSArray *types = @[
        @(TOPShareFilePDF),
        @(TOPShareFileJPG),
        @(TOPShareFileLongJPG),
        @(TOPShareFileTxt)];
    return types;
}

@end
