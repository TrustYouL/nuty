#import "TOPScannerHttpRequest.h"
#define RequestTimeoutInterval 60.0
@implementation TOPScannerHttpRequest
+(instancetype)shareManager{
    static TOPScannerHttpRequest* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TOPScannerHttpRequest alloc]init];
    });
    return manager;
}

- (void)top_GetNetDataWith:(NSString *)str withDic:(NSDictionary *)dic andSuccess:(void (^)(NSDictionary * _Nonnull))successBlock andFailure:(void (^)(void))failueBlock{
    AFHTTPSessionManager *netManager = [AFHTTPSessionManager manager];
    netManager.responseSerializer    = [AFHTTPResponseSerializer serializer];
    netManager.requestSerializer.timeoutInterval= RequestTimeoutInterval;
    
    AFHTTPRequestSerializer *requestSerializer =  [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"5" forHTTPHeaderField:@"appType"];
    [requestSerializer setValue:[TOPDocumentHelper top_getCurrentSecondTimeInterval] forHTTPHeaderField:@"requestTime"];
    [requestSerializer setValue:[TOPAppTools getAppVersion] forHTTPHeaderField:@"tongsoft-appVersion"];
    [requestSerializer setValue:[TOPAppTools SystemVersion] forHTTPHeaderField:@"systemVersion"];
    [requestSerializer setValue:[TOPAppTools deviceVersion] forHTTPHeaderField:@"phoneModel"];

    netManager.requestSerializer = requestSerializer;
    [netManager GET:str parameters:dic headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary*dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"responseObject==%@",dic);
        if (successBlock) {
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failueBlock) {
            failueBlock();
        }
    }];
}
- (void)top_PostNetDataWith:(NSString *)url withDic:(NSDictionary *)params andSuccess:(void (^)(NSDictionary * _Nonnull responseObject))successBlock andFailure:(void (^)(NSError * error))failueBlock
{
    
    // 1.获得请求管理者
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer    = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval= RequestTimeoutInterval;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/html", nil];

    if (!url) url = @"";
    // 创建POST请求
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary:@{@"tongsoft-appversion":[TOPAppTools getAppVersion],@"systemversion":[TOPAppTools SystemVersion],@"appType":@"5",@"requestTime":[TOPDocumentHelper top_getCurrentSecondTimeInterval],@"phoneModel":[TOPAppTools deviceVersion]}];


    [manager POST:url parameters:params headers:headerDic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary*dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];

        if (successBlock) {
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failueBlock) {
            failueBlock(error);
        }
    }];
}



#pragma mark -- 测试是否可以连接Google
- (void)top_tryConnectGoogle {
    NSString *urlString = @"https://www.google.com";
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:5];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (response) {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {//请求成功
                NSString *date = [[httpResponse allHeaderFields] objectForKey:@"Date"];
                now = [self googleTimeInterval:date];
                [TOPScanerShare top_writeSaveGoogleConnection:YES];
            } else {
                [TOPScanerShare top_writeSaveGoogleConnection:NO];
            }
        } else {
            [TOPScanerShare top_writeSaveGoogleConnection:NO];
        }
    }];
    [task resume];
}

- (NSTimeInterval)googleTimeInterval:(NSString *)date {
    date = [date substringFromIndex:5];
    date = [date substringToIndex:[date length]-4];
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    NSTimeInterval now = [netDate timeIntervalSince1970];
    return now;
}

#pragma mark -- Google识别的限制
- (void)top_loadWanleFinishState{
    NSString * urlString = @"https://www.tongsoft.top/OCR/GG_USABLE";
    [self top_GetNetDataWith:urlString withDic:@{} andSuccess:^(NSDictionary * _Nonnull dictionary) {
        NSString * statuString = [NSString stringWithFormat:@"%@",dictionary[@"status"]];
        if ([statuString isEqualToString:@"1"]) {
            NSDictionary * dataDic = dictionary[@"data"];
            NSString * dicCount = [NSString stringWithFormat:@"%@",dataDic[@"GG_USABLE"]];
            [TOPScanerShare top_writeSaveWlanFinish:dicCount];
        }
        if ([statuString isEqualToString:@"0"]) {
            [TOPScanerShare top_writeSaveWlanFinish:@"0"];
        }
    } andFailure:^{
        [TOPScanerShare top_writeSaveWlanFinish:@"0"];
    }];
}

@end
