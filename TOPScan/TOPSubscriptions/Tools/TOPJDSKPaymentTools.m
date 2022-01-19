

#import "TOPJDSKPaymentTools.h"
#import "TOPFreeBaseSqliteTools.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "TOPSandBoxHelper.h"
#import "TOPPurchasepayModel.h"
#import "TOPPurchaseValidationHandler.h"

static NSString * const receiptKey = @"receipt_data";
static NSString * const dateKey = @"date_key";
static NSString * const userIdKey = @"userid";
static NSString * const countMoney = @"order_amount";
static NSString * const orderKey = @"orderId";
static NSString * const productId = @"product_id";
static NSString * const transactionIdentID = @"transaction_id";
static NSString * const original_transaction_id = @"original_transaction_id";

dispatch_queue_t iap_queue() {
    static dispatch_queue_t as_iap_queue;
    static dispatch_once_t onceToken_iap_queue;
    dispatch_once(&onceToken_iap_queue, ^{
        as_iap_queue = dispatch_queue_create("com.iap.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_iap_queue;
}

@interface TOPJDSKPaymentTools() <SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (nonatomic, copy) NSString *receipt; //交易成功后拿到的一个64编码字符串
@property (nonatomic, copy) NSString *date; //交易时间
@property (nonatomic, copy) NSString *userid; //交易人
//是否正在校验
@property (nonatomic, assign) BOOL isVerifications;
/*
 商品Key ID
 */
@property (nonatomic,copy) NSString * commodityCode;
/*
 金额
 */
@property (nonatomic, copy) NSString *moneyCount;
/** 当前请求的商品请求 */
@property (nonatomic,strong) SKProductsRequest *productRequest;
/** 当前请求的商品请求 */
@property (nonatomic,strong) NSMutableArray *restoreMutableArrays;
/**
 *请求订单号的次数
 *
 **/
@property (nonatomic, assign) NSInteger requestOrderNumber;
/**
 *取消请求订单号的次数
 *
 **/
@property (nonatomic, assign) NSInteger requestCancelOrderNumber;
/**
 *与服务器校验次数
 *
 **/
@property (nonatomic, assign) NSInteger verifyNumber;
/**
 *与服务器校验次数22
 *
 **/
@property (nonatomic, assign) NSInteger dingyueverifyNumber;
/**
 *交易的订单id 从服务器获取
 *有未完成的订单则从本地获取再次与服务器验证
 **/
@property (nonatomic, copy) NSString *orderID;
/**
 当前订阅的Model数据
 **/
@property (nonatomic, strong) TOPPurchasepayModel *numberbuyInfoModel;
@end
@implementation TOPJDSKPaymentTools
+ (instancetype)shareInstance {
    static  TOPJDSKPaymentTools *skTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        skTool = [[TOPJDSKPaymentTools alloc] init];
    });
    return skTool;
}
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    [self.restoreMutableArrays removeAllObjects];
    self.restoreMutableArrays = [NSMutableArray array];
    for(SKPaymentTransaction *tran in transaction){
        NSLog(@"SKPaymentTransactionObserver -- observer = %@",tran.transactionIdentifier);
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                if ([_delegate respondsToSelector:@selector(top_succeedWithsucceedCode:)]) {
                    [_delegate top_succeedWithsucceedCode:IAPSucceedCode_Succeed];
                }
                if (tran.originalTransaction) {//自动订阅续费
                    NSLog(@"tran.originalTransaction--------%@---===>>>>%@",tran.originalTransaction.transactionIdentifier,tran.payment.productIdentifier);
                }
                [self top_getReceipt:tran]; //获取交易成功后的购买凭证
                
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                //NSLog(@"商品添加进列表--------%@---",tran.transactionIdentifier);
                break;
            case SKPaymentTransactionStateRestored:{
                
                //NSLog(@"已经购买过商品------%@---%@",tran.transactionIdentifier,tran.mj_keyValues);
                if (tran.originalTransaction) {//自动订阅续费
                    [self.restoreMutableArrays addObject:tran];
                }
                [self restoreTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败");
                [SVProgressHUD dismiss];
                [self top_failedTransaction:tran];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark -- 数组排序
- (NSMutableArray *)soreCustomArray:(NSMutableArray *)temp  {
    //获取合成后的新文件下的所有文件 有显示图片和原始图片(original_)
    //排序,根据图片的后几位数字去排序
    NSArray *sortArray = [temp sortedArrayUsingComparator:^NSComparisonResult(SKPaymentTransaction *tempContentPath1, SKPaymentTransaction *tempContentPath2) {
        NSString *sortNO1 = [NSString stringWithFormat:@"%f",[tempContentPath1.transactionDate timeIntervalSince1970]*1000];
        NSString *sortNO2 =[NSString stringWithFormat:@"%f",[tempContentPath2.transactionDate timeIntervalSince1970]*1000];
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return [sortArray mutableCopy];
}
// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"%@",error);
    if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:andError:)]) {
        [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_RestoreFiled andError:nil];
    }
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (self.restoreMutableArrays.count) {
        self.restoreMutableArrays = [self soreCustomArray:self.restoreMutableArrays];
        NSMutableArray *endRestorArrays = [NSMutableArray array];
        WS(weakself);
        [endRestorArrays addObject:[self.restoreMutableArrays lastObject]];
        [self.restoreMutableArrays enumerateObjectsUsingBlock:^(SKPaymentTransaction *  _Nonnull tranObj, NSUInteger idx, BOOL * _Nonnull stop) {
            SKPaymentTransaction * lastTranObj = [weakself.restoreMutableArrays lastObject];
            if ([lastTranObj.originalTransaction.transactionIdentifier isEqualToString:tranObj.originalTransaction.transactionIdentifier]) {
                return;
            }
        }];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [endRestorArrays enumerateObjectsUsingBlock:^(SKPaymentTransaction *  _Nonnull tranObj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"最终需要恢复购买的数据-------%@",tranObj.mj_keyValues);
                [weakself top_restoreDingYueSendAppStoreRequestWith:tranObj withSemaphore:semaphore];
            }];
        });
    }else{
        if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:andError:)]) {
            [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_NORestoreData andError:nil];
        }
    }
}

