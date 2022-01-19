#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPActionExtensionHandler : NSObject

//解析action Extension的共享数据
+ (void)top_parsingDataSuccess:(void (^)(NSMutableArray *dataArr, NSString *filePath))success;

//解析共享数据 返回DocumentModel模型数据
+ (void)top_parsingDataBuildModelsSuccess:(void (^)(NSMutableArray *dataArr, NSString *filePath))success;

@end

NS_ASSUME_NONNULL_END
