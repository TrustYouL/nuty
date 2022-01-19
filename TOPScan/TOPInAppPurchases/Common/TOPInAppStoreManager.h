
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "TOPStoreManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPInAppStoreManager : NSObject

/// -- 单例初始化
+ (instancetype)shareInstance;
@property (nonatomic, copy) NSDictionary *localProductList;//所有内购产品信息(TOPSKProductList.plist)
@property (nonatomic, copy) NSArray<SKProduct *> *availableProducts;//有效商品
@property (nonatomic, copy) NSArray<NSString *> *invalidProductIdentifiers;//失效商品id
@property (nonatomic, strong) NSMutableArray *storeResponse;//回调数据
@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, weak) id<TOPStoreManagerProtocol> delegate;

/// -- 开始获取商品 identifiers：商品id -- 本地写死
- (void)topstartProductRequestWithIdentifiers:(NSArray *)identifiers;
/// --  订阅产品的周期单位：按年或月...
- (NSString *)topProductPeriodUnit:(NSString *)productIdentifier;
/// -- 所有订阅id
- (NSArray *)topSubscriptionsKeyList;
/// -- 所有消耗品id
- (NSArray *)topConsumablesKeyList;
/// -- 产品类型  OCR点数、订阅 ...
- (NSString *)topProductType:(NSString *)productIdentifier;

@end

NS_ASSUME_NONNULL_END
