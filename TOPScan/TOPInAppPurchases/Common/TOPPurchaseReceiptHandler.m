

#import "TOPPurchaseReceiptHandler.h"
#import "TOPSandBoxHelper.h"
#import "TOPInAppStoreManager.h"

static NSString * const receiptKey = @"receipt_data";
static NSString * const dateKey = @"date_key";
static NSString * const userIdKey = @"userid";
static NSString * const countMoney = @"order_amount";
static NSString * const orderKey = @"orderId";
static NSString * const productId = @"product_id";
static NSString * const transactionIdentID = @"transaction_id";
static NSString * const original_transaction_id = @"original_transaction_id";
static NSString * const appType = @"appType";
static NSString * const bundleId = @"bundle_id";
static NSString * const deviceId = @"deviceId";

@implementation TOPPurchaseReceiptHandler

+ (NSString *)top_receiptData {
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodedReceipt = [receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodedReceipt;
}

#pragma mark -- 持久化存储用户购买凭证(这里最好还要存储当前日期，用户id等信息，用于区分不同的凭证)
+ (NSMutableDictionary *)top_saveReceipt:(SKPaymentTransaction *)transaction {
    NSMutableDictionary *dic = [self top_receiptParam:transaction];
    if ([self top_receiptType:transaction] == InAppReceiptTypeOCR) {//ocr点数
        NSString *savedPath = [self top_localOCRPath:transaction.transactionIdentifier];
        if ([TOPWHCFileManager top_isExistsAtPath:savedPath]) {
            [TOPWHCFileManager top_removeItemAtPath:savedPath];
        }
        [dic writeToFile:savedPath atomically:YES];
    } else {
        NSString *savedingyuePath = [self top_localSubscriptionPath:transaction];
        if ([TOPWHCFileManager top_isExistsAtPath:savedingyuePath]) {
            [TOPWHCFileManager top_removeItemAtPath:savedingyuePath];
        }
        [dic writeToFile:savedingyuePath atomically:YES];
    }
    return dic;
}

#pragma mark -- 票据类型 订阅 or OCR
+ (InAppReceiptType)top_receiptType:(SKPaymentTransaction *)transaction {
    NSString *type = [[TOPInAppStoreManager shareInstance] topProductType:transaction.payment.productIdentifier];
    if ([type isEqualToString:@"ocr"]) {
        return InAppReceiptTypeOCR;
    } else if ([type isEqualToString:@"subs"]) {
        return InAppReceiptTypeSubscription;
    }
    return InAppReceiptTypeSubscription;
}

+ (NSMutableDictionary *)top_receiptParam:(SKPaymentTransaction *)transaction {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[receiptKey] = [self top_receiptData];
    dic[dateKey] = [TOPAppTools top_getCurrentTimeSeconds];
    dic[productId] = transaction.payment.productIdentifier;
    dic[transactionIdentID] = transaction.transactionIdentifier;
    if (transaction.originalTransaction) {
        dic[original_transaction_id] = transaction.originalTransaction.transactionIdentifier;
    }
    if ([TOPSubscriptTools googleLoginStates]) {
        dic[userIdKey] = [FIRAuth auth].currentUser.uid;
    }
    dic[appType] = AppType_SimpleScan;
    dic[bundleId] = [TOPAppTools appBundleId];
    dic[deviceId] = [TOPUUID top_getUUID];
    return dic;
}

+ (NSString *)top_localOCRPath:(NSString *)transactionId {
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@.plist", [TOPSandBoxHelper iapReceiptPath], transactionId];
    return savedPath;
}

+ (NSString *)top_localSubscriptionPath:(SKPaymentTransaction *)transaction {
    NSString *savedingyuePath = [NSString stringWithFormat:@"%@/%@.plist", [TOPSandBoxHelper iapReceiptDingYuePath], transaction.transactionIdentifier];
    if (transaction.originalTransaction) {
        savedingyuePath = [NSString stringWithFormat:@"%@/%@.plist", [TOPSandBoxHelper iapReceiptDingYuePath], transaction.originalTransaction.transactionIdentifier];
    }
    return savedingyuePath;
}

+ (BOOL)top_removeReceipt:(NSString *)path {
    BOOL isSuccess = [TOPWHCFileManager top_removeItemAtPath:path];
    return isSuccess;
}

@end
