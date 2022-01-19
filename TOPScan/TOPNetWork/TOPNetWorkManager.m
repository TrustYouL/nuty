
#import "TOPNetWorkManager.h"
#import <AFNetworking/AFNetworking.h>

#define SSRequestTimeoutInterval 60.0

static NSString *prodUrlDomain = @"https://simplescanner.tongsoft.top";//pro
static NSString *testUrlDomain = @"https://9717-184-169-168-250.ngrok.io";//@"https://www.tongsoft.top";//test

static NSString *NET_HEADER_APP_CODE = @"app-code";
static NSString *NET_HEADER_APP_VERSION = @"tongsoft-app-version";
static NSString *NET_HEADER_APP_TYPE = @"app-type";
static NSString *NET_HEADER_REQUEST_TIME = @"request-time";
static NSString *NET_HEADER_DEVICES_SYSTEM = @"system-version";
static NSString *NET_HEADER_PHONE_MODEL = @"phone-model";
static NSString *NET_HEADER_USE_ID = @"uu-id";
static NSString *NET_HEADER_DEVICES_ID = @"device-id";

@implementation TOPNetWorkManager

#pragma mark -- 检测主工程当前环境 模块切换与之对应的环境
+ (NSString *)checkEnvironment {
    NSInteger envi = 0;
    if (DEBUG) {
        envi = 2;
    } else {
        envi = 1;
    }
    NSString *taCornerUrlDomain = envi == 1 ? prodUrlDomain : testUrlDomain;
    [[NSUserDefaults standardUserDefaults] setInteger:envi forKey:@"TACornerEnvironment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return taCornerUrlDomain;
}

+ (void)topPostRequestWithUrl:(NSString *)url Param:(NSDictionary *)param success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSString *requestUrl = [self wholeRequestUrlWithPath:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self configResponseSerializer:manager];
    [manager POST:requestUrl parameters:param headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSInteger respenseCode = [[NSString stringWithFormat:@"%@",JSON[@"status"]] integerValue];
        if (respenseCode == 1) {
            NSMutableDictionary *resData = [JSON[@"data"] mutableCopy];
            NSTimeInterval timeInter = [JSON[@"currentTimeMillis"] doubleValue];
            if (timeInter > 0) {
                [resData setValue:@(timeInter) forKey:@"currentTimeMillis"];
            }
            if (success) {
                success(resData);
            }
        } else {
            if (failure) {
                NSError * newError = [[NSError alloc]initWithDomain:@"vip.service.error" code:[JSON[@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey :  JSON[@"message"], @"statusCode": [NSString stringWithFormat:@"%@", JSON[@"code"]]}];
                failure(newError);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            NSHTTPURLResponse * reponse = (NSHTTPURLResponse *)task.response;
            NSError * newError = [self definNewWorkErrorWithError:error statusCode:reponse.statusCode];
            failure(newError);
        }
    }];
}

+ (void)topGetRequestWithUrl:(NSString *)url Param:(NSDictionary *)param success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSString *requestUrl = [self wholeRequestUrlWithPath:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self configResponseSerializer:manager];
    [manager GET:requestUrl parameters:param headers:@{} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSInteger respenseCode = [[NSString stringWithFormat:@"%@",JSON[@"status"]] integerValue];
        if (respenseCode == 1) {
            NSDictionary *resData = JSON[@"data"];
            if (success) {
                success(resData);
            }
        } else {
            if (failure) {
                NSError * newError = [[NSError alloc]initWithDomain:@"vip.service.error" code:[JSON[@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey :  JSON[@"message"], @"statusCode": [NSString stringWithFormat:@"%@", JSON[@"code"]]}];
                failure(newError);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            NSHTTPURLResponse * reponse = (NSHTTPURLResponse *)task.response;
            NSError * newError = [self definNewWorkErrorWithError:error statusCode:reponse.statusCode];
            failure(newError);
        }
    }];
}

+ (void)topDownloadFileWithUrl:(NSString *)url
                   progress:(nonnull void (^)(NSProgress * _Nonnull))progress
          completionHandler:(nonnull void (^)(NSString * _Nullable))completionHandler {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDownloadTask *downTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *fullPaht = @"";
        return [NSURL fileURLWithPath:fullPaht];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
        } else {
            NSString *originFilePath = [filePath path];
            if (completionHandler) {
                completionHandler(originFilePath);
            }
        }
    }];
    [downTask resume];
}

