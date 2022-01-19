#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShareFileDataHandler : NSObject
/// -- 首页和nextFolder界面的分享数据
+ (NSMutableArray *)top_fetchShareFileData:(NSArray *)fileArray;
/// -- homeChild界面的分享数据
+ (NSMutableArray *)top_fetchShareImageData:(NSArray *)fileArray;
@end

NS_ASSUME_NONNULL_END
