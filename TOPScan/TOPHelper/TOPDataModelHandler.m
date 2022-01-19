#import "TOPDataModelHandler.h"
#import "TOPPictureProcessTool.h"
#import "TOPDBDataHandler.h"

@implementation TOPDataModelHandler

#pragma mark -- 构造主界面数据
+ (NSMutableArray *)top_buildHomeData {
    //重新生成一个新文件
    if (![TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_getCoverImageFileString]]) {
        [TOPWHCFileManager top_createDirectoryAtPath:[TOPDocumentHelper top_getCoverImageFileString]];
    }
    NSLog(@"top_getFoldersPathString==%@\ntop_getDocumentsPathString==%@",[TOPDocumentHelper top_getFoldersPathString],[TOPDocumentHelper top_getDocumentsPathString]);
    //Folders路径下的文件夹
    NSArray *blFdArray = [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getFoldersPathString]];
    //获取Documents/Documents里面的文档
    NSArray *blDtArray = [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getDocumentsPathString]];
    NSMutableArray *dataArray = @[].mutableCopy;
    NSMutableArray *fdArray = @[].mutableCopy;
    NSMutableArray *dtArray = @[].mutableCopy;
    NSMutableArray *sortFdArray = [NSMutableArray new];
    NSMutableArray *sortDtArray = [NSMutableArray new];

    if (blFdArray.count > 0) {
        NSString *path = [TOPDocumentHelper top_getFoldersPathString];
        for (NSString *fdStr in blFdArray) {
            NSString *fdPath = [path stringByAppendingPathComponent:fdStr];
            DocumentModel *dtModel = [self top_buildFolderTargetModelWithPath:fdPath];
            if (dtModel) {
                [fdArray addObject:dtModel];
            }
        }
        sortFdArray = [self top_sortFileDataWithModelArray:fdArray atPath:path];
    }
    
    if (blDtArray.count > 0) {
        NSString *path = [TOPDocumentHelper top_getDocumentsPathString];
        for (NSString *dtStr in blDtArray) {
            NSString *dtPath = [path stringByAppendingPathComponent:dtStr];
            DocumentModel *dtModel = [self top_buildDocumentTargetModelWithPath:dtPath];
            if (dtModel) {
                [dtArray addObject:dtModel];
            }
        }
        sortDtArray = [self top_sortFileDataWithModelArray:dtArray atPath:path];

    }
    
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 1) {//文件夹排前文档排后
        [dataArray addObjectsFromArray:sortFdArray];
        [dataArray addObjectsFromArray:sortDtArray];
    }else{
        [dataArray addObjectsFromArray:sortDtArray];
        [dataArray addObjectsFromArray:sortFdArray];
    }
    return dataArray;
}

#pragma mark -- 对模型数据重新排序
+ (NSMutableArray *)top_loadDataSortAgain:(NSMutableArray *)dataArray withType:(BOOL)type withPath:(nonnull NSString *)path{
    NSMutableArray * sendArray = [NSMutableArray new];
    NSMutableArray * folderArray = [NSMutableArray new];
    NSMutableArray * docArray = [NSMutableArray new];
    NSMutableArray *sortFdArray = [NSMutableArray new];
    NSMutableArray *sortDtArray = [NSMutableArray new];
    for (DocumentModel * model in dataArray) {
        if ([model.type isEqualToString:@"1"]) {
            [docArray addObject:model];
        }else{
            [folderArray addObject:model];
        }
    }
    
    if (folderArray.count>0) {
        if (type) {
            path = [TOPDocumentHelper top_getFoldersPathString];//因为首页的folder doc类文件夹的数据结构的原因 不能直接用传递过来的路径 需要重新处理
        }
        sortFdArray = [self top_sortFileDataWithModelArray:folderArray atPath:path];
    }
    
    if (docArray.count>0) {
        if (type) {
            path = [TOPDocumentHelper top_getDocumentsPathString];
        }
        //doc排序
        sortDtArray = [self top_sortFileDataWithModelArray:docArray atPath:path];
        //doc下的tag排序
        NSMutableArray * tagTempArray = [NSMutableArray new];
        for (DocumentModel * docModel in docArray) {
            if (docModel.tagsArray.count>0) {
                tagTempArray = [self top_sortFileDataWithModelArray:docModel.tagsArray atPath:docModel.tagsPath];
                //tag排序过后重新赋值
                docModel.tagsArray = [tagTempArray copy];
            }
        }
    }
    
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 1) {//文件夹排前文档排后
        [sendArray addObjectsFromArray:sortFdArray];
        [sendArray addObjectsFromArray:sortDtArray];
    }else{
        [sendArray addObjectsFromArray:sortDtArray];
        [sendArray addObjectsFromArray:sortFdArray];
    }
    return sendArray;
}
#pragma mark -- doc类文档和folder类文档的前后排序 dataArray排序的模型数组
+ (NSMutableArray *)top_docFolerBeforeAndAfter:(NSMutableArray *)dataArray{
    NSMutableArray * sendArray = [NSMutableArray new];
    NSMutableArray * folderArray = [NSMutableArray new];
    NSMutableArray * docArray = [NSMutableArray new];
    for (DocumentModel * model in dataArray) {
        if ([model.type isEqualToString:@"1"]) {
            [docArray addObject:model];
        }else{
            [folderArray addObject:model];
        }
    }
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 1) {//文件夹排前文档排后
        [sendArray addObjectsFromArray:folderArray];
        [sendArray addObjectsFromArray:docArray];
    }else{
        [sendArray addObjectsFromArray:docArray];
        [sendArray addObjectsFromArray:folderArray];
    }
    return sendArray;
}
#pragma mark -- 所有的doc文件夹集合
+ (NSMutableArray *)top_getDocArray:(NSMutableArray *)buildHomeData{
    NSMutableArray * docArray = [NSMutableArray new];//存放所有doc的数组
    for (DocumentModel *model in buildHomeData) {
        if ([model.type isEqual:@"0"]) {
            //将folder类文件夹里的doc文件夹放入数组
            [docArray addObjectsFromArray:model.docArray];
        }
        
        if([model.type isEqual:@"1"]){
            //将doc文件夹放入数组
            [docArray addObject:model];
        }
    }
    
    return docArray;
}

