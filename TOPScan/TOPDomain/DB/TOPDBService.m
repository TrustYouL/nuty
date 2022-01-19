

#import "TOPDBService.h"
#import <Realm/Realm.h>

static NSString * const DBFilePrefix = @"topscan_db_";
//realm 数据库版本迁移,每次改变数据库结构时,请将 REALM_SCHAME_VERSION 值加 1,并保证REALM_SCHAME_VERSION为正整数
static NSUInteger  const REALM_SCHAME_VERSION = 18;

@implementation TOPDBService

/// 配置数据库
/// @param identifier  数据库标识符（建议用唯一标识）
+ (void)top_configDBWithIdentifier:(NSString *)identifier {
    if ([identifier length]) {
        NSString *dbName = [NSString stringWithFormat:@"%@%@.realm",DBFilePrefix,identifier];//数据库名
        NSString *dbPath = [TOPDocumentHelper top_getDBPathString];//数据库目录
        NSString *dbFile = [dbPath stringByAppendingPathComponent:dbName];//数据库文件路径
        
        RLMRealmConfiguration *defaultConfig = [RLMRealmConfiguration defaultConfiguration];
        defaultConfig.fileURL = [NSURL fileURLWithPath:dbFile];
        defaultConfig.schemaVersion = 1;
        [RLMRealmConfiguration setDefaultConfiguration:defaultConfig];
//        NSLog(@"DBPath:%@",defaultConfig.fileURL);
    }
}
//#warning  改变数据库模型类，如新增字段或者删除字段，如果需要做对应的处理，就在对应的版本，处理对应的字段，如果不需要处理这些字段，可以什么也不写，只需要增加‘REALM_SCHAME_VERSION’的版本号，每次变更都需要加 1
+ (void)top_realmDBMigration {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = REALM_SCHAME_VERSION;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 9) {
            [migration enumerateObjects:TOPAppDocument.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                newObject[@"docNoticeLock"] = @(0);
            }];
        }
        if (oldSchemaVersion < 12) {
            [migration enumerateObjects:TOPAppDocument.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                newObject[@"rtime"] = oldObject[@"utime"];
            }];
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

/// 返回当前使用的数据库实例
+ (RLMRealm *)top_currentRealm {
    RLMRealm *realm = [RLMRealm defaultRealm];
    return realm;
}

/// 执行事务
/// @param block 事务执行内容
+ (void)top_transactionWithBlock:(void(^)(void))block {
    RLMRealm *realm = [self top_currentRealm];
    [realm transactionWithBlock:block];
}

/// 清空数据库
+ (void)top_clearRealmDB {
    RLMRealm *realm = [self top_currentRealm];
    // 每个线程只需要使用一次即可
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];
}

/// 删除单个
/// @param object 删除对象
+ (void)top_removeObject:(RLMObject *)object {
    if (!object.isInvalidated && object) {
        RLMRealm *realm = [self top_currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm deleteObject:object];
        }];
    }
}

/// 删除多个
/// @param objects 删除对象
+ (void)top_removeAllObjects:(id)objects {
    if (objects) {
        RLMRealm *realm = [self top_currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm deleteObjects:objects];
        }];
    }
}

/// 保存单个
/// @param object 保存对象
+ (void)top_saveObject:(RLMObject *)object {
    if (object) {
        RLMRealm *realm = [self top_currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addObject:object];
        }];
    }
}

/// 保存更新单个
/// @param object 保存对象
+ (void)top_addOrUpdateObject:(RLMObject *)object {
    if (object) {
        RLMRealm *realm = [self top_currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addOrUpdateObject:object];
        }];
    }
}

/// 保存更新多个
/// @param objects 保存对象
+ (void)top_addOrUpdateObjects:(id)objects {
    if (objects) {
        RLMRealm *realm = [self top_currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addOrUpdateObjects:objects];
        }];
    }
}

/// 保存多个
/// @param objects 保存对象
+ (void)top_saveAllObjects:(id)objects {
    if (objects) {
        RLMRealm *realm = [self top_currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addObjects:objects];
        }];
    }
}

/// 删除、保存多个对象
/// @param objects 删除对象组
/// @param addObjs 保存对象组
+ (void)top_deleteObjects:(id)objects saveObjects:(id)addObjs {
    if (objects && addObjs) {
        RLMRealm *realm = [self top_currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm deleteObjects:objects];
            [realm addObjects:addObjs];
        }];
    }
}

+ (void)top_batchUpdateObjects:(id)objects data:(NSDictionary *)data {
    if (objects && data) {
        RLMRealm *realm = [self top_currentRealm];
        [realm transactionWithBlock:^{
            // 将每个 object 对象的 keyPath 属性设置为 value
            for (NSString *keyPath in data) {
                [objects setValue:data[keyPath] forKeyPath:keyPath];
            }
        }];
    }
}

+ (NSArray *)convertToArray:(RLMResults *)results {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *object in results) {
        [array addObject:object];
    }
    return array;
}

+ (NSArray *)convertRLMArray:(RLMArray *)array {
    NSMutableArray *_temp = [NSMutableArray array];
    for (RLMObject *obj in array) {
        [_temp addObject:obj];
    }
    return _temp;
}


@end