// 提示账号过期
- (void)top_showCountTransactionFailure {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"topscan_tips", @"") message:NSLocalizedString(@"topscan_subscriptfailedtips", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"topscan_ok" ,@"") otherButtonTitles: nil];
    [alertView show];
    
}
- (void)top_startManager { //开启监听
    dispatch_async(iap_queue(), ^{
        /***
         内购支付两个阶段：
         1.app直接向苹果服务器请求商品，支付阶段；
         2.苹果服务器返回凭证，app向公司服务器发送验证，公司再向苹果服务器验证阶段；
         */
        /**
         阶段一正在进中,app退出。
         在程序启动时，设置监听，监听是否有未完成订单，有的话恢复订单。
         */
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        /**
         阶段二正在进行中,app退出。
         在程序启动时，检测本地是否有receipt文件，有的话，去二次验证。
         */
        [self top_checkIAPFilesType];
        TOPSubscriptModel *ocrModel = [TOPSubscriptTools getSubScriptData];
        if (ocrModel.original_transaction_id.length>0) {
            [self top_requestDingyueInfoWithDevice];
        }
        [[TOPFreeBaseSqliteTools sharedSingleton] openObserveGoogleFirebaseValue];
        
    });
}

- (void)top_stopManager{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    });
}

#pragma mark 开始购买
- (void)top_requestProductWithId:(NSString *)productId{
    if ([SKPaymentQueue canMakePayments]) { //用户允许app内购
        if (productId.length != 0) {
            self.commodityCode = productId;
            NSArray *product = [[NSArray alloc] initWithObjects:productId, nil];
            NSSet *set = [NSSet setWithArray:product];
            self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
            self.productRequest.delegate = self;
            [ self.productRequest start];
        } else {
            NSLog(@"商品为空");
            [SVProgressHUD dismiss];
            [self top_filedWithErrorCode:IAP_FILEDCOED_EMPTYGOODS error:nil];
        }
    } else { //没有权限
        [SVProgressHUD dismiss];
        [self top_filedWithErrorCode:IAP_FILEDCOED_NORIGHT error:nil];
    }
}
#pragma mark - SKProductsRequestDelegate
//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        NSLog(@"---------没有商品信息");
        [self top_filedWithErrorCode:IAP_FILEDCOED_CANNOTGETINFORMATION error:nil];
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"description:%@", [pro description]);
        NSLog(@"localizedTitle:%@", [pro localizedTitle]);
        NSLog(@"localizedDescription:%@", [pro localizedDescription]);
        NSLog(@"price:%@", [pro price]);
        NSLog(@"productIdentifier:%@", [pro productIdentifier]);
        if([pro.productIdentifier isEqualToString:self.commodityCode]){
            p = pro;
        }
    }
    [self top_takePayMent:p];
}