#pragma mark -- tag列表的All Docs 模型
+ (TOPTagsListModel *)top_allDocModelWithDocArray:(NSMutableArray *)docArray withBuildHomeArray:(NSMutableArray *)homeDataArray{
    NSInteger allNum = 0;//所有doc的数量

    allNum = docArray.count;
    //创建标签列表模型
    TOPTagsListModel * allListModel = [TOPTagsListModel new];
    allListModel.tagName = TOP_TRTagsAllDocesKey;
    allListModel.tagNum = [NSString stringWithFormat:@"%ld",allNum];
    allListModel.docArray = [homeDataArray copy];
    return allListModel;
}
#pragma mark -- tag列表的Ungrouped 模型
+ (TOPTagsListModel *)top_ungrouperListModelWithDocArray:(NSMutableArray *)docArray{
    NSInteger ungrouperNum = 0;//没有标签的doc数量
    NSMutableArray * ungrouperArray = [NSMutableArray new];//没有标签的数组
    //标签数组为空说明没有标签
    for (DocumentModel * docModel in docArray) {
        if (docModel.tagsArray.count == 0) {
            [ungrouperArray addObject:docModel];
        }
    }
    ungrouperNum = ungrouperArray.count;
    TOPTagsListModel * ungrouperListModel = [TOPTagsListModel new];
    ungrouperListModel.tagName = TOP_TRTagsUngroupedName;
    ungrouperListModel.tagNum = [NSString stringWithFormat:@"%ld",ungrouperNum];
    ungrouperListModel.docArray = [ungrouperArray copy];
    return ungrouperListModel;
}
#pragma mark -- tags列表数据
+ (NSMutableArray *)top_getTagsListData{
    NSMutableArray * homeDataArray = [self top_buildHomeData];
    //标签列表数据
    NSMutableArray * tagListArray = [NSMutableArray new];
    NSMutableArray * docArray = [self top_getDocArray:homeDataArray];
    [tagListArray addObject:[self top_allDocModelWithDocArray:docArray withBuildHomeArray:homeDataArray]];
    [tagListArray addObject:[self top_ungrouperListModelWithDocArray:docArray]];
    //这种情况tags列表数据不需要排序
    NSMutableArray * traverseArray = [self top_getTagsListRootTagsData:docArray];
    [tagListArray addObjectsFromArray:traverseArray];
    return tagListArray;
}
#pragma mark -- 获取根目录下Tags数据
+ (NSMutableArray *)top_getTagsListRootTagsData:(NSMutableArray *)docArray{
    //标签列表数据
    NSMutableArray * tagListArray = [NSMutableArray new];
    //获取根目录下Tags文件夹的路径
    NSString * homeTagsPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    //获取homeTagsPath下的文件夹名称
    NSArray * homeTagsPathArray = [TOPDocumentHelper top_getCurrentFileAndPath:homeTagsPath];
    NSMutableArray * traverseArray = [self top_getTraverseData:homeTagsPathArray withAllDataArray:docArray];
    [tagListArray addObjectsFromArray:traverseArray];
    return tagListArray;
}
#pragma mark -- 根据根目录下Tags数据 创建 TOPTagsListModel模型
+ (NSMutableArray *)top_getTraverseData:(NSArray *)homeTagsPathArray withAllDataArray:(NSMutableArray *)docArray{
    NSMutableArray * tagListArray = [NSMutableArray new];//标签列表数据
    for (NSString * tagName in homeTagsPathArray) {
        NSMutableArray * tagArray = [NSMutableArray new];
        TOPTagsListModel * listModel = [TOPTagsListModel new];
        for (DocumentModel * docModel in docArray) {//遍历所有doc文件夹
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name = %@",tagName];
            NSArray * tagDocs = [docModel.tagsArray filteredArrayUsingPredicate:predicate];
            if (tagDocs.count>0) {
                [tagArray addObject:docModel];
            }
        }
        listModel.tagName = tagName;
        listModel.tagNum = [NSString stringWithFormat:@"%ld",tagArray.count];
        listModel.docArray = [tagArray copy];
        [tagListArray addObject:listModel];
    }
    return tagListArray;
}

#pragma mark --tags管理页面的 tags列表数据 是需要排序的
+ (NSMutableArray *)top_getTagsListManagerData{
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    NSMutableArray * tagListArray  = [TOPDBDataHandler top_buildTagListWithDB];
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"load Linked in %f ms", linkTime *1000.0);
    
    NSInteger num = linkTime * 1000;
    NSString * sendString = [NSString new];
    if (num>6000) {
        sendString = @"MoreThan6000";
    }else{
        NSInteger sendNum = (num/200+1)*200;
        sendString = [NSString stringWithFormat:@"%ld",sendNum];
    }
    [FIRAnalytics logEventWithName:[NSString stringWithFormat:@"loadTime_%@",sendString] parameters:nil];
    return tagListArray;
}

