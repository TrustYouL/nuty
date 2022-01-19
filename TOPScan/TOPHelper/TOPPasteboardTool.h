#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPasteboardTool : NSObject
+ (instancetype)shareTool; //单例方法
- (void)top_initPasteboard:(NSString*)name;
- (void)top_saveData:(NSData *)data forKey:(NSString*)key;
- (id)top_dataForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