#pragma mark - Private
+ (NSString *)wholeRequestUrlWithPath:(NSString *)urlPath {
    NSString *domainStr = [self checkEnvironment];
    if ([urlPath hasPrefix:@"/"]) {
        return [NSString stringWithFormat:@"%@%@",domainStr,urlPath];
    }
    else
        return [NSString stringWithFormat:@"%@/%@",domainStr,urlPath];
}

+ (void)configResponseSerializer:(AFHTTPSessionManager *)manager {
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[TOPAppTools getAppVersion] forHTTPHeaderField:NET_HEADER_APP_CODE];
    [manager.requestSerializer setValue:[TOPAppTools getAppVersion] forHTTPHeaderField:NET_HEADER_APP_VERSION];
    [manager.requestSerializer setValue:AppType_SimpleScan forHTTPHeaderField:NET_HEADER_APP_TYPE];
    [manager.requestSerializer setValue:[TOPDocumentHelper top_getCurrentSecondTimeInterval] forHTTPHeaderField:NET_HEADER_REQUEST_TIME];
    [manager.requestSerializer setValue:[TOPAppTools SystemVersion] forHTTPHeaderField:NET_HEADER_DEVICES_SYSTEM];
    [manager.requestSerializer setValue:[TOPAppTools deviceVersion] forHTTPHeaderField:NET_HEADER_PHONE_MODEL];
    if ([TOPSubscriptTools googleLoginStates]) {
        NSString *userId = [FIRAuth auth].currentUser.uid;
        [manager.requestSerializer setValue:userId forHTTPHeaderField:NET_HEADER_USE_ID];
    }
    [manager.requestSerializer setValue:[TOPUUID top_getUUID] forHTTPHeaderField:NET_HEADER_DEVICES_ID];
    manager.requestSerializer.timeoutInterval = SSRequestTimeoutInterval;
}

+ (NSError *)definNewWorkErrorWithError:(NSError *)error statusCode:(NSInteger)code {
    NSString * msg = @"";
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableLeaves error:&error];
        if ([jsonData isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resDic = (NSDictionary *)jsonData;
            msg = [resDic objectForKey:@"msg"];
            
        }
    }
    if (!msg.length && (error.code == -1001)) {
        msg = @"网络请求超时";
    } else if (!msg.length && ![self topJudgeNetwork]) {
        msg = @"网络不可用，请查看网络设置";
    } else if (!msg.length) {
        msg = @"网络请求失败";
    }
    return [[NSError alloc]initWithDomain:@"vip.service.error" code:code userInfo:@{NSLocalizedDescriptionKey : msg, @"statusCode": [NSString stringWithFormat:@"%ld", error.code]}];
}

+ (BOOL)topJudgeNetwork {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    if (manager.reachable) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -- 监听网络转态
+ (void)topReachabilityNewWorkStatusBlock:(void (^)(BOOL))statusBlock {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        BOOL isOnline = YES;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                isOnline = NO;
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                isOnline = NO;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                isOnline = YES;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                isOnline = YES;
                break;
        }
        if (statusBlock) {
            statusBlock(isOnline);
        }
        NSDictionary *info = @{@"status" : @(isOnline)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SSNetWorkConnectStatusNotification" object:self userInfo:info];
    }];
    [manager startMonitoring];
}

+ (void)topFetchGoogleTimeSuccess:(void (^)(NSTimeInterval))success {
    NSString *urlString = @"https://www.google.com";
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:3];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (response) {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                NSString *date = [[httpResponse allHeaderFields] objectForKey:@"Date"];
                now = [self googleTimeInterval:date];
                [TOPScanerShare top_writeSaveGoogleConnection:YES];
            } else {
                [TOPScanerShare top_writeSaveGoogleConnection:NO];
            }
        } else {
            [TOPScanerShare top_writeSaveGoogleConnection:NO];
        }
        if (success) {
            success(now);
        }
    }];
    [task resume];
}

+ (NSTimeInterval)googleTimeInterval:(NSString *)date {
    date = [date substringFromIndex:5];
    date = [date substringToIndex:[date length]-4];
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    NSTimeInterval now = [netDate timeIntervalSince1970];
    return now;
}

@end