+ (NSMutableArray *)getTagsManagerListRootTagsData:(NSMutableArray *)docArray{
    NSMutableArray * tagListArray = [NSMutableArray new];//标签列表数据
    //获取根目录下Tags文件夹的路径
    NSString * homeTagsPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    //获取homeTagsPath下的文件夹名称
    NSArray * homeTagsPathArray = [TOPDocumentHelper top_getCurrentFileAndPath:homeTagsPath];
    //排序 按创建时间排序
    NSArray * sortArray = [self top_sortTagsFileData:homeTagsPathArray atPath:homeTagsPath];
    NSMutableArray * traverseArray = [self top_getTraverseData:sortArray withAllDataArray:docArray];
    [tagListArray addObjectsFromArray:traverseArray];
    return tagListArray;
}

#pragma mark -- 标签管理界面 对标签重新排序
+ (NSMutableArray *)top_tagsManagerListSort:(NSMutableArray *)tagsArray{
    //获取根目录下Tags文件夹的路径
    NSString * homeTagsPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    //排序 按创建时间排序
    NSArray * sortArray = [self top_sortTagsFileData:tagsArray atPath:homeTagsPath];
    return [sortArray mutableCopy];
}
#pragma mark -- Folder次级界面数据
+ (NSMutableArray *)top_buildFolderSecondaryDataAtPath:(NSString *)path {
    NSArray *documentArray = [TOPDocumentHelper top_getCurrentFileAndPath:path];

    //这里下次更新需要去掉 --版本兼容处理
    NSMutableArray * getDocumentArray = [NSMutableArray new];
    for (NSString * tempString in documentArray) {
        if ([tempString isEqualToString:@"Documents"]||[tempString isEqualToString:@"Folders"]) {
            [TOPWHCFileManager top_removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,tempString]];
        }else{
            [getDocumentArray addObject:tempString];
        }
    }
    
    NSMutableArray * blFdArray = [NSMutableArray new];
    NSMutableArray * blDtArray = [NSMutableArray new];
    
    for (NSString * lastString in getDocumentArray) {
        NSString * componentStr = [NSString stringWithFormat:@"%@/%@",path,lastString];
        
        NSArray * componentArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentStr];
        if (componentArray.count>0) {
            NSString * contentStr = componentArray[0];
            NSString *fullStr = [NSString stringWithFormat:@"%@/%@",componentStr,contentStr];//判断一下是图片路径还是文件夹路径
            //判断第二层内是不是文件夹 若是文件夹 说明上层为folder 反之为documemnt
            if ([TOPWHCFileManager top_isDirectoryAtPath:fullStr]) {
                [blFdArray addObject:lastString];
            }
            
            //document文档
            if ([TOPWHCFileManager top_isFileAtPath:fullStr]) {
                [blDtArray addObject:lastString];
            }
        }else{
            [blFdArray addObject:lastString];
        }
    }
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *dtArray = [NSMutableArray array];
    NSMutableArray *fdArray = [NSMutableArray array];
    
    if (blFdArray.count > 0) {
        NSMutableArray * tempArray = [NSMutableArray new];
        for (NSString *fdStr in blFdArray) {
            NSString *fdPath = [path stringByAppendingPathComponent:fdStr];
            DocumentModel *dtModel = [self top_buildFolderTargetModelWithPath:fdPath];
            if (dtModel) {
                [tempArray addObject:dtModel];
            }
        }
        //排序
        fdArray = [self top_sortFileDataWithModelArray:tempArray atPath:path];

    }
    if (blDtArray.count > 0) {
        NSMutableArray * tempArray = [NSMutableArray new];
        for (NSString *dtStr in blDtArray) {
            NSString *dtPath = [path stringByAppendingPathComponent:dtStr];
            DocumentModel *dtModel = [self top_buildDocumentTargetModelWithPath:dtPath];
            if (dtModel) {
                [tempArray addObject:dtModel];
            }
        }
        //排序
        dtArray = [self top_sortFileDataWithModelArray:tempArray atPath:path];
    }
    
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 1) {
        [dataArray addObjectsFromArray:fdArray];
        [dataArray addObjectsFromArray:dtArray];
    }else{
        [dataArray addObjectsFromArray:dtArray];
        [dataArray addObjectsFromArray:fdArray];
    }
    return dataArray;
}

#pragma mark -- Document次级界面数据
+ (NSMutableArray *)top_buildDocumentSecondaryDataAtPath:(NSString *)path {
    NSMutableArray *dataArray = @[].mutableCopy;
    if (!path) {
        return dataArray;
    }
    NSArray *imageArray = [TOPDocumentHelper top_sortPicsAtPath:path];
    NSMutableArray *dtArray = [NSMutableArray array];
    for (NSString *dtStr in imageArray) {
        DocumentModel *dtModel = [self top_buildImageModelWithName:dtStr atPath:path];
        //处理后缀
        NSInteger imgIndex = [imageArray indexOfObject:dtStr];
        if (imgIndex + 1 < 10) {
            dtModel.name = [NSString stringWithFormat:@"0%ld",imgIndex + 1];
        }else{
            dtModel.name = [NSString stringWithFormat:@"%ld",imgIndex + 1];
        }
        [dtArray addObject:dtModel];
    }
    //根据名字再进行一次排序 这里是满足底部的sorty by功能
    dataArray = [[self top_imageSortWithData:dtArray] mutableCopy];
    return dataArray;
}

