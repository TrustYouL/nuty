#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTagsModel : NSObject
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, assign) BOOL  isFile;
@property (nonatomic, assign) BOOL  selectStatus;
@end

NS_ASSUME_NONNULL_END