- (void)top_takePayMent:(SKProduct *)pro {
    if (@available(iOS 12.2, *)) {
        if (pro.discounts.count) {
            SKProductDiscount *proDiscount = pro.discounts.firstObject;
            NSDictionary *param = @{@"appBundleId": [TOPAppTools appBundleId],
                      @"productIdentifier": pro.productIdentifier,
                      @"offerIdentifier": proDiscount.identifier,
                      @"applicationUsername": [TOPAppTools hashedValueForAccountName:[TOPUUID top_getUUID]],
            };
            [TOPPurchaseValidationHandler topFetchOfferSignatureWithParam:param success:^(SKPaymentDiscount * _Nonnull payDiscount) {
                SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:pro];
                payment.applicationUsername =  self.orderID;
                payment.paymentDiscount = payDiscount;
                [[SKPaymentQueue defaultQueue] addPayment:payment];
            } failure:^(NSError * _Nonnull error) {
                [SVProgressHUD dismiss];
            }];
        } else {
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:pro];
            payment.applicationUsername =  self.orderID;
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    } else {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:pro];
        payment.applicationUsername =  self.orderID;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

#pragma mark -- 请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"------------------错误-----------------:%@", error);
    [self top_filedWithErrorCode:IAP_FILEDCOED_APPLECODE error:[error localizedDescription]];
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"------------反馈信息结束-----------------");
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)top_failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        [self top_filedWithErrorCode:IAP_FILEDCOED_BUYFILED error:nil];
    } else {
        [self top_filedWithErrorCode:IAP_FILEDCOED_USERCANCEL error:nil];
    }
    self.productRequest.delegate = nil;
    [self.productRequest cancel];
    self.productRequest = nil;
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark 恢复订阅
- (void)top_restoreSubscriptTransaction
{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    NSLog(@"开始恢复订阅请求");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
#pragma mark 获取交易成功后的购买凭证
- (void)top_getReceipt:(SKPaymentTransaction *)transaction {
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    self.receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (self.receipt.length != 0) {
        [self top_saveReceipt:transaction];
    }else{
        [self completeTransaction:transaction];
        if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:error:)]) {
            [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_parameterempty andError:nil];
        }
    }
}

#pragma mark  持久化存储用户购买凭证(这里最好还要存储当前日期，用户id等信息，用于区分不同的凭证)
-(void)top_saveReceipt:(SKPaymentTransaction *)transaction {
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@.plist", [TOPSandBoxHelper iapReceiptPath], transaction.transactionIdentifier];
    NSString *savedingyuePath = [NSString stringWithFormat:@"%@/%@.plist", [TOPSandBoxHelper iapReceiptDingYuePath], transaction.transactionIdentifier];
    if (transaction.originalTransaction) {
        savedingyuePath = [NSString stringWithFormat:@"%@/%@.plist", [TOPSandBoxHelper iapReceiptDingYuePath], transaction.originalTransaction.transactionIdentifier];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[receiptKey] = self.receipt;
    dic[dateKey] = [self top_getCurrentDateWithTransverseFormat];
    dic[productId] = transaction.payment.productIdentifier;
    dic[countMoney] = self.moneyCount;
    dic[transactionIdentID] = transaction.transactionIdentifier;
    if (transaction.originalTransaction) {
        dic[original_transaction_id] = transaction.originalTransaction.transactionIdentifier;
    }
    dic[userIdKey] = self.userid;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *receiveCreditArrays =  @[@"20210624_ocrpages_1",@"20210624_ocrpages_2"];
    if ([receiveCreditArrays containsObject:transaction.payment.productIdentifier]) {
        if (![fileManager fileExistsAtPath:savedPath])
        {
            [fileManager createFileAtPath:savedPath contents:nil attributes:nil];
            if ( [dic writeToFile:savedPath atomically:YES]) {
                NSLog(@"-----savePath->%@",savedPath);
                [self top_checkIAPFilesType];//把self.receipt发送到服务器验证是否有效
                [self completeTransaction:transaction];
            }
        }
        else
        {
            [self top_checkIAPFilesType];//把self.receipt发送到服务器验证是否有效
            [self completeTransaction:transaction];
        }
        
    }else{
        
        if ([fileManager fileExistsAtPath:[TOPSandBoxHelper iapReceiptDingYuePath]])
        {
            [self top_removeReceipt:[TOPSandBoxHelper iapReceiptDingYuePath]];
            [fileManager createDirectoryAtPath:[TOPSandBoxHelper iapReceiptDingYuePath] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if ([fileManager fileExistsAtPath:savedingyuePath])
        {
            [self top_removeReceipt:savedingyuePath];
        }
        if (![fileManager fileExistsAtPath:savedingyuePath])
        {
            [fileManager createFileAtPath:savedingyuePath contents:nil attributes:nil];
            if ( [dic writeToFile:savedingyuePath atomically:YES]) {
                NSLog(@"-----dingyueSavePath->%@",savedingyuePath);
                [self top_checkIAPFilesDingYueType];//把self.receipt发送到服务器验证是否有效
                [self completeTransaction:transaction];
            }
        }
        else
        {
            [self top_checkIAPFilesDingYueType];//把self.receipt发送到服务器验证是否有效
            [self completeTransaction:transaction];
        }
    }
}


#pragma mark 将存储到本地的IAP文件发送给服务端 验证receipt失败,App启动后再次验证
- (void)top_checkIAPFilesType{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //搜索该目录下的所有文件和目录
    NSArray *cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:[TOPSandBoxHelper iapReceiptPath] error:&error];
    if (error == nil) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSString *name in cacheFileNameArray) {
                if ([name hasSuffix:@".plist"]){ //如果有plist后缀的文件，说明就是存储的购买凭证
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [TOPSandBoxHelper iapReceiptPath], name];
                    [self top_sendAppStoreRequestBuyPlist:filePath withSemaphore:semaphore];
                }
            }
        });
        
    }else {
        NSLog(@"AppStoreInfoLocalFilePath error:%@", [error domain]);
    }
}