+ (NSMutableArray *)top_buildSearchDataAtPath:(NSString *)path{
    NSMutableArray * tempAllDataArray = [NSMutableArray new];
    NSString * componentFondersStr = [NSString stringWithFormat:@"%@/%@",path,@"Folders"];
    NSString * componentDocumentsStr = [NSString stringWithFormat:@"%@/%@",path,@"Documents"];

    //获取首页Documents/Documents里面的文件夹 这里获取的是文件夹的名称
    NSArray *blDtArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentDocumentsStr];
    NSLog(@"--- %@",blDtArray);
    //拼接成文件夹完整路径
    NSMutableArray * allDtArray = [NSMutableArray new];
    for (NSString * blStr in blDtArray) {
        NSString * fullStr = [componentDocumentsStr stringByAppendingPathComponent:blStr];
        [allDtArray addObject:fullStr];
    }
    
    //folder文件夹下的文件夹名称集合
    NSArray *blFdArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentFondersStr];
    NSLog(@"--- %@",blFdArray);
    
    //获取folder下的所有docunments文件夹路径
    if (blFdArray.count>0) {
        for (NSString * fdStr in blFdArray) {
            DocumentModel * dtModel = [DocumentModel new];
            NSString *fullStr = [NSString stringWithFormat:@"%@/%@",componentFondersStr,fdStr];
            dtModel.path = fullStr;
            NSMutableArray * documentArray = [NSMutableArray new];
            //Documents文件夹下的所有文件夹的路径
            NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:dtModel.path documentArray:documentArray];
            [allDtArray addObjectsFromArray:getArry];
        }
    }
    NSLog(@"allDtArray===%@",allDtArray);
    
    for (NSString *dtStr in allDtArray) {
        NSLog(@"dtStr=====%@",dtStr);
        DocumentModel *dtModel = [self top_buildDocumentTargetModelWithPath:dtStr];
        if (dtModel) {
            [tempAllDataArray addObject:dtModel];
        }
    }
    
    return tempAllDataArray;
}

//一旦发现有docunemnt类的文档立马停止便利 返回
+ (BOOL)top_documentIsThereAnyData:(NSString *)path{
    BOOL isThis = NO;
    NSMutableArray * allDtArray = [NSMutableArray new];
    NSString * componentFondersStr = [NSString stringWithFormat:@"%@/%@",path,@"Folders"];
    NSString * componentDocumentsStr = [NSString stringWithFormat:@"%@/%@",path,@"Documents"];
    //获取首页Documents/Documents里面的文件夹 这里获取的是文件夹的名称
    NSArray *blDtArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentDocumentsStr];
    if (blDtArray.count>0) {
        isThis = YES;
        return isThis;
    }
    
    //folder文件夹下的文件夹名称集合
    NSArray *blFdArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentFondersStr];
    if (blFdArray.count>0) {
        for (NSString * fdStr in blFdArray) {
            if (allDtArray.count>0) {
                isThis = YES;
                return isThis;
            }else{
                DocumentModel * dtModel = [DocumentModel new];
                NSString *fullStr = [NSString stringWithFormat:@"%@/%@",componentFondersStr,fdStr];
                dtModel.path = fullStr;
                NSMutableArray * documentArray = [NSMutableArray new];
                //Documents文件夹下的所有文件夹的路径
                NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:dtModel.path documentArray:documentArray];
                [allDtArray addObjectsFromArray:getArry];
            }
        }
    }
    return isThis;
}
#pragma mark -- 根据名字再进行一次排序 这里是满足底部的sorty by功能
+ (NSArray *)top_imageSortWithData:(NSArray *)data {
    NSArray * nameSortArray = [data sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        DocumentModel * model1 = obj1;
        DocumentModel * model2 = obj2;
        
        if ([model1.numberIndex integerValue] > [model2.numberIndex integerValue]) {
            if ([TOPScanerShare top_childViewByType] == 1) {
                return NSOrderedDescending;
            }else{
                return NSOrderedAscending;
            }
        }else if ([model1.numberIndex integerValue] < [model2.numberIndex integerValue]){
            if ([TOPScanerShare top_childViewByType] == 1) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }else{
            return NSOrderedSame;
        }
    }];
    return nameSortArray;
}
/*
 FolderDocumentCreateDescending,//由新到旧
 FolderDocumentCreateAscending, //由旧到新
 FolderDocumentFileNameAToZ, //首字母A到Z
 FolderDocumentFileNameZToA, //首字母Z到A
 */
