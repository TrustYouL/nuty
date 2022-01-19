
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RLMObject;
@class RLMRealm;
@interface TOPDBService : NSObject

#pragma mark - Init
/// 配置数据库
/// @param identifier  数据库标识符（建议用唯一标识）
+ (void)top_configDBWithIdentifier:(NSString *)identifier;

/// 数据库版本迁移
+ (void)top_realmDBMigration;

/// 返回当前使用的数据库实例
+ (RLMRealm *)top_currentRealm;

/// 执行事务
/// @param block 事务执行内容
+ (void)top_transactionWithBlock:(void(^)(void))block;

/// 清空数据库
+ (void)top_clearRealmDB;

/// 删除单个
/// @param object 删除对象
+ (void)top_removeObject:(RLMObject *)object;

/// 删除多个
/// @param objects 删除对象
+ (void)top_removeAllObjects:(id)objects;

/// 保存单个
/// @param object 保存对象
+ (void)top_saveObject:(RLMObject *)object;

/// 保存更新单个
/// @param object 保存对象
+ (void)top_addOrUpdateObject:(RLMObject *)object;
/// 保存更新多个
/// @param objects 保存对象
+ (void)top_addOrUpdateObjects:(id)objects;
/// 保存多个
/// @param objects 保存对象
+ (void)top_saveAllObjects:(id)objects;

/// 删除、保存多个对象
/// @param objects 删除对象组
/// @param addObjs 保存对象组
+ (void)top_deleteObjects:(id)objects saveObjects:(id)addObjs;

/**
 批量更新对象，更新多个数据使用

 @param objects 要更新对象的集合
 @param data 批量设置的数据 @{@"keyPath":@"value"}
 */
+ (void)top_batchUpdateObjects:(id)objects data:(NSDictionary *)data;
/// 数据库集合数据转换
+ (NSArray *)convertToArray:(RLMResults *)results;
+ (NSArray *)convertRLMArray:(RLMArray *)array;
@end

NS_ASSUME_NONNULL_END
