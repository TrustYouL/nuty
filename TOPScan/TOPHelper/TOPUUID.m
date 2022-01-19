
#import "TOPUUID.h"
#import "TOPKeyChainStore.h"
#import <sys/utsname.h>

@implementation TOPUUID

+(NSString *)top_getUUID
{
    NSString * strUUID = (NSString *)[TOPKeyChainStore load:KEY_USERUU_UUID];
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        CFRelease(uuidRef);
        [TOPKeyChainStore save:KEY_USERUU_UUID data:strUUID];
    }
    return strUUID;
}
@end