#pragma mark -- 根据设置条件排序(文件) 这个针对的是doc文档
+ (NSMutableArray *)top_sortFileData:(NSArray *)blFdArray atPath:(NSString *)path {
    NSInteger type = [TOPScanerShare top_sortType];
    NSMutableArray *sortFdArray = @[].mutableCopy;
    if (type == FolderDocumentCreateDescending) {
        sortFdArray = [TOPDocumentHelper top_sortByCreateTimeNewToOld:blFdArray path:path];
    }else if (type == FolderDocumentCreateAscending){
        sortFdArray = [TOPDocumentHelper top_sortByCreateTimeOldToNew:blFdArray path:path];
    }else if (type == FolderDocumentUpdateDescending){
        sortFdArray = [TOPDocumentHelper top_sortByTimeNewToOld:blFdArray path:path];
    }else if (type == FolderDocumentUpdateAscending){
        sortFdArray = [TOPDocumentHelper top_sortByTimeOldToNew:blFdArray path:path];
    }else if (type == FolderDocumentFileNameAToZ){
        sortFdArray = [TOPDocumentHelper top_sortByNameAZ:blFdArray];
    }else if (type == FolderDocumentFileNameZToA){
        sortFdArray = [TOPDocumentHelper top_sortByNameZA:blFdArray];
    }
    return sortFdArray;
}
+ (NSMutableArray *)top_sortFileDataWithModelArray:(NSArray *)modelArray atPath:(NSString *)path{
    NSInteger type = [TOPScanerShare top_sortType];
    NSMutableArray *sortFdArray = @[].mutableCopy;
    if (type == FolderDocumentCreateDescending) {
        sortFdArray = [TOPDocumentHelper top_sortByCreateTimeNewToOld:modelArray path:path];
    }else if (type == FolderDocumentCreateAscending){
        sortFdArray = [TOPDocumentHelper top_sortByCreateTimeOldToNew:modelArray path:path];
    }else if (type == FolderDocumentUpdateDescending){
        sortFdArray = [TOPDocumentHelper top_sortByTimeNewToOld:modelArray path:path];
    }else if (type == FolderDocumentUpdateAscending){
        sortFdArray = [TOPDocumentHelper top_sortByTimeOldToNew:modelArray path:path];
    }else if (type == FolderDocumentFileNameAToZ){
        sortFdArray = [TOPDocumentHelper top_sortByNameAZ:modelArray];
    }else if (type == FolderDocumentFileNameZToA){
        sortFdArray = [TOPDocumentHelper top_sortByNameZA:modelArray];
    }
    return sortFdArray;
}
#pragma mark -- 根据设置条件排序(tags标签) 这个针对的是tags标签 tags标签是按创建时间的顺序排列
+ (NSMutableArray *)top_sortTagsFileData:(NSArray *)blFdArray atPath:(NSString *)path {
    NSInteger type = [TOPScanerShare top_sortTagsType];
    NSMutableArray *sortFdArray = @[].mutableCopy;
    if (type == FolderDocumentCreateDescending) {
        sortFdArray = [TOPDocumentHelper top_sortByCreateTimeNewToOld:blFdArray path:path];
    }else if (type == FolderDocumentCreateAscending){
        sortFdArray = [TOPDocumentHelper top_sortByCreateTimeOldToNew:blFdArray path:path];
    }else if (type == FolderDocumentUpdateDescending){
        sortFdArray = [TOPDocumentHelper top_sortByTimeNewToOld:blFdArray path:path];
    }else if (type == FolderDocumentUpdateAscending){
        sortFdArray = [TOPDocumentHelper top_sortByTimeOldToNew:blFdArray path:path];
    }else if (type == FolderDocumentFileNameAToZ){
        sortFdArray = [TOPDocumentHelper top_sortByNameAZ:blFdArray];
    }else if (type == FolderDocumentFileNameZToA){
        sortFdArray = [TOPDocumentHelper top_sortByNameZA:blFdArray];
    }
    return sortFdArray;
}
#pragma mark -- 构造Folder数据模型 -- Folders目录下 fdStr:文件路径
+ (DocumentModel *)top_buildFolderTargetModelWithPath:(NSString *)fdStr {
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    dtModel.name = [TOPWHCFileManager top_fileNameAtPath:fdStr suffix:YES];
    dtModel.path = fdStr;
    dtModel.createDate =  [TOPDocumentHelper top_getModifyTimeString:dtModel.path];
    dtModel.type = @"0";
    dtModel.isFile = NO;
    dtModel.docArray = [self top_getFolderBottomDocumentWithPath:fdStr];
    dtModel.number = [NSString stringWithFormat:@"%ld", dtModel.docArray.count];
    return dtModel;
}
#pragma mark -- Folder数据模型下Document的数据 -- Folders目录下 folderPath:文件路径
+ (NSArray *)top_getFolderBottomDocumentWithPath:(NSString *)folderPath{
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * documentArray = [NSMutableArray new];
    //folder下的Documents类型所有文件夹的路径，图片都是存放在documents类型的文件夹里的
    NSMutableArray * getDocArry = [TOPDocumentHelper top_getAllDocumentsWithPath:folderPath documentArray:documentArray];
    for (NSString * docPath in getDocArry) {
        //构造Document数据模型
        DocumentModel * model = [self top_buildDocumentTargetModelWithPath:docPath];
        if (model) {
            [tempArray addObject:model];
        }
    }
    return [tempArray copy];
}
#pragma mark -- 构造Document数据模型 -- Documents目录下 dtStr:文档路径
+ (DocumentModel *)top_buildDocumentTargetModelWithPath:(NSString *)dtStr {
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    dtModel.path = dtStr;
    NSArray *blsonArr = [TOPDocumentHelper top_sortPicsAtPath:dtModel.path];
    //document下的文件夹若是空的就删除掉
    if (!blsonArr.count) {
        [TOPWHCFileManager top_removeItemAtPath:dtModel.path];
        return nil;
    }
    dtModel.name = [TOPWHCFileManager top_fileNameAtPath:dtStr suffix:YES];
    dtModel.createDate =  [TOPDocumentHelper top_getModifyTimeString:dtModel.path];
    dtModel.type = @"1";
    dtModel.isFile = YES;
    dtModel.number = [NSString stringWithFormat:@"%ld", [blsonArr count]];
    NSString *imageName = blsonArr.firstObject;
    dtModel.imagePath = [dtModel.path stringByAppendingPathComponent:imageName];
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[dtModel.path stringByReplacingOccurrencesOfString:@"/" withString:@""],imageName];
    dtModel.coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    dtModel.gaussianBlurPath = [TOPDocumentHelper top_gaussianBlurImgFileString:coverName]; 
    dtModel.tagsPath = [TOPDocumentHelper top_getTagsPathString:dtStr];
    dtModel.tagsArray = [self top_getDocumentTagsArrayWithPath:dtStr];
    dtModel.docPasswordPath = [TOPDocumentHelper top_getDocPasswordPathString:dtStr];
    return dtModel;
}

