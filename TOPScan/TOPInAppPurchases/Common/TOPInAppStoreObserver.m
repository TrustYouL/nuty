

#import "TOPInAppStoreObserver.h"
#import "TOPPurchaseValidationHandler.h"
#import "TOPPurchaseReceiptHandler.h"

static dispatch_queue_t validationQueue;

@interface TOPInAppStoreObserver () {
    dispatch_semaphore_t validationSemaphore;
}

@end

@implementation TOPInAppStoreObserver

#pragma mark -- 单例初始化
+ (instancetype)shareInstance {
    static TOPInAppStoreObserver *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPInAppStoreObserver alloc] init];
    });
    return singleTon;
}

- (instancetype)init {
    if ([super init]) {
        validationQueue  = dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);
        validationSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

#pragma mark -- 购买监听写在程序入口,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
- (void)topStartTransactionObserver {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark -- 程序挂起时移除监听
- (void)topRemoveTransactionObserver {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark -- 校验锁
- (void)topLockValidation {
    dispatch_semaphore_wait(validationSemaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark -- 校验解锁
- (void)topUnlockValidattion {
    dispatch_semaphore_signal(validationSemaphore);
}

#pragma mark -- 是否允许用户支付 查询应用商店时先告知用户
- (BOOL)topIsAuthorizedForPayments {
    return [SKPaymentQueue canMakePayments];
}

#pragma mark-- 购买商品
- (void)topBuyProduct:(SKProduct *)product {
    if (product.productIdentifier) {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.applicationUsername = [TOPAppTools hashedValueForAccountName:[TOPUUID top_getUUID]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

#pragma mark -- 恢复所有以前完成的购买
- (void)topRestorePurchases {
    if (self.restored.count) {
        [self.restored removeAllObjects];
    }
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark -- 交易结束
- (void)topFinishTransaction:(SKPaymentTransaction *)transaction {
    if (transaction) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -- 处理付款交易
#pragma mark -- 处理成功的购买交易
- (void)topHandlePurchased:(SKPaymentTransaction *)transaction {
    [self.purchased addObject:transaction];
    [self topValidateReceipt:transaction];
}

#pragma mark -- 处理失败的购买事务
- (void)topHandleFailed:(SKPaymentTransaction *)transaction {
    NSString *msg = @"";
    if (transaction.error != nil) {
        if(transaction.error.code != SKErrorPaymentCancelled) {
            msg = [NSString stringWithFormat:@"%@\n %@",InAppPurchaseFailure, transaction.error.localizedDescription];
        }
    } else {
        msg = [NSString stringWithFormat:@"%@\n network anomaly",InAppPurchaseFailure];
    }
    [self topObserverCallBackMessage:msg];
    [self topFinishTransaction:transaction];
}

#pragma mark -- 处理恢复的购买交易
- (void)topHandleRestored:(SKPaymentTransaction *)transaction {
    self.hasRestorablePurchases = YES;
    [self.restored addObject:transaction];
}

#pragma mark -- 校验购买凭证
- (void)topValidateReceipt:(SKPaymentTransaction *)transaction {
    dispatch_async(validationQueue, ^{
        self.validatingTrans = transaction;
        [self topShuntValidation:transaction];
        [self topLockValidation];
    });
}

- (void)topShuntValidation:(SKPaymentTransaction *)transaction {
    NSString *receipt = [TOPPurchaseReceiptHandler top_receiptData];
    if (receipt.length) {
        NSMutableDictionary *param = [TOPPurchaseReceiptHandler top_saveReceipt:transaction];
        InAppReceiptType type = [TOPPurchaseReceiptHandler top_receiptType:transaction];
        switch (type) {
            case InAppReceiptTypeOCR:
                [self topValidateOCRCredit:param];
                break;
            case InAppReceiptTypeSubscription:
                [self topValidateSubscription:param];
                break;
            default:
                break;
        }
    } else {
        [self topObserverTipNoAppReceipt];
    }
}

#pragma mark -- 是否需要校验 本地
- (BOOL)needValidate:(SKPaymentTransaction *)transaction {
    if (transaction.originalTransaction.transactionIdentifier) {
        NSMutableArray *temp = [[NSUserDefaults standardUserDefaults] valueForKey:@"finishTrans"];
        if ([temp containsObject:transaction.originalTransaction.transactionIdentifier]) {
            return NO;
        }
    }
    return YES;
}

- (void)saveValidateTrans:(NSString *)original_transaction_id {
    if (original_transaction_id) {
        NSMutableArray *temp = [[NSUserDefaults standardUserDefaults] valueForKey:@"finishTrans"];
        [temp addObject:original_transaction_id];
        [[NSUserDefaults standardUserDefaults] setValue:temp forKey:@"finishTrans"];
    }
}

#pragma mark -- 校验订阅票据
- (void)topValidateSubscription:(NSDictionary *)param {
    [TOPPurchaseValidationHandler topValidateSubscriptionsWithParam:param success:^(NSDictionary * _Nonnull data) {
        [self topFinishTransaction:self.validatingTrans];
        [self topObserverValidateSucceed];
        [self topUnlockValidattion];
    } failure:^(NSError * _Nonnull error) {
        [self topObserverValidateAgain];
    }];
}

#pragma mark -- 校验ocr点数票据
- (void)topValidateOCRCredit:(NSDictionary *)param {
    [TOPPurchaseValidationHandler topValidateOCRCreditsWithParam:param success:^(NSDictionary * _Nonnull data) {
        NSString *path = [TOPPurchaseReceiptHandler top_localOCRPath:param[@"transaction_id"]];
        [TOPPurchaseReceiptHandler top_removeReceipt:path];
        [self topFinishTransaction:self.validatingTrans];
        [self topObserverValidateSucceed];
        [self topUnlockValidattion];
    } failure:^(NSError * _Nonnull error) {
        [self topObserverValidateAgain];
    }];
}

- (SKPaymentTransaction *)validatingTransaction:(NSString *)transaction_id {
    for (SKPaymentTransaction *tran in self.purchased) {
        if ([tran.transactionIdentifier isEqualToString:transaction_id]) {
            return tran;
        }
    }
    return nil;
}

#pragma mark -- SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStatePurchased:
                [self topHandlePurchased:tran];
                break;
            case SKPaymentTransactionStateFailed:
                [self topHandleFailed:tran];
                break;
            case SKPaymentTransactionStateRestored:
                [self topHandleRestored:tran];
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"挂起");
                break;
            default:
                break;
        }
    }
}

#pragma mark -- 记录已从支付队列中删除的所有事务
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {

}

#pragma mark -- 当支付队列处理了所有可恢复的事务时调用
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (!self.hasRestorablePurchases) {
        [self topObserverCallBackMessage:NSLocalizedString(@"topscan_nopurrestore", @"")];
    } else {
        [self topRestoreValidation:self.restored.lastObject];
    }
}

#pragma mark -- 恢复购买发生错误 通知用户错误
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [self topObserverCallBackMessage:[error localizedDescription]];
}

- (void)topRestoreValidation:(SKPaymentTransaction *)transaction {
    NSString *receipt = [TOPPurchaseReceiptHandler top_receiptData];
    if (receipt.length) {
        NSMutableDictionary *param = [TOPPurchaseReceiptHandler top_saveReceipt:transaction];
        [TOPPurchaseValidationHandler topValidateSubscriptionsWithParam:param success:^(NSDictionary * _Nonnull data) {
            [self topFinishTransaction:transaction];
            BOOL status = [data[@"apple_sub_status"] boolValue];
            if (status) {
                [self topObserverRestoreSucceed];
            } else {
                [self topObserverCallBackMessage:NSLocalizedString(@"topscan_nopurrestore", @"")];
            }
        } failure:^(NSError * _Nonnull error) {
            [self topObserverCallBackMessage:NSLocalizedString(@"topscan_restorefailed", @"")];
        }];
    } else {
        [self topObserverCallBackMessage:InAppReceiptEmpty];
    }
}

#pragma mark -- 校验成功
- (void)topObserverValidateSucceed {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(topStoreObserverValidateSucceed)]) {
            [self.delegate topStoreObserverValidateSucceed];
        }
    });
}

