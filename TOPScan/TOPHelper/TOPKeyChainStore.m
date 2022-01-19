

#import "TOPKeyChainStore.h"

@implementation TOPKeyChainStore

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)deleteKeyData:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}
+ (void)changeKeyData:(NSString *)password andKeyData:(NSString *)service
{

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];

    NSDictionary *updatedItems = @{
                                   (id)kSecValueData: [NSKeyedArchiver archivedDataWithRootObject:password],
      };

     SecItemUpdate((CFDictionaryRef)keychainQuery, (CFDictionaryRef)updatedItems);
}

+ (void)changeKeyWithDictData:(NSDictionary *)dict andKeyData:(NSString *)service
{

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];

    NSDictionary *updatedItems = @{
                                   (id)kSecValueData: [NSKeyedArchiver archivedDataWithRootObject:dict],
      };

     SecItemUpdate((CFDictionaryRef)keychainQuery, (CFDictionaryRef)updatedItems);
}

@end
