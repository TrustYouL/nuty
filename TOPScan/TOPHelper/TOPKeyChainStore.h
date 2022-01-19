

#import <Foundation/Foundation.h>

@interface TOPKeyChainStore : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;

+ (void)changeKeyData:(NSString *)password andKeyData:(NSString *)service;

+ (void)changeKeyWithDictData:(NSDictionary *)dict andKeyData:(NSString *)service;
@end
