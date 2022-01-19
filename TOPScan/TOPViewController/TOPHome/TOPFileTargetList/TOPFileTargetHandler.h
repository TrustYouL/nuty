#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFileTargetHandler : NSObject
@property (assign, nonatomic) TOPFileHandleType fileHandleType;
@property (copy, nonatomic) NSString *currentFilePath;
- (NSArray *)top_getFileArrayWithType:(TOPFileTargetType)type;
@end

NS_ASSUME_NONNULL_END
