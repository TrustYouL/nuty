

#import "TOPInAppStoreManager.h"

@interface TOPInAppStoreManager ()<SKProductsRequestDelegate, SKRequestDelegate>

@end

@implementation TOPInAppStoreManager

#pragma mark -- 单例初始化
+ (instancetype)shareInstance {
    static TOPInAppStoreManager *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPInAppStoreManager alloc] init];
    });
    return singleTon;
}


#pragma mark -- 开始获取商品
- (void)topstartProductRequestWithIdentifiers:(NSArray *)identifiers {
    [self topFetchProducts:identifiers];
}

#pragma mark -- 从App Store获取产品信息
- (void)topFetchProducts:(NSArray *)identifiers {
    NSSet *productIdentifiers = [NSSet setWithArray:identifiers];
    self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productRequest.delegate = self;
    [self.productRequest start];
}

#pragma mark -- SKProductsRequestDelegate
#pragma mark -- 商品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (self.storeResponse.count) {
        [self.storeResponse removeAllObjects];
    }
    if (response.invalidProductIdentifiers.count) {
        self.invalidProductIdentifiers = response.invalidProductIdentifiers;
    }
    if (response.products.count) {
        self.availableProducts = response.products;
        [self.storeResponse addObject:@{@"type":@"availableProducts", @"elements":self.availableProducts}];
        [self managerReceiveResponse:self.storeResponse];
    } else {//没有可用商品
        [self managerReceiveMessage:InAppNoProducts];
    }
}

#pragma mark -- SKRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self managerReceiveMessage:[error localizedDescription]];
}

- (void)managerReceiveResponse:(id)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(topStoreManagerDidReceiveResponse:)]) {
            [self.delegate topStoreManagerDidReceiveResponse:response];
        }
    });
}

- (void)managerReceiveMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(topStoreManagerDidReceiveMessage:)]) {
            [self.delegate topStoreManagerDidReceiveMessage:msg];
        }
    });
}

#pragma mark --  产品类型 OCR点数、订阅 ...
- (NSString *)topProductType:(NSString *)productIdentifier {
    NSDictionary *detailDic = self.localProductList[@"ProductDetail"];
    NSDictionary *proDic = detailDic[productIdentifier];
    NSString *type = proDic[@"type"];
    return type;
}

#pragma mark -- 所有订阅id
- (NSArray *)topSubscriptionsKeyList {
    NSArray *subs = self.localProductList[@"Subscriptions"];
    return subs;
}

#pragma mark -- 所有消耗品id
- (NSArray *)topConsumablesKeyList {
    NSArray *cons = self.localProductList[@"Consumables"];
    return cons;
}

#pragma mark -- -  订阅产品的周期单位：按年或月...
- (NSString *)topProductPeriodUnit:(NSString *)productIdentifier {
    NSDictionary *detailDic = self.localProductList[@"ProductDetail"];
    NSDictionary *proDic = detailDic[productIdentifier];
    NSString *unit = proDic[@"periodUnit"];
    return unit;
}

#pragma mark -- lazy
- (NSMutableArray *)storeResponse {
    if (!_storeResponse) {
        _storeResponse = @[].mutableCopy;
    }
    return _storeResponse;
}

- (NSDictionary *)localProductList {
    if (!_localProductList) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TOPSKProductList" ofType:@"plist"];
        NSDictionary *proDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        _localProductList = proDic;
    }
    return _localProductList;
}


@end
