
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPNetWorkManager : NSObject

+(void)topPostRequestWithUrl:(NSString *)url Param:(NSDictionary *)param
                  success:(void (^)(NSDictionary * res))success
                  failure:(void (^)(NSError *error))failure;
   
+(void)topGetRequestWithUrl:(NSString *)url Param:(NSDictionary *)param
                 success:(void (^)(NSDictionary * res))success
                 failure:(void (^)(NSError *error))failure;
+ (void)topDownloadFileWithUrl:(NSString *)url
         progress:(void(^)(NSProgress * _Nonnull downloadProgress))progress
completionHandler:(void(^)(NSString * _Nullable filePath))completionHandler;
+ (void)topReachabilityNewWorkStatusBlock:(void (^)(BOOL isOnline))statusBlock;
+ (BOOL)topJudgeNetwork;
+ (void)topFetchGoogleTimeSuccess:(void (^)(NSTimeInterval time))success;

@end

NS_ASSUME_NONNULL_END
