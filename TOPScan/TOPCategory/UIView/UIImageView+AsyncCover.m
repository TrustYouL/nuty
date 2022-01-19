#import "UIImageView+AsyncCover.h"
#import <objc/runtime.h>

const char *str = "imageIdKey";

@implementation UIImageView (AsyncCover)

- (void)setImageId:(NSString *)imageId {
    objc_setAssociatedObject(self, str, imageId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)imageId {
    NSString *imgId = objc_getAssociatedObject(self, str);
    return imgId;
}

- (void)setCoverImageWithPath:(NSString *)path coverPath:(NSString *)coverPath {
    self.imageId = path;
    self.image = nil;
    if (![TOPWHCFileManager top_isExistsAtPath:coverPath]) {
        [TOPDataModelHandler top_getCoverImage:path atPath:coverPath complete:^(NSString * _Nonnull imgPath) {
            UIImage *coverImage = [UIImage imageWithContentsOfFile:coverPath];
            if (!coverImage) {
                coverImage = [UIImage imageWithContentsOfFile:path];
            }
            if ([self.imageId isEqualToString:imgPath]) {
                self.image = coverImage;
            }
        }];
    } else {
        self.image = [UIImage imageWithContentsOfFile:coverPath];
    }
}

- (void)top_createCoverImage:(NSString *)path atPath:(NSString *)coverPath complete:(void (^)(UIImage * _Nonnull))complete {
    self.imageId = path;
    self.image = nil;
    if (![TOPWHCFileManager top_isExistsAtPath:coverPath]) {
        [TOPDataModelHandler top_getCoverImage:path atPath:coverPath complete:^(NSString * _Nonnull imgPath) {
            UIImage *coverImage = [UIImage imageWithContentsOfFile:coverPath];
            if (!coverImage) {
                coverImage = [UIImage imageWithContentsOfFile:path];
            }
            if ([self.imageId isEqualToString:imgPath]) {
                if (complete) {
                    complete(coverImage);
                }
            }
        }];
    } else {
        if (complete) {
            UIImage *coverImage = [UIImage imageWithContentsOfFile:coverPath];
            complete(coverImage);
        }
    }
}
@end
