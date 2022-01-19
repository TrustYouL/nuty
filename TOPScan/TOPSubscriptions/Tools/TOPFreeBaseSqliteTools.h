
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFreeBaseSqliteTools : NSObject

#pragma mark-   初始化单利

+ (instancetype)sharedSingleton;

#pragma mark-   开启数据库实时的监听

/**
 开启数据库实时的监听
 */
- (void)openObserveGoogleFirebaseValue;

#pragma mark-   移除所有的监听

/**
    移除所有的监听
 */
- (void)removeAllObserveGoogleFirebase;
#pragma mark-  添加OCR订阅历史
/**
 添加识别历史
 **/
- (void)setOcr_recognize_historyToServiceWith:(NSString *)recognizeHistory;

#pragma mark- 设置余额到实时数据库
/**
 设置余额到实时数据库
 **/
- (void)setOcr_recognize_pagesToServiceWith:(NSInteger )recognize_pages;

#pragma mark-  添加充值历史
/**
 添加充值历史
 **/
- (void)setOcr_buyhistoryToServiceWith:(NSString *)buyHistory;
@end

NS_ASSUME_NONNULL_END
