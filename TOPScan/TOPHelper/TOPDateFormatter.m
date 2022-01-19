#import "TOPDateFormatter.h"
static TOPDateFormatter *_singleTon = nil;
static dispatch_once_t onceToken;
@implementation TOPDateFormatter

+ (instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        _singleTon = [[TOPDateFormatter alloc] init];
        _singleTon.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [_singleTon setDateFormat:[TOPScanerShare top_documentDateType]];
    });
    return _singleTon;
}
#pragma mark -- 单利销毁
- (void)top_removeSingleTon{
    onceToken = 0;
    _singleTon = nil;
}
@end
