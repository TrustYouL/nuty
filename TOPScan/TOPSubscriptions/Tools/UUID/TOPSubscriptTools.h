

#import <Foundation/Foundation.h>
@class TOPSubscriptModel;

NS_ASSUME_NONNULL_BEGIN
@interface TOPSubscriptTools : NSObject
/**
获取本地订阅状态
 */
+ (TOPSubscriptModel *)getSubScriptData;
/**
修改本地订阅状态
 */
+(void)changeSaveSubScripWith:(TOPSubscriptModel *)subModel;
/**
获取当前的余额 -- 识别OCR
 */
+ (NSInteger )getCurrentUserBalance;

/**
获取当前的可用OCR识别点数
 */
+ (NSInteger)getCurrentAvailableOcrNum;

/**
修改当前的余额
 */
+ (void )saveWriteCurrentUserBalance:(NSInteger)currentBalance;


/**
获取当前的免费识别点数
 */
+ (NSInteger )getCurrentFreeIdentifyNum;

/**
修改当前的免费点数
 */
+ (void )saveWriteCurrentFreeIdentifyNum:(NSInteger)freeOcrNum;

/**
获取当前的订阅后每个月的识别点数
 */
+ (NSInteger )getCurrentSubscriptIdentifyNum;

/**
修改当前的订阅后每个月的识别点数
 */
+ (void )saveWriteCurrentSubscripIdentifyNum:(NSInteger)ocrNum;
/**
修改当前OCR充值时间
 */
+ (void )saveWriteSubscriptResetOcrNumTime:(double)uploadTime;
/**
获取登录状态
 */
+ (BOOL)googleLoginStates;

/**
获取订阅状态
 */
+ (BOOL)getSubscriptStates;

// 删除订阅信息
+ (void)removeSubscript;

#pragma mark- iCloud云端存储

/*
 *更新修改数据到iCloud云端的数据
 */
+ (void)updateiCloudKitModel:(NSInteger)userBalance;

/*
 *查询iCloud云端的数据
 *查询单条数据
 */
+ (void)querySingleUserBalanceRecord;

@end

NS_ASSUME_NONNULL_END
