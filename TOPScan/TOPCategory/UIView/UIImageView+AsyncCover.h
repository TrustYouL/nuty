#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (AsyncCover)
@property (nonatomic,copy) NSString *imageId;
- (void)setCoverImageWithPath:(NSString *)path coverPath:(NSString *)coverPath;
- (void)top_createCoverImage:(NSString *)path atPath:(NSString *)coverPath complete:(nonnull void (^)(UIImage * img))complete;
@end

NS_ASSUME_NONNULL_END
