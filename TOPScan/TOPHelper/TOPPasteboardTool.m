#import "TOPPasteboardTool.h"

@implementation TOPPasteboardTool{
    UIPasteboard * _myPasteboard;
}

static TOPPasteboardTool *tool = nil;
+ (instancetype)shareTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[TOPPasteboardTool alloc]init];
        [tool top_initPasteboard:SHAREBOARD];
    });
    return tool;
}

- (void)top_initPasteboard:(NSString*)name
{
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:name create:YES];
    _myPasteboard = pasteboard;
}

- (void)top_saveData:(NSData *)data forKey:(NSString *)key{
    
    [_myPasteboard setData:data forPasteboardType:key];
    
}

- (id)top_dataForKey:(NSString *)key{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[_myPasteboard dataForPasteboardType:key]];
}
@end
