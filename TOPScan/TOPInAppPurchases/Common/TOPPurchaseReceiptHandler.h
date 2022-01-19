

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

//列表的排列方式
typedef NS_ENUM(NSUInteger, InAppReceiptType) {
    InAppReceiptTypeOCR = 1,  //ocr
    InAppReceiptTypeSubscription, // simplescan订阅
};

@interface TOPPurchaseReceiptHandler : NSObject

/// -- 从沙盒中获取交易凭证
+ (NSString *)top_receiptData;
/// -- 持久化存储用户购买凭证(这里最好还要存储当前日期，用户id等信息，用于区分不同的凭证)
+ (NSMutableDictionary *)top_saveReceipt:(SKPaymentTransaction *)transaction;
/// -- 票据类型 订阅 or OCR
+ (InAppReceiptType)top_receiptType:(SKPaymentTransaction *)transaction;
+ (BOOL)top_removeReceipt:(NSString *)path;
+ (NSString *)top_localOCRPath:(NSString *)transactionId;
@end

NS_ASSUME_NONNULL_END