#pragma mark -- 二次校验
- (void)topObserverValidateAgain {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(topStoreObserverValidateAgain)]) {
            [self.delegate topStoreObserverValidateAgain];
        }
    });
}

#pragma mark -- 购买成功
- (void)topObserverPurchaseSucceed {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(topStoreObserverPurchaseSucceed)]) {
            [self.delegate topStoreObserverPurchaseSucceed];
        }
    });
}

#pragma mark -- 回调信息
- (void)topObserverCallBackMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(top_topStoreObserverDidReceiveMessage:)]) {
            [self.delegate top_topStoreObserverDidReceiveMessage:msg];
        }
    });
}

#pragma mark -- 恢复购买成功
- (void)topObserverRestoreSucceed {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(top_topStoreObserverRestoreDidSucceed)]) {
            [self.delegate top_topStoreObserverRestoreDidSucceed];
        }
    });
}

#pragma mark -- 票据为空，提示用户去主动获取收据
- (void)topObserverTipNoAppReceipt {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(topStoreObserverAppReceiptIsEmpty)]) {
            [self.delegate topStoreObserverAppReceiptIsEmpty];
        }
    });
}

#pragma mark -- 二次校验，上次的校验失败，用户主动选择再次校验
- (void)topValidateAgain {
    [self topUnlockValidattion];
    [self topValidateReceipt:self.validatingTrans];
}

#pragma mark -- 更新收据
- (void)topRefreshAppReceipt {
    SKReceiptRefreshRequest *receiptRefreshRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    receiptRefreshRequest.delegate = self;
    [receiptRefreshRequest start];
}

#pragma mark -- SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    if (self.purchased.count) {
        [self topValidateAgain];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self topUnlockValidattion];
    [self topObserverCallBackMessage:[error localizedDescription]];
}

#pragma mark -- 获取详情
- (void)topFetchSubscriptionInfo {
    TOPSubscriptModel *ocrModel = [TOPSubscriptTools getSubScriptData];
    if (ocrModel.original_transaction_id.length>0) {
        [TOPPurchaseValidationHandler topFetchSubscriptionsWithParam:@{} success:^(NSDictionary * _Nonnull data) {
            NSLog(@"subscription info = %@",data);
        } failure:^(NSError * _Nonnull error) {
            
        }];
    } else {
        ocrModel = [[TOPSubscriptModel alloc] init];
        [TOPSubscriptTools changeSaveSubScripWith:ocrModel];
    }
}

#pragma mark -- lazy
- (NSMutableArray *)purchased {
    if (!_purchased) {
        _purchased = @[].mutableCopy;
    }
    return _purchased;
}

- (NSMutableArray *)restored {
    if (!_restored) {
        _restored = @[].mutableCopy;
    }
    return _restored;
}

@end