#pragma mark 将存储到本地的IAP文件发送给服务端 验证receipt失败,App启动后再次验证
- (void)top_checkIAPFilesDingYueType{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *cacheDingyueFileNameArray = [fileManager contentsOfDirectoryAtPath:[TOPSandBoxHelper iapReceiptDingYuePath] error:&error];
    if (error == nil) {
        if (self.isVerifications == YES) {
            return;
        }
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.isVerifications = YES;
            for (NSString *name in cacheDingyueFileNameArray) {
                if ([name hasSuffix:@".plist"]){ //如果有plist后缀的文件，说明就是存储的购买凭证
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [TOPSandBoxHelper iapReceiptDingYuePath], name];
                    [self top_dingyueSendAppStoreRequestBuyPlist:filePath withSemaphore:semaphore];
                }
            }
            self.isVerifications = NO;
        });
    }
}



- (void)top_sendAppStoreRequestBuyPlist:(NSString *)plistPath withSemaphore:(dispatch_semaphore_t )semaphore  {
    if (self.verifyNumber >= 5)
    {
        dispatch_semaphore_signal(semaphore);
        [SVProgressHUD dismiss];
        if ([_delegate respondsToSelector:@selector(top_filedWithErrorCode:error:)]) {
            [_delegate top_filedWithErrorCode:IAP_FILEDCOED_SERVERERROR andError:nil];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self top_showCountTransactionFailure];
        });
        return;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[receiptKey] = [dic objectForKey:receiptKey];
    params[transactionIdentID] =[dic objectForKey:transactionIdentID];
    params[@"deviceId"] =  [TOPUUID top_getUUID];
    params[@"bundle_id"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([TOPSubscriptTools googleLoginStates]) {
        params[@"userId"] = [FIRAuth auth].currentUser.uid;
    }
    params[@"appType"] = AppType_SimpleScan;
    NSLog(@"内购充值======>>>%@",params);
    [[TOPScannerHttpRequest shareManager] top_PostNetDataWith:TOP_TRBuyCreditsCheck withDic:params andSuccess:^(NSDictionary * _Nonnull responseObject) {
        dispatch_semaphore_signal(semaphore);
        NSInteger code = [responseObject[@"status"] integerValue];
        if (code == 1) {
            NSDictionary *resultRes = responseObject[@"data"];
            NSInteger resultType = [resultRes[@"resultType"] integerValue];
            switch (resultType) {
                case 0:
                {
                    NSInteger userCurrentBalance = [TOPSubscriptTools getCurrentUserBalance];
                    NSString * countCurrentIndex = @"200";
                    if ([resultRes.allKeys containsObject:@"product_id"]) {
                        NSString *product_id = resultRes[@"product_id"];
                        if ([product_id isEqualToString:@"20210624_ocrpages_1"]) {
                            userCurrentBalance = userCurrentBalance +200;
                            countCurrentIndex = @"200";
                        }else if ([product_id isEqualToString:@"20210624_ocrpages_2"])
                        {
                            userCurrentBalance = userCurrentBalance +1000;
                            countCurrentIndex = @"1000";
                        }
                    }
                    [TOPSubscriptTools saveWriteCurrentUserBalance:userCurrentBalance];
                    NSString * buyHistory = [NSString stringWithFormat:@"%@ADDDDDD ====%@==transactionIdentID:%@ iOS",[self top_getCurrentDateWithTransverseFormat],countCurrentIndex,resultRes[transactionIdentID]];
                    [[TOPFreeBaseSqliteTools sharedSingleton] setOcr_buyhistoryToServiceWith:buyHistory];
                    //验证成功 移除凭证
                    [self top_removeReceipt:plistPath];
                    if ([self->_delegate respondsToSelector:@selector(top_succeedWithsucceedCode:)]) {
                        [self.delegate top_succeedWithsucceedCode:IAPSucceedCode_ServersSucceed];
                    }
                }
                    break;
                default:
                    break;
            }
        }else{
            [SVProgressHUD dismiss];
            if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:andError:)]) {
                [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_parameterempty andError:nil];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(semaphore);
        self.verifyNumber += 1;
        
        [self top_sendAppStoreRequestBuyPlist:plistPath withSemaphore:semaphore];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
#pragma mark - 验证成功就从plist中移除凭证
/**
 错误信息反馈
 @param path  plist路径
 */
- (void) top_removeReceipt:(NSString *)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"移除充值凭证成功");
        [fileManager removeItemAtPath:path error:nil];
    }
}
#pragma mark - 错误信息反馈
/**
 错误信息反馈
 @param code  错误码
 @param error  错误内容
 */