#pragma mark -- 获取document文件夹下Tags文件夹的数据
+ (NSArray *)top_getDocumentTagsArrayWithPath:(NSString *)dtStr{
    NSMutableArray * sortDtArray = [NSMutableArray new];
    NSString * tempTagsPath = [TOPDocumentHelper top_getTagsPathString:dtStr];
    if (tempTagsPath.length>0) {
        //获取Tags文件夹下的标签文件夹的名称
        NSArray *tagsArray = [TOPDocumentHelper top_getCurrentFileAndPath:tempTagsPath];
        //判断Tags文件夹下有没有数据 没有就删除掉
        if (!tagsArray.count) {
            [TOPWHCFileManager top_removeItemAtPath:tempTagsPath];
            return nil;
        }
        NSMutableArray * tempTagsArray = [NSMutableArray new];
        for (NSString *dtStr in tagsArray) {
            //拼接tags文件夹下的标签文件夹的路径
            NSString *dtPath = [tempTagsPath stringByAppendingPathComponent:dtStr];
            //根据路径创建标签文件夹的模型
            TOPTagsModel * tagModel = [self top_buildDocumentBottomTagsModelWithPath:dtPath];
            if (tagModel) {
                [tempTagsArray addObject:tagModel];
            }
        }
        
        //对tags文件夹下的标签文件夹进行排序
        sortDtArray = [self top_sortTagsFileData:tempTagsArray atPath:tempTagsPath];
    }
    return [sortDtArray copy];
} 
#pragma mark -- 根据标签文件夹路径创建模型
+ (TOPTagsModel *)top_buildDocumentBottomTagsModelWithPath:(NSString *)dtStr{
    TOPTagsModel * tagsModel = [TOPTagsModel new];
    tagsModel.path = dtStr;
    tagsModel.name = [TOPWHCFileManager top_fileNameAtPath:dtStr suffix:NO];
    tagsModel.selectStatus = NO;
    return tagsModel;
}
#pragma mark -- 构造Image数据模型 -- dtStr: 图片名 path：当前文档路径
+ (DocumentModel *)top_buildImageModelWithName:(NSString *)dtStr atPath:(NSString *)path {
    NSString *fileName = [TOPWHCFileManager top_fileNameAtPath:path suffix:YES];
    DocumentModel *dtModel = [[DocumentModel alloc] init];
    NSString *fullStr = [NSString stringWithFormat:@"%@/%@",path,dtStr];
    dtModel.fileName = fileName;
    dtModel.path = fullStr;//图片路径
    dtModel.createDate = [TOPDocumentHelper top_getModifyTimeString:fullStr];
    dtModel.movePath = path;//文件夹路径
    dtModel.isFile = YES;
    dtModel.type = @"1";
    dtModel.number = [TOPDocumentHelper top_getFileMemorySize:fullStr];
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
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[path stringByReplacingOccurrencesOfString:@"/" withString:@""],dtStr];
    dtModel.coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    dtModel.midCoverImgPath = [TOPDocumentHelper top_coverImageFile:[NSString stringWithFormat:@"mid_%@",coverName]];
    return dtModel;
}

#pragma mark -- 生成一张中等大小的缩率图用作展示存放在一个临时文件备用
+ (void)top_createMidCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath {
    NSData *coverImg = [NSData dataWithContentsOfFile:coverImagePath];
    if (!coverImg.length) {//没有缩略图
        NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *oriImg = [UIImage imageWithContentsOfFile:imagePath];
        CGFloat sizeWidth = oriImg.size.width / 2;
        if (imgData) {
            UIImage *showImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(sizeWidth, oriImg.size.height / 2)];
            [TOPDocumentHelper top_saveImage:showImg atPath:coverImagePath];
        } else {
            if (imagePath == nil) {
                imagePath = @"";
            }
            [FIRAnalytics logEventWithName:@"DataHandler_createCoverImage" parameters:@{@"path":imagePath}];
        }
    }
}

#pragma mark -- 生成一张缩率图用作展示存放在一个临时文件备用
+ (void)top_createCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath {
    NSData *coverImg = [NSData dataWithContentsOfFile:coverImagePath];
    if (!coverImg.length) {//没有缩略图
        NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat sizeWidth = TOPScreenWidth / 2;
        if (imgData) {
            UIImage *showImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(sizeWidth * scale, sizeWidth * scale)];
            [TOPDocumentHelper top_saveImage:showImg atPath:coverImagePath];
        } else {
            if (imagePath == nil) {
                imagePath = @"";
            }
            [FIRAnalytics logEventWithName:@"DataHandler_createCoverImage" parameters:@{@"path":imagePath}];
        }
    }
}

+ (void)top_getCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath complete:(void (^)(NSString * _Nonnull))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_createCoverImage:imagePath atPath:coverImagePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(imagePath);
            }
        });
    });
}

#pragma mark --
+ (void)top_updateCoverImage:(NSString *)imagePath atPath:(NSString *)coverImagePath {
    NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat sizeWidth = TOPScreenWidth / 2;
    if (imgData) {
        UIImage *showImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(sizeWidth * scale, sizeWidth * scale)];
        [TOPDocumentHelper top_saveImage:showImg atPath:coverImagePath];
    } else {
        if (imagePath == nil) {
            imagePath = @"";
        }
        [FIRAnalytics logEventWithName:@"DataHandler_createCoverImage" parameters:@{@"path":imagePath}];
    }
}

