#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPScannerHttpRequest;

typedef void (^httpRequestSuccess)(TOPScannerHttpRequest* manager,id responObj , int status);
typedef void (^httpRequestFailure)(TOPScannerHttpRequest* manager,NSError* error);

@interface TOPScannerHttpRequest : NSObject
+(instancetype)shareManager;
- (void)top_GetNetDataWith:(NSString*)str withDic:(NSDictionary*)dic andSuccess:(void(^)(NSDictionary* dictionary))successBlock  andFailure:(void(^)(void))failueBlock;

- (void)top_PostNetDataWith:(NSString *)url withDic:(NSDictionary *)params andSuccess:(void (^)(NSDictionary * _Nonnull responseObject))successBlock andFailure:(void (^)(NSError * error))failueBlock;
- (void)top_tryConnectGoogle;
- (void)top_loadWanleFinishState;
@end

NS_ASSUME_NONNULL_END