- (void)top_filedWithErrorCode:(NSInteger)code error:(NSString *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(top_filedWithErrorCode:andError:)]) {
        switch (code) {
                /**
                 *  苹果返回错误信息
                 */
            case IAP_FILEDCOED_APPLECODE:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_APPLECODE andError:error];
                break;
                /**
                 *  用户禁止应用内付费购买
                 */
            case IAP_FILEDCOED_NORIGHT:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_NORIGHT andError:nil];
                break;
                /**
                 *  商品为空
                 */
            case IAP_FILEDCOED_EMPTYGOODS:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_EMPTYGOODS andError:nil];
                break;
                /**
                 *  无法获取产品信息，请重试
                 */
            case IAP_FILEDCOED_CANNOTGETINFORMATION:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_CANNOTGETINFORMATION andError:nil];
                break;
                /**
                 *  购买失败，请重试
                 */
            case IAP_FILEDCOED_BUYFILED:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_BUYFILED andError:nil];
                
                break;
                /**
                 *  用户取消交易
                 */
            case IAP_FILEDCOED_USERCANCEL:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_USERCANCEL andError:nil];
                break;
                /**
                 *  服务器验证失败
                 */
            case IAP_FILEDCOED_SERVERERROR:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_SERVERERROR andError:nil];
                break;
                /**
                 *  绑定号码失败
                 */
            case IAP_FILEDCOED_BindNumFiled:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_BindNumFiled andError:nil];
                break;
                /**
                 *  恢复订阅失败
                 */
            case IAP_FILEDCOED_RestoreFiled:
                [self.delegate top_filedWithErrorCode:IAP_FILEDCOED_RestoreFiled andError:nil];
                break;
            default:
                break;
        }
    }
}
#pragma mark - 开始订阅
/**
 开始订阅
 @param payModel  订阅信息 (号码 国家 订阅类型)
 */
-(void)top_startBuyNumberWithServer:( TOPPurchasepayModel*)payModel {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    self.dingyueverifyNumber = 0;
    self.verifyNumber = 0;
    self.numberbuyInfoModel = payModel;
    [self top_requestProductWithId:payModel.purchaseKey];
    NSInteger count = [TOPScanerShare top_theCountClickPurchased];
    count ++;
    [TOPScanerShare top_writeClickPurchasedCount:count];
}
#pragma mark  验证订阅
/**
 订阅绑定号码
 @param plistPath 数据包路径
 */
