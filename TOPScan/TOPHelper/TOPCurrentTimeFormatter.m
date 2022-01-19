#import "TOPCurrentTimeFormatter.h"

static TOPCurrentTimeFormatter *_singleTon = nil;
static dispatch_once_t onceToken;
@implementation TOPCurrentTimeFormatter

+ (instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        _singleTon = [[TOPCurrentTimeFormatter alloc] init];
        [_singleTon setDateFormat:@"yyyyMMddHHmmss"];
        [_singleTon setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return _singleTon;
}

+ (void)top_destroyInstance {
    onceToken = 0;
    _singleTon = nil;
}

@end
