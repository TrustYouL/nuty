#import "TOPHomeModel.h"

@implementation TOPHomeModel
+(NSDictionary*)mj_objectClassInArray{
    return @{@"folderList": @"FolderModel"};
}
@end
@implementation  DocumentModel

- (NSString *)originalImagePath {
    NSString * imageUrl = self.path;
    //带后缀的图片名
    NSString * imgName = [TOPWHCFileManager top_fileNameAtPath:imageUrl suffix:YES];
    //拼接成原图片的图片名
    NSString *sourceFileName =  [NSString stringWithFormat:@"%@%@",TOPRSimpleScanOriginalString,imgName];
    //拼接成原图片的路径
    _originalImagePath = [NSString stringWithFormat:@"%@/%@",self.movePath,sourceFileName];
    return _originalImagePath;
}

@end