- (void)top_dingyueSendAppStoreRequestBuyPlist:(NSString *)plistPath withSemaphore:(dispatch_semaphore_t )semaphore
{
    if (self.dingyueverifyNumber >= 2)
    {
        dispatch_semaphore_signal(semaphore);
        [SVProgressHUD dismiss];
        if ([_delegate respondsToSelector:@selector(top_filedWithErrorCode:error:)]) {
            [_delegate top_filedWithErrorCode:IAP_FILEDCOED_SERVERERROR andError:nil];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self top_showCountTransactionFailure];
        });
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[receiptKey] = [dic objectForKey:receiptKey];
    params[@"product_id"] =  dic[@"product_id"];
    params[transactionIdentID] =[dic objectForKey:transactionIdentID];
    params[original_transaction_id] =[dic objectForKey:original_transaction_id];
    params[@"deviceId"] =  [TOPUUID top_getUUID];
    params[@"appType"] =  AppType_SimpleScan;
    params[@"bundle_id"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([TOPSubscriptTools googleLoginStates]) {
        params[@"userId"] = [FIRAuth auth].currentUser.uid;
    }
    NSLog(@"===%@",params);
    [[TOPScannerHttpRequest shareManager] top_PostNetDataWith:TOP_TRAddAppleIAPServer withDic:params andSuccess:^(NSDictionary * _Nonnull responseObject) {
        NSInteger code = [responseObject[@"status"] integerValue];
        dispatch_semaphore_signal(semaphore);
        if (code == 1) {
            NSDictionary *resultRes = responseObject[@"data"];
            if (resultRes) {
                NSInteger resultType = [resultRes[@"apple_sub_status"] integerValue];
                TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
                NSString *productKey = resultRes[@"product_id"];
                subModel.purchaseKey = productKey;
                subModel.subscriptEndTime = [resultRes[@"expires_date_ms"] doubleValue];
                subModel.is_trial_period = [resultRes[@"is_trial_period"] boolValue];
                subModel.original_transaction_id = resultRes[@"original_transaction_id"];
                subModel.transaction_id = resultRes[@"transaction_id"];
                subModel.freeOcrNum = 0;
                switch (resultType) {//0过期,1正常
                    case 0:
                    {
                        subModel.auto_renew_status = 0;
                        subModel.apple_sub_status = NO;
                        subModel.subOcrNum = 0;
                    }
                        break;
                    case 1:{
                        subModel.auto_renew_status = 1;
                        subModel.apple_sub_status = YES;
                        subModel.subOcrNum = 1000;
                        [TOPScanerShare top_writeshowSubscriptViewNum:9];
                        if ([productKey isEqualToString:InAppProductIdSubscriptionMonth]) {
                            //OCR识别点数重置时间（订阅结束时间）
                            subModel.subscriptUpdateTime = [resultRes[@"expires_date_ms"] doubleValue];
                            subModel.priceTitle =@"1 Month Premium";
                            
                        }else  if ([productKey isEqualToString:InAppProductIdSubscriptionYear] || [productKey isEqualToString:@"20211123_year_sub"]) {
                            
                            subModel.priceTitle =@"1 Year Premium";
                            //订阅为1年时下次订阅套餐OCR识别点数重置时间
                            double purchaseTime = [resultRes[@"purchase_date_ms"] doubleValue];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [TOPDocumentHelper top_subscriptEndTimeRenewedDay:purchaseTime SuccessBlock:^(BOOL resultStates, NSString * _Nonnull amazonDateStr) {
                                    if (resultStates) {
                                        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                                        formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                        //设置时间格式
                                        [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        NSDate *  pDate2   = [formatter1 dateFromString:amazonDateStr];
                                        double subupdateTime = [pDate2 timeIntervalSince1970]*1000;
                                        subModel.subscriptUpdateTime = subupdateTime;
                                        [TOPSubscriptTools changeSaveSubScripWith:subModel];
                                    }else{
                                        subModel.subscriptUpdateTime = purchaseTime;
                                        [TOPSubscriptTools changeSaveSubScripWith:subModel];
                                    }
                                }];
                            });
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                [TOPScanerShare top_writePurchasedSubscriptionsCount:1];
                [TOPSubscriptTools changeSaveSubScripWith:subModel];
                if ([self->  _delegate respondsToSelector:@selector(top_succeedWithsucceedCode:)]) {
                    [self.delegate top_succeedWithsucceedCode:IAPSucceedCode_ServersSucceed];
                }
            }
        }else{
            self.dingyueverifyNumber += 1;
            if (self.dingyueverifyNumber >= 2)
            {
                dispatch_semaphore_signal(semaphore);
                [SVProgressHUD dismiss];
                if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:error:)]) {
                    [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_SERVERERROR andError:nil];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self top_showCountTransactionFailure];
                });
            }else{
                [self top_dingyueSendAppStoreRequestBuyPlist:plistPath withSemaphore:semaphore];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
        
    } andFailure:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(semaphore);
        self.dingyueverifyNumber += 1;
        [self top_dingyueSendAppStoreRequestBuyPlist:plistPath withSemaphore:semaphore];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark  恢复购买验证订阅
/**
 订阅绑定号码
 */
- (void)top_restoreDingYueSendAppStoreRequestWith:(SKPaymentTransaction *)tran withSemaphore:(dispatch_semaphore_t )semaphore
{
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *appStoreReceipt = [NSData dataWithContentsOfURL:receiptUrl];
    self.receipt = [appStoreReceipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[receiptKey] =  self.receipt ;
    params[@"product_id"] =  tran.payment.productIdentifier;
    params[transactionIdentID] = tran.transactionIdentifier;
    params[original_transaction_id] =tran.originalTransaction.transactionIdentifier;
    params[@"deviceId"] =  [TOPUUID top_getUUID];
    params[@"appType"] =  AppType_SimpleScan;
    params[@"bundle_id"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([TOPSubscriptTools googleLoginStates]) {
        params[@"userId"] = [FIRAuth auth].currentUser.uid;
    }
    [[TOPScannerHttpRequest shareManager] top_PostNetDataWith:TOP_TRAddAppleIAPServer withDic:params andSuccess:^(NSDictionary * _Nonnull responseObject) {
        dispatch_semaphore_signal(semaphore);
        NSInteger code = [responseObject[@"status"] integerValue];
        if (code == 1) {
            NSDictionary *resultRes = responseObject[@"data"];
            if (resultRes) {
                NSInteger resultType = [resultRes[@"apple_sub_status"] integerValue];
                TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
                NSString *productKey = resultRes[@"product_id"];
                subModel.purchaseKey = productKey;
                subModel.subscriptEndTime = [resultRes[@"expires_date_ms"] doubleValue];
                subModel.is_trial_period = [resultRes[@"is_trial_period"] boolValue];
                subModel.original_transaction_id = resultRes[@"original_transaction_id"];
                subModel.transaction_id = resultRes[@"transaction_id"];
//                subModel.priceTitle = self.numberbuyInfoModel.productTitle;
                if ([productKey isEqualToString:InAppProductIdSubscriptionMonth]) {
                    subModel.priceTitle =@"1 Month Premium";
                    
                }else  if ([productKey isEqualToString:InAppProductIdSubscriptionYear] || [productKey isEqualToString:@"20211123_year_sub"]) {
                    subModel.priceTitle =@"1 Year Premium";
                }
                subModel.freeOcrNum = 0;
                switch (resultType) {//0过期,1正常
                    case 0:
                    {
                        subModel.auto_renew_status = 0;
                        subModel.apple_sub_status = NO;
                        [TOPSubscriptTools changeSaveSubScripWith:subModel];
                        if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:andError:)]) {
                            [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_NORestoreData andError:nil];
                        }
                    }
                        break;
                    case 1:{
                        subModel.auto_renew_status = 1;
                        subModel.apple_sub_status = YES;
                        subModel.subOcrNum = 1000;
                        [TOPScanerShare top_writeshowSubscriptViewNum:9];
                        [TOPSubscriptTools changeSaveSubScripWith:subModel];
                        if ([productKey isEqualToString:InAppProductIdSubscriptionMonth]) {
                            //OCR识别点数重置时间（订阅结束时间）
                            subModel.subscriptUpdateTime = [resultRes[@"expires_date_ms"] doubleValue];
                        }else  if ([productKey isEqualToString:InAppProductIdSubscriptionYear] || [productKey isEqualToString:@"20211123_year_sub"]) {
                            //订阅为1年时下次订阅套餐OCR识别点数重置时间
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                double purchaseTime = [resultRes[@"purchase_date_ms"] doubleValue];
                                [TOPDocumentHelper top_subscriptEndTimeRenewedDay:purchaseTime SuccessBlock:^(BOOL resultStates, NSString * _Nonnull amazonDateStr) {
                                    if (resultStates) {
                                        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                                        formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                        //设置时间格式
                                        [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        NSDate *  pDate2   = [formatter1 dateFromString:amazonDateStr];
                                        double subupdateTime = [pDate2 timeIntervalSince1970]*1000;
                                        subModel.subscriptUpdateTime = subupdateTime;
                                        [TOPSubscriptTools changeSaveSubScripWith:subModel];
                                    }else{
                                        subModel.subscriptUpdateTime = purchaseTime;
                                        [TOPSubscriptTools changeSaveSubScripWith:subModel];
                                    }
                                }];
                            });
                        }
                        if ([self->  _delegate respondsToSelector:@selector(top_succeedWithsucceedCode:)]) {
                            [self.delegate top_succeedWithsucceedCode:IAPSucceedCode_ServersRestoreSucceed];
                        }
                    }
                        break;
                    default:
                        [TOPSubscriptTools changeSaveSubScripWith:subModel];
                        break;
                }
            }
        }else{
            if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:andError:)]) {
                [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_RestoreFiled andError:nil];
            }
            NSDictionary *toolMessageDic = responseObject;
            if ([toolMessageDic.allKeys containsObject:@"message"] && toolMessageDic[@"message"] != nil) {
                [[TOPCornerToast shareInstance] makeToast:toolMessageDic[@"message"]];
            }
        }
        
    } andFailure:^(NSError * _Nonnull error) {
        if ([self->_delegate respondsToSelector:@selector(top_filedWithErrorCode:andError:)]) {
            [self->_delegate top_filedWithErrorCode:IAP_FILEDCOED_RestoreFiled andError:nil];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
/**
 获取当前时间点横杠格式- 格式2020-06-23 16:23:43
 @return 返回time
 */
- (NSString *)top_getCurrentDateWithTransverseFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    [formatter setTimeZone:timeZone];
    //设置时间格式
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStr = [formatter  stringFromDate:[NSDate date]];
    return dateStr;
}
#pragma mark  获取订阅信息
/**
 获取订阅信息
 */
- (void)top_requestDingyueInfoWithDevice
{
    TOPSubscriptModel *model = [TOPSubscriptTools getSubScriptData];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"transaction_id"] = model.transaction_id;
    params[@"original_transaction_id"] = model.original_transaction_id;
    params[@"deviceId"] =  [TOPUUID top_getUUID];
    if ([TOPSubscriptTools googleLoginStates]) {
        params[@"userId"] = [FIRAuth auth].currentUser.uid;
    }
    NSLog(@"===%@",params);
    [[TOPScannerHttpRequest shareManager] top_PostNetDataWith:TOP_TRGETSubscriptInfo withDic:params andSuccess:^(NSDictionary * _Nonnull responseObject) {
        NSInteger code = [responseObject[@"status"] integerValue];
        NSLog(@"responseObjectxxxxx==%@",responseObject);
        if (code == 1) {
            NSDictionary *resultRes = responseObject[@"data"];
            NSInteger resultType = [resultRes[@"apple_sub_status"] integerValue];
            TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
            NSString *productKey = resultRes[@"product_id"];
            subModel.purchaseKey = productKey;
            subModel.subscriptEndTime = [resultRes[@"expires_date_ms"] doubleValue];
            subModel.auto_renew_status = [resultRes[@"auto_renew_status"] boolValue];
            subModel.is_trial_period = [resultRes[@"is_trial_period"] boolValue];
            switch (resultType) {//0过期,1正常
                case 0:
                {
                    subModel.apple_sub_status = NO;
                    subModel.subOcrNum = 0;
                }
                    break;
                case 1:{
                    subModel.apple_sub_status = YES;
                }
                    break;
                    
                default:
                    break;
            }
            [TOPSubscriptTools changeSaveSubScripWith:subModel];
            [self top_getSubscriptUpdateRestOcrNum];
        }
    } andFailure:^(NSError * _Nonnull error) {
        [self top_getSubscriptUpdateRestOcrNum];
        
    }];
}
#pragma mark- 每次进入app判断OCR余额是否需要重置
- (void)top_getSubscriptUpdateRestOcrNum{
    TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
    if (subModel.apple_sub_status) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPDocumentHelper top_subscriptEndTimeRenewedDay:subModel.subscriptUpdateTime SuccessBlock:^(BOOL resultStates, NSString * _Nonnull amazonDateStr) {
                if (resultStates) {//当前的亚马逊时间大于当前更新时间 更新每个月的1000点
                    subModel.subOcrNum = 1000;
                    [TOPSubscriptTools changeSaveSubScripWith:subModel];
                    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                    formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    //设置时间格式
                    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *  pDate2   = [formatter1 dateFromString:amazonDateStr];
                    double subupdateTime = [[TOPDocumentHelper top_getAroundDateFromDate:pDate2 month:1] timeIntervalSince1970]*1000;
                    [TOPSubscriptTools saveWriteSubscriptResetOcrNumTime:subupdateTime];
                }
            }];
        });
    }
}
@end