+ (NSArray *)ocrLanguageType{
    NSArray * lanArray = @[@{@"Arabic - ara":@"ara"},@{@"Bulgarian - bul":@"bul"},@{@"Chinese(Simplified) - chs":@""},@{@"Chinese(Traditional) - cht":@""},@{@"Croatian - hrv":@""},@{@"Czech - cze":@""},@{@"Danish - dan":@""},@{@"Dutch - dut":@""},@{@"English - eng":@""},@{@"Finnish - fin":@""},@{@"French - fre":@""},@{@"German - ger":@""},@{@"Greek - gre":@""},@{@"Hungarian - hun":@""},@{@"Korean - ko":@""},@{@"Italian - ita":@""},@{@"Japanese - jpn":@""},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{},@{}];
    return lanArray;
}

#pragma mark -- 选中的图片
+ (NSArray *)top_selectedImageArray:(NSArray *)selectFiles {
    NSMutableArray * imgArray = [[NSMutableArray alloc] init];
    for (DocumentModel * model in selectFiles) {
        NSArray *images = @[];
        if ([model.type isEqualToString:@"0"]) {//folder下的图片
            images = [TOPDocumentHelper top_getAllJPEGFileForDeep:model.path];
        }
        if ([model.type isEqualToString:@"1"]) {//doc下的图片
            images = [TOPDocumentHelper top_sortPicsAtPath:model.path];
        }
        for (NSString *content in images) {
            NSString *imgPath = [model.path stringByAppendingPathComponent:content];
            UIImage * img = [UIImage imageWithContentsOfFile:imgPath];
            if (img) {
                [imgArray addObject:img];
            }
        }
    }
    return imgArray;
}

+ (CGRect)top_adaptiveBGImage:(UIImage *)image fatherW:(CGFloat)fatherWidth fatherH:(CGFloat)fatherHeight{
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    if  (imageTy.size.width/imageTy.size.height >= fatherWidth/fatherHeight) {
        imgWidth = fatherWidth;
        imgHeight = imgWidth / imageTy.size.width * imageTy.size.height;
    } else {
        imgHeight = fatherHeight;
        imgWidth = imgHeight / imageTy.size.height * imageTy.size.width;
    }
    return CGRectMake((fatherWidth-imgWidth)/2, (fatherHeight-imgHeight)/2, imgWidth, imgHeight);
}

#pragma mark -- 坐标点转换 准备存入数据库
+ (NSMutableArray *)top_pointsFromModel:(TOPSaveElementModel *)elementModel {
    NSMutableArray *points = @[].mutableCopy;
    CGPoint sizePot = CGPointMake(elementModel.saveW, elementModel.saveH);
    [points addObject:NSStringFromCGPoint(sizePot)];
    for (NSValue *potVal in elementModel.pointArray) {//需要转成字符串才能写入数据库
        NSString *pot = NSStringFromCGPoint(potVal.CGPointValue);
        [points addObject:pot];
    }
    return points;
}

///图片自动裁剪时需要保存的坐标数据
+ (TOPSaveElementModel *)top_getBatchSavePointData:(NSArray *)pointArray imgPath:(nonnull NSString *)originalPath imgRect:(CGRect)imgRect{
    UIImage * img = [UIImage imageWithContentsOfFile:originalPath];
    TOPSaveElementModel * saveModel = [self top_getBatchSavePointData:pointArray img:img imgRect:imgRect];
    return saveModel;
}

///图片自动裁剪时需要保存的坐标数据
+ (TOPSaveElementModel *)top_getBatchSavePointData:(NSArray *)pointArray img:(UIImage *)originalImg imgRect:(CGRect)imgRect{
    if (!pointArray.count) {//防闪退保护，如果没有数据，则用顶点
        if (DEBUG) {
            [NSException raise:@"异常的源数据" format:@"源数据不能为空"];
        }
        pointArray = [self top_apexPointsWithImageViewRect:imgRect];
    }
    UIImage * img = originalImg;//展示图
    NSMutableArray * tempArray = [NSMutableArray new];
    CGPoint point0 = [(NSValue *)pointArray[0] CGPointValue];
    CGPoint point1 = [(NSValue *)pointArray[1] CGPointValue];
    CGPoint point2 = [(NSValue *)pointArray[2] CGPointValue];
    CGPoint point3 = [(NSValue *)pointArray[3] CGPointValue];
    
    CGFloat topWidth = [TOPDocumentHelper top_distanceBetweenPoints:point0 :point1];
    CGFloat bottomWidth = [TOPDocumentHelper top_distanceBetweenPoints:point3 :point2];
    CGFloat leftHeight = [TOPDocumentHelper top_distanceBetweenPoints:point0 :point3];
    CGFloat rightHeight = [TOPDocumentHelper top_distanceBetweenPoints:point1 :point2];
    CGFloat newWidth = MAX(topWidth, bottomWidth);
    CGFloat newHeight = MAX(leftHeight, rightHeight);
    CGFloat widthScale = img.size.width/imgRect.size.width;
    CGFloat heightScale = img.size.height/imgRect.size.height;
    
    for (NSValue *pVal in pointArray) {
        CGPoint point = pVal.CGPointValue;
        CGPoint cropViewPoint = CGPointMake((point.x * widthScale), (point.y * heightScale));
        [tempArray addObject:[NSValue valueWithCGPoint:cropViewPoint]];
    }
    TOPSaveElementModel * saveModel = [TOPSaveElementModel new];
    saveModel.saveW = newWidth*widthScale;
    saveModel.saveH = newHeight*widthScale;
    saveModel.originalImage = img;
    saveModel.pointArray = tempArray;
    return saveModel;
}

