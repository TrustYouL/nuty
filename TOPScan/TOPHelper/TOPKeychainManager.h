#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPKeychainManager : NSObject
+(TOPKeychainManager *)defaultManager;
//根据字典存储对象到钥匙串
- (void)top_saveToKeychain:(NSString *)service keychainData:(id)data;
//根据字典读取字符串对象
- (id)top_loadKeychain:(NSString *)service;
//删除钥匙串数据
- (void)top_deleteKeychain:(NSString *)service;
@end

NS_ASSUME_NONNULL_END