#pragma mark -- 裁剪图的四个顶点坐标
+ (NSMutableArray *)top_apexPointsWithImageViewRect:(CGRect)imgRect {
    NSMutableArray * apexArray = @[].mutableCopy;
    //保存四个顶点坐标
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, 0)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, imgRect.size.height)]];
    [apexArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, imgRect.size.height)]];
    return apexArray;
}

#pragma mark -- 校验手动裁剪坐标和自动裁剪坐标是否相同
+ (BOOL)top_pointEqual:(NSString *)imageId {
    TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:imageId];
    NSData *data;
    NSData *autoData;
    UIDeviceOrientation faceOr = [[UIDevice currentDevice] orientation];
    if (faceOr == UIDeviceOrientationLandscapeLeft || faceOr == UIDeviceOrientationLandscapeRight) {
        data = imgFile.landscapePoints;
        autoData = imgFile.autoLandscapePoints;
    } else {//当前设备是竖向,就取竖向的点
        data = imgFile.portraitPoints;
        autoData = imgFile.atuoPortraitPoints;
    }
    if (!data || !autoData) {//如果有一个坐标没有数据，那就共用同一套坐标数据
        return YES;
    }
    NSArray *points = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSArray *autoPoints = [NSJSONSerialization JSONObjectWithData:autoData options:NSJSONReadingMutableLeaves error:nil];
    return [self top_comparePointsIsEqual:points withOtherPoints:autoPoints];
}

+ (BOOL)top_comparePointsIsEqual:(NSArray *)points withOtherPoints:(NSArray *)autoPoints {
    if (points.count != autoPoints.count) {
        return NO;
    }
    for (int i = 0; i < points.count; i++) {
        NSString *pStr = points[i];
        CGPoint point = CGPointFromString(pStr);
        if (i < autoPoints.count) {
            NSString *atPStr = autoPoints[i];
            CGPoint atPoint = CGPointFromString(atPStr);
            if (point.x != atPoint.x || point.y != atPoint.y) {
                return NO;
            }
        }
    }
    return YES;
}

+ (BOOL)top_compareArray:(NSMutableArray *)array1 withArray:(NSMutableArray *)array2{
    NSSet * set1 = [NSSet setWithArray:[array1 copy]];
    NSSet * set2 = [NSSet setWithArray:[array2 copy]];
    if ([set1 isEqualToSet:set2]) {
        return NO;
    }
    return YES;
}

#pragma mark -- 读取功能权限配置文件
+ (NSDictionary *)top_readPermissionJsonFile {
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SSVipPermission" ofType:@"json"]];
    NSDictionary *config = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    return config;
}

+ (NSString *)top_permissionKey:(TOPPermissionType)type {
    NSDictionary *vipKeys = @{@(TOPPermissionTypeAdvertising):    @"Advertising",
                              @(TOPPermissionTypeOCROnline):      @"OcrOnline",
                              @(TOPPermissionTypeCollageSave):    @"CollageSave",
                              @(TOPPermissionTypePDFWaterMark):   @"PDFWaterMark",
                              @(TOPPermissionTypePDFSignature):   @"PDFSignature",
                              @(TOPPermissionTypePDFPageNO):      @"PDFPageNO",
                              @(TOPPermissionTypePDFPassword):    @"PDFPassword",
                              @(TOPPermissionTypeEmailMySelf):    @"EmailMySelf",
                              @(TOPPermissionTypeImageSign):      @"ImageSign",
                              @(TOPPermissionTypeImageGraffiti):  @"ImageGraffiti",
                              @(TOPPermissionTypeImageHigh):      @"ImageHigh",
                              @(TOPPermissionTypeImageSuperHigh): @"ImageSuperHigh",
                              @(TOPPermissionTypeCreateFolder):   @"CreateFolder",
                              @(TOPPermissionTypeUploadFile):     @"UploadFile",
                            };
    NSString *theKey = vipKeys[@(type)];
    return theKey;
}

+ (void)top_configPermissionJsonFile {
    NSDictionary *vipDic = @{[self top_permissionKey:TOPPermissionTypeOCROnline]: @{@"vip" : @(1),
                                                                             @"old" : @(0)},
                             [self top_permissionKey:TOPPermissionTypeCollageSave]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypePDFWaterMark]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypePDFSignature]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypePDFPageNO]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypePDFPassword]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypeEmailMySelf]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypeImageSign]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypeImageGraffiti]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypeImageHigh]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypeImageSuperHigh]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypeAdvertising]: @{@"vip" : @(1),
                                                                             @"old" : @(0)},
                             [self top_permissionKey:TOPPermissionTypeCreateFolder]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                             [self top_permissionKey:TOPPermissionTypeUploadFile]: @{@"vip" : @(1),
                                                                             @"old" : @(1)},
                            };
    [self writeFileWithJson:vipDic];
}

+ (void)writeFileWithJson:(NSDictionary *)dic {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    //写入路径
    NSString *cachePatch = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *fileName = @"SSVipPermission";
    NSString *filePath = [cachePatch stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",fileName]];
    //将路径转换为本地url形式
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    //writeToURL 的好处是，既可以写入本地url也可以写入远程url，苹果推荐使用此方法写入文件
    [jsonString writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
